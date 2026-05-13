---
name: scientific-documentation
description: Writing senior-level documentation for scientific software. Covers NumPy/Google docstring styles, type hints as documentation, README structure for research tools, Sphinx vs MkDocs setup, API reference generation via mkdocstrings or autodoc, tutorial notebooks that stay reproducible, Architecture Decision Records (ADRs) for scientific design choices, and citation/reproducibility metadata. Use when documenting a module, designing the docs site for a project, or writing an ADR for a significant scientific decision.
version: 0.1.0
---

# Scientific Documentation

## When to use
- Adding/improving docstrings in a Python module.
- Setting up a documentation site for a new project (your-dicom-tool, your-radiology-tool, etc.).
- Writing an ADR for a non-obvious scientific or architectural decision.
- Reviewing existing docs before a release or paper submission.
- Preparing software for JOSS / Zenodo / FAIR compliance.

## Philosophy

Documentation is not "extra work after coding". It's part of the code's contract with future users (including future-you). Three audiences:

1. **First-time users**: need quickstart, install, one example.
2. **Active users**: need API reference, examples per function.
3. **Maintainers**: need ADRs explaining why decisions were made.

Documentation that ages well has these properties:
- Examples are runnable and tested in CI.
- API reference is auto-generated from docstrings (no duplication).
- ADRs capture *why*, not just *what*.

## Process

### Phase 1 — Docstring style

#### NumPy style (recommended for scientific code)

This is the de-facto standard in scientific Python (NumPy, SciPy, sklearn, pandas).

```python
def compute_dice(
    prediction: np.ndarray,
    ground_truth: np.ndarray,
    *,
    smooth: float = 1e-6,
) -> float:
    """Compute the Dice similarity coefficient between two binary masks.

    The Dice coefficient measures the overlap between two binary masks and
    is widely used to evaluate medical image segmentation quality.

    Parameters
    ----------
    prediction : np.ndarray
        Binary mask predicted by the model, shape (Z, Y, X), dtype uint8.
        Values must be in {0, 1}.
    ground_truth : np.ndarray
        Ground-truth binary mask, same shape and dtype as ``prediction``.
    smooth : float, optional
        Smoothing factor to avoid division by zero when both masks are empty.
        Default is 1e-6.

    Returns
    -------
    float
        Dice score in [0, 1]. Returns 1.0 if both masks are empty.

    Raises
    ------
    ValueError
        If ``prediction`` and ``ground_truth`` have different shapes,
        or if values are not binary.

    Notes
    -----
    The Dice coefficient is defined as:

    .. math:: \\text{Dice} = \\frac{2 |X \\cap Y|}{|X| + |Y|}

    For evaluation of model quality, prefer reporting Dice alongside
    Hausdorff distance (HD95) and average surface distance (ASSD),
    since Dice alone is insensitive to boundary errors [1]_.

    References
    ----------
    .. [1] Maier-Hein, L. et al. (2024). Metrics reloaded:
       recommendations for image analysis validation. Nat Methods, 21.

    Examples
    --------
    >>> import numpy as np
    >>> pred = np.array([[1, 1, 0], [1, 0, 0]], dtype=np.uint8)
    >>> gt = np.array([[1, 0, 0], [1, 0, 0]], dtype=np.uint8)
    >>> compute_dice(pred, gt)
    0.6666...
    """
    if prediction.shape != ground_truth.shape:
        raise ValueError(f"Shape mismatch: {prediction.shape} vs {ground_truth.shape}")
    ...
```

Sections in order:
1. **One-line summary** (imperative mood: "Compute X", not "This computes X").
2. **Extended description** (1-2 paragraphs).
3. **Parameters** with type and constraints.
4. **Returns** with type and meaning.
5. **Raises** for exceptions.
6. **Notes** with mathematical formulas, caveats, or design rationale.
7. **References** to papers/standards (with proper citation).
8. **Examples** as doctests (run automatically in CI with pytest --doctest-modules).

#### Google style (acceptable, more popular in non-scientific)
```python
def compute_dice(prediction, ground_truth, *, smooth=1e-6):
    """Compute Dice similarity coefficient.

    Args:
        prediction: Binary mask, shape (Z, Y, X), dtype uint8.
        ground_truth: Ground-truth mask, same shape and dtype as prediction.
        smooth: Smoothing factor. Defaults to 1e-6.

    Returns:
        Dice score in [0, 1].

    Raises:
        ValueError: If shapes mismatch.
    """
    ...
```

Pick ONE style and stick with it across the project. Add to CONTRIBUTING.md.

### Phase 2 — Type hints as documentation

Type hints reduce what you need to document:

```python
# Without type hints: docstring carries all the burden
def resample(image, target_spacing, interpolator="linear"):
    """
    Parameters
    ----------
    image : np.ndarray
        3D array
    target_spacing : tuple
        Tuple of 3 floats
    interpolator : str
        Either "linear" or "nearest"
    """

# With type hints: docstring focuses on meaning
def resample(
    image: Array3D,
    target_spacing: tuple[float, float, float],
    *,
    interpolator: Literal["linear", "nearest"] = "linear",
) -> Array3D:
    """Resample volume to isotropic target spacing.

    Parameters
    ----------
    image
        Volume to resample. World spacing should be set in metadata.
    target_spacing
        Target voxel spacing in millimeters (z, y, x).
    interpolator
        "linear" for intensity images, "nearest" for label masks.
    """
```

Repetition of type info in docstring is no longer needed; focus on **semantics, constraints, and use cases**.

### Phase 3 — Module-level docstrings

Every public module needs a module docstring:

```python
"""DICOM tag-level anonymization for GDPR/HIPAA compliance.

This module implements DICOM de-identification following DICOM PS 3.15-AnnexE
Basic Profile, with extensions for Spanish hospital workflows (a university hospital, a biomedical research institute).

The anonymization is configurable via :class:`AnonymizationProfile` and supports
three modes:

* **Strict**: remove all identifying information per Basic Profile.
* **Research**: keep dates shifted by a per-patient random offset.
* **Linkage**: keep a one-way hash of the patient ID for cross-study linking.

For typical use, see :func:`anonymize_series`.

Notes
-----
This module does NOT remove burned-in PHI in pixel data. Use
:mod:`dicomshield.pixel_inspector` for that.

References
----------
DICOM PS 3.15: Security and System Management Profiles
https://dicom.nema.org/medical/dicom/current/output/chtml/part15/sect_E.1.html
"""
```

### Phase 4 — README structure

A scientific tool's README should answer 5 questions in order:

1. **What is this?** (one sentence + one paragraph)
2. **What does it look like?** (screenshot/diagram/code snippet)
3. **How do I install it?**
4. **How do I use it?** (minimal working example)
5. **How do I cite it?**

Template:

```markdown
# your-dicom-tool

[![CI](https://github.com/.../actions/workflows/ci.yml/badge.svg)](...)
[![PyPI](https://img.shields.io/pypi/v/dicomshield.svg)](...)
[![DOI](https://zenodo.org/badge/.../zenodo.svg)](...)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](...)

GDPR-compliant DICOM de-identification for clinical research workflows.

your-dicom-tool removes Protected Health Information (PHI) from DICOM datasets
according to DICOM PS 3.15-AnnexE Basic Profile, while preserving the
study structure and timestamps needed for longitudinal research.

## Install
```bash
pip install dicomshield
```

## Quick example
```python
from dicomshield import anonymize_series, AnonymizationProfile

profile = AnonymizationProfile.research(date_shift_days=180)
anonymize_series(
    input_dir="raw/patient001/",
    output_dir="anon/patient001/",
    profile=profile,
)
```

## Documentation
Full docs: https://dicomshield.readthedocs.io

## Citing
If you use your-dicom-tool in research, please cite the Zenodo deposit:
> El Arfaoui Belbouli, W. (2026). your-dicom-tool (v1.0.0). Zenodo. DOI: 10.5281/...

## License
Apache 2.0
```

### Phase 5 — Documentation site

#### MkDocs Material (recommended for most projects)

```bash
pip install mkdocs-material mkdocstrings[python] mkdocs-include-markdown-plugin
mkdocs new .
```

`mkdocs.yml`:
```yaml
site_name: your-dicom-tool
site_description: GDPR-compliant DICOM de-identification
site_url: https://dicomshield.readthedocs.io
repo_url: https://github.com/<your-username>/dicomshield
edit_uri: edit/main/docs/

theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.suggest
    - content.code.copy
    - content.code.annotate
  palette:
    - media: "(prefers-color-scheme: light)"
      primary: indigo
      scheme: default
      toggle:
        icon: material/brightness-7
        name: Dark mode
    - media: "(prefers-color-scheme: dark)"
      primary: indigo
      scheme: slate

plugins:
  - search
  - include-markdown
  - mkdocstrings:
      handlers:
        python:
          options:
            docstring_style: numpy
            show_source: false
            show_signature_annotations: true
            separate_signature: true
            merge_init_into_class: true

nav:
  - Home: index.md
  - Quickstart: quickstart.md
  - User guide:
    - Concepts: guide/concepts.md
    - Profiles: guide/profiles.md
    - Pixel inspection: guide/pixels.md
  - Examples:
    - Basic anonymization: examples/basic.md
    - Multi-center pipeline: examples/multicenter.md
  - API reference:
    - dicomshield: api/core.md
    - dicomshield.io: api/io.md
  - Contributing: contributing.md
  - Changelog: changelog.md

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
  - pymdownx.tabbed
  - pymdownx.snippets
  - pymdownx.highlight
  - pymdownx.inlinehilite
```

API reference auto-generated:
```markdown
# Core API

::: dicomshield.anonymize_series

::: dicomshield.AnonymizationProfile
```

#### Sphinx (for larger/more formal projects)

Choose Sphinx when:
- You need versioned docs (multiple stable versions live).
- You need LaTeX/PDF output.
- The project will be referenced in journal papers (formal feel).

Use **Furo** or **pydata-sphinx-theme** for the look.

### Phase 6 — Reproducible tutorial notebooks

Tutorials in `examples/notebooks/` should be tested in CI:

```yaml
# .github/workflows/notebooks.yml
- name: Execute notebooks
  run: |
    pip install jupyter nbconvert
    for nb in examples/notebooks/*.ipynb; do
      jupyter nbconvert --to notebook --execute "$nb" --output executed_"$(basename $nb)"
    done
```

Or use **MyST notebooks** (Markdown + Jupyter) for version control friendliness:
```bash
pip install jupytext
jupytext --set-formats ipynb,md:myst examples/notebooks/quickstart.ipynb
```

Now `quickstart.md` is the source of truth; `.ipynb` regenerated as needed.

### Phase 7 — Architecture Decision Records (ADRs)

ADRs capture significant decisions and their context. Critical for scientific software where decisions have methodological consequences.

Folder structure:
```
docs/adr/
├── 0001-use-numpy-style-docstrings.md
├── 0002-record-anonymization-decisions.md
├── 0003-mask-resampling-uses-nearest.md
└── README.md
```

Template (Michael Nygard format, simplified):

```markdown
# 3. Mask resampling uses nearest-neighbor interpolation

Date: 2026-05-10

## Status
Accepted

## Context
When resampling DICOM volumes from anisotropic to isotropic spacing for
nnU-Net inference, we have two choices for the corresponding label masks:

- Linear interpolation: produces smoother boundaries but introduces
  fractional label values that have no semantic meaning.
- Nearest-neighbor: preserves label discreteness but may produce
  stair-step artifacts on coarse boundaries.

The literature (Maier-Hein et al. 2024, IBSI 2020) recommends
nearest-neighbor for labels.

## Decision
Use scipy.ndimage.zoom with order=0 (nearest-neighbor) for all mask
resampling. Image resampling uses order=1 (linear).

## Consequences
- Boundaries on small structures (<5 voxels) may exhibit stair-step
  artifacts. Acceptable trade-off.
- Code consistency: a single resampling utility enforces this
  (see :func:`dicomshield.transforms.resample`).
- Edge cases (e.g., multi-class masks with > 2 labels) are now
  unambiguous.
```

When to write an ADR:
- Choice between multiple valid technical approaches.
- Methodological decisions (which metric, which baseline, which preprocessing).
- Decisions reversing previous behavior.
- Anything you'd otherwise re-discuss in a year.

Keep them short. 1 page max.

### Phase 8 — Citation infrastructure

#### `CITATION.cff`
At repo root, machine-readable citation metadata:
```yaml
cff-version: 1.2.0
message: "If you use your-dicom-tool in research, please cite as below."
type: software
title: "your-dicom-tool"
abstract: "GDPR-compliant DICOM de-identification toolkit."
authors:
  - family-names: "El Arfaoui Belbouli"
    given-names: "Wasim"
    orcid: "https://orcid.org/XXXX-XXXX-XXXX-XXXX"
    affiliation: "a biomedical research institute"
version: "1.0.0"
date-released: "2026-05-12"
doi: "10.5281/zenodo.XXXXXXX"
license: Apache-2.0
repository-code: "https://github.com/<your-username>/dicomshield"
keywords:
  - DICOM
  - anonymization
  - medical imaging
  - GDPR
preferred-citation:
  type: software
  ...
```

GitHub auto-displays "Cite this repository" button when this exists.

#### Zenodo integration
- Link the GitHub repo at zenodo.org/account/settings/github/.
- Every GitHub release creates a Zenodo deposit with a DOI.
- Update README badge with the latest DOI.

#### Software paper (JOSS)
For research software with substantive scholarly content, write `paper.md`:
```markdown
---
title: 'your-dicom-tool: GDPR-compliant DICOM de-identification'
tags:
  - Python
  - DICOM
  - medical imaging
authors:
  - name: the project maintainer
    orcid: 0000-0000-0000-0000
    affiliation: 1
affiliations:
  - name: a biomedical research institute
    index: 1
date: 12 May 2026
bibliography: paper.bib
---

# Summary
...

# Statement of need
...

# Acknowledgements
...

# References
```

Submit to https://joss.theoj.org/.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| README with no install instructions | Trivial blocker | Always include `pip install` or equivalent |
| Docstrings that repeat the function name | Adds no info | "Compute Dice score" is fine; "compute_dice computes the Dice score" is not |
| Examples that don't run | Embarrassing in JOSS review | Run examples in CI via doctest or notebook execution |
| Inline `# this normalizes the image` comments | Explain code, not why | Comments explain rationale; docstrings explain interface |
| Massive `__init__.py` with everything imported | Slow import; circular risk | Explicit minimal exports via `__all__` |
| Auto-generated API without curation | Wall of text, no narrative | Pair API ref with hand-written guides |
| Docs that lag code | Confusing, untrusted | Auto-generate from docstrings; CI enforces |
| No CHANGELOG | Users don't know what changed | Keep one; automate with release-please |
| No ADRs for important decisions | Re-discussed every 6 months | Write ADRs for major design choices |

## Verification gates

Before a module is "documented":

- [ ] Module-level docstring exists.
- [ ] Every public function/class has a docstring (NumPy or Google style, consistent).
- [ ] Type hints on all public functions.
- [ ] Examples that run as doctests.
- [ ] README has install + minimal example + citation.
- [ ] Docs site builds without warnings.
- [ ] CHANGELOG.md updated.
- [ ] If significant decision: ADR added.
- [ ] CITATION.cff present (for OSS projects).

## Output format when invoked

When invoked, ask:
1. What's being documented: a single function, module, or whole project?
2. Style preference (NumPy/Google) — default NumPy.
3. Docs site exists already, or starting fresh?

Then produce:
- Drafted docstrings/README/ADR for the target.
- Notes on conventions to apply across the codebase.
- Suggestions for CI checks to enforce documentation quality.
