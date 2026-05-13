---
name: bioinformatics-pipelines
description: Design and implementation of reproducible bioinformatics and ML pipelines using workflow managers (Snakemake, Nextflow), containers (Singularity/Apptainer, Docker), conda environments with lock files, data versioning (DVC), experiment tracking (MLflow, Weights & Biases), and FAIR-by-design principles. Covers when to choose each tool, HPC integration, and nf-core as a model of best practices. Use when designing a new pipeline, refactoring existing ad-hoc scripts into a reproducible workflow, or documenting an analysis for publication.
version: 0.1.0
---

# Bioinformatics Pipelines — Reproducibility-First

## When to use
- Designing a new analysis pipeline (radiomics, sequence analysis, multi-step ML training).
- Refactoring ad-hoc bash/Python scripts into a maintainable workflow.
- Preparing a pipeline for publication (Zenodo deposit, JOSS, Nature Methods).
- Documenting reproducibility for grant applications or thesis chapters.
- Moving from local prototype to HPC/SLURM production.

## Process

### Phase 1 — Choose the right workflow manager

| Tool | When to choose | Strengths | Weaknesses |
|---|---|---|---|
| **Bash scripts** | Single-machine, <5 steps, one-off analysis | Zero learning curve | No DAG resolution, no resume on failure, no parallelism management |
| **Make / Just** | Simple file-based dependencies | Native to Unix, available everywhere | No HPC integration, no cluster awareness |
| **Snakemake** | Python ecosystem, single-investigator pipelines, medium complexity (5-50 steps) | Python-native, excellent SLURM support, large community in bioinformatics | DAG explicitness can be verbose |
| **Nextflow** | Multi-investigator pipelines, cross-institutional, container-first | Process isolation, hybrid cloud/HPC, strong community (nf-core) | DSL2 has learning curve; Groovy-flavored |
| **WDL (Cromwell, miniwdl)** | Cloud-first (Terra, DNAnexus, AnVIL), big data | Strong typing, scalable | Heavier infrastructure |
| **CWL** | Maximum portability, very large multi-org projects | Standardized | Verbose YAML, less ergonomic |
| **Luigi / Airflow / Prefect / Dagster** | Production data engineering, scheduled pipelines | DAG visualization, scheduling | Overkill for one-off analyses |

**Recommendation for your stack**:
- Use **Snakemake** as default for medical imaging / radiomics pipelines (Python-heavy, a biomedical research institute-internal, SLURM).
- Use **Nextflow** when you want to follow nf-core patterns (e.g., genomics pipelines, sharing across institutions, publication-grade).
- Skip Airflow/Dagster — these are for data engineering, not research analysis.

### Phase 2 — Containerization strategy

| Layer | Tool | When |
|---|---|---|
| Build & test locally | **Docker** | Local development, CI/CD |
| Run on HPC | **Singularity / Apptainer** | Required by most HPCs (no root daemon) |
| Run on workstation | **Docker** or **Podman** | Local |
| Multi-arch | **Docker buildx** | If supporting ARM (M1/M2 Macs) |

**Pattern**: build with Docker, convert to Singularity for HPC.

```bash
# Build
docker build -t myproject:1.0 .

# Convert to Singularity for HPC
singularity build myproject_1.0.sif docker-daemon://myproject:1.0
# Or pull directly from a registry
singularity pull docker://myproject:1.0
```

Pin everything in the Dockerfile:
```dockerfile
FROM python:3.12.5-slim@sha256:abc123...  # SHA-pinned, not just :3.12
RUN pip install --no-cache-dir \
    pyradiomics==3.1.0 \
    SimpleITK==2.4.0 \
    numpy==2.0.1
```

### Phase 3 — Environment management

#### Pin everything, lock everything
- **Conda**: use `conda-lock` to generate platform-specific lock files. Commit them.
- **Pip**: use `pip-tools` (`pip-compile`) or **uv** (faster, modern). Commit lock files.
- **Poetry**: ecosystem-locked alternative; auto-generates lockfiles.

Example with uv (recommended modern stack):
```bash
uv init my-pipeline
uv add pyradiomics SimpleITK numpy
uv lock  # produces uv.lock
```

Commit `uv.lock`. Reinstall reproducibly with `uv sync`.

#### Don't commit `requirements.txt` from `pip freeze`
- It captures your local environment including OS-specific stuff.
- Use `pip-compile` or `uv lock` instead, which separate "direct dependencies" from "transitive".

### Phase 4 — Data versioning with DVC

For data-heavy ML pipelines, code in git ≠ data in git. Use DVC:

```bash
# Setup
pip install dvc[s3]  # or [gs], [azure], [ssh] for HPC
dvc init
git add .dvc/ .dvcignore
git commit -m "Initialize DVC"

# Add a dataset
dvc add data/raw/ielcap_cohort/
git add data/raw/ielcap_cohort.dvc .gitignore
git commit -m "Track ielcap cohort with DVC"

# Configure remote storage (HPC scratch, S3, MinIO)
dvc remote add -d ielcap-storage ssh://user@hpc.example.com/scratch/dvc-store
dvc push
```

Now:
- Git tracks `.dvc` files (lightweight pointers).
- DVC manages the actual data files.
- Any collaborator: `git clone && dvc pull` and they have your exact dataset.

For pipeline-level versioning:
```bash
# Define pipeline stages
dvc stage add -n preprocess \
    -d src/preprocess.py -d data/raw/ \
    -o data/preprocessed/ \
    python src/preprocess.py

dvc stage add -n extract_features \
    -d src/extract.py -d data/preprocessed/ \
    -o data/features.parquet \
    python src/extract.py

dvc repro  # runs everything from the start, skips unchanged stages
```

### Phase 5 — Experiment tracking

For ML training runs, use one of:

| Tool | Strengths | When |
|---|---|---|
| **MLflow** | Open source, self-hostable, integrates with everything | Self-hosted or local |
| **Weights & Biases** | Best UX, collaboration features | Cloud (free for academic); sensitive data needs careful handling |
| **TensorBoard** | Comes with PyTorch/TF, no setup | Basic logging only |
| **Aim** | Open source, modern UX | Lightweight alternative |
| **ClearML** | Full pipeline + experiment platform | Self-hosted, heavier |

**For your projects with PHI/clinical data**: self-hosted **MLflow** is the right answer. Avoid sending clinical data or feature vectors to cloud-only services unless you have a DPA in place.

MLflow setup pattern:
```python
import mlflow

mlflow.set_tracking_uri("http://hpc-mlflow.irblleida.cat:5000")
mlflow.set_experiment("ct-lungscore-v0")

with mlflow.start_run():
    mlflow.log_params({"lr": 1e-4, "epochs": 100, "model": "DINOv2-3D"})
    # Train model
    mlflow.log_metrics({"val_cindex": 0.78, "val_brier": 0.18})
    mlflow.log_artifact("model_checkpoint.pt")
    mlflow.log_dict(config, "config.yaml")
```

### Phase 6 — Snakemake recipe for medical imaging

Typical structure for a radiomics study:

```
project/
├── Snakefile
├── config/
│   └── config.yaml
├── workflow/
│   ├── rules/
│   │   ├── preprocess.smk
│   │   ├── segment.smk
│   │   ├── features.smk
│   │   └── train.smk
│   ├── scripts/
│   │   ├── preprocess.py
│   │   ├── extract_features.py
│   │   └── train.py
│   └── envs/
│       ├── pyradiomics.yaml
│       └── monai.yaml
├── resources/
│   └── (input data, not in git, tracked by DVC)
├── results/
│   └── (outputs)
├── .gitignore
└── README.md
```

`Snakefile`:
```python
configfile: "config/config.yaml"

PATIENTS = config["patients"]

rule all:
    input:
        expand("results/features/{pid}.parquet", pid=PATIENTS),
        "results/model.pkl"

include: "workflow/rules/preprocess.smk"
include: "workflow/rules/segment.smk"
include: "workflow/rules/features.smk"
include: "workflow/rules/train.smk"
```

`workflow/rules/segment.smk`:
```python
rule segment_lungs:
    input:
        ct = "resources/dicom/{pid}/series/"
    output:
        mask = "results/masks/{pid}_lungs.nii.gz"
    container:
        "docker://totalsegmentator/totalsegmentator:2.4.0"
    resources:
        mem_mb = 16000,
        runtime = 30,  # minutes
        slurm_partition = "gpu",
        gres = "gpu:1"
    shell:
        "TotalSegmentator -i {input.ct} -o {output.mask} --task total"
```

Execute on SLURM:
```bash
snakemake --slurm --use-singularity --jobs 100 \
    --default-resources slurm_account=trrm slurm_partition=normal \
    --resources mem_mb=200000
```

### Phase 7 — nf-core as the model

Even if you use Snakemake, study nf-core (https://nf-co.re) for:
- Project structure conventions.
- Testing patterns (`test/` profile with small synthetic data).
- Documentation conventions (`docs/usage.md`, `docs/output.md`).
- Schema validation (`nextflow_schema.json`).
- Pre-commit hooks (`pre-commit run --all-files`).
- CI patterns (matrix testing across config profiles).

nf-core has been adopted by major consortia (ELIXIR, ENA, EBI). Even Snakemake users borrow heavily from its style.

### Phase 8 — FAIR-by-design

For research pipelines that will be published:

#### Findable
- DOI via Zenodo (link your GitHub repo).
- ORCID for authors.
- Rich metadata in `CITATION.cff`.
- Listed in registries: bio.tools, WorkflowHub, FAIRsharing.

#### Accessible
- Public GitHub repo, clear license.
- Pre-built container images on Docker Hub / Quay.io.
- Mirror to Software Heritage for archival.

#### Interoperable
- Use community standards: BIDS for neuroimaging, OME-TIFF/OME-Zarr for microscopy, DICOM for radiology, FHIR for clinical, GTF/BED/VCF for genomics.
- Document your I/O schemas.

#### Reusable
- Permissive license (Apache 2.0 / MIT).
- Tests with example data.
- Clear contributing guidelines.
- Versioned releases.

### Phase 9 — Reproducibility checklist

Before publishing a pipeline:

- [ ] All code in git, public.
- [ ] All dependencies pinned (lock files committed).
- [ ] Container image available (Docker Hub / GHCR), tagged with version.
- [ ] Test data included (small synthetic or public-domain).
- [ ] Continuous integration runs end-to-end on test data.
- [ ] Random seeds documented.
- [ ] Hardware requirements documented (GPU model used, RAM, runtime).
- [ ] `README` describes data inputs and outputs precisely.
- [ ] DOI assigned via Zenodo.
- [ ] Citation file (CITATION.cff).
- [ ] License clear.
- [ ] If using HPC: SLURM job script committed with comments.
- [ ] If using MLflow: tracking server accessible to reviewers (or logs exported).

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Ad-hoc bash scripts named `run_v3_final.sh` | Lost provenance, irreproducible | Workflow manager from day 1 |
| `pip install` without version pins | Breaks 3 months later | Lock file (uv.lock, conda-lock, requirements.txt from pip-compile) |
| Conda environment without lock file | Resolves differently each install | Use conda-lock or pixi |
| Data committed in git | Blows up repo, no access control | DVC, git-annex, or external storage with manifest |
| Container with `FROM ubuntu` (no tag) | Breaks on rebuild | SHA-pinned base images |
| MLflow runs without parameter logging | Can't reproduce results | Log ALL hyperparameters + git commit + dataset version |
| "Reproduction" instructions in README that don't work | Embarrassing on JOSS review | Test the README yourself in a fresh environment |
| Hand-edited Snakemake DAG by manually deleting outputs | DVC and Snakemake can both handle this | Let the tool resolve dependencies |
| Different scripts in `dev/` and `prod/` | Drift, irreproducibility | Same pipeline, different config profiles |

## Verification gates

Before declaring a pipeline "publication-ready":

- [ ] `git clone && <some-command>` works for a reviewer with zero context.
- [ ] CI green.
- [ ] Container image pulls and runs.
- [ ] At least one end-to-end run on test data in < 30 min.
- [ ] Outputs are deterministic (or seed-controlled) for the same input.
- [ ] DAG can be drawn and the diagram is in the docs.
- [ ] All file paths are config-driven (no hardcoded `/home/user/...`).
- [ ] License + citation + contribution docs present.

## Example use cases

### a lung cancer screening cohort radiomics
- Snakemake.
- Singularity containers for nnU-Net, TotalSegmentator, PyRadiomics.
- DVC for the 638-patient cohort + masks.
- MLflow for the LASSO + classifier sweeps.
- Final deposit: GitHub + Zenodo DOI.

### a CT-based prognostic model
- Snakemake or Nextflow (more complex multi-stage).
- MLflow for training runs across NLST, LIDC-IDRI, a lung cancer screening cohort, a longitudinal post-COVID cohort.
- W&B or MLflow for hyperparameter sweeps.
- Container per stage (segmentation, DINOv2 backbone, transformer, competing risks head).

### a longitudinal physiological signal model
- Snakemake for a multicenter sleep cohort preprocessing.
- HuggingFace Trainer wrapped in MLflow.
- Heavy data: DVC + HPC scratch as remote.

### your-dicom-tool
- Not a pipeline per se, but a tool. CI critical: matrix-test multiple DICOM datasets.
- pytest + small synthetic DICOMs (use `pydicom`'s test data or generate synthetic).

## Output format when invoked

When invoked, ask:
1. What's the analysis? (one paragraph)
2. Single machine, HPC, or cloud?
3. Estimated number of stages and runtime.
4. Data sensitivity (PHI / public).

Then produce:
- Recommended workflow manager + justification.
- Recommended container strategy.
- Recommended experiment tracker.
- Project structure tree.
- Skeleton Snakefile / nextflow.config.
- CI workflow skeleton.
- Reproducibility checklist tailored to the analysis.
