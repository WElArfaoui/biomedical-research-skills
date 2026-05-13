---
name: response-to-reviewers
description: Drafting point-by-point responses to peer reviewer comments for medical/biomedical journals. Covers tone calibration (firm but diplomatic), structuring the response letter, handling unreasonable comments without escalation, marking changes in the manuscript, and signaling agreement vs disagreement clearly. Use when preparing a revision response to reviewers, including for major or minor revisions.
version: 0.1.0
---

# Response to Reviewers

## When to use
- Preparing the response letter for a revised manuscript.
- Drafting a rebuttal for a reject-with-resubmission decision.
- Reviewing a colleague's response letter before submission.
- NOT for initial submission cover letters (use `cover-letter-medical` for that).

## Core principles

1. **Every comment gets a response.** Even if the answer is "we agree and have changed X" — silence is read as ignoring.
2. **Tone**: respectful and assumes good faith, even when the reviewer is wrong. Editor reads the response too.
3. **Format**: the editor and reviewers should be able to track changes without re-reading the manuscript.
4. **Disagreement is allowed**, but must be supported with evidence (citation, clarification, additional analysis).

## Process

### Phase 1 — Triage all comments

Categorize each reviewer comment into one of:

| Category | What to do |
|---|---|
| Valid + easy | Make the change, acknowledge gratefully |
| Valid + costly (new analysis, new figure) | Make the change if feasible; if not, explain trade-off |
| Misunderstanding | Clarify in manuscript AND in response |
| Disagreement | Push back politely with evidence |
| Out of scope | Acknowledge the point, defer to future work, justify deferral |
| Contradictory between reviewers | Pick one path, explain the choice to both |

### Phase 2 — Structure of the response document

Standard format:

```
Dear [Editor name],

We thank the editor and reviewers for their constructive feedback on our 
manuscript [REF #]. We have carefully addressed each comment below. Changes 
in the revised manuscript are highlighted in [color/track-changes]. We believe 
these revisions have substantially strengthened the manuscript.

Sincerely,
[Authors]

----

Reviewer 1

Comment 1.1: [Verbatim quote of reviewer's comment]
Response: [Your response]
Changes: [Page X, lines Y-Z, or "no changes needed because..."]

Comment 1.2: [...]
Response: [...]
Changes: [...]

----

Reviewer 2
[Same structure]
```

### Phase 3 — Drafting individual responses

#### Template for "we agree"
```
Comment: [verbatim]

Response: We thank the reviewer for this important observation. We have 
[specific action: re-analyzed X, added Y to the discussion, clarified Z 
in Methods]. The revised text now reads:

"[New text from manuscript]"

Changes: Page X, lines Y-Z.
```

#### Template for "we disagree but politely"
```
Comment: [verbatim]

Response: We respectfully disagree with this interpretation, although we 
appreciate the reviewer's careful reading. Our reasoning is as follows:
[Evidence-based argument: citation, methodological justification, additional 
sensitivity analysis result]

To address the underlying concern, we have [softening action: added a 
limitation, clarified the rationale, conducted a sensitivity analysis 
showing the conclusion is robust].

Changes: [If any made; or "We did not modify the original analysis 
because..."]
```

#### Template for "out of scope"
```
Comment: [verbatim]

Response: This is an excellent suggestion that we agree warrants future 
investigation. However, [specific reason it's out of scope: data not 
available, sample size insufficient, requires prospective design]. We have 
acknowledged this point in the Discussion as a direction for future work:

"[Quote from revised manuscript]"

Changes: Page X, lines Y-Z.
```

#### Template for "misunderstanding / clarification"
```
Comment: [verbatim]

Response: We thank the reviewer for highlighting this point of confusion, 
which suggests our original wording was insufficiently clear. To clarify: 
[plain-language explanation of what was actually done]. We have revised 
the [Methods/Results/Discussion] section to make this explicit:

"[Quote from revised manuscript]"

Changes: Page X, lines Y-Z.
```

### Phase 4 — Tone calibration

#### Phrases that work well
- "We thank the reviewer for this insightful comment."
- "We appreciate the reviewer's careful reading."
- "We respectfully disagree, and our reasoning is..."
- "This is a valuable suggestion. We have..."
- "We acknowledge this limitation and have..."

#### Phrases to AVOID
| Don't write | Why | Alternative |
|---|---|---|
| "The reviewer is mistaken" | Confrontational | "We respectfully disagree" |
| "As we clearly stated..." | Implies reviewer didn't read | "To clarify our original statement..." |
| "This is beyond the scope" (without justification) | Dismissive | "This warrants future investigation; specifically because [reason]..." |
| "We have addressed this concern" (without specifics) | Vague | Quote the change verbatim |
| "Obviously..." | Condescending | Just explain |

#### Handling Reviewer 2 (the difficult one)
- Stay even-toned. The editor sees both reviews.
- If a request is unreasonable (e.g., "redo the entire analysis with a different cohort"), explain WHY it's unreasonable in factual terms (data unavailable, beyond stated scope, prior multi-center validation already shows generalizability).
- If a reviewer demands a citation to their own work that isn't relevant, decline politely: "We considered this reference but found it addresses [different topic X], whereas our study focuses on [Y]."
- If two reviewers contradict, pick the one more aligned with the editor's letter and explain the choice to both.

### Phase 5 — Final checks

- [ ] Every reviewer comment has an explicit response.
- [ ] Every change has a page/line reference.
- [ ] Tone is respectful throughout, even on disagreements.
- [ ] Response letter is also numbered/structured (not a wall of text).
- [ ] Quoted reviewer comments verbatim (avoids "you said something I'm interpreting" arguments).
- [ ] Manuscript changes match what's described in the response.
- [ ] Track changes / colored highlighting consistent in revised manuscript.
- [ ] Reviewer-numbered response (Reviewer 1, Reviewer 2 — keep them anonymous in your text).
- [ ] No defensive language, no excuses, no implicit blame on reviewers.
- [ ] Editor's letter also addressed if it had specific points beyond reviewer comments.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Bulk responses ("We have addressed all comments below...") | Editor needs traceability | Numbered, point-by-point |
| Defensive tone | Suggests author can't take feedback | Even when right, frame collaboratively |
| Ignoring a comment | Treated as not addressing | Always respond, even if just to clarify |
| Making changes without flagging where | Reviewers will ask | Always cite page/line |
| Long philosophical justifications | Reviewers tire | Keep responses focused, evidence-first |
| Apologizing for limitations of the field | Unprofessional | State limitation factually, propose mitigation |

## Output format when invoked

When invoked, ask the user for:
1. The reviewer comments (paste verbatim).
2. The relevant section of the original manuscript (so changes can be drafted).
3. The author's preferred stance (agree/disagree/clarify) per comment, if known.

Then produce:
- Drafted point-by-point response in the standard format.
- Suggested manuscript edits as quoted text with track-change markers.
- Flag any comments where the user should reconsider their stance based on review of the comment's validity.
