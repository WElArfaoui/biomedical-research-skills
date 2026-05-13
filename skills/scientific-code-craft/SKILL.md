---
name: scientific-code-craft
description: Writing scientific/research code at senior engineer level. Covers project structure, module organization, function design, type hints, naming, error handling, separation of concerns, idiomatic Python/NumPy/PyTorch patterns, defensive programming for scientific data, and the trade-offs between research-grade and production-grade code. Use when starting a new module, refactoring existing code, or learning the canonical patterns for medical imaging / ML / bioinformatics codebases.
version: 0.1.0
---

# Scientific Code Craft

## When to use
- Starting a new module/library (your-dicom-tool, your-imaging-tool, your-radiology-tool, etc.).
- Refactoring messy code into something maintainable.
- Establishing project conventions before contributors join.
- Reviewing your own writing patterns to level up.

## Philosophy

Scientific code lives on a spectrum:

```
Research script <-- exploratory --|------ research-grade ------|-- production --> Library
   no tests, magic numbers              type hints, tests           strict types,
   one Jupyter cell                     docstrings                  100% coverage
                                         CI                          versioned API
```

The goal is **fluid movement up the spectrum**, not perfection at the start. Write the simplest thing that works, then mature it section by section as the code stabilizes.

Bad outcomes happen when:
- Premature production-ization slows research velocity (over-engineering).
- Permanent research-script style ships to others (under-engineering).

## Process

### Phase 1 — Project structure (canonical Python)

A scientific Python package should look like:

```
myproject/
├── pyproject.toml           # Single source of truth for metadata + deps
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CITATION.cff
├── src/
│   └── myproject/
│       ├── __init__.py      # Defines the public API (explicit exports)
│       ├── __version__.py   # Single-source version
│       ├── core/            # Domain logic
│       │   ├── __init__.py
│       │   ├── models.py
│       │   └── transforms.py
│       ├── io/              # File I/O isolated
│       │   ├── __init__.py
│       │   ├── dicom.py
│       │   └── nifti.py
│       ├── cli.py           # Click/Typer entry points
│       └── _internal/       # Private API (leading underscore convention)
├── tests/
│   ├── conftest.py
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── docs/
├── examples/
│   └── notebooks/
└── .github/
    └── workflows/ci.yml
```

Key decisions:
- **`src/` layout** vs flat: `src/` prevents accidental import of uninstalled code; the standard for serious projects.
- **Public vs private**: leading underscore (`_internal`, `_helpers.py`) marks private modules. Users should only touch what's exported in `__init__.py`.
- **I/O isolated**: never mix domain logic and file I/O in the same module. Makes testing 10x harder otherwise.

### Phase 2 — `pyproject.toml` modern setup

Use **PEP 621** metadata (not legacy `setup.py`):

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "dicomshield"
dynamic = ["version"]
description = "GDPR-compliant DICOM de-identification"
readme = "README.md"
license = {file = "LICENSE"}
authors = [{name = "the project maintainer", email = "maintainer@example.com"}]
requires-python = ">=3.11"
dependencies = [
    "pydicom>=2.4.0,<3.0",
    "numpy>=1.26",
]
classifiers = [
    "License :: OSI Approved :: Apache Software License",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Topic :: Scientific/Engineering :: Medical Science Apps.",
]

[project.optional-dependencies]
dev = ["pytest>=7", "pytest-cov", "ruff", "mypy", "pre-commit"]
docs = ["mkdocs-material", "mkdocstrings[python]"]

[project.scripts]
dicomshield = "dicomshield.cli:main"

[tool.hatch.version]
path = "src/dicomshield/__version__.py"

[tool.ruff]
line-length = 100
target-version = "py311"
select = ["E", "F", "I", "N", "UP", "B", "SIM", "PT", "RUF"]

[tool.mypy]
strict = true
python_version = "3.11"

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-ra --strict-markers"
```

Why `hatchling` and not `setuptools`: cleaner, faster, modern. Also valid: `pdm`, `poetry`.

### Phase 3 — Function design

#### Signature design
```python
# BAD: positional booleans, magic constants
def preprocess(image, True, 5, "max")

# GOOD: keyword-only parameters for non-obvious args
def preprocess(
    image: np.ndarray,
    *,
    normalize: bool = True,
    kernel_size: int = 5,
    aggregation: Literal["max", "mean"] = "max",
) -> np.ndarray:
    ...
```

Rules:
- **Required args positional, optional args keyword-only** (use `*,`).
- **Type hints always** for public functions. Use `Literal` or `Enum` for fixed choices.
- **Return type explicit** even when obvious. Helps mypy and readers.
- **Names follow domain**: `compute_dice`, not `helper2`.
- **Verbs for actions, nouns for queries**: `load_dicom_series()` for action, `has_pixel_data` for query.

#### Pure functions where possible
```python
# BAD: side-effects buried in compute
def extract_features(image_path):
    img = load_image(image_path)        # I/O hidden
    img = normalize(img)
    img = save_intermediate(img)        # side effect!
    return compute_radiomics(img)

# GOOD: I/O at the boundary, compute is pure
def extract_features(image: np.ndarray) -> pd.DataFrame:
    normalized = normalize(image)
    return compute_radiomics(normalized)

# Caller decides where data comes from
img = load_image(path)
features = extract_features(img)
save_features(features, output_path)
```

#### Error handling
```python
# BAD: silent failure
def load_mask(path):
    try:
        return nib.load(path).get_fdata()
    except:
        return None  # caller doesn't know what failed

# GOOD: fail loud with context
def load_mask(path: Path) -> np.ndarray:
    if not path.exists():
        raise FileNotFoundError(f"Mask file not found: {path}")
    try:
        mask = nib.load(path).get_fdata()
    except nib.filebasedimages.ImageFileError as e:
        raise ValueError(f"Invalid NIfTI at {path}: {e}") from e
    if not np.all(np.isin(mask, [0, 1])):
        raise ValueError(f"Mask must be binary, found values: {np.unique(mask)}")
    return mask.astype(np.uint8)
```

Rules:
- **Validate at boundaries**, trust internals.
- **Use specific exception types**, never bare `except:`.
- **Preserve causes with `from`** when re-raising.
- **No silent failure**: returning `None` for an error is a footgun.

### Phase 4 — Type hints

For scientific code, type hints are not optional past prototype stage:

```python
from typing import Literal, Protocol, TypeVar
from pathlib import Path
import numpy as np
import numpy.typing as npt
import pandas as pd

# Numpy arrays with dtype hints
Array3D = npt.NDArray[np.float32]
Mask3D = npt.NDArray[np.uint8]

# Protocol for duck typing
class Resampler(Protocol):
    def resample(self, image: Array3D, spacing: tuple[float, float, float]) -> Array3D: ...

# Generic over array dtype
T = TypeVar("T", bound=np.generic)

def crop_to_mask(
    image: npt.NDArray[T],
    mask: Mask3D,
    *,
    margin_mm: float = 5.0,
) -> npt.NDArray[T]:
    ...
```

Run `mypy --strict` regularly. Treat type errors like test failures.

### Phase 5 — Configuration management

Stop putting magic numbers in functions:

```python
# BAD
def preprocess(image):
    image = np.clip(image, -1024, 600)        # what are these?
    image = (image - (-1024)) / (600 - (-1024))
    return image

# GOOD: typed config object
from dataclasses import dataclass

@dataclass(frozen=True)
class LungCTPreprocessConfig:
    hu_min: float = -1024.0    # air HU
    hu_max: float = 600.0      # max for lung parenchyma analysis

def preprocess(image: Array3D, config: LungCTPreprocessConfig) -> Array3D:
    clipped = np.clip(image, config.hu_min, config.hu_max)
    return (clipped - config.hu_min) / (config.hu_max - config.hu_min)
```

For runtime configuration (load from YAML/TOML):
- **`pydantic`** for validated settings (recommended for production).
- **`hydra`** for complex experiment configuration with composition.
- **`dataclasses` + `tomllib`** for simple cases.

### Phase 6 — Logging vs printing

```python
# BAD: print everywhere
print(f"Processing patient {pid}")
print(f"Done")

# GOOD: structured logging
import logging

logger = logging.getLogger(__name__)

def process_patient(pid: str) -> None:
    logger.info("processing patient", extra={"patient_id": pid})
    ...
    logger.info("processing complete", extra={"patient_id": pid})
```

Rules:
- **`logging` module always**, even in research code (you can silence it; you can't silence prints).
- **Logger per module**: `logger = logging.getLogger(__name__)`.
- **Levels matter**: DEBUG (internal trace), INFO (milestones), WARNING (recoverable issue), ERROR (failed), CRITICAL (system-level).
- **Structured context** via `extra=` instead of f-strings makes logs grep-able.

### Phase 7 — Idiomatic Python for scientific code

#### Pathlib over `os.path`
```python
# BAD
import os
path = os.path.join(base_dir, "subdir", "file.nii.gz")
exists = os.path.exists(path)

# GOOD
from pathlib import Path
path = Path(base_dir) / "subdir" / "file.nii.gz"
exists = path.exists()
```

#### Context managers for resources
```python
# BAD: leak risk
f = open(path)
data = f.read()
f.close()

# GOOD
with open(path) as f:
    data = f.read()
```

#### List comprehensions over `map`/`filter`
```python
# Less Pythonic
ids = list(map(extract_id, scans))

# More Pythonic
ids = [extract_id(s) for s in scans]
```

#### Match-case for dispatch (Python 3.10+)
```python
def get_loader(extension: str):
    match extension.lower():
        case ".dcm" | ".dicom":
            return load_dicom
        case ".nii" | ".nii.gz":
            return load_nifti
        case ".mha" | ".mhd":
            return load_mhd
        case _:
            raise ValueError(f"Unsupported extension: {extension}")
```

#### Use `dataclasses` for value objects
```python
# BAD: dict-driven code
patient = {"id": "p001", "age": 65, "sex": "M"}
print(patient["id"])  # typo-prone

# GOOD: typed dataclass
@dataclass(frozen=True)
class Patient:
    id: str
    age: int
    sex: Literal["M", "F"]

patient = Patient(id="p001", age=65, sex="M")
print(patient.id)  # autocompleted, type-checked
```

### Phase 8 — Defensive programming for scientific data

#### Always validate shapes
```python
def compute_dice(pred: Mask3D, gt: Mask3D) -> float:
    if pred.shape != gt.shape:
        raise ValueError(f"Shape mismatch: pred {pred.shape} vs gt {gt.shape}")
    if pred.dtype != np.uint8 or gt.dtype != np.uint8:
        raise TypeError("Masks must be uint8")
    ...
```

#### Document units in names or types
```python
# BAD: what's the unit?
def is_large_nodule(size: float) -> bool:
    return size > 30

# GOOD: unit in name
def is_large_nodule(size_mm: float) -> bool:
    return size_mm > 30.0

# BETTER: unit as type (with libraries like pint)
from pint import UnitRegistry
ureg = UnitRegistry()
def is_large_nodule(size: ureg.Quantity) -> bool:
    return size > 30 * ureg.millimeter
```

#### Sanity-check intermediates in pipelines
```python
def pipeline(volume: Array3D) -> pd.DataFrame:
    mask = segment(volume)
    assert mask.shape == volume.shape, "segmentation changed shape"
    assert 0 < mask.sum() < mask.size, "mask is empty or full"

    features = extract(volume, mask)
    assert not features.isna().any().any(), "NaN in features"

    return features
```

Use `assert` for *invariants* (things that must be true by construction). They can be disabled with `python -O`, so don't use them for input validation — that's `raise ValueError`.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| `from numpy import *` | Namespace pollution | `import numpy as np` |
| Mutable default args | Shared state across calls | `def f(items=None): items = items or []` |
| Catch-all `except:` | Hides real bugs | Catch specific exceptions |
| `print` for debugging in modules | Pollutes user output | `logger.debug` |
| `os.path.join` with manual `/` | OS-incompatible | `pathlib.Path` |
| Functions with > 5 parameters | Hard to remember order | Use a config dataclass |
| Functions that do both compute AND save | Untestable | Split: compute returns, caller saves |
| `time.sleep()` in production code | Fragile timing | Event-driven, futures, retry libraries |
| `# type: ignore` everywhere | Defeats type checking | Fix the underlying type issue |
| `__init__.py` that imports everything | Slow import, circular import risk | Explicit, minimal exports |

## Verification gates

Before declaring a module "done":

- [ ] Public API documented in `__init__.py` via `__all__`.
- [ ] All public functions have type hints.
- [ ] `mypy --strict` passes for the module.
- [ ] `ruff check` passes.
- [ ] Each public function has at least one test.
- [ ] No magic numbers; constants named.
- [ ] No print statements; logging used.
- [ ] No hardcoded paths.
- [ ] Errors fail loud with context.
- [ ] Module docstring explains purpose and usage.

## Output format when invoked

When invoked, ask:
1. What's the task (new module, refactor, review pattern)?
2. What's the domain (DICOM, ML training, statistics)?
3. Where in the spectrum (exploratory → production)?

Then produce:
- Recommended module structure.
- Skeleton code with type hints and docstrings.
- List of conventions to apply consistently.
- Maturation path: what to add next as the code stabilizes.
