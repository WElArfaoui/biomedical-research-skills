---
name: cover-letter-medical
description: Drafting cover letters for submission to medical/biomedical journals. Covers scope-match justification, novelty claim calibrated to evidence, structure expected by clinical editors, and journal-specific conventions (Radiology, Eur Respir J, Med Image Anal, JAMIA, etc.). Use when preparing a submission cover letter for a medical journal.
version: 0.1.0
---

# Cover Letter — Medical Journal Submission

## When to use
- Preparing a cover letter for first submission to a medical/biomedical journal.
- Resubmitting after a desk reject elsewhere (different framing).
- Reviewing a colleague's cover letter.

## Why it matters

Editorial decisions often happen in <5 minutes. The cover letter is read first; it determines whether the editor will engage with the paper itself. A weak cover letter leads to desk reject regardless of paper quality.

## Process

### Phase 1 — Identify journal expectations

Different journals have different cover letter expectations:

| Journal type | Cover letter style |
|---|---|
| High-impact general (NEJM, Lancet, JAMA) | Short, punchy, immediate clinical relevance, "why this journal now" |
| Specialty clinical (Eur Respir J, Radiology, Chest) | Mid-length, scope match explicit, contribution to specialty |
| Methodological (Med Image Anal, JBHI, Bioinformatics) | Methodological novelty primary, application secondary |
| AI / informatics (npj Digit Med, JAMIA, JBI) | Both methodological AND clinical relevance |
| Open access (PLOS, Sci Rep) | Lighter requirements; still need scope match |

Always check journal's "Instructions for Authors" → "Cover letter" section for required content (some require ethics statement, COI, suggested reviewers).

### Phase 2 — Standard structure (1 page max)

```
[Date]

[Editor's name and title — if not specified, "Dear Editor"]
[Journal name]

Dear Dr. [Last name] / Dear Editor,

[Paragraph 1 — Submission and identification]
We are pleased to submit the manuscript entitled "[Full title]" for 
consideration as an [Original Article / Brief Report / Research Letter] 
in [Journal Name].

[Paragraph 2 — Clinical problem and gap]
[2-3 sentences setting up the clinical importance and the specific 
gap your work addresses.]

[Paragraph 3 — What we did and what we found]
[2-4 sentences. State design, dataset (n), key methods one sentence, 
primary finding with effect size. NO methodological detail beyond 
necessary.]

[Paragraph 4 — Why this journal]
[1-2 sentences. Explicit scope match. Reference recent papers in the 
journal that align with the topic, if applicable.]

[Paragraph 5 — Standard statements]
The manuscript has not been published elsewhere and is not under 
consideration by another journal. All authors have approved the 
submission. We declare [no / the following] conflicts of interest. 
[Add ethics approval reference if required upfront, e.g., approved 
by CEIm-a university hospital under reference XXX.]

[Optional: suggested or excluded reviewers, if journal allows]

We thank you for considering our work.

Sincerely,
[Corresponding author full name]
[Affiliation]
[Email]
```

### Phase 3 — Calibrating novelty claim

Don't oversell. Editors detect inflation immediately. Match the claim to the evidence:

| Evidence | Acceptable claim |
|---|---|
| First single-center retrospective study | "We provide initial evidence that..." / "First reported [in this specific setting]..." |
| External validation on independent cohort | "We provide external validation of..." |
| Multi-center, prospective | "We demonstrate generalizability of..." |
| Methodological improvement with comparison | "We propose [method] and show improved [metric] vs [baseline]" |
| Novel application of existing method | "We apply [method] to [new clinical question]" |

Phrases to AVOID in cover letters:
- "Groundbreaking", "paradigm-shifting", "revolutionary"
- "Definitive evidence" (almost always overstated for a single study)
- "AI will replace [clinician role]"
- Claims about generalizability beyond the studied population

### Phase 4 — Scope match (the make-or-break)

The single most important paragraph. Should answer: *Why this journal and not a different one?*

Structures that work:
- "Given [Journal]'s focus on [specific topic area], we believe our work on [your topic] is particularly aligned with the readership."
- "Recent work in [Journal] (e.g., [Author Year, Author Year]) has explored [related topic]; our contribution extends this by [specific addition]."
- "The clinical implications of our findings are most relevant to [specialty]; [Journal]'s primary readership in this field makes it an ideal venue."

Avoid:
- Generic statements ("[Journal] is a leading journal in...").
- Listing multiple unrelated journal scope areas.

### Phase 5 — Special cases

#### After a desk reject elsewhere
- Don't mention the previous journal explicitly.
- Refresh the "why this journal" paragraph for the new venue.
- If the previous reviewer comments led to substantive improvements, you may mention "the manuscript has been substantially revised based on prior feedback" — but be brief.

#### For a Brief Report / Research Letter
- One paragraph cover letter is fine.
- Emphasize urgency or specificity that justifies the short format.

#### For methodological papers in clinical journals
- Lead with the clinical problem, not the method.
- "We address [clinical problem] by introducing [method], which [advantage]."

#### For papers with methodological + clinical contributions
- One paragraph for methodological novelty, one for clinical relevance, one for scope match.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Cover letter > 1 page | Editor stops reading | Trim ruthlessly; details belong in the paper |
| Repeating the abstract | Wastes space | Summarize in 2-3 sentences max |
| "Please find attached..." | Outdated, formulaic | Direct opening: "We are pleased to submit..." |
| No scope match paragraph | Editor wonders why this journal | Always include explicit alignment |
| Overstating novelty | Loses credibility immediately | Match claim to evidence (see Phase 3) |
| Listing all 8 reasons the paper is great | Self-important tone | One specific contribution, well-stated |
| Mentioning IF or rejection elsewhere | Unprofessional | Don't |
| Generic "groundbreaking" language | Pattern editors filter out | Specific, measured language |

## Verification gates

- [ ] One page or less.
- [ ] Manuscript title quoted exactly as in the paper.
- [ ] Journal name spelled correctly (this matters; "Eur Respir J" not "European Respiratory Journal" if that's how they write it).
- [ ] Editor's name correct (check current editorial board).
- [ ] Article type matches what the journal accepts (Original Article, Brief Report, Letter, etc.).
- [ ] Standard statements: no prior publication, no concurrent submission, COI, ethics approval.
- [ ] Scope match explicit and specific.
- [ ] Novelty claim calibrated to evidence.
- [ ] No typos in author names or affiliations.
- [ ] Corresponding author email correct.

## Output format when invoked

When invoked, ask the user for:
1. Manuscript title and target journal.
2. Article type.
3. One-line summary of the clinical problem and the contribution.
4. Sample size and key result with effect size.
5. Any specific scope match angle (related recent papers in the journal, special issues, etc.).

Then produce:
- Drafted cover letter.
- Notes on what could be tightened or expanded depending on journal type.
- Reminder of any standard statements that must be added per the specific journal's instructions.
