---
name: senior-scientific-code-review
description: Senior-level code review specifically for scientific/research code in bioinformatics, medical imaging, ML/DL pipelines, and statistical software. Covers correctness (numerical stability, data leakage, label leakage, reproducibility), maintainability (separation of concerns, testability), scientific validity (statistical correctness, methodological soundness), and the specific anti-patterns common in research code. Use when reviewing your own code before commit, reviewing a colleague's pull request, or auditing legacy research code before publication.
version: 0.1.0
---

# Senior Scientific Code Review

## When to use
- Reviewing your own code before committing to a research project.
- Reviewing a colleague's pull request in your-dicom-tool, your-imaging-tool, or similar.
- Auditing legacy notebook/script code before turning it into a publishable pipeline.
- Self-reviewing a paper's analysis code before submission.
- Reviewing student code if you supervise.

## Philosophy

Scientific code has different failure modes than SaaS code. A SaaS bug shows up as a 500 error or a wrong UI; a scientific bug shows up as a **wrong result that still looks plausible**. The reviewer's job is to catch the second kind. Cosmetic issues are secondary.

Reviewer hierarchy of concerns:

1. **Correctness** (does it compute what it claims?)
2. **Validity** (is the method statistically/scientifically sound?)
3. **Reproducibility** (will the same input give the same output, forever?)
4. **Maintainability** (can someone else extend this in 6 months?)
5. **Style** (linting, formatting — last priority, automate this)

## Process

### Phase 1 — Understand intent before reviewing line by line

Before opening the diff:
- Read the linked issue/paper section. **What is this code supposed to compute?**
- If no issue or unclear: stop. Ask the author "what's the scientific claim this code supports?"
- Identify the inputs (datasets, hyperparameters) and the claim (a number, a figure, a model).

If you can't articulate the scientific claim in one sentence, the code is not reviewable.

### Phase 2 — Correctness review checklist

#### Data handling
- [ ] **Train/val/test split is patient-level**, not image-level, slice-level, or random-row-level (CRITICAL in medical imaging).
- [ ] Split happens BEFORE any preprocessing that uses statistics (normalization, feature selection, imputation).
- [ ] If multiple patients have multiple timepoints/scans, longitudinal structure preserved.
- [ ] No future information leaks into past predictions (especially time series, survival).
- [ ] Outcome variable is never in the feature set, even disguised.
- [ ] Random seeds set BEFORE the split, not after.
- [ ] Missing data handled coherently and documented.

#### Numerical correctness
- [ ] Float comparisons use tolerance, not `==`.
- [ ] Division by zero handled (or impossible by construction; document why).
- [ ] Log/sqrt operations have domain checks or clipping (e.g., `np.log(p + 1e-8)`).
- [ ] Off-by-one errors in indexing (especially with slice arithmetic on volumes).
- [ ] Dimension ordering verified: numpy [Z,Y,X] vs SimpleITK [X,Y,Z] vs DICOM is a frequent bug source.
- [ ] Spacing/origin/orientation preserved through transformations.
- [ ] Resampling uses correct interpolator (linear for images, nearest for masks, NEVER linear for masks).
- [ ] Coordinate frame transformations explicit (world vs voxel space).

#### Statistical correctness
- [ ] Confidence intervals reported, not just point estimates.
- [ ] Bootstrap uses correct resampling unit (patient, not row).
- [ ] Multiple comparisons addressed if running many tests.
- [ ] PH assumption verified for Cox models.
- [ ] Kaplan-Meier NOT used when competing risks exist.
- [ ] DeLong for paired AUC comparisons (not unpaired test on paired data).
- [ ] Calibration assessed alongside discrimination.

#### Model correctness
- [ ] Threshold for binary classification chosen on training/val, never on test.
- [ ] Hyperparameter selection done with proper nested CV or held-out validation, NOT on test.
- [ ] Class imbalance handled coherently (weighted sampling, weighted loss, or stratification).
- [ ] Augmentation applied only to training data, not validation/test.
- [ ] Test-time augmentation, if used, documented.
- [ ] Pre-trained weights cited; transfer learning protocol explicit.

### Phase 3 — Reproducibility review

- [ ] Random seeds set for: Python `random`, NumPy, PyTorch, CUDA, dataloader workers.
- [ ] PyTorch deterministic mode set if needed (`torch.use_deterministic_algorithms(True)`).
- [ ] Dependencies pinned (`requirements.txt` from `pip-compile` or `uv.lock`).
- [ ] Software versions logged (PyTorch + CUDA + driver).
- [ ] Hardware logged (GPU model, count, RAM).
- [ ] Data version logged (DVC hash, dataset DOI, or path with timestamp).
- [ ] Git commit hash logged with output (e.g., MLflow tag).
- [ ] No hardcoded `/home/user/...` paths; config-driven.
- [ ] Random sampling order doesn't depend on dict iteration (Python 3.7+ is ordered, but older code may surprise).

### Phase 4 — Maintainability review

#### Structure
- [ ] One responsibility per function. If a function has "and" in its name, split it.
- [ ] Pure functions where possible (input → output, no side effects).
- [ ] Side effects (file I/O, logging, network) localized to specific layers.
- [ ] Configuration separated from logic (YAML/TOML/dataclass, not magic constants in code).
- [ ] Long Jupyter cells refactored into named functions or modules.
- [ ] No god-classes (>500 lines or >10 methods is suspicious).

#### Naming
- [ ] Variable names descriptive: `lung_mask_voxels` not `m`, `patient_ids` not `pids`.
- [ ] Avoid Hungarian/notation prefixes; use type hints instead.
- [ ] Booleans named as questions: `is_trained`, `has_label`, not `flag`.
- [ ] Constants in `UPPER_CASE`.
- [ ] No abbreviations except universally understood (CT, MRI, AUC).

#### Testability
- [ ] Functions can be tested without GPU when possible (dependency injection).
- [ ] No `import side-effect` (modules that download data on import — never).
- [ ] Test fixtures exist for tricky cases (empty mask, single voxel, all-zeros input).

#### Error handling
- [ ] Errors fail loud, not silent. Avoid bare `except:`.
- [ ] Use specific exceptions: `ValueError`, `FileNotFoundError`, custom domain errors.
- [ ] Validate inputs at function boundaries; fail early.
- [ ] Don't catch what you can't handle.

### Phase 5 — Domain-specific patterns to flag

#### Medical imaging
| Anti-pattern | Fix |
|---|---|
| Loading DICOM with `pydicom.dcmread()` and using `.PixelData` directly | Use `.pixel_array` and apply `RescaleSlope`/`RescaleIntercept` for HU |
| Assuming all scans are axial | Check `ImageOrientationPatient`; orient consistently |
| Computing radiomic features without resampling | Resample to isotropic before texture features |
| Resampling mask with linear interpolation | Always nearest-neighbor for labels |
| Saving NIfTI without setting affine | Output is unusable in any viewer |
| Using `np.fliplr` on a 3D volume thinking it's L-R | DICOM/NIfTI orientation rules; verify with a viewer |
| ROI cropped tightly without padding | DL models need context; pad before crop |

#### ML/DL
| Anti-pattern | Fix |
|---|---|
| `model.train()` left on during validation | Always `model.eval()` + `torch.no_grad()` |
| Batch norm in eval mode without enough warmup batches | Track running stats; or use GroupNorm |
| Computing loss on softmax output then taking softmax in metric | Pick logits vs probabilities consistently |
| Saving "best" model based on training loss | Track validation metric |
| `lr_scheduler.step()` called per batch when scheduler expects per epoch | Check scheduler docs |
| Loading checkpoint without strict=True or version check | Silent partial loads, accuracy drops mysteriously |
| Mixed precision (`autocast`) wrapping loss but not metrics | Inconsistent dtypes downstream |

#### Pandas / NumPy
| Anti-pattern | Fix |
|---|---|
| Chained assignment `df[col1][col2] = value` | Use `.loc[col2, col1]` |
| Iterating rows with `df.iterrows()` for compute | Vectorize or `df.apply` (still slow) or move to numpy |
| `==` comparison on floats | `np.isclose(a, b)` or `math.isclose` |
| Modifying a slice without `.copy()` | Either explicit copy or use `.loc` |
| `df.append()` in loop (deprecated, O(n²)) | Build list of dicts, then `pd.DataFrame(list)` once |

#### SLURM/HPC
| Anti-pattern | Fix |
|---|---|
| Hardcoded paths to `/home/user/...` | Use `$SLURM_SUBMIT_DIR` or config |
| No checkpointing in long jobs | Save every N epochs; resume on requeue |
| One job with 1000 parallel tasks via Python multiprocessing | Use `--array=0-999` SLURM job array |
| GPU job without `--gres=gpu:1` | Job lands on CPU node, fails |
| Modules loaded inside Python script | Load in submit script before launching |

### Phase 6 — Review etiquette (when reviewing others)

#### Tone
- Comment on the code, not the person. "This function..." not "you should have..."
- For each criticism, suggest a concrete alternative.
- Distinguish blocking issues from suggestions: use prefixes like `[BLOCKING]`, `[SUGGESTION]`, `[NIT]`, `[QUESTION]`.
- Praise correct decisions when they're non-obvious. Reinforces good patterns.

#### Granularity
- Don't pile 50 nits onto a small PR. Pick the top 5 most important.
- For large PRs (>500 lines), ask for it to be split before reviewing.
- For drive-by reviews on a project you don't maintain, focus on correctness only.

#### Approval criteria
A PR is approvable when:
1. Correctness verified by tests AND by your reading.
2. Maintenance burden acceptable.
3. No worse than the baseline it's replacing.
4. Reviewer disagreements resolved or explicitly deferred.

### Phase 7 — Producing the review output

When invoked as a slash command, produce review in this structure:

```
## Summary
[One paragraph: what the code does, your overall verdict]

## Blocking issues
1. [File:line] [Issue + why it blocks + suggested fix]
...

## Suggestions
1. [File:line] [Suggestion + rationale]
...

## Questions
1. [Question for the author]
...

## Nits
[Style/formatting issues, brief]

## Verdict
- [ ] Approve
- [ ] Request changes
- [ ] Comment only
```

## Anti-patterns specific to research code

| Pattern | Why it fails | Correction |
|---|---|---|
| `# TODO: fix later` left in published code | Never fixed, becomes legacy | Either fix or open issue and link |
| Commented-out code blocks "in case we need them" | Bit-rot, confuses readers | Delete; git has history |
| Magic numbers in code (`threshold = 0.42`) | No traceability | Named constant + comment with provenance |
| One huge Jupyter cell that's actually the analysis | Unreviewable, fragile | Refactor into module + thin notebook |
| Notebook outputs committed | Repo bloat, merge conflicts | `nbstripout` or Jupytext + don't commit `.ipynb` outputs |
| `from foo import *` | Namespace pollution | Explicit imports |
| `global` variables in research scripts | Untraceable state | Pass through function args or use a class |
| Inconsistent function signatures across the codebase | Mental load | Standardize patterns (e.g., always `(X, y, **kwargs)`) |
| Mixing OOP and functional inconsistently | Confusing | Pick one style per module |

## Output format when invoked

When invoked, ask:
1. What's the code? (paste or file path)
2. What does it compute? (one sentence)
3. Is this for: own commit, PR review, or audit?

Then produce a structured review per Phase 7.
