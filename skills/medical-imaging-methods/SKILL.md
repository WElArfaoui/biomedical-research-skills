---
name: medical-imaging-methods
description: Drafting and reviewing the Methods section of papers involving medical imaging, radiomics, or deep learning on imaging modalities (CT, MRI, X-ray, US, WSI). Covers acquisition reporting, preprocessing pipelines, segmentation methodology, feature extraction (PyRadiomics + IBSI), DL architectures (nnU-Net, TotalSegmentator), validation strategy, and metric selection (Dice, HD95, AUC, calibration, c-index). Use when writing or reviewing the Methods section of an imaging-based study.
version: 0.1.0
---

# Medical Imaging Methods

## When to use
- Writing the Methods section of a paper involving CT/MRI/X-ray/US/WSI.
- Reviewing such a section for compliance and reproducibility.
- Adapting a thesis chapter on a radiomics/DL imaging pipeline into manuscript form.
- Documenting a pipeline for internal protocols (CERT submission, study log).

This skill complements `clinical-paper-writing` — that one handles overall manuscript structure; this one handles the imaging-specific technical depth.

## Process

Methods for an imaging study should cover, IN THIS ORDER:

### 1. Imaging acquisition
Reviewers will reject methods that don't report:
- **Modality and scanner manufacturer/model(s)**: e.g., "Siemens SOMATOM Force, GE Revolution CT".
- **Acquisition parameters**: kVp, mAs (or CTDIvol), slice thickness, pixel spacing, reconstruction kernel (sharp vs soft tissue), iterative reconstruction strategy if used.
- **Contrast protocol** (if applicable): agent, dose, injection rate, timing of acquisition.
- **Multi-vendor heterogeneity**: if the cohort spans scanners, state this and how it was handled (harmonization or stratification).

For longitudinal data, also report:
- Number of timepoints per patient.
- Acquisition interval (median, IQR).

### 2. Preprocessing
Document EXACTLY:
- **Resampling**: target voxel spacing (e.g., 1×1×1 mm) and interpolation method (linear for image, nearest for mask).
- **Intensity normalization**: HU clipping range for CT (e.g., [-1024, 600] for lung), z-score / Nyul / WhiteStripe for MRI, why this choice.
- **Registration** (if multi-sequence or longitudinal): rigid/affine/deformable, software (ANTs, Elastix, SimpleITK).
- **Cropping/ROI definition**: how the bounding box was determined.
- **Anonymization**: tool used (e.g., dcm2niix + custom script, CTP, dcm-anonymizer), what tags were modified, whether PixelData was inspected for burned-in PHI.

### 3. Segmentation (if applicable)
Choose ONE primary path and justify:

| Approach | When to use | What to report |
|---|---|---|
| Manual by experts | Gold standard, small cohort | Number of annotators, training, blinding, inter-/intra-observer ICC or DSC |
| Semi-automatic | Pragmatic, need expert verification | Tool, default parameters, manual edit time, expert reviewer |
| Fully automated (nnU-Net, TotalSegmentator) | Large cohort, validated tool | Version, model checkpoint, manual quality review protocol, exclusion criteria for failed cases |

Always report:
- Reference/ground truth definition.
- Quality control: whether segmentations were reviewed, by whom, blinded to outcome.
- Exclusions due to segmentation failure (count and why).

### 4. Radiomic feature extraction (if applicable)
- **Software** + version: e.g., PyRadiomics v3.1.0, MITK, LIFEx.
- **IBSI compliance**: state explicitly whether features are IBSI-compliant. If using PyRadiomics, note that not all features are IBSI-validated by default.
- **Feature classes extracted**: shape, first-order, GLCM, GLRLM, GLSZM, NGTDM, GLDM. State filters applied (LoG with which sigmas, wavelet which decomposition).
- **Discretization**: bin width or bin count, justification.
- **Number of features extracted** (raw, before selection).
- **Test-retest reproducibility**: if available, ICC threshold for retention.
- **Harmonization**: ComBat for multi-scanner data, with what covariates protected.

### 5. Deep learning model (if applicable)
- **Architecture**: name + reference (nnU-Net, U-Net, ResNet-50, DINOv2, ViT). If custom, describe with a diagram.
- **Pretraining**: from scratch, ImageNet, RadImageNet, MedicalNet, self-supervised on internal data.
- **Input format**: 2D slices, 2.5D, 3D patches (size), full volume.
- **Training**:
  - Optimizer (Adam/AdamW/SGD), learning rate, schedule.
  - Loss function (cross-entropy, Dice, focal, compound).
  - Batch size.
  - Epochs / steps and stopping criterion (early stopping with patience N on val metric).
  - Augmentation: list specifically (rotation, flip, elastic, intensity, MixUp, etc.).
  - Class imbalance handling (weighted sampling, focal loss).
- **Hardware**: GPU model, count, framework + version (PyTorch 2.x), CUDA version. This is for reproducibility and runtime comparison.
- **Reproducibility**: random seeds set, deterministic flags, container hash if Singularity/Apptainer/Docker.

### 6. Validation strategy
The single most scrutinized part. Be explicit:
- **Split level**: patient-level. State how this was enforced (especially for longitudinal data where one patient has multiple scans).
- **Split ratios**: e.g., 70/15/15 or k-fold cross-validation (k=5).
- **Internal vs external**: if external, describe the external cohort separately with its own characteristics table.
- **Stratification**: outcome, sex, age group, scanner.
- **Lock**: state that the test set was held out and accessed only once for final reporting.

### 7. Metrics
Pick metrics matched to the task:

| Task | Primary | Secondary | Always report |
|---|---|---|---|
| Segmentation | Dice (DSC) | HD95, ASSD, sensitivity, specificity per voxel | Per-class breakdown if multi-class; volume per case |
| Detection | Sensitivity at FPs/scan, FROC | Free-response AUC | Per-lesion size stratification |
| Binary classification | AUC | F1, precision, recall, PR-AUC | Calibration (Brier, ICI), decision curve analysis (DCA) |
| Multi-class | Macro AUC | Per-class AUC, confusion matrix | Class support |
| Survival/time-to-event | C-index (Harrell or Uno) | Time-dependent AUC, IBS | Calibration (calibration plot per quantile), competing risks if relevant |
| Prognostic biomarker | Hazard ratio with CI | Kaplan-Meier with log-rank | Number at risk under curves |

For ALL metrics:
- 95% CI via bootstrap (state B = 1000 typically, percentile or BCa).
- Comparison to a meaningful baseline (radiologist, clinical score, prior model).

### 8. Statistical comparisons
- DeLong test for AUCs (independent), bootstrap for paired.
- McNemar for paired sensitivity/specificity at fixed threshold.
- Wilcoxon signed-rank for paired Dice.
- State whether multiple-comparison correction was applied (Bonferroni, Holm, FDR).

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| "Standard preprocessing was applied" | Not reproducible | List every step with parameters |
| Image-level split with patients having multiple scans | Test set leakage | Patient-level split, with code excerpt in supplementary |
| Reporting only Dice for segmentation | Misses boundary errors | Add HD95 and ASSD; report per-class; show failure cases |
| "Augmentation was used" without specifics | Reviewers will ask | Itemize: rotation ±10°, flip H, elastic with α=..., etc. |
| PyRadiomics features called "IBSI-compliant" without verification | Some PyRadiomics features are NOT IBSI-validated | Cite IBSI list, state which features were retained as compliant |
| AUC reported without CI | Single number is unfalsifiable | Bootstrap 95% CI mandatory |
| No calibration for prediction models | Discrimination ≠ calibration | Report Brier score, calibration plot, ICI |
| Multi-scanner cohort without harmonization | Confounded performance | Apply ComBat or report per-scanner stratified results |
| GPU model not reported | Can't reproduce timing or replicate | State GPU + framework + CUDA versions |

## Verification gates

Before declaring Methods done:

- [ ] Every parameter mentioned has a value (no placeholders).
- [ ] Software with versions (don't say "Python", say "Python 3.11").
- [ ] Patient-level split confirmed in code; flow diagram shows n at each stage.
- [ ] At least one metric with calibration assessment if it's a prediction task.
- [ ] Comparator stated for primary metric.
- [ ] Random seeds and reproducibility: documented.
- [ ] Code/data availability statement drafted (even if "available on request").
- [ ] If radiomics: IBSI compliance addressed.
- [ ] If multi-scanner: harmonization addressed.
- [ ] Quality control of segmentations described.

## Notes on common mistakes specific to your projects

- **a CT-based prognostic model (competing risks)**: state that competing risks were modeled with Fine-Gray or cause-specific Cox; report cumulative incidence functions, not Kaplan-Meier as if it were single-cause; calibration via cause-specific calibration plots.
- **a lung cancer screening cohort nodule project**: explicitly state Lung-RADS version used, and how borderline cases were handled.
- **a longitudinal post-COVID cohort longitudinal**: patient-level split must respect longitudinal structure; state which timepoint(s) are inputs and which are outputs.
- **an ICU follow-up cohort subset of PostUCI**: clearly state the relationship between cohorts to avoid reviewer confusion.
