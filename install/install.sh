#!/usr/bin/env bash
# ============================================================================
# Biomedical Research Skills - Installer
#
# Installs the skill pack to ~/tools/biomed-skills/ and generates slash
# commands in ~/.claude/commands/ for explicit opt-in invocation.
#
# Skills do NOT auto-discover; they activate only via slash commands.
#
# Usage: ./install/install.sh
# ============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="$HOME/tools/biomed-skills"
CMD_DIR="$HOME/.claude/commands"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1"; }

echo ""
echo "==========================================================="
echo "    Biomedical Research Skills - Installer"
echo "==========================================================="
echo ""

# --- Prerequisites ---
info "Checking prerequisites..."
command -v claude >/dev/null 2>&1 || warn "Claude Code CLI not detected. Install: npm install -g @anthropic-ai/claude-code"
command -v git >/dev/null 2>&1 || { err "git is required"; exit 1; }
log "git: $(git --version | head -1)"

# --- Copy skills ---
info "Installing skills to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
if [ -d "$INSTALL_DIR/skills" ]; then
  warn "$INSTALL_DIR/skills already exists. Updating in place."
fi
cp -r "$REPO_DIR/skills" "$INSTALL_DIR/"
SKILL_COUNT=$(ls "$INSTALL_DIR/skills" | wc -l)
log "$SKILL_COUNT skills installed"

# --- Generate slash commands ---
info "Generating slash commands in $CMD_DIR..."
mkdir -p "$CMD_DIR"

make_cmd() {
  local cmd_name=$1
  local skill_name=$2
  local extra=${3:-""}
  cat > "$CMD_DIR/${cmd_name}.md" <<EOF
Read the file \`$INSTALL_DIR/skills/${skill_name}/SKILL.md\` and apply its workflow to the following context.
${extra}

\$ARGUMENTS
EOF
}

# Clinical writing
make_cmd "clinical"   "clinical-paper-writing"        "Output in academic English."
make_cmd "imaging"    "medical-imaging-methods"       "Output in academic English."
make_cmd "stats"      "clinical-statistics-reporting" "Output in academic English."
make_cmd "cover"      "cover-letter-medical"          "Output in academic English."
make_cmd "reviewers"  "response-to-reviewers"         "Output in academic English; diplomatic-firm tone."

# Funding
make_cmd "grant-es"   "grant-writing-spanish"         "Output in formal academic Spanish."
make_cmd "grant-eu"   "grant-writing-eu"              "Output in academic English."

# Senior engineering
make_cmd "sci-review" "senior-scientific-code-review"
make_cmd "craft"      "scientific-code-craft"
make_cmd "sci-docs"   "scientific-documentation"
make_cmd "mature"     "research-code-maturation"
make_cmd "sci-debug"  "scientific-debugging"

# Specialized domains
make_cmd "wearable"   "embedded-medical-wearable"
make_cmd "oss-contrib" "oss-contribution"
make_cmd "oss-setup"  "oss-project-setup"
make_cmd "pipelines"  "bioinformatics-pipelines"

CMD_COUNT=$(ls "$CMD_DIR"/*.md 2>/dev/null | wc -l)
log "Slash commands generated"

# --- Summary ---
echo ""
echo "==========================================================="
echo "                INSTALLATION COMPLETE"
echo "==========================================================="
echo ""
echo "Installed:"
echo "  $INSTALL_DIR/skills/    ($SKILL_COUNT skills)"
echo "  $CMD_DIR/               ($CMD_COUNT total slash commands)"
echo ""
echo "Quick test:"
echo "  claude"
echo "  > /clinical drafting a paper on lung nodule detection"
echo "  > /grant-eu structure the Excellence section for an MSCA-PF"
echo ""
echo "Documentation: see docs/quickstart.md"
echo ""
echo "To uninstall:"
echo "  rm -rf $INSTALL_DIR"
echo "  rm $CMD_DIR/{clinical,imaging,stats,cover,reviewers,grant-es,grant-eu}.md"
echo "  rm $CMD_DIR/{sci-review,craft,sci-docs,mature,sci-debug}.md"
echo "  rm $CMD_DIR/{wearable,oss-contrib,oss-setup,pipelines}.md"
