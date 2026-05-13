# Contributing

Thank you for considering contributing. This document describes how to propose changes effectively.

## Ways to contribute

1. **Improve an existing skill** — fix an error, clarify a workflow, update a reporting guideline reference.
2. **Add a new skill** — propose via issue first, then implement.
3. **Add an example** — a sanitized real-world usage scenario.
4. **Improve documentation** — README, quickstart, troubleshooting.
5. **Fix bugs** in install scripts or validation workflows.

## Workflow

### 1. Open an issue first

For anything beyond a typo fix:
- Use the appropriate issue template.
- Wait for maintainer feedback before investing effort.
- This protects your time: not all proposals fit the pack's scope.

### 2. Fork and branch

```bash
gh repo fork WElArfaoui/biomedical-research-skills --clone
cd biomedical-research-skills
git checkout -b feat/SKILL_NAME    # new skill
git checkout -b fix/SKILL_NAME     # fix
git checkout -b docs/SECTION       # docs
```

### 3. Make changes

For skill changes:
- Edit `skills/SKILL_NAME/SKILL.md`.
- Bump the `version` in frontmatter for non-trivial changes.
- Update the "When to use" if scope changed.

For new skills:
- Create `skills/SKILL_NAME/SKILL.md` following the existing format.
- Add an entry to `install/install.sh` (the `make_cmd` block).
- Add an entry to the README catalog.

### 4. Validate

```bash
# Run the same checks CI runs
python3 install/validate.py
```

### 5. Commit using Conventional Commits

```
feat(skills): add genomics-pipeline-design skill
fix(clinical): correct TRIPOD+AI reference link
docs: clarify install.sh prerequisites
test(ci): add YAML frontmatter validation
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `style`, `ci`, `perf`.

### 6. Open a PR

Use the PR template. Reference the issue. Wait for review.

## Scope

This pack focuses on **biomedical research**. We welcome:
- New reporting guidelines (CONSORT, REMARK, IBSI updates).
- Funding bodies not yet covered (NIH, ANR, DFG, NWO).
- Specialized clinical sub-fields (pathology, radiology, cardiology, oncology, sleep medicine).
- Senior engineering practices specific to research code.
- Regulatory frameworks (FDA, MDR, IMDRF).

We typically decline:
- Generic SaaS/web engineering skills (use [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills)).
- General scientific skills covered by [`K-Dense-AI/scientific-agent-skills`](https://github.com/K-Dense-AI/scientific-agent-skills).
- Non-biomedical domains.

## Skill format

- Frontmatter required: `name`, `description`, `version`.
- Process-oriented: describe phases or steps.
- Include verification gates (checklist).
- Include anti-patterns table (`Pattern | Why it fails | Correction`).
- Include "When to use" section at top.
- Include "Output format when invoked" at bottom.
- Content in English; output language is whatever the user requests.

## Code of conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to abide by its terms.

## License of contributions

By submitting a contribution, you agree it will be licensed under Apache 2.0.
