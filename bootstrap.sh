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
clone https://github.com/hesreallyhim/awesome-claude-code.git awesome-claude-code
# Frontend animation / 3D skill sources
clone https://github.com/greensock/gsap-skills.git         gsap-skills-repo
clone https://github.com/CloudAI-X/threejs-skills.git      threejs-skills-repo
clone https://github.com/GoogleChrome/modern-web-guidance.git chrome-web-repo
clone https://github.com/199-biotechnologies/motion-dev-animations-skill.git motion-dev-repo
clone https://github.com/MiniMax-AI/skills.git             minimax-skills-repo
# NOTE: ECC (affaan-m/ecc) is intentionally excluded. It loaded ~200 skill descriptions
# into every session context. Individual skills are curated into kit/skills/ instead.

echo "==> 2/4 Installing kit agents + skills (symlinks)"
for f in "$KIT"/agents/*.md; do
  ln -sf "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done
for d in "$KIT"/skills/*/; do
  ln -sfn "${d%/}" "$SKILLS_DIR/$(basename "$d")"
done
# Frontend animation / 3D skills from source clones
for d in "$SKILLS_DIR"/gsap-skills-repo/skills/*/ "$SKILLS_DIR"/threejs-skills-repo/skills/*/; do
  ln -sfn "${d%/}" "$SKILLS_DIR/$(basename "$d")"
done
ln -sfn "$SKILLS_DIR/chrome-web-repo/skills/modern-web-guidance" "$SKILLS_DIR/modern-web-guidance"
ln -sfn "$SKILLS_DIR/motion-dev-repo" "$SKILLS_DIR/motion-dev-animations"
ln -sfn "$SKILLS_DIR/minimax-skills-repo/skills/shader-dev" "$SKILLS_DIR/shader-dev"

echo "==> 3/4 Installing slash commands"
cp "$KIT"/commands/*.md "$CLAUDE_DIR/commands/"

echo "==> 4/5 Regenerating AGENT_INDEX.md for this machine"
"$KIT/regen-index.sh"

echo "==> 5/5 Plugins + MCP connectors (needs claude CLI)"
if command -v claude >/dev/null 2>&1; then
  claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp 2>/dev/null || echo "    context7 already added or failed (non-fatal)"
  claude plugin marketplace add Leonxlnx/taste-skill 2>/dev/null || true
  claude plugin install --scope user taste-skill@taste-skill 2>/dev/null || echo "    taste-skill already installed or failed (non-fatal)"
  claude plugin install --scope user typescript-lsp@claude-plugins-official 2>/dev/null || true
  claude plugin install --scope user php-lsp@claude-plugins-official 2>/dev/null || true
  echo "    context7 MCP + taste-skill, typescript-lsp, php-lsp plugins done"
else
  echo "    claude CLI not found — run the commands in EFFICIENCY_STACK.md manually"
fi

echo ""
echo "Done. Installed:"
echo "  - $(ls "$KIT"/agents/*.md | wc -l | tr -d ' ') agents -> ~/.claude/agents/"
echo "  - $(ls -d "$KIT"/skills/*/ | wc -l | tr -d ' ') skills -> ~/.claude/skills/ (+ gsap/threejs/motion/shader/web sets)"
echo "  - $(ls "$KIT"/commands/*.md | wc -l | tr -d ' ') commands: /onboard /task /worker /build /genesis /rootcause /ship"
echo ""
echo "Restart Claude Code to pick up the commands."
echo ""
echo "Already installed on this machine before? Run migrate.sh to clean up ECC:"
echo "  ~/.claude/universal-kit/migrate.sh"
