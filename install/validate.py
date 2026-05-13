#!/usr/bin/env python3
"""Validate that all SKILL.md files have proper frontmatter.

Run from the repo root:
    python3 install/validate.py
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: pyyaml not installed. Install with: pip install pyyaml")
    sys.exit(1)


REQUIRED_FIELDS = ["name", "description", "version"]
SKILLS_DIR = Path(__file__).parent.parent / "skills"


def validate_skill(skill_dir: Path) -> list[str]:
    """Validate a single skill directory. Returns list of error messages."""
    errors = []
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        return [f"{skill_dir.name}: missing SKILL.md"]

    content = skill_md.read_text(encoding="utf-8")

    # Check frontmatter delimiters
    if not content.startswith("---\n"):
        errors.append(f"{skill_dir.name}: SKILL.md must start with '---' frontmatter")
        return errors

    parts = content.split("---\n", 2)
    if len(parts) < 3:
        errors.append(f"{skill_dir.name}: malformed frontmatter (missing closing '---')")
        return errors

    fm_text = parts[1]
    body = parts[2]

    # Parse YAML
    try:
        fm = yaml.safe_load(fm_text)
    except yaml.YAMLError as e:
        errors.append(f"{skill_dir.name}: invalid YAML in frontmatter: {e}")
        return errors

    if not isinstance(fm, dict):
        errors.append(f"{skill_dir.name}: frontmatter must be a YAML mapping")
        return errors

    # Required fields
    for field in REQUIRED_FIELDS:
        if field not in fm:
            errors.append(f"{skill_dir.name}: missing required field '{field}'")

    # Name should match directory name
    if "name" in fm and fm["name"] != skill_dir.name:
        errors.append(
            f"{skill_dir.name}: frontmatter name '{fm['name']}' doesn't match directory"
        )

    # Description should be non-trivial
    if "description" in fm:
        desc = fm["description"]
        if not isinstance(desc, str) or len(desc) < 20:
            errors.append(f"{skill_dir.name}: description must be at least 20 characters")

    # Version should look like semver
    if "version" in fm:
        v = str(fm["version"])
        if not all(p.isdigit() for p in v.split(".")):
            errors.append(f"{skill_dir.name}: version '{v}' should be semver-style (x.y.z)")

    # Body should have some content
    if len(body.strip()) < 100:
        errors.append(f"{skill_dir.name}: SKILL.md body is suspiciously short")

    return errors


def main() -> int:
    if not SKILLS_DIR.is_dir():
        print(f"ERROR: skills/ directory not found at {SKILLS_DIR}")
        return 1

    skill_dirs = sorted([d for d in SKILLS_DIR.iterdir() if d.is_dir()])
    if not skill_dirs:
        print("ERROR: no skill directories found")
        return 1

    print(f"Validating {len(skill_dirs)} skills...\n")

    all_errors = []
    for skill_dir in skill_dirs:
        errors = validate_skill(skill_dir)
        if errors:
            all_errors.extend(errors)
            for err in errors:
                print(f"  [FAIL] {err}")
        else:
            print(f"  [OK]   {skill_dir.name}")

    print()
    if all_errors:
        print(f"FAILED: {len(all_errors)} validation error(s)")
        return 1
    else:
        print(f"PASSED: all {len(skill_dirs)} skills valid")
        return 0


if __name__ == "__main__":
    sys.exit(main())
