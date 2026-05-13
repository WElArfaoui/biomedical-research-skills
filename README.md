# Biomedical Research Skills for Claude Code

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

> Senior-level [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) skills for biomedical researchers: clinical writing, medical imaging methodology, statistical reporting, fellowship and grant applications, scientific software engineering, medical hardware design, and open source contribution.

## What this is

A curated pack of **16 skills** for Claude Code, designed for researchers at the intersection of medicine, bioinformatics, and software engineering. Each skill encodes domain-specific best practices, reporting guidelines (TRIPOD+AI, CLAIM, STROBE, STARD, IBSI), regulatory frameworks (IEC 62304, ISO 13485, MDR), and senior-engineer-level review criteria.

Unlike generic coding skills, these are **opinionated for research workflows**: patient-level splits, reproducibility-by-design, FAIR principles, competing-risks analysis, and the writing conventions of medical journals and EU/Spanish funding agencies.

**Design philosophy**: opt-in invocation only. Skills install outside Claude Code's auto-discovery path and activate only when explicitly invoked via slash commands. No background activation, no surprises.

## Quick start

```bash
git clone https://github.com/WElArfaoui/biomedical-research-skills.git
cd biomedical-research-skills
./install/install.sh
```

Then in Claude Code:

```
> /clinical drafting a paper on automated lung nodule detection
> /grant-eu help me structure the Excellence section of an MSCA-PF
> /sci-review review src/pipeline.py for data leakage and reproducibility
> /mature my project is in stage 3, plan the path to stage 5
```

See [`docs/quickstart.md`](docs/quickstart.md) for the full walkthrough.

## Skills catalog

### Clinical and scientific writing

| Slash | Skill | Purpose |
|---|---|---|
| `/clinical` | `clinical-paper-writing` | IMRaD structure + reporting guideline selection (TRIPOD+AI, CLAIM, STARD, STROBE) |
| `/imaging` | `medical-imaging-methods` | Methods section for CT/MRI/PET studies, radiomics, DL segmentation |
| `/stats` | `clinical-statistics-reporting` | Discrimination + calibration + DCA; competing risks; bootstrap CIs |
| `/cover` | `cover-letter-medical` | Cover letters for medical journals (1-page, scope match) |
| `/reviewers` | `response-to-reviewers` | Point-by-point rebuttals with calibrated tone |

### Funding applications

| Slash | Skill | Purpose |
|---|---|---|
| `/grant-es` | `grant-writing-spanish` | PFIS, Joan Oró, FPI, FPU, Sara Borrell, Río Hortega |
| `/grant-eu` | `grant-writing-eu` | MSCA-PF, Horizon Europe, ERC — Excellence/Impact/Implementation |

### Senior scientific software engineering

| Slash | Skill | Purpose |
|---|---|---|
| `/sci-review` | `senior-scientific-code-review` | Code review focused on data leakage, numerical correctness, reproducibility |
| `/craft` | `scientific-code-craft` | Idiomatic Python scientific code: structure, type hints, error handling |
| `/sci-docs` | `scientific-documentation` | NumPy docstrings, MkDocs Material, ADRs, CITATION.cff |
| `/mature` | `research-code-maturation` | Maturity stages 0-5: notebook → script → module → package → library |
| `/sci-debug` | `scientific-debugging` | CUDA OOM, NaN/Inf, reproducibility, SLURM, multiprocessing issues |

### Specialized domains

| Slash | Skill | Purpose |
|---|---|---|
| `/wearable` | `embedded-medical-wearable` | MCU selection (nRF52840), medical sensors, BLE, IEC 60601/62304 |
| `/oss-contrib` | `oss-contribution` | Finding tractable issues, mergeable PRs, maintainer communication |
| `/oss-setup` | `oss-project-setup` | License, README, CI/CD, Zenodo DOI, JOSS readiness |
| `/pipelines` | `bioinformatics-pipelines` | Snakemake/Nextflow, containers, DVC, MLflow, FAIR-by-design |

## How it works

Each skill is a `SKILL.md` file with YAML frontmatter (`name`, `description`, `version`) and a structured workflow. The install script:

1. Clones this repo to `~/tools/biomed-skills/`.
2. Generates lightweight slash commands in `~/.claude/commands/` that reference each `SKILL.md`.

When you invoke `/clinical your-task`, Claude Code reads the corresponding `SKILL.md` into context and applies its workflow. Skills are **not** auto-discovered — they activate only when you explicitly invoke them. This is deliberate: it keeps sessions focused and predictable.

## Installation requirements

- Linux or macOS (Windows via WSL2)
- [Claude Code](https://docs.claude.com/en/docs/claude-code/quickstart) v2.x or higher
- `git`, `bash`

Optional:
- `gh` (GitHub CLI) — recommended for OSS contribution skills
- `uv` — recommended for Python dependency management

## Compatibility

These skills target **Claude Code v2.x** using the slash command + `SKILL.md` pattern. Other agents (Cursor, Cody, Gemini CLI) may work with adaptations to the invocation pattern.

## Status

**Pre-1.0**. The skills are functional and used in production research workflows. Slash command names and the frontmatter schema may change before v1.0. Pin to a specific git tag if you need stability.

## Contributing

Improvements to existing skills, new skills, documentation, examples — all welcome. For new skill proposals, **open an issue first** using the "New skill request" template. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Citing

If you use this pack in research, please cite it:

```bibtex
@software{elarfaoui_biomedical_research_skills_2026,
  author  = {El Arfaoui Belbouli, Wasim},
  title   = {Biomedical Research Skills for Claude Code},
  year    = {2026},
  version = {0.1.0},
  url     = {https://github.com/WElArfaoui/biomedical-research-skills}
}
```

## License

Apache License 2.0. See [LICENSE](LICENSE).


