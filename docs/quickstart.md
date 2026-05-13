# Quickstart

This guide gets you from zero to invoking your first skill in under 5 minutes.

## Prerequisites

- Linux or macOS (Windows: use WSL2).
- [Node.js 20+](https://nodejs.org/) for Claude Code.
- `git` and `bash`.

## 1. Install Claude Code (if you don't have it)

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

The first time you run `claude`, you'll be prompted to authenticate with your Anthropic account (Pro/Max plan or API key).

## 2. Clone this repository

```bash
git clone https://github.com/WElArfaoui/biomedical-research-skills.git
cd biomedical-research-skills
```

## 3. Install the skills

```bash
./install/install.sh
```

This script:
- Copies the 16 skills to `~/tools/biomed-skills/skills/`.
- Generates 16 slash commands in `~/.claude/commands/`.
- Does **not** touch your existing Claude Code configuration.

If you already had skills installed in `~/.claude/commands/` from another pack, this won't conflict — slash commands have unique names (`/clinical`, `/wearable`, etc.).

## 4. Verify

```bash
ls ~/.claude/commands/ | grep -E "(clinical|wearable|sci-review)"
# Expected: clinical.md  wearable.md  sci-review.md
```

## 5. Try your first invocation

Open Claude Code in any working directory:

```bash
claude
```

Then try:

```
> /clinical I want to draft a paper on automated detection of lung nodules in chest CT
```

Claude Code will read `~/tools/biomed-skills/skills/clinical-paper-writing/SKILL.md`, load its workflow into context, and start applying it.

## 6. Other examples

```
# Grant application — European
> /grant-eu structure the Excellence section for an MSCA-PF on medical imaging AI

# Grant application — Spanish
> /grant-es draft the Texto 2b for a PFIS application on a lung cancer screening cohort

# Code review (senior, science-flavored)
> /sci-review review src/pipeline.py for patient-level split correctness and reproducibility

# Code maturation
> /mature my project is in stage 3, plan the path to a JOSS-ready stage 5

# Hardware design
> /wearable architecture proposal for a wrist device measuring SpO2, ECG, and temperature

# Bioinformatics pipelines
> /pipelines refactor my radiomics analysis from bash to Snakemake on SLURM
```

See the [skills catalog](skills-catalog.md) for the full list of slash commands and what each one does.

## Updating

```bash
cd /path/to/biomedical-research-skills
git pull
./install/install.sh        # safe to re-run; overwrites in place
```

## Uninstalling

```bash
rm -rf ~/tools/biomed-skills
# Remove the slash commands (only the ones from this pack):
cd ~/.claude/commands
rm -f clinical.md imaging.md stats.md cover.md reviewers.md
rm -f grant-es.md grant-eu.md
rm -f sci-review.md craft.md sci-docs.md mature.md sci-debug.md
rm -f wearable.md oss-contrib.md oss-setup.md pipelines.md
```

## Troubleshooting

### `claude: command not found`
Install Node.js first, then `npm install -g @anthropic-ai/claude-code`.

### `/clinical: command not found` inside Claude Code
- Check that `~/.claude/commands/clinical.md` exists.
- Restart Claude Code if you installed during an active session.

### A slash command runs but says "file not found"
The `~/tools/biomed-skills/skills/` directory was moved or deleted. Re-run `./install/install.sh`.

### YAML / validation errors when contributing
```bash
pip install pyyaml
python3 install/validate.py
```
