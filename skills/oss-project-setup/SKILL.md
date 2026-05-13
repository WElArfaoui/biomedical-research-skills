---
name: oss-project-setup
description: Setting up an open source project from scratch with the right files, conventions, and infrastructure to invite contributions and ensure long-term maintainability. Covers license selection (MIT, Apache 2.0, GPL, AGPL, BSD-3-Clause), required files (README, LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CHANGELOG), semantic versioning, conventional commits, GitHub Actions CI/CD, issue/PR templates, dependabot, release automation (release-please), documentation (MkDocs Material, Sphinx), DOI assignment via Zenodo for citable academic software. Use when starting a new OSS project or refurbishing an existing one for public release.
version: 0.1.0
---

# OSS Project Setup

## When to use
- Starting a new open source repository.
- Refurbishing an existing private project (your-dicom-tool, your-hpc-dashboard, your-radiology-tool, your-imaging-tool, your-scientometric-tool) for public release.
- Auditing an existing OSS project for missing infrastructure.
- Preparing a research software for citation (Zenodo DOI, JOSS submission).

## Process

### Phase 1 — Strategic decisions before any code commits

#### 1.1 — Define the project's contract with users

Before writing the README, answer these in your head:

| Question | Why it matters |
|---|---|
| Who is the user? | Determines README tone, examples, install instructions |
| What problem does it solve? | The one-sentence pitch |
| What does it NOT do? | Prevents wrong expectations |
| Is this research code or production code? | Sets the stability promise (semver, deprecation policy) |
| What's the maintenance commitment? | Be honest. Solo project = no SLA |

For your projects:
- **your-dicom-tool**: production-style, others depend on it. Strict semver.
- **your-hpc-dashboard**: tool, narrow audience. Looser stability promise.
- **your-imaging-tool / your-scientometric-tool**: research-flavored, lower stability promise expected.
- **your-radiology-tool, your-genomics-tool**: depending on goal.

#### 1.2 — License selection

Pick one and stick with it. Changing later is painful.

| License | When to choose | Constraints |
|---|---|---|
| **MIT** | Maximum adoption, you don't care about derivative works | Effectively no constraints; commercial use fine |
| **Apache 2.0** | Same as MIT but with explicit patent grant | Slightly heavier; required for commercial-friendly projects with patent concerns |
| **BSD-3-Clause** | Equivalent to MIT, slightly different attribution | Marginal differences |
| **GPL-3.0** | You want derivatives to remain open | Strong copyleft; less adoption in commercial settings |
| **AGPL-3.0** | Same as GPL but covers SaaS (network use) | Very restrictive for commercial adoption; common for "open core" |
| **EUPL-1.2** | EU-focused projects, public sector | Compatible with GPL; explicit EU legal framing |

For medical research software intended for broad scientific reuse: **Apache 2.0** is the safest default. It allows commercial use, includes patent protection, and is the de facto standard for ML/AI projects.

For your-dicom-tool specifically: Apache 2.0 fits because it touches GDPR/clinical workflows and you want it adopted broadly.

#### 1.3 — Naming
- Lowercase, hyphenated for the repo name (`nodule-explorer`, not `your-imaging-tool`).
- Avoid trademark-conflicting names (check PyPI, npm, Docker Hub).
- Avoid generic single words.

### Phase 2 — Required files at the project root

#### README.md
Structure that works:

```markdown
# Project Name

> One-sentence tagline.

[badges: build status, PyPI version, DOI, license]

## What it does
Short paragraph: problem and solution. Concrete.

## Quick start
```bash
pip install your-project
```
```python
from your_project import main_function
result = main_function(input)
```

## Why this exists
Differentiation vs alternatives.

## Documentation
Link to full docs.

## Citing
If used in research, please cite [Zenodo DOI / JOSS paper].

## Contributing
Brief paragraph, link to CONTRIBUTING.md.

## License
Apache 2.0
```

Anti-patterns:
- "I built this in my free time" disclaimers — unprofessional.
- Roadmap section listing features you haven't built — overpromises.
- ASCII-art logo at the top — wastes space.

#### LICENSE
Plain text file with the exact license text. Use GitHub's "Add file" → templates, or `gh repo create --license apache-2.0`.

#### CONTRIBUTING.md
Tell contributors how to:
- Set up dev environment.
- Run tests.
- Run linters/formatters.
- Branch naming convention.
- Commit message convention (conventional commits).
- PR process.
- Where to ask questions (Discussions, Discord, Matrix).

Template:
```markdown
# Contributing

Thanks for considering contributing! Here's how to get started.

## Dev setup
[Concrete commands]

## Running tests
`pytest` or whatever.

## Code style
We use `ruff` and `black`. Run `pre-commit run --all-files` before pushing.

## Commit messages
We follow [Conventional Commits](https://www.conventionalcommits.org/).

## Workflow
1. Open an issue first to discuss approach.
2. Fork and create a feature branch.
3. Open a draft PR early for visibility.
4. Make sure tests pass and docs are updated.
5. Mark as ready for review.

## DCO
We require a `Signed-off-by` line in each commit.
```

#### CODE_OF_CONDUCT.md
Use the **Contributor Covenant 2.1**. It's the standard. Don't write your own.

#### SECURITY.md
How to report security issues. Critical for projects touching clinical data.
```markdown
# Security Policy

## Reporting a vulnerability

Please do NOT open a public issue. Email [your security email] 
with details. We aim to respond within 5 business days.

## Supported versions
| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |
| 0.x     | No        |
```

#### CHANGELOG.md
Use [Keep a Changelog](https://keepachangelog.com/) format. Or automate with release-please.

### Phase 3 — `.github/` infrastructure

#### `.github/ISSUE_TEMPLATE/bug_report.md`
```markdown
---
name: Bug report
about: Report a bug
labels: bug
---

**Description**
What's broken?

**Reproduction**
1. Steps to reproduce.

**Expected behavior**

**Environment**
- OS:
- Python version:
- Package version:

**Logs / traceback**
```

#### `.github/ISSUE_TEMPLATE/feature_request.md`
Similar pattern.

#### `.github/PULL_REQUEST_TEMPLATE.md`
```markdown
## Summary
What does this PR do?

## Related issue
Closes #N

## Testing
- [ ] Added tests
- [ ] All tests pass locally
- [ ] Linter clean

## Checklist
- [ ] Updated CHANGELOG
- [ ] Updated docs
- [ ] DCO sign-off
```

#### `.github/dependabot.yml`
Automated dependency updates:
```yaml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
```

#### `.github/workflows/ci.yml`
Minimum viable CI for a Python project:
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: pip install -e ".[dev]"
      - run: ruff check .
      - run: pytest --cov
```

For medical imaging projects, also add:
- Caching of large test datasets.
- A separate job for slow integration tests, run only on main.

### Phase 4 — Versioning and releases

#### Semantic Versioning
- `MAJOR.MINOR.PATCH`.
- MAJOR: breaking changes.
- MINOR: new features, backward compatible.
- PATCH: bug fixes.
- Pre-1.0 is acceptable to signal "API may change".

#### release-please (recommended)
Automates CHANGELOG, version bumping, and GitHub releases from Conventional Commits:

`.github/workflows/release-please.yml`:
```yaml
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: python
```

#### Zenodo DOI for citation
- Connect your GitHub repo to Zenodo (https://zenodo.org/account/settings/github/).
- Each GitHub release auto-creates a Zenodo deposit with a DOI.
- Add the DOI badge to README.
- Add `CITATION.cff` at repo root:

```yaml
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
title: "Your Project"
authors:
  - family-names: "El Arfaoui Belbouli"
    given-names: "Wasim"
    orcid: "https://orcid.org/0000-0000-0000-0000"
version: 1.0.0
date-released: 2026-05-12
doi: "10.5281/zenodo.XXXXXXX"
license: Apache-2.0
repository-code: "https://github.com/yourname/yourproject"
```

GitHub will then display a "Cite this repository" button automatically.

#### JOSS (Journal of Open Source Software)
For research software with substantial scholarly effort, consider submitting to JOSS:
- Peer-reviewed publication of the software itself.
- DOI + citation.
- Free.
- Requires a `paper.md` (Markdown) and `paper.bib` (BibTeX) in the repo.
- Best for tools used by other researchers (your-radiology-tool, your-genomics-tool, your-scientometric-tool are plausible candidates).

### Phase 5 — Documentation

#### Small project: README only
- 200-500 lines max.
- Examples directory with notebooks.

#### Medium project: README + docs site
**MkDocs Material** is the right default. Setup:

```bash
pip install mkdocs-material mkdocstrings[python]
mkdocs new .
```

`mkdocs.yml`:
```yaml
site_name: Your Project
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.expand
  palette:
    primary: indigo
plugins:
  - search
  - mkdocstrings
nav:
  - Home: index.md
  - Quick start: quickstart.md
  - API reference: api.md
  - Contributing: contributing.md
```

Deploy with `.github/workflows/docs.yml`:
```yaml
name: Docs
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install mkdocs-material mkdocstrings[python]
      - run: mkdocs gh-deploy --force
```

#### Large project / scientific software: Sphinx
Use Sphinx if you need:
- LaTeX output for PDF manuals.
- Cross-references between modules at scale.
- Versioned docs (multiple versions live).
- Theme like Furo or pydata-sphinx-theme.

### Phase 6 — Project-specific recommendations

#### your-dicom-tool
- Apache 2.0 license.
- Strict semver from day 1 — others depend on this.
- CI: matrix testing across Python 3.11/3.12, multiple DICOM datasets, OS coverage (Ubuntu + macOS, skip Windows initially).
- Security: emphasize GDPR/HIPAA implications; SECURITY.md mandatory.
- Documentation: MkDocs Material with clear "what gets removed" tables.
- Citation: Zenodo DOI + JOSS submission candidate.

#### your-hpc-dashboard
- Apache 2.0 license.
- Web stack: ensure Docker image is reproducible.
- Documentation: focus on SLURM admin setup; include sample configs.

#### your-imaging-tool / your-scientometric-tool / your-genomics-tool / your-radiology-tool
- Apache 2.0.
- Research software framing: lower stability promise, explicit "research code" warning in README.
- JOSS candidacy if the science is novel.

### Phase 7 — Sustainability and community

- **Discussions** > Issues for questions. Enable GitHub Discussions.
- **All-contributors bot** to credit non-code contributors.
- **CODEOWNERS** file once others contribute, to auto-request review.
- **funding.yml** if you accept GitHub Sponsors or Open Collective.
- **Triage labels** consistent across projects: `bug`, `enhancement`, `documentation`, `good first issue`, `help wanted`, `question`, `wontfix`.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| No LICENSE file | Legally cannot be used | Always include from commit 1 |
| Custom CoC | Often weaker than Contributor Covenant | Use Contributor Covenant 2.1 |
| README starts with installation | Skips "what is this" | Start with the one-sentence pitch |
| No tests directory | Signals immaturity | Even `tests/test_smoke.py` with one test is better than nothing |
| `master` instead of `main` | Inconsistent with current default | Use `main` |
| Hand-edited CHANGELOG | Drifts, gets forgotten | Automate with release-please |
| Versioning by date | Breaks tooling, semver dependents | Use SemVer |
| Releasing 0.0.1 forever | Signals abandonment | Reach 1.0 when API is stable |
| No `pyproject.toml` (still using `setup.py` only) | Outdated; tools assume modern config | Migrate to `pyproject.toml` (PEP 621) |

## Verification gates

Before tagging v1.0.0 of an OSS project:

- [ ] LICENSE file at repo root, matches `pyproject.toml`.
- [ ] README has all sections (pitch, quickstart, docs link, citation, license).
- [ ] CONTRIBUTING.md with dev setup.
- [ ] CODE_OF_CONDUCT.md (Contributor Covenant 2.1).
- [ ] SECURITY.md.
- [ ] CHANGELOG.md (or release-please auto-generation).
- [ ] CITATION.cff with ORCID.
- [ ] `pyproject.toml` (PEP 621).
- [ ] Issue templates (bug, feature).
- [ ] PR template.
- [ ] CI workflow that runs tests + linter.
- [ ] dependabot.yml.
- [ ] Branch protection on `main` (require CI + 1 review).
- [ ] Documentation site deployed (MkDocs or Sphinx).
- [ ] Zenodo DOI (or plan to get one with first release).
- [ ] Discussions enabled.
- [ ] First release tagged.

## Output format when invoked

When invoked, ask:
1. Project name and one-sentence purpose.
2. Existing or new repo?
3. License preference (or accept Apache 2.0 default).
4. Target user (researchers, clinicians, developers).
5. Maintenance commitment realistic.

Then produce:
- Suggested README skeleton.
- LICENSE choice with justification.
- File list to add to repo.
- `.github/` directory contents.
- CI workflow tailored to language/stack.
- Documentation plan.
