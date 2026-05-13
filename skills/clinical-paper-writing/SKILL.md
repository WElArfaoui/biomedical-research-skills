---
name: clinical-paper-writing
description: Drafting and review of clinical/biomedical research manuscripts following IMRaD structure and applicable reporting guidelines (TRIPOD+AI for prediction models, CONSORT-AI for clinical trials with AI, STARD for diagnostic accuracy, STROBE for observational studies, CLAIM for medical AI). Use when drafting, restructuring, or reviewing manuscripts for medical/biomedical journals.
version: 0.1.0
---

# Clinical Paper Writing

## When to use
- Drafting a new manuscript for a medical/biomedical journal.
- Restructuring sections to comply with reporting guidelines.
- Self-review before submission.
- Adapting a thesis chapter, technical report, or conference abstract into a publishable paper.
- NOT a substitute for the actual scientific work — this guides structure and reporting, not the methodology itself.

## Process

### Phase 1 — Pre-writing decisions

1. **Identify study type** and select the matching reporting guideline:

| Study type | Guideline | Key items reviewers will check |
|---|---|---|
| Prediction model (DL/ML/radiomics) | TRIPOD+AI (2024) | Sample size justification, train/val/test split at patient level, calibration, fairness across subgroups |
| Medical AI intervention/tool | CLAIM (2020, updated 2024) | Architecture, training data provenance, ground truth definition, error analysis |
| Diagnostic accuracy | STARD 2015 | Reference standard, blinding, flow diagram of participants |
| Observational cohort | STROBE | Setting, eligibility, variables, confounding, sensitivity analyses |
| RCT with AI | CONSORT-AI | AI version, integration with workflow, human-AI interaction |
| Systematic review | PRISMA 2020 | Flow diagram, risk of bias assessment |
| Imaging biomarker | IBSI compliance + REMARK if prognostic | Feature reproducibility, validation cohort |

2. **Confirm target journal**: scope match, IF, average article length, structure (some merge Results+Discussion), format (Vancouver vs APA citations), supplementary policy.

3. **Build outline** mapping IMRaD sections to the reporting guideline checklist. Every checklist item must have a destination section.

### Phase 2 — Section-by-section drafting

#### Title
- Specific, declarative, includes study type ("...: a retrospective multicenter study", "...: a TRIPOD+AI compliant prediction model").
- Avoid acronyms unless universally known.
- 12-15 words is a good target.

#### Abstract (250-300 words, structured)
Required sub-sections (adapt to journal's exact format):
- **Background**: 1-2 sentences. Clinical problem + gap.
- **Methods**: Design, setting, participants (n), key methods (one phrase: "deep learning model trained on..."), validation strategy, primary outcome.
- **Results**: Cohort characteristics (key numbers), primary result with 95% CI, key secondary.
- **Conclusions**: Clinical implication, NOT overstated. Mention what the study does NOT yet demonstrate.

#### Introduction (3-5 paragraphs)
- **Para 1**: Clinical context, burden of disease, why it matters.
- **Para 2-3**: State of the art. What's been tried, with citations. Limitations of existing approaches.
- **Para 4**: Explicit gap statement. "Despite [previous work], no study has [specific gap]."
- **Para 5**: Aim, hypothesis, contribution. End with one sentence preview of methods, NOT results.

Anti-pattern: introducing results in the introduction. Results live in Results.

#### Methods (most detailed; reproducibility is the standard)
Order these sub-sections explicitly:
1. **Study design and setting** — retrospective/prospective, single/multi-center, dates, ethics approval (CEIm code).
2. **Participants/dataset** — inclusion/exclusion criteria, recruitment, n at each stage. **Provide a CONSORT-style flow diagram** if any exclusions occurred.
3. **Predictors/features** — definition, measurement protocol, reproducibility (intra/inter-observer if applicable, ICC values).
4. **Outcome** — definition, ascertainment, blinding of outcome assessors.
5. **Sample size** — justification (power analysis for inferential, EPV ≥ 10-20 for prediction models).
6. **Model development** (if ML/DL):
   - Architecture (cite or describe).
   - Hyperparameters and how they were chosen.
   - Training protocol (epochs, optimizer, lr, augmentation).
   - Hardware (GPU model, framework + version).
7. **Validation strategy** — split (patient-level, NEVER image-level for medical imaging), internal vs external, cross-validation if used.
8. **Statistical analysis** — software + version, significance level, missing data handling, primary metric with CI estimation method (bootstrap with B replicates, percentile or BCa).

Anti-pattern: vague phrases like "standard preprocessing was applied". Be specific.

#### Results
- **Lead with descriptive**: cohort characteristics in Table 1, stratified by relevant grouping (e.g., outcome group).
- **Primary outcome**: point estimate + 95% CI. State the comparator explicitly.
- **Secondary outcomes**: in order of importance, not order of significance.
- **Subgroup/sensitivity analyses**: state pre-specification.
- **Discrimination AND calibration** for prediction models (AUC alone is insufficient).
- **Figures**: each should make a single point. Caption must be self-contained.

Anti-pattern: chasing p-values. Effect sizes with CIs are what matter.

#### Discussion (3-5 paragraphs, ~1000 words)
- **Para 1**: Summary of main findings (in plain language, NO new results).
- **Para 2-3**: Comparison with literature. Where does this fit? Why are results similar/different from prior work?
- **Para 4**: Clinical implications. Calibrated, not overhyped. State the population to which results generalize.
- **Para 5**: Limitations. Be honest, not strategic. "Single-center", "retrospective", "no external validation", "sample size limited for subgroup analysis".
- **Final paragraph**: Conclusion — one sentence on contribution, one on future work.

Anti-pattern: "future work" used as a way to dismiss limitations. Limitations and future work are different.

### Phase 3 — Self-review checklist (mandatory before declaring done)

- [ ] Every claim in Abstract has support in Results.
- [ ] Methods reproducible by another team without contacting authors.
- [ ] No data leakage: patient-level split, no contamination between train/val/test.
- [ ] CIs reported for all key metrics, not just point estimates.
- [ ] Calibration reported (not just discrimination) for prediction models.
- [ ] Reporting guideline checklist completed and submitted as supplementary.
- [ ] Limitations explicit and proportionate to claims.
- [ ] Author contributions, funding, COI, data/code availability statements present.
- [ ] No "AI will replace radiologists" overclaiming.
- [ ] Figures/tables referenced in order in text.
- [ ] Citations: format matches journal, all DOIs present, no missing references.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| "State-of-the-art" claim without CI comparison vs published baselines | Reviewers reject vague superlatives | Report metric ± 95% CI vs cited baseline numbers |
| Image-level train/val/test split for patient-level outcome | Same patient in train+test inflates performance | Patient-level split, document explicitly with flow diagram |
| Single-center validation claimed as "generalizable" | External validity unsupported | Acknowledge as limitation, propose multi-center external validation |
| AUC as sole metric for imbalanced data | Misleads on minority class performance | Add F1, precision-recall AUC, calibration, decision curve analysis |
| "Our model achieves [metric]" with no comparator | Performance has no context | Always compare to a baseline (clinical score, prior model, radiologist) |
| Reporting only the best of multiple model variants | Multiplicity inflation | Pre-specify primary model; report all variants in supplementary |
| "Future work" used to dismiss limitations | Reviewers see through it | Limitations = what this study cannot address; future work = next step |
| Discussion that re-states results | Wastes word count | Discussion interprets, contextualizes, places in literature |

## Verification gates

Before declaring a section complete, the agent must produce evidence:

- **Methods**: Cite the reporting guideline checklist items covered in this section.
- **Results**: Every number traces back to a specific analysis script/notebook (mention which).
- **Discussion**: Every literature comparison has a citation; every clinical implication has a stated population scope.

## Default style

- **English**: academic, formal but not pompous. Sentences under 30 words where possible.
- **Tense**: past tense for Methods/Results ("we trained"), present tense for established knowledge ("CT is the standard imaging modality").
- **Voice**: active where it improves clarity ("we collected"), passive where the agent is irrelevant ("samples were processed").
- **Hedging**: "may", "suggests", "is consistent with" for inference. Never for facts.
- **Citations**: Vancouver numeric for most clinical journals (verify journal guide). Avoid citing review articles when primary sources exist.
- **Numbers**: 95% CI in parentheses, not separate sentence. Decimal places matched to measurement precision (don't report Dice = 0.84231).

## Resources to reference if needed

- TRIPOD+AI 2024 checklist: https://www.tripod-statement.org/
- CLAIM 2024: https://pubs.rsna.org/doi/10.1148/ryai.240300
- STARD 2015: https://www.equator-network.org/reporting-guidelines/stard/
- STROBE: https://www.strobe-statement.org/
- IBSI for radiomics features: https://theibsi.github.io/
