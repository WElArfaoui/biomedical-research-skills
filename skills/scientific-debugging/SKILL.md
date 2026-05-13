---
name: scientific-debugging
description: Senior-level debugging specifically for scientific code failure modes. Covers CUDA out-of-memory errors, numerical instability (NaN/Inf propagation), reproducibility failures, multiprocessing/GIL issues, segmentation faults in C extensions (pydicom, SimpleITK, ITK), race conditions in dataloaders, silent correctness bugs, HPC/SLURM job failures, and the methodology of debugging "wrong but plausible" results. Use when a pipeline fails, gives unexpected results, or differs from a previous run.
version: 0.1.0
---

# Scientific Debugging

## When to use
- Pipeline crashes (CUDA OOM, segfault, kernel died).
- Results differ from a previous run on the "same" data.
- Numbers look wrong but the code "runs fine".
- A test passes locally but fails on HPC (or vice versa).
- Multi-GPU/distributed training is slower than expected.
- A DICOM/NIfTI loader silently produces wrong-orientation outputs.

## Philosophy

Scientific bugs fall into three categories, listed by difficulty:

1. **Loud crashes** (segfault, OOM, exception): code stops. These are easiest because the failure is visible.
2. **Performance issues** (slow, hangs): code runs but is suboptimal. Medium difficulty.
3. **Silent correctness bugs** (wrong number, wrong orientation, data leakage): code runs, returns plausible output, ships to publication. **Hardest and most damaging.**

The right debug method depends on the category. Brute-force `print()` works for #1; for #3 you need a controlled experiment.

## Process

### Phase 1 — Diagnose the bug category

Ask:
- Did the program crash? → Category 1.
- Did the program run but slowly/hang? → Category 2.
- Did the program produce output that is wrong (or suspicious)? → Category 3.

For each, the methodology differs. Don't jump to `print()` until you know which category.

### Phase 2 — Category 1: Crashes

#### CUDA Out-of-Memory

Symptoms:
- `RuntimeError: CUDA out of memory. Tried to allocate X GiB...`
- Often mid-epoch, after some successful steps.

Diagnostic ladder (run in order until you find the culprit):

1. **Confirm the actual usage**:
   ```python
   import torch
   print(torch.cuda.memory_summary())
   ```

2. **Are you accumulating gradients silently?**
   ```python
   # BAD: list of tensors grows, each holding the graph
   losses = []
   for batch in dataloader:
       loss = compute_loss(batch)
       losses.append(loss)  # graph retained!

   # GOOD: detach or .item()
   losses.append(loss.item())
   ```

3. **Are you keeping the computation graph longer than needed?**
   ```python
   # During validation
   with torch.no_grad():  # ESSENTIAL
       output = model(input)
   ```

4. **Batch too large?** Try `batch_size=1`. If OOM persists, the model itself doesn't fit.

5. **Activations too large?**
   - Mixed precision: `torch.cuda.amp.autocast` halves memory.
   - Gradient checkpointing: `torch.utils.checkpoint.checkpoint`.
   - Smaller patch size for 3D nnU-Net / medical imaging.

6. **Multiple processes on same GPU?** Check `nvidia-smi`. Another job may be using memory.

7. **Memory fragmentation**:
   ```python
   torch.cuda.empty_cache()  # last resort; doesn't help if real usage is the issue
   ```

8. **PyTorch's memory caching**:
   ```bash
   PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128 python train.py
   ```

For medical imaging 3D models specifically:
- Patch size dominates memory (cubic scaling).
- nnU-Net's auto-detection of patch size is usually optimal; don't override unless you know.
- DataLoader `pin_memory=True` is faster but uses host RAM.

#### Segfaults in C extensions

Symptoms:
- `Segmentation fault (core dumped)` with no Python traceback.
- Crash inside `pydicom`, `SimpleITK`, `ITK`, `OpenCV`, or `nibabel`.

Strategy:

1. **Get a traceback**: install `faulthandler`:
   ```python
   import faulthandler
   faulthandler.enable()
   ```
   This prints C-level traceback on crash.

2. **Run under valgrind** (memory bug) or **gdb** (segfault source) if needed:
   ```bash
   gdb --args python script.py
   (gdb) run
   (gdb) bt   # backtrace after crash
   ```

3. **Common culprits in medical imaging**:
   - Corrupted DICOM file (zero-byte pixel data, invalid VR).
   - Mismatched ITK ↔ SimpleITK versions.
   - Conflicting OpenCV builds (system OpenCV vs pip-installed).
   - Old NumPy / new C extension ABI mismatch.

4. **Isolate by bisection**:
   - Process files one-by-one with logging to find the culprit file.
   - In a Python loop, log filename before processing; the last logged file is the suspect.

#### "Killed" (no traceback)

Often **Linux OOM killer**. Check:
```bash
dmesg | tail
journalctl -k --since "1 hour ago" | grep -i oom
```

If confirmed: not Python's fault, you ran out of RAM. Reduce batch size, dataloader workers, or processes.

#### Container crashes (Docker/Singularity)

- Check `docker logs <container>`.
- For Singularity: stderr to file with `singularity exec ... 2>err.log`.
- For SLURM: check `slurm-<jobid>.out` and `slurm-<jobid>.err`.

### Phase 3 — Category 2: Performance / hangs

#### "Training is slow"

Diagnostic ladder:

1. **Where's the bottleneck?**
   - Profile: `torch.profiler` or `nvprof` or `nsys`.
   - Quick check: `nvidia-smi` during training. If GPU utilization is <80%, it's data loading.

2. **Data loading bottleneck (most common)**:
   - Increase `num_workers` in DataLoader (start with `os.cpu_count() // 2`).
   - `pin_memory=True`.
   - `persistent_workers=True` (avoids re-spawning workers each epoch).
   - Prefetch: `prefetch_factor=2` or higher.
   - If still slow: cache preprocessed tensors to disk; load tensors not raw images.

3. **DICOM loading specifically**:
   - `pydicom` is slow. For high-throughput training, preconvert to NIfTI/HDF5/Zarr.
   - For Zarr/HDF5: SSD vastly outperforms HDD.

4. **CPU-side preprocessing**:
   - MONAI's `CacheDataset` / `PersistentDataset` for repeated transforms.
   - Move what you can to GPU (e.g., normalization).

5. **Distributed slowness**:
   - Check NCCL backend setup: `NCCL_DEBUG=INFO`.
   - Bandwidth between GPUs: P2P or NVLink available?
   - Gradient sync frequency: too frequent kills throughput.

#### Hangs

- **Hanging DataLoader on multi-GPU**: stuck at process barrier. Verify all processes started, none crashed silently.
- **Hanging at start**: usually `torch.distributed.init_process_group` waiting for all ranks.
- **Hanging mid-epoch**: deadlock in custom collate, or worker crashed silently.
- **Diagnostic**: `py-spy dump --pid <PID>` shows the stack of a running Python process without modifying it.

### Phase 4 — Category 3: Silent correctness

This is where senior-level debugging matters most. **A wrong number that looks right is the most dangerous bug in scientific code.**

#### Methodology: hypothesis-driven debugging

Don't randomly add prints. Form a hypothesis, design an experiment to falsify it.

**Step 1 — Spot the suspicious result**:
- "AUC went from 0.78 to 0.92 with one preprocessing change" → too good to be true.
- "Dice on lung is 0.99" → check for data leakage.
- "Results not reproducible across runs" → seed issue.

**Step 2 — Form hypotheses (multiple)**:
- H1: Data leakage (test data leaked into training).
- H2: Wrong evaluation metric (e.g., computed on training set by accident).
- H3: Different preprocessing applied to test vs train.
- H4: Random seed not actually set.

**Step 3 — Design experiments**:

For H1:
```python
# Verify no patient overlap
train_pids = set(extract_pids(train_loader))
test_pids = set(extract_pids(test_loader))
overlap = train_pids & test_pids
assert not overlap, f"Patient overlap: {overlap}"
```

For H2:
```python
# Verify metric is computed on the right set
print(f"Evaluating {len(test_loader.dataset)} samples")
# Are these all test? Check the split logic explicitly.
```

For H3:
```python
# Pull one item from each loader, compare preprocessing
train_sample = next(iter(train_loader))[0][0]
test_sample = next(iter(test_loader))[0][0]
print(f"Train: mean={train_sample.mean()}, std={train_sample.std()}")
print(f"Test:  mean={test_sample.mean()}, std={test_sample.std()}")
# If different scales, preprocessing differs.
```

For H4 (reproducibility):
```python
# Set ALL seeds
import os, random, numpy as np, torch
seed = 42
os.environ["PYTHONHASHSEED"] = str(seed)
random.seed(seed)
np.random.seed(seed)
torch.manual_seed(seed)
torch.cuda.manual_seed_all(seed)
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False
torch.use_deterministic_algorithms(True)
```

Then run twice. If outputs differ, find the non-determinism source:
- cuDNN nondeterministic ops (some convolutions).
- DataLoader workers without seeded `worker_init_fn`.
- Some scikit-learn / scipy functions use `np.random.default_rng()` separately.

#### Common silent bugs in medical imaging

| Symptom | Likely cause | Diagnostic |
|---|---|---|
| Excellent metrics, fails on new data | Data leakage | Audit patient-level splits |
| Mask shifted relative to image | Coordinate frame mismatch | Visualize a slice; check spacing/origin/orientation |
| Mask resampled "smoothed" | Linear interp on mask | Change to nearest-neighbor |
| Inconsistent feature values rerunning PyRadiomics | Bin width chosen from data | Fix bin width, document |
| AUC differs between Python and R | Class encoding differs | Verify positive class encoding |
| Different results on CPU vs GPU | Non-determinism in some ops | Set deterministic flags |
| Loss explodes | NaN in input, missing normalization | `torch.isnan().any()` check |
| Metric improves but val loss increases | Overfitting; metric on wrong set | Verify metric computed on val set |
| Augmentation present in val | DataLoader misconfigured | Print transforms for each split |
| Different result on rerun "same seed" | Worker seeds not set | `worker_init_fn=lambda i: np.random.seed(seed + i)` |

#### Visual debugging for imaging
When debugging segmentation/registration/preprocessing:
- Save intermediate volumes to NIfTI: `nib.save(nib.Nifti1Image(arr, affine), "debug.nii.gz")`.
- View in **3D Slicer**, **ITK-SNAP**, or **freeview** (FreeSurfer).
- Compare side-by-side: input, expected, actual.
- Often the bug is visible immediately (e.g., wrong orientation, off-by-one cropping).

### Phase 5 — HPC/SLURM specifics

Diagnosing SLURM job failures:

1. **Read the log files**:
   ```bash
   ls slurm-*.out slurm-*.err
   ```

2. **Common SLURM failure modes**:
   - Walltime exceeded (`State: TIMEOUT`).
   - OOM (`OUT_OF_MEMORY` or "Killed" in log).
   - GPU not requested (`--gres=gpu:1` missing).
   - Modules not loaded inside the job (load in script before `python`).

3. **Resource queries**:
   ```bash
   sacct -j <jobid> --format=JobID,State,ExitCode,MaxRSS,Elapsed,ReqMem,AllocCPUS
   ```
   `MaxRSS` shows peak memory used (compare to requested).

4. **Interactive debugging**:
   ```bash
   srun --pty --gres=gpu:1 --mem=32G --time=01:00:00 bash
   # Now you're on a compute node with a GPU; debug directly
   ```

5. **Singularity-specific**:
   - `singularity exec --nv ...` for GPU access (`--nv` exposes NVIDIA libs).
   - Bind mounts: `--bind /scratch:/scratch` if data is on scratch.

### Phase 6 — Multi-process / dataloader issues

PyTorch DataLoaders use `multiprocessing`. Common issues:

#### `RuntimeError: dataloader workers exited unexpectedly`
- Worker crashed silently. Set `num_workers=0` to see the actual error.

#### CUDA contexts in workers
- DO NOT initialize CUDA in `__init__` of the Dataset; this breaks fork-based workers.
- Use `spawn` start method on macOS/Windows or when needed:
  ```python
  import torch.multiprocessing as mp
  mp.set_start_method("spawn", force=True)
  ```

#### Sharing CUDA tensors between processes
- Don't. Use shared memory CPU tensors and copy to GPU in the main process.

#### Open files exhausted
- DataLoaders open file handles; with many workers + many files, OS limit hit.
- `ulimit -n 65536` to raise the limit.
- Or use lmdb/HDF5/Zarr instead of one-file-per-sample.

### Phase 7 — Numerical stability

Symptoms: loss is NaN, weights become Inf, gradient overflow.

#### Detect NaN/Inf early
```python
def check_numerics(tensor: torch.Tensor, name: str) -> None:
    if torch.isnan(tensor).any():
        raise RuntimeError(f"NaN detected in {name}")
    if torch.isinf(tensor).any():
        raise RuntimeError(f"Inf detected in {name}")
```

Use `torch.autograd.set_detect_anomaly(True)` during debugging (slow, but pinpoints which op produced NaN).

#### Common sources
- Division by zero: `log(0)`, `1/x` for x=0.
- Sqrt of negative (from numerical noise): use `sqrt(x + eps)`.
- Softmax overflow: use `log_softmax` instead of `log(softmax(x))`.
- Mixed precision underflow: use `GradScaler` with autocast.
- Learning rate too high: classic. Lower it.

### Phase 8 — Producing a debugging report

When invoked, produce a structured analysis:

```
## Symptoms
[What's happening]

## Category
[Crash / Performance / Silent correctness]

## Hypotheses (priority order)
1. H1: [...] — likelihood, falsification experiment.
2. H2: [...]

## Recommended diagnostic steps
1. [Specific command or code to run]
2. ...

## Quick wins
[Things to try first, ordered by cost/benefit]

## If quick wins fail
[Next escalation steps]
```

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Adding `print()` everywhere randomly | No signal | Hypothesis-driven: predict what you'll see, compare |
| Changing multiple things at once | Can't tell what fixed it | One change at a time, observe |
| Believing "it works on my machine" | Hides reproducibility issues | Reproduce in clean env / Docker |
| `try/except` to "make it work" | Hides bugs | Find root cause; only catch what you can handle |
| Restarting kernel and re-running | Avoids the bug, doesn't fix it | Diagnose the underlying state issue |
| Assuming `torch.manual_seed` is enough | DataLoader workers + cuDNN have their own RNGs | Set ALL seeds; use `worker_init_fn` |
| Debugging in notebook | State leaks between cells | Reproduce in clean script |
| Ignoring warnings | Warnings often precede bugs | Treat warnings as errors during debug: `python -W error` |
| `time.sleep()` to "fix" race condition | Fragile | Actually synchronize with locks / events |
| Profiling for 5 seconds | Not representative | Profile a realistic workload |

## Verification gates

You've solved a bug when:

- [ ] You can explain in words **why** the bug happened.
- [ ] You can demonstrate it with a minimal reproducer.
- [ ] You've added a regression test that fails before the fix and passes after.
- [ ] You've documented the cause in a commit message or ADR.
- [ ] You've checked whether the same pattern exists elsewhere in the codebase.

## Output format when invoked

When invoked, ask:
1. What's the symptom (paste error/output)?
2. What were you doing when it happened?
3. What changed recently?

Then produce:
- Categorization of the bug.
- Hypotheses with falsification experiments.
- Diagnostic command sequence.
- Recommended fix once root cause is confirmed.
- Regression test suggestion.
