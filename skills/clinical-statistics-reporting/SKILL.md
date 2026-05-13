---
name: clinical-statistics-reporting
description: Reporting of statistical analyses in clinical/biomedical manuscripts according to STROBE, TRIPOD+AI and journal expectations. Covers descriptive statistics, hypothesis testing, regression models (logistic, Cox, Fine-Gray for competing risks), bootstrap CIs, calibration assessment (Brier, ICI, calibration plots), discrimination (AUC, c-index, time-dependent AUC), decision curve analysis (DCA), and handling of missing data and multiple comparisons. Use when drafting or reviewing statistical methods/results in clinical papers.
version: 0.1.0
---

# Clinical Statistics Reporting

## When to use
- Writing the "Statistical analysis" subsection of Methods.
- Writing Results numbers and their interpretation.
- Reviewing whether the statistical reporting in a draft is rigorous and complete.
- Adapting analyses to a specific reporting guideline (STROBE for observational, TRIPOD+AI for prediction, REMARK for prognostic biomarkers).

This skill complements `clinical-paper-writing` and `medical-imaging-methods`; it is the deepest dive on the statistical reporting layer.

## Process

### Phase 1 — Identify the analytical task

| Task | Primary inferential approach | Key reporting items |
|---|---|---|
| Describe a cohort | Descriptive | Median (IQR) for non-normal, mean (SD) for normal, n (%) for categorical |
| Compare two groups, continuous | t-test or Mann-Whitney | Test choice justified, effect size + 95% CI |
| Compare two groups, categorical | χ² or Fisher's exact | Effect size (OR or RD) + 95% CI |
| Risk factor (binary outcome) | Logistic regression | OR + 95% CI, calibration, discrimination |
| Time-to-event, single cause | Cox PH | HR + 95% CI, PH assumption check, c-index |
| Time-to-event with competing events | Fine-Gray (subdistribution) OR cause-specific Cox | sHR or csHR, cumulative incidence functions |
| Diagnostic accuracy | Sensitivity/specificity at threshold + AUC | 95% CI for all, comparison vs reference |
| Prediction model development | Multivariable model + internal validation | Discrimination + calibration + DCA |

### Phase 2 — Pre-specify before any analysis runs

In Methods, you must state:
- **Software + version**: e.g., R 4.4.0, Python 3.11 with scikit-survival 0.23.0.
- **Significance level**: α = 0.05 (two-sided) unless otherwise.
- **Primary outcome and primary analysis**: one each. Everything else is secondary.
- **Sample size justification**: power calculation for inferential, EPV ≥ 10-20 for prediction.
- **Missing data strategy**: complete case, multiple imputation (with method, m, predictors), or single imputation (rarely justifiable).
- **Multiple comparisons**: state if/how corrected (Bonferroni, Holm, BH-FDR).
- **Subgroup analyses**: pre-specified vs exploratory.

### Phase 3 — Reporting templates

#### Descriptive statistics (Table 1)
- Continuous variables: report **median (IQR)** for non-normal, mean (SD) for approximately normal. Test normality only if reporting mean (SD) — don't run Shapiro-Wilk on every variable.
- Categorical: n (%).
- Compare across groups only if relevant; do NOT run a t-test on every row of Table 1 ("Table 1 fallacy").

#### Logistic regression
- Report **OR with 95% CI** for each predictor.
- Report calibration: **Hosmer-Lemeshow test** is weak; prefer **calibration plot** + **Brier score** + **ICI (integrated calibration index)**.
- Report discrimination: **AUC with 95% CI** (DeLong or bootstrap).
- Internal validation: **bootstrap (B ≥ 200, typically 1000)** or k-fold cross-validation. Report optimism-corrected metrics.

#### Cox proportional hazards
- Report **HR with 95% CI**.
- **Check PH assumption**: Schoenfeld residuals (cox.zph in R survival, or analogous in Python lifelines). Report whether assumption held.
- If violated: stratification, time-varying coefficient, or change to AFT model.
- Discrimination: **c-index (Harrell or Uno) with 95% CI**.
- Calibration: calibration plot at fixed time horizons.

#### Competing risks (relevant for a CT-based prognostic model)
- Identify the competing event(s) explicitly. For long-term pulmonary mortality, competing events include cardiovascular death, cancer death other than lung, etc.
- Two coherent approaches:
  - **Cause-specific Cox** for each cause: csHR. Estimates the effect on the rate of the cause of interest. Good for etiologic inference.
  - **Fine-Gray subdistribution hazard**: sHR. Estimates the effect on the cumulative incidence. Good for prediction.
  - **State explicitly which you used and why.**
- Report **cumulative incidence functions (CIF)**, NOT 1−Kaplan-Meier (the latter overestimates in presence of competing risks).
- Calibration: cause-specific calibration plots at fixed horizons.
- Discrimination: time-dependent AUC for cause of interest, or Wolbers' c-index for competing risks.

#### Diagnostic accuracy
- Choose threshold a priori OR justify Youden's J derivation in training data only.
- Report sensitivity, specificity, PPV, NPV at the chosen threshold, ALL with 95% CI (Wilson or Clopper-Pearson).
- AUC with 95% CI (DeLong for paired, bootstrap otherwise).
- If comparing to a reference (radiologist, prior model): McNemar (paired) or comparison of AUCs (DeLong paired).

#### Prediction model (TRIPOD+AI)
A complete report has THREE pillars:
1. **Discrimination**: AUC / c-index with CI.
2. **Calibration**: calibration plot (intercept and slope, or LOWESS) + Brier score + ICI.
3. **Clinical utility**: **decision curve analysis (DCA)** showing net benefit across threshold probabilities, vs treat-all and treat-none.

If you skip any of these, expect reviewer pushback.

### Phase 4 — Confidence intervals and uncertainty

Default approach for any metric:
- **Bootstrap with B = 1000 replicates**, percentile or BCa method.
- Report **95% CI** in parentheses immediately after the point estimate.
- Decimal places matched to measurement precision: AUC to 2-3 decimals, p-values to 2-3 significant figures, do NOT report "p < 0.001" without exact value when journal allows.
- **Never** report p-values without effect sizes.

### Phase 5 — Multiple comparisons and selective reporting

- Pre-specify the primary analysis. Everything else is exploratory.
- For prediction model with many candidate predictors:
  - Pre-specify selection method (LASSO, stability selection, clinical knowledge).
  - Report whether selection was done before or after train/test split (must be after).
- If running many subgroup analyses: BH-FDR correction or just report unadjusted with explicit warning that they are exploratory.
- **Do not** report only the model with best performance after testing many. Report all primary candidates; differentiate primary from sensitivity.

### Phase 6 — Missing data

| Pattern | Acceptable handling |
|---|---|
| < 5% missing, MCAR | Complete case analysis with note |
| 5-30% missing, MAR | Multiple imputation by chained equations (MICE), m ≥ 20, include outcome in imputation model, Rubin's rules for combining |
| > 30% missing | Sensitivity analysis: tipping point, pattern-mixture model |
| MNAR suspected | Sensitivity analysis with assumed deviation |

Always report:
- n missing per variable.
- Method used for handling.
- For MI: predictors used, m, software (mice in R, IterativeImputer in scikit, fancyimpute, statsmodels).

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Reporting p-value without effect size + CI | Uninterpretable | Effect size + 95% CI is primary; p-value secondary |
| Hosmer-Lemeshow as sole calibration check | Sample-size dependent, weak | Calibration plot + Brier + ICI |
| Kaplan-Meier in presence of competing risks | Overestimates cumulative incidence | Cumulative incidence function (Aalen-Johansen) |
| AUC as sole prediction metric | Misses calibration & utility | AUC + calibration + DCA |
| Multiple imputation with outcome dropped from imputation model | Biases the analysis toward null | Always include outcome in imputation predictors |
| "Statistically significant trend" without adjustment for multiple looks | False positive risk | Pre-specify or correct |
| Optimism-uncorrected metrics from training data | Overfitting unreported | Bootstrap optimism correction or external validation |
| Reporting only "best" model from many | Selective reporting bias | Pre-specify primary; report all in supplementary |
| Threshold chosen on test set | Performance inflation | Pick threshold on training/development set only |
| "Categorize age into quintiles" without justification | Loss of information | Keep continuous unless biological rationale; if categorize, justify cuts |

## Verification gates

Before declaring statistical reporting done:

- [ ] Software + version stated.
- [ ] Primary outcome and primary analysis identified.
- [ ] Sample size / EPV justification present.
- [ ] Missing data approach stated.
- [ ] All effect sizes have 95% CI.
- [ ] Calibration AND discrimination reported for any prediction model.
- [ ] Competing risks acknowledged and handled appropriately if applicable.
- [ ] Multiple comparisons strategy stated.
- [ ] Subgroup analyses labeled as pre-specified or exploratory.
- [ ] Decision curve analysis present for clinical utility claim.
- [ ] PH assumption tested for any Cox model.
- [ ] Random seeds and reproducibility documented.
- [ ] Code/software/scripts cited or available.

## Quick formula reference

For when you need to write the actual numbers:

- **Bootstrap CI (percentile)**: sort the B replicates, take 2.5th and 97.5th percentiles.
- **Bootstrap CI (BCa)**: bias-corrected and accelerated; use when distribution is skewed (rms::validate in R, scipy.stats.bootstrap in Python).
- **DeLong CI for AUC**: pROC::ci.auc in R; sklearn doesn't have it natively, use the implementation in Sun & Xu (2014).
- **Brier score**: mean((y - p)²); 0 = perfect, 0.25 = naïve constant.
- **ICI**: mean(|p - smooth_calibration(p)|); 0 = perfect calibration.
- **Net benefit at threshold p_t**: (TP/n) - (FP/n) × (p_t / (1 - p_t)).

## Software notes specific to your stack

- **Python competing risks**: `lifelines.fitters.fine_gray_model` or `scikit-survival` `CoxnetSurvivalAnalysis` + manual handling. For full DCA-style outputs use `pycox` or implement via cumulative incidence.
- **R alternative**: `survival`, `cmprsk`, `rms`, `riskRegression` (the last is the gold standard for prediction model evaluation with competing risks).
- **Bootstrap**: `scipy.stats.bootstrap` in Python (Python 3.9+); manual loop for paired comparisons.
- **DCA**: `dcurves` in R; in Python implement the net benefit formula manually or use `dcal` (less mature).

## Output format when invoked

When this skill is invoked, produce:
1. The drafted Statistical Analysis paragraph(s) for Methods.
2. The drafted Results paragraphs with placeholder numbers (so the user fills in actual values).
3. A checklist of pending verification items.
4. Code skeleton (only if user asks) for the proposed analyses.
