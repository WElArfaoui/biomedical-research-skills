# Skills catalog

Each skill below is invoked with its slash command and reads the corresponding `SKILL.md` into Claude Code's context.

## Clinical and scientific writing

### `/clinical` — clinical-paper-writing
Drafting and reviewing clinical/biomedical manuscripts. Selects the right reporting guideline (TRIPOD+AI for prediction models, CLAIM for medical AI, STARD for diagnostic accuracy, STROBE for observational, CONSORT-AI for trials). Walks IMRaD section by section with anti-patterns and verification gates.

**Example**:
```
/clinical I'm drafting a paper on automated lung nodule detection,
retrospective single-center, n=620 patients, primary metric is sensitivity at 1 FP/scan
```

### `/imaging` — medical-imaging-methods
The Methods section for CT/MRI/PET/X-ray/US studies. Covers acquisition reporting, preprocessing, segmentation methodology, radiomic feature extraction (with IBSI compliance), DL training protocols, validation strategy (patient-level splits enforced), and metric selection (Dice, HD95, AUC, c-index, calibration).

### `/stats` — clinical-statistics-reporting
Statistical analysis subsection for clinical papers. Covers descriptive statistics, hypothesis testing, logistic regression, Cox PH, **competing risks (Fine-Gray vs cause-specific Cox)**, diagnostic accuracy, prediction model evaluation (discrimination + calibration + decision curve analysis), bootstrap CIs, and missing-data handling.

### `/cover` — cover-letter-medical
One-page cover letters for medical journal submission. Scope match calibration, novelty claim aligned to evidence level, journal-specific conventions.

### `/reviewers` — response-to-reviewers
Point-by-point rebuttals to peer reviewers. Templates for "we agree", "we disagree but politely", "out of scope", and "misunderstanding/clarification". Tone calibration that protects relationships while maintaining your position.

## Funding applications

### `/grant-es` — grant-writing-spanish
Spanish fellowship and grant applications: PFIS (ISCIII), Joan Oró (AGAUR), FPI (AEI), FPU (MIU), Sara Borrell, Río Hortega. Section-by-section guidance, anglicism avoidance, scoring criteria alignment, ethics/gender/open science checkpoints.

### `/grant-eu` — grant-writing-eu
European funding applications: MSCA-PF, Horizon Europe RIA/IA, ERC. Covers the Excellence/Impact/Implementation triad, gender dimension, FAIR/open-science DMP, CDE plan with KPIs, mobility rules for MSCA.

## Senior scientific software engineering

### `/sci-review` — senior-scientific-code-review
Code review specific to scientific code. Detects data leakage (patient-level split violations), numerical instability, reproducibility gaps, statistical errors (KM with competing risks, threshold chosen on test), and domain-specific anti-patterns in medical imaging (DICOM orientation, mask interpolation) and ML/DL (eval mode, BN behavior).

### `/craft` — scientific-code-craft
Writing idiomatic Python scientific code at senior engineer level. Covers project structure (src/ layout), pyproject.toml, type hints (numpy typing), error handling, logging, dataclasses for value objects, defensive programming for scientific data (shape validation, unit-aware naming).

### `/sci-docs` — scientific-documentation
Documentation for scientific software. NumPy-style docstrings (the de-facto standard), MkDocs Material setup with mkdocstrings, ADRs for non-obvious methodology decisions, CITATION.cff for citability, JOSS submission readiness, tutorial notebooks tested in CI.

### `/mature` — research-code-maturation
Roadmap to mature research code through six stages: scratch notebook → cleaned notebook → script → module with tests → installable package → publishable library. Concrete acceptance criteria per stage and pitfalls to avoid.

### `/sci-debug` — scientific-debugging
Debugging specific to scientific pipelines. CUDA out-of-memory diagnostic ladder, NaN/Inf propagation, reproducibility failures (seeds, cuDNN nondeterminism, worker init), SLURM job failures, multiprocessing/GIL/dataloader issues, segfaults in C extensions (pydicom, SimpleITK), hypothesis-driven debugging for "wrong but plausible" results.

## Specialized domains

### `/wearable` — embedded-medical-wearable
Architecture and component selection for a medical wearable device. MCU comparison (nRF52840 vs ESP32-S3 vs RP2040), medical sensors with regulatory classification (MAX30003 ECG, MAX30205 temp, BMI270 IMU), BLE 5.x GATT design, power management for 5-7 day battery life, IEC 60601 / IEC 62304 / ISO 13485 / MDR pathway.

### `/oss-contrib` — oss-contribution
Strategy for contributing to external open source projects. Picking tractable issues (good-first-issue criteria), reading unfamiliar codebases efficiently, communicating with maintainers, anatomy of mergeable PRs (tests, docs, conventional commits, DCO), code review etiquette as contributor.

### `/oss-setup` — oss-project-setup
Setting up your own open source project. License selection (Apache 2.0 vs MIT vs GPL), required files (README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CITATION.cff), GitHub Actions CI/CD, semantic versioning, release-please automation, Zenodo DOI for citability, JOSS submission path.

### `/pipelines` — bioinformatics-pipelines
Reproducible bioinformatics and ML pipelines. Workflow manager selection (Snakemake vs Nextflow), containerization (Docker → Singularity for HPC), conda/uv lock files, data versioning with DVC, experiment tracking with MLflow (self-hosted for PHI), FAIR-by-design principles, nf-core as a model.

## Conventions

### Output language
All skill bodies are in English, but they produce output in the language the user requests. By default:
- Clinical writing and scientific engineering skills: output in academic English.
- `/grant-es`: output in formal academic Spanish.
- `/reviewers`: output in English with diplomatic-firm tone.
- Other skills: output in whatever language the user writes in.

### Versioning
Each skill has its own version in its frontmatter. The pack as a whole follows semantic versioning at the repo level. Pre-1.0 means slash command names and frontmatter schema may change between minor versions.

### Composition
Skills can be invoked in sequence within a single Claude Code session. For example:

```
/clinical draft the abstract for my lung nodule paper
/stats now review the statistical analysis subsection
/sci-review check the analysis code in src/pipeline.py
/oss-setup prepare the repo for Zenodo deposit and JOSS submission
```

Each invocation refreshes context with the relevant SKILL.md.
