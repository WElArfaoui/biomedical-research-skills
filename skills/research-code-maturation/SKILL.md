---
name: research-code-maturation
description: "Maturing research code through stages: exploratory notebook → reusable script → versioned module → installable package → publishable library. Covers when to refactor, what to extract first, how to add tests retroactively, dependency hygiene, semantic versioning adoption, and CI gradual rollout. Use when an exploratory notebook is becoming production-shaped, when a script is being reused by colleagues, or when preparing internal code for public release."
version: 0.1.0
---

# Research Code Maturation

## When to use
- A Jupyter notebook is being reused enough that copy-paste hurts.
- A colleague asks for "the script you used for X".
- Code is being prepared for publication (Zenodo, JOSS, paper supplementary).
- A prototype works and now needs to be production-grade.
- An internal tool (your-dicom-tool, your-hpc-dashboard) needs to go public.

## Philosophy

Research code lives on a maturity spectrum. Forcing immediate production quality kills exploration; staying at notebook-quality forever kills reproducibility. The goal is **conscious progression** stage by stage.

```
Stage 0: Notebook scratch              <- exploration, never reused
Stage 1: Cleaned notebook              <- runs end-to-end, no errors
Stage 2: Script with parametrized I/O  <- runnable on different data
Stage 3: Module with tests             <- importable, basic CI
Stage 4: Installable package           <- pip install, semver
Stage 5: Publishable library           <- docs, DOI, JOSS-grade
```

Move up only when:
- The pain of staying is higher than the cost of moving.
- The code will be reused (don't mature one-off code).
- You have time budget for it.

## Process

### Stage 0 → Stage 1: Clean notebook

Symptoms you're at Stage 0:
- Cells run out of order to "work".
- Magic numbers everywhere.
- Variables shadowed across cells.
- Outputs committed in git diffs.

Actions:
1. **Restart kernel & Run All**. If it doesn't work, fix until it does.
2. **Add a header markdown cell**: title, author, date, purpose, inputs, outputs.
3. **Group cells by purpose**: Setup → Load → Process → Analyze → Save. Add markdown headers.
4. **Remove dead cells**. Git has history; you don't need them.
5. **Hardcoded paths → variables at the top.**
6. **Install `nbstripout`**: `pip install nbstripout && nbstripout --install`. Now notebook outputs stay out of commits.

Acceptance: another person can clone the repo, install dependencies, restart kernel, run all, and get the same outputs.

### Stage 1 → Stage 2: Notebook to script

Symptoms you need Stage 2:
- You want to run on different patients/datasets without editing the notebook.
- The notebook is being called from SLURM.
- Results need to be regenerated reliably.

Actions:
1. **Extract the notebook to a `.py` file** with `jupyter nbconvert --to python`.
2. **Wrap top-level code in `main()`**:
   ```python
   def main():
       ...
   if __name__ == "__main__":
       main()
   ```
3. **Replace hardcoded paths with argparse or Click/Typer**:
   ```python
   import typer
   def main(
       input_dir: Path = typer.Argument(...),
       output_dir: Path = typer.Argument(...),
       config: Path = typer.Option(None, "--config"),
   ):
       ...
   if __name__ == "__main__":
       typer.run(main)
   ```
4. **Move plots to functions that save to disk** rather than inline display.
5. **Add basic logging**:
   ```python
   import logging
   logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
   logger = logging.getLogger(__name__)
   ```
6. **Pin dependencies** in `requirements.txt` (or better, `uv.lock`).

Acceptance: `python script.py /path/to/input /path/to/output --config foo.yaml` works.

### Stage 2 → Stage 3: Script to module with tests

Symptoms you need Stage 3:
- Multiple scripts share functions (copy-paste happening).
- You need to call individual functions from other code.
- The code is wrong sometimes and you can't tell why.

Actions:

#### 1. Create package structure
```
myproject/
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── io.py            # File loading/saving
│       ├── preprocess.py    # Image preprocessing
│       ├── features.py      # Feature extraction
│       └── pipeline.py      # Orchestration
├── tests/
│   ├── conftest.py
│   ├── test_io.py
│   ├── test_preprocess.py
│   └── fixtures/
├── scripts/
│   └── run_pipeline.py      # Thin CLI on top of the library
├── pyproject.toml
└── README.md
```

#### 2. Extract pure functions first
Look for blocks of code that:
- Take inputs, return outputs.
- Don't print, save, or log.
- Don't depend on global state.

These extract cleanly to functions. Keep moving things that **don't** touch I/O into module functions; leave I/O orchestration in the script.

#### 3. Add type hints
Even if just for the function signatures:
```python
def normalize_ct(
    volume: np.ndarray,
    *,
    hu_min: float = -1024.0,
    hu_max: float = 600.0,
) -> np.ndarray:
    ...
```

#### 4. Add tests retroactively (the hard part)

Strategy: **test the outputs, not the internals**.

```python
# tests/test_preprocess.py
import numpy as np
import pytest
from myproject.preprocess import normalize_ct

def test_normalize_ct_clips_high_values():
    volume = np.array([[700.0, 100.0], [-100.0, 0.0]], dtype=np.float32)
    result = normalize_ct(volume, hu_min=-1024.0, hu_max=600.0)
    assert result.max() == pytest.approx(1.0)

def test_normalize_ct_clips_low_values():
    volume = np.array([[-2000.0, 100.0]], dtype=np.float32)
    result = normalize_ct(volume, hu_min=-1024.0, hu_max=600.0)
    assert result.min() == pytest.approx(0.0)

def test_normalize_ct_preserves_relative_order():
    volume = np.array([100.0, 200.0, 300.0], dtype=np.float32)
    result = normalize_ct(volume)
    assert np.all(np.diff(result) > 0)
```

Coverage of 30-50% on first pass is acceptable. Aim for:
- Every public function has at least one test.
- Edge cases: empty input, single element, all-same values, NaN, infinity.

#### 5. Set up CI
`.github/workflows/ci.yml`:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -e ".[dev]"
      - run: ruff check .
      - run: pytest --cov=src/myproject
```

Acceptance: module is importable (`from myproject import normalize_ct`), tests run, CI green.

### Stage 3 → Stage 4: Module to installable package

Symptoms you need Stage 4:
- Colleagues want to use the module from their own projects.
- You need versioning to track which version produced which result.
- You want to publish to PyPI or share via `pip install git+...`.

Actions:

#### 1. Proper `pyproject.toml`
See `scientific-code-craft` skill for full template. Key parts:
- `name` (final, won't change).
- `version` (use `dynamic = ["version"]` + `__version__.py` for single-source).
- `dependencies` (production deps, pinned to compatible ranges).
- `optional-dependencies` (dev, docs, etc.).
- `requires-python`.
- `classifiers` (PyPI metadata).

#### 2. Adopt semantic versioning
- `0.1.0` for first usable version.
- `0.x.y` while API is unstable; break things freely.
- `1.0.0` when you commit to stability.
- After 1.0: MAJOR for breaking, MINOR for features, PATCH for fixes.

#### 3. Conventional commits
```
feat(preprocess): add ComBat harmonization

fix(io): handle DICOM series with mixed slice spacing

docs: add multicenter example

chore: bump pydicom to >=3.0
```

Use `commitizen` or follow manually. Pairs with `release-please` for automated CHANGELOG.

#### 4. Test the install
In a fresh virtualenv:
```bash
python -m venv /tmp/test-install
source /tmp/test-install/bin/activate
pip install .
python -c "from myproject import normalize_ct; print('OK')"
```

If your own package can't install cleanly, no one else's will.

#### 5. Lock files for reproducibility
- `uv lock` produces `uv.lock` (modern).
- Or `pip-compile requirements.in -o requirements.txt` produces a pinned file.
- Commit the lock file for applications; do NOT commit it for libraries (libraries should be flexible).

Acceptance: `pip install myproject` works from a clean env, version is tagged, CHANGELOG exists.

### Stage 4 → Stage 5: Installable package to publishable library

Symptoms you need Stage 5:
- You want a Zenodo DOI for paper citation.
- You're submitting to JOSS.
- The library has real external users.

Actions:

#### 1. Documentation site
See `scientific-documentation` skill. Minimum:
- Quickstart that works copy-paste.
- API reference auto-generated from docstrings.
- 1-2 tutorial notebooks tested in CI.
- Contributing guide.

#### 2. Citation infrastructure
- `CITATION.cff` with ORCID.
- Zenodo-GitHub link.
- DOI badge in README.

#### 3. License clarity
- License at repo root.
- Header in source files (optional, but cleaner for OSS):
  ```python
  # SPDX-License-Identifier: Apache-2.0
  # Copyright 2026 the project maintainer
  ```

#### 4. Contribution infrastructure
- `CONTRIBUTING.md` with dev setup, test commands, commit conventions.
- Issue templates (bug, feature, question).
- PR template.
- `CODE_OF_CONDUCT.md` (Contributor Covenant).
- `SECURITY.md` (critical for clinical software).
- Dependabot config.

#### 5. Release automation
Use **release-please**:
```yaml
# .github/workflows/release-please.yml
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

Every PR merged updates a "Release PR" with CHANGELOG entries. When you merge that, it tags a new release.

#### 6. Pre-commit hooks
`.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
      - id: ruff-format
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.11.0
    hooks:
      - id: mypy
        additional_dependencies: [numpy, pydicom]
  - repo: https://github.com/codespell-project/codespell
    rev: v2.3.0
    hooks:
      - id: codespell
```

Acceptance: project is JOSS-submission ready. DOI assigned. External users can contribute via standard OSS workflow.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| Skipping straight from Stage 1 to Stage 5 | Burns months on infrastructure | Move stage by stage as needed |
| Refactoring while still exploring | Wasted work; design will change | Stay at Stage 0/1 until problem is understood |
| Adding tests only at the end | Code structure makes testing hard | Add tests as you extract functions |
| Big-bang refactor (rewrite all at once) | Too risky; behavior changes | Extract one function at a time, keep tests passing |
| `pip install -r requirements.txt` from `pip freeze` | Captures OS-specific deps | Use `pip-compile` or `uv lock` |
| `setup.py` only (no `pyproject.toml`) | Outdated; tools assume modern config | Migrate to `pyproject.toml` (PEP 621) |
| Tagging v1.0 too early | Have to break it later | Stay at 0.x until API is stable |
| No `__version__` in code | Hard to debug "which version produced this output?" | Define in `__version__.py`, expose via `pkg.__version__` |
| Notebooks as the "source of truth" for analysis | Brittle, untestable | Library + thin notebook for figures |

## Example maturation paths

### your-dicom-tool (currently in production at a biomedical research institute)
- Currently: Stage 3-4 likely.
- Next: Stage 5 (publishable). Add JOSS paper, ADRs documenting de-identification choices, full docs site with anonymization profiles table.

### your-imaging-tool
- Likely Stage 2-3.
- Next: write tests for the core extraction functions, add type hints, package as `pip install`-able.

### your-hpc-dashboard
- Likely Stage 3.
- Next: docs site for SLURM admin setup, Dockerfile for one-line install, JOSS candidacy is possible.

### your-scientometric-tool / your-radiology-tool / your-genomics-tool
- Variable. Audit each one and pick which to mature.
- Candidate for JOSS if methodologically novel.

## Verification gates by stage

**Stage 1 → 2:**
- [ ] Notebook runs end-to-end after kernel restart.
- [ ] Parameters extracted to top.
- [ ] Same notebook can run on different inputs by editing only the top.

**Stage 2 → 3:**
- [ ] Script callable from command line with args.
- [ ] No hardcoded paths.
- [ ] Logs go to stderr/file, not stdout.
- [ ] Dependencies in requirements.

**Stage 3 → 4:**
- [ ] `src/` layout.
- [ ] At least 30% test coverage.
- [ ] CI green.
- [ ] Type hints on public API.
- [ ] Module importable as library.

**Stage 4 → 5:**
- [ ] `pyproject.toml` complete.
- [ ] Versioning adopted, first tag exists.
- [ ] CHANGELOG.md.
- [ ] `pip install .` works in clean env.

**Stage 5 → public release:**
- [ ] Docs site deployed.
- [ ] CITATION.cff present.
- [ ] LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY.md.
- [ ] Zenodo DOI.
- [ ] First public release tagged.
- [ ] (Optional) JOSS submission.

## Output format when invoked

When invoked, ask:
1. Which project? Current state?
2. What's the goal (next stage, or skip ahead)?
3. Time budget available?

Then produce:
- Audit of current stage.
- Concrete next-stage plan with deliverables.
- Priority-ordered task list.
- Anti-patterns to watch for.
