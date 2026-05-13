---
name: oss-contribution
description: Strategy for contributing to open source projects effectively. Covers identifying tractable issues (good first issue, help wanted), reading unfamiliar codebases efficiently, communicating with maintainers, anatomy of mergeable pull requests (tests, docs, conventional commits, sign-off, DCO), code review etiquette from contributor side, and avoiding common rejection patterns. Use when planning to contribute to an external OSS project or when reviewing whether a contribution is ready to submit.
version: 0.1.0
---

# Open Source Contribution

## When to use
- Planning to contribute to an external OSS project (nnU-Net, MONAI, scikit-survival, etc.).
- Evaluating whether a draft PR is ready for submission.
- Drafting an issue or RFC for an upstream project.
- Reviewing how to respond to maintainer feedback on your PR.

## Process

### Phase 1 — Strategic project selection

Pick projects where contribution is high-leverage:

| Tier | Examples for your stack | Why contribute |
|---|---|---|
| Tools you use daily | nnU-Net, TotalSegmentator, MONAI, PyRadiomics, scikit-survival, lifelines, pydicom, MLflow | Bugs/features you actually hit; deepest understanding |
| Foundation libraries | NumPy, SciPy, scikit-learn, PyTorch, transformers | Highest visibility but harder to land PRs |
| Adjacent ecosystem | DICOM toolkits (highdicom, pynetdicom), bioinformatics workflow tools (Snakemake, Nextflow), nf-core | Wider perspective, fits your career direction |
| Niche domain | Medical imaging viewers (Cornerstone3D, OHIF), DICOM anonymizers (CTP, deid) | Less competition, faster merging |

**Rule**: avoid contributing to projects you don't actually use. Maintainers spot drive-by contributions immediately.

### Phase 2 — Finding tractable issues

#### Search filters that work
```bash
# In any repo
gh issue list --label "good first issue" --state open
gh issue list --label "help wanted" --state open
gh issue list --label "documentation" --state open  # Often easier first PRs

# Across multiple repos via web
# https://github.com/issues?q=is:open+is:issue+label:%22good+first+issue%22+language:python
```

#### What to look for in a candidate issue
- **Clear scope**: title and body define what done means.
- **Recent activity**: commented within the last few months (otherwise it may be stale).
- **No assignee**: someone hasn't already taken it.
- **No "in progress" PR**: search PRs referencing the issue.
- **Maintainer-acknowledged**: maintainer has responded confirming the issue is real and welcomes a fix.

#### Issues to AVOID as first contributions
- Issues older than 1 year with no activity.
- Issues where multiple people have argued about the right approach (architectural disputes).
- Issues requiring deep domain knowledge of the project's internals.
- Issues with "needs design review" or "RFC" labels — these need maintainer input first.

### Phase 3 — Reading the codebase efficiently

When you join a new project, you have ~30 minutes before fatigue. Use them well:

1. **README and CONTRIBUTING.md first** — always.
2. **Repo structure** — `tree -L 2 -I 'node_modules|__pycache__|.git'`.
3. **Tests directory** — read test names. Tells you what the code is supposed to do.
4. **Entrypoints** — `setup.py`, `pyproject.toml`, `__main__.py`, CLI definitions.
5. **The specific area touched by your issue** — use `grep -r` or `gh code-search` to find relevant files.
6. **Recent PRs in the same area** — copy their patterns.

For a Python ML library specifically:
- `__init__.py` exports define the public API.
- `tests/` should pass before you start: run `pytest` first to establish baseline.
- Look at how typing is used (annotations? mypy? type stubs?).
- Look at logging patterns: do they use `logging` standard library, `loguru`, or something custom?

### Phase 4 — The first comment on the issue

Before coding anything:

```
Hi, I'd like to take a look at this. My plan is:

1. [Specific approach in one sentence]
2. [Specific approach for the test/validation]

Does this align with how you'd like this addressed? I'd rather check 
before opening a PR.

Context: I'm a [bioinformatician/researcher] who uses [project] in 
[clinical/research context]. Background: [one sentence].
```

This:
- Gets early feedback so you don't waste effort.
- Shows you've understood the issue.
- Builds rapport with the maintainer.
- Marks the issue as "in progress" socially.

If maintainer doesn't respond in 1-2 weeks, proceed but mention "no response yet, proceeding with this approach" in the PR.

### Phase 5 — Anatomy of a mergeable PR

#### Branch
```bash
git checkout -b fix/issue-1234-shortdesc
# or
git checkout -b feat/issue-1234-shortdesc
```

#### Commit messages — Conventional Commits
```
fix(segmentation): handle empty masks in dice computation

When all voxels are background, dice was returning NaN. This caused
test runs to fail mid-evaluation. Returns 1.0 if both prediction and
GT are empty (consistent with sklearn convention), 0.0 if only one
is empty.

Fixes #1234

Signed-off-by: the project maintainer <email@example.com>
```

Components:
- Type: `fix`, `feat`, `docs`, `test`, `refactor`, `perf`, `chore`, `style`, `ci`.
- Scope: optional, the module/area touched.
- Subject: imperative, lowercase, no period, ≤72 chars.
- Body: WHY, not just WHAT. Reference the issue.
- Footer: `Fixes #N` for auto-close, `Signed-off-by` if project requires DCO.

#### Tests
- **Always** add a test that fails without the fix and passes with it.
- Match the existing test framework (pytest, unittest, etc.).
- Match the existing test style (where do fixtures go? how are parametrize markers used?).
- Run the full test suite before pushing: `pytest`, `nox`, `tox`.

#### Documentation
- Update docstrings if API changes.
- Update relevant `.md` or `.rst` files in `docs/`.
- For new public functions: add to API reference if there's an autodoc index.
- For breaking changes: add to CHANGELOG.

#### Linting and formatting
Match the project's tools without imposing yours:
- `pre-commit run --all-files` if `.pre-commit-config.yaml` exists.
- Black, ruff, isort, flake8, mypy — only run what the project uses.
- DON'T reformat unrelated code — keep diff focused.

### Phase 6 — Opening the PR

Use the project's template if it has one (`.github/PULL_REQUEST_TEMPLATE.md`).

Standard structure:
```markdown
## Summary
One paragraph: what does this PR do, what issue it addresses.

## Changes
- Bullet list of concrete changes.

## Testing
- [ ] Added test [name] in [file].
- [ ] All existing tests pass locally (`pytest`).
- [ ] Linter passes (`ruff check .`).

## Related
Closes #1234
```

### Phase 7 — Responding to review

#### When the reviewer requests a change
- Make the change in a NEW commit (don't force-push during review unless requested).
- Reply per comment indicating done or pushing back with reasoning.
- Don't argue. If you disagree, present the trade-off and defer to maintainer judgment.

#### When reviewer requests force-push (squash, rebase)
- Rebase or squash as requested.
- Force-push: `git push --force-with-lease` (safer than `--force`).

#### When the PR sits without review
- Wait at least 2 weeks before bumping.
- Bump politely: "Hi, just wanted to check if there's anything else needed. Happy to address feedback."
- Don't bump again for at least 4 weeks.

### Phase 8 — Cultural norms by ecosystem

| Ecosystem | Norms |
|---|---|
| Python scientific (NumPy, SciPy, sklearn) | Heavy emphasis on tests + docs + type hints; PRs >100 lines need detailed justification |
| Medical imaging (nnU-Net, MONAI) | Smaller community, often welcomes contributions; expect domain-specific feedback |
| ML frameworks (PyTorch, transformers) | Very high bar; small PRs with focused scope land best |
| Web (Next.js, FastAPI) | Fast-moving; check Discord/Slack for context beyond GitHub |
| Embedded (Zephyr, Arduino) | DCO required, formal RFC for major features |

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Drive-by PR with no prior issue | Maintainer wonders "why this person?" | Comment on the issue first; build context |
| Reformatting whole file | Diff is unreviewable | Format ONLY lines you change |
| Adding new dependencies casually | Maintainers are wary of supply chain | Justify in PR; check existing deps first |
| PR that fixes 5 things | Hard to review, hard to revert | One PR = one issue |
| "Fixed it!" with no test | Will not be merged in serious projects | Test that fails without fix, passes with |
| Passive voice in commit ("Fixed bug") | Convention is imperative ("Fix bug") | Imperative, present tense |
| Force-pushing during active review | Loses comment context | Add commits during review; squash at end if requested |
| Refactoring as part of feature PR | Mixes concerns | Separate PR for refactor first, then feature |
| Mentioning yourself or others in a way that's promotional | Off-putting | Stick to the technical work |

## Verification gates

Before clicking "Create pull request":

- [ ] Linked to an existing issue (or opened one first if you're proactive).
- [ ] Maintainer pinged or issue confirmed by them.
- [ ] Tests pass locally (run them all, not just yours).
- [ ] Linter/formatter clean.
- [ ] CHANGELOG updated if project has one.
- [ ] Docs updated if API changed.
- [ ] Commit messages follow project convention.
- [ ] DCO `Signed-off-by` if required.
- [ ] PR description filled in per template.
- [ ] No unrelated changes in diff.
- [ ] Branch name is descriptive.

## Output format when invoked

When invoked, ask:
1. Which project? URL.
2. Which issue or feature?
3. What's your proposed approach?

Then produce:
- Read of the project's CONTRIBUTING.md (web fetch if available).
- Suggested first comment on the issue.
- Plan: branch name, files to touch, test approach, commit message structure.
- Pre-PR checklist tailored to the project's specifics.
