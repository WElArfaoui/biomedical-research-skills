#!/usr/bin/env bash
# ============================================================================
# sanitize.sh - Replace personal/institutional references with generic terms
#
# Run from the repo root: ./install/sanitize.sh
#
# This script makes the skills publishable by removing references to specific
# people, institutions, internal projects, and infrastructure details.
# ============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_DIR/skills"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "Sanitizing skills in $SKILLS_DIR..."
echo ""

# Apply replacements across all SKILL.md files
find "$SKILLS_DIR" -name "SKILL.md" -type f | while read -r file; do
  # Institutions
  sed -i 's/IRBLleida (Institut de Recerca Biomèdica de Lleida)/a biomedical research institute/g' "$file"
  sed -i 's/IRBLleida/a biomedical research institute/g' "$file"
  sed -i 's/Hospital Universitari Arnau de Vilanova (HUAV)/a university hospital/g' "$file"
  sed -i 's/HUAV/a university hospital/g' "$file"
  sed -i 's/Translational Research in Respiratory Medicine (TRRM)/a respiratory medicine research group/g' "$file"
  sed -i 's/TRRM\/IRBLleida/a respiratory research group/g' "$file"
  sed -i 's/TRRM/a research group/g' "$file"
  sed -i 's/CIBERES/a CIBER consortium/g' "$file"
  sed -i 's/CERT-HUAV\|CERT\/CEIC/your ethics committee/g' "$file"
  sed -i 's/CEIm-HUAV/your CEIm/g' "$file"

  # Internal projects (generalize as example domains)
  sed -i 's/IELCAP-Lleida/a lung cancer screening cohort/g' "$file"
  sed -i 's/IELCAP/a lung cancer screening cohort/g' "$file"
  sed -i 's/CT-LungScore/a CT-based prognostic model/g' "$file"
  sed -i 's/POSTCOVID/a longitudinal post-COVID cohort/g' "$file"
  sed -i 's/METASLEEP-2/a multicenter sleep cohort/g' "$file"
  sed -i 's/METASLEEP/a multicenter sleep cohort/g' "$file"
  sed -i 's/SleepLM/a longitudinal physiological signal model/g' "$file"
  sed -i 's/TENACITY/an ICU follow-up cohort/g' "$file"

  # Personal OSS project names → generic examples
  sed -i 's/DicomShield/your-dicom-tool/g' "$file"
  sed -i 's/HPCDash/your-hpc-dashboard/g' "$file"
  sed -i 's/RadBot/your-radiology-tool/g' "$file"
  sed -i 's/GenomeMC/your-genomics-tool/g' "$file"
  sed -i 's/NoduleExplorer/your-imaging-tool/g' "$file"
  sed -i 's/PaperScore/your-scientometric-tool/g' "$file"

  # Author name in body content (keep only as illustration, not "your" workflow)
  sed -i 's/Wasim El Arfaoui Belbouli/the project maintainer/g' "$file"
  sed -i 's/wasim@example.com/maintainer@example.com/g' "$file"
  sed -i 's|/home/wasim/|/home/user/|g' "$file"
  sed -i 's/github\.com\/wasim/github.com\/<your-username>/g' "$file"

  # PACS / infrastructure (defensive - just in case)
  sed -i 's/10\.80\.128\.[0-9]*/<your-pacs-ip>/g' "$file"
  sed -i 's/RS_HUAV/<your-ae-title>/g' "$file"

  log "$(basename "$(dirname "$file")")"
done

# Remove any "Specific recommendations for your projects" sections
# These are tailored to the original author and don't belong in a generic pack
echo ""
echo "Renaming/cleaning 'Specific recommendations' sections..."
for file in $(find "$SKILLS_DIR" -name "SKILL.md" -type f); do
  if grep -q "## Specific recommendations for your projects\|## Specific maturation plans" "$file"; then
    # Rename heading to be more neutral
    sed -i 's/## Specific recommendations for your projects/## Example use cases/g' "$file"
    sed -i 's/## Specific maturation plans for your projects/## Example maturation paths/g' "$file"
    log "Renamed section in $(basename "$(dirname "$file")")"
  fi
done

echo ""
echo "Verifying sanitization..."
ISSUES=0
for pattern in "IRBLleida" "HUAV" "Ferran Barbé" "Iván Benítez" "Ivan Benitez" "Jessica González" "Jessica Gonzalez" "IELCAP-Lleida" "CT-LungScore" "POSTCOVID" "METASLEEP" "TENACITY" "DicomShield" "HPCDash" "RadBot" "GenomeMC" "NoduleExplorer" "PaperScore" "Wasim El Arfaoui"; do
  if grep -r -q "$pattern" "$SKILLS_DIR" 2>/dev/null; then
    warn "Still found: $pattern"
    ISSUES=$((ISSUES+1))
  fi
done

if [ "$ISSUES" -eq 0 ]; then
  echo ""
  log "All personal/institutional references removed."
else
  echo ""
  warn "$ISSUES patterns still need manual review."
fi
