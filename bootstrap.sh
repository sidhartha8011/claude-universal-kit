#!/usr/bin/env bash
# Universal Kit bootstrap — sets up a new machine to match the original.
# Usage: ~/.claude/universal-kit/bootstrap.sh
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/agents" "$SKILLS_DIR" "$CLAUDE_DIR/commands"

echo "==> 1/4 Cloning source libraries (skipped if present)"
clone() {
  local url="$1" dest="$SKILLS_DIR/$2"
  if [ -d "$dest/.git" ]; then
    echo "    $2 exists, pulling latest"
    git -C "$dest" pull --quiet || true
  else
    git clone --depth 1 --quiet "$url" "$dest"
    echo "    cloned $2"
  fi
}
clone https://github.com/anthropics/skills.git            anthropic-skills-repo
clone https://github.com/wshobson/agents.git               wshobson-agents
clone https://github.com/affaan-m/ecc.git                  ecc
clone https://github.com/hesreallyhim/awesome-claude-code.git awesome-claude-code

echo "==> 2/4 Installing kit agents + skills (symlinks)"
for f in "$KIT"/agents/*.md; do
  ln -sf "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done
for d in "$KIT"/skills/*/; do
  ln -sfn "${d%/}" "$SKILLS_DIR/$(basename "$d")"
done

echo "==> 3/4 Installing slash commands"
cp "$KIT"/commands/*.md "$CLAUDE_DIR/commands/"

echo "==> 4/4 Regenerating AGENT_INDEX.md for this machine"
"$KIT/regen-index.sh"

echo ""
echo "Done. Installed:"
echo "  - $(ls "$KIT"/agents/*.md | wc -l | tr -d ' ') agents -> ~/.claude/agents/"
echo "  - $(ls -d "$KIT"/skills/*/ | wc -l | tr -d ' ') skills -> ~/.claude/skills/"
echo "  - $(ls "$KIT"/commands/*.md | wc -l | tr -d ' ') commands: /onboard /task /build /genesis /rootcause /ship"
echo ""
echo "Restart Claude Code to pick up the commands. Optional plugins to add"
echo "manually via /plugin: anthropic-skills marketplace, ECC."
