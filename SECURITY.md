# Security Policy

## Reporting a vulnerability

If you discover a security issue in this repository (e.g., a script that could harm a user's system, or instructions that could compromise clinical data), please report it privately:

**Email**: elarfaouiwasim@gmail.com

Please do **not** open a public issue for security matters.

I aim to acknowledge reports within 5 business days and provide a timeline for resolution within 15 days.

## Scope

This project contains:

- **Shell install scripts** that modify your `~/.claude/` and `~/tools/` directories.
- **Markdown skill files** that Claude Code loads as context.

Out of scope:
- Vulnerabilities in Claude Code itself — report to Anthropic at https://www.anthropic.com/security.
- Vulnerabilities in the upstream repositories cloned by `install.sh` (Osmani's `agent-skills`, K-Dense's `scientific-agent-skills`, Master-cai's `Research-Paper-Writing-Skills`) — report those to their respective maintainers.

## Important note for clinical users

These skills are **not medical devices** and **not validated for clinical use**. Workflows that touch patient data (DICOM anonymization, clinical reporting, etc.) are reference frameworks only. You remain responsible for:

- Ethical approval (CEIm/IRB) for any clinical use.
- GDPR / HIPAA / equivalent compliance.
- MDR / FDA regulatory pathways if the output supports a medical device.
- Independent validation of any output before clinical decisions.

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.x     | Yes (current pre-release line) |

After v1.0, the latest minor will receive security fixes.
