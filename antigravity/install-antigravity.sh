#!/usr/bin/env bash
# Install the universal-kit Antigravity adapter into a project.
# Antigravity config is PROJECT-level: <project>/.agent/{rules,workflows,skills}
# Usage: ./install-antigravity.sh /path/to/project
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
PROJ="${1:?Usage: ./install-antigravity.sh /path/to/project}"
AGENT_DIR="$PROJ/.agent"

mkdir -p "$AGENT_DIR/rules" "$AGENT_DIR/workflows" "$AGENT_DIR/skills"
cp "$SRC"/rules/*.md "$AGENT_DIR/rules/"
cp "$SRC"/workflows/*.md "$AGENT_DIR/workflows/"

# Optional: port the kit's curated agents as Antigravity skills (flat .md files)
KIT_AGENTS="$SRC/../agents"
if [ -d "$KIT_AGENTS" ]; then
  cp "$KIT_AGENTS"/*.md "$AGENT_DIR/skills/" 2>/dev/null || true
fi

echo "Installed into $AGENT_DIR:"
echo "  rules:     $(ls "$AGENT_DIR/rules" | wc -l | tr -d ' ')"
echo "  workflows: $(ls "$AGENT_DIR/workflows" | wc -l | tr -d ' ') (onboard, task, rootcause, ship, genesis)"
echo "  skills:    $(ls "$AGENT_DIR/skills" | wc -l | tr -d ' ')"
echo "Open the project in Antigravity; workflows appear as slash commands."
