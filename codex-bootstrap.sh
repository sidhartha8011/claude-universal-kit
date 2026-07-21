#!/usr/bin/env bash
# Codex adapter for Claude Universal Kit.
# Keeps ~/.claude/universal-kit as the canonical source, while exposing the
# kit's skills and workflow prompts to Codex under ~/.codex.
# Usage: ~/.claude/universal-kit/codex-bootstrap.sh
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"
CODEX_SKILLS_DIR="$CODEX_DIR/skills"
CODEX_PROMPTS_DIR="$CODEX_DIR/prompts/universal-kit"

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills"
mkdir -p "$CODEX_SKILLS_DIR" "$CODEX_PROMPTS_DIR"

echo "==> 1/5 Cloning source libraries (skipped if present)"
clone() {
  local url="$1"
  local dest="$CLAUDE_DIR/skills/$2"
  if [ -d "$dest/.git" ]; then
    echo "    $2 exists, pulling latest"
    git -C "$dest" pull --quiet || true
  else
    git clone --depth 1 --quiet "$url" "$dest"
    echo "    cloned $2"
  fi
}

clone https://github.com/anthropics/skills.git anthropic-skills-repo
clone https://github.com/wshobson/agents.git wshobson-agents
clone https://github.com/hesreallyhim/awesome-claude-code.git awesome-claude-code
clone https://github.com/greensock/gsap-skills.git gsap-skills-repo
clone https://github.com/CloudAI-X/threejs-skills.git threejs-skills-repo
clone https://github.com/GoogleChrome/modern-web-guidance.git chrome-web-repo
clone https://github.com/199-biotechnologies/motion-dev-animations-skill.git motion-dev-repo
clone https://github.com/MiniMax-AI/skills.git minimax-skills-repo

echo "==> 2/5 Installing kit agents + commands in ~/.claude"
for f in "$KIT"/agents/*.md; do
  ln -sf "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

for f in "$KIT"/commands/*.md; do
  ln -sf "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
  ln -sf "$f" "$CODEX_PROMPTS_DIR/$(basename "$f")"
done

echo "==> 3/5 Exposing kit skills to Codex"
for d in "$KIT"/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "${d%/}" "$CLAUDE_DIR/skills/$name"
  ln -sfn "${d%/}" "$CODEX_SKILLS_DIR/$name"
done

echo "==> 4/5 Exposing optional source-library skills if present"
link_optional_skill() {
  local source="$1"
  local name="$2"
  if [ -f "$source/SKILL.md" ]; then
    ln -sfn "$source" "$CLAUDE_DIR/skills/$name"
    ln -sfn "$source" "$CODEX_SKILLS_DIR/$name"
    echo "    linked $name"
  fi
}

for d in "$CLAUDE_DIR"/skills/gsap-skills-repo/skills/*/ "$CLAUDE_DIR"/skills/threejs-skills-repo/skills/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name="$(basename "$d")"
  ln -sfn "${d%/}" "$CODEX_SKILLS_DIR/$name"
done

link_optional_skill "$CLAUDE_DIR/skills/chrome-web-repo/skills/modern-web-guidance" "modern-web-guidance"
link_optional_skill "$CLAUDE_DIR/skills/motion-dev-repo" "motion-dev-animations"
link_optional_skill "$CLAUDE_DIR/skills/minimax-skills-repo/skills/shader-dev" "shader-dev"

echo "==> 5/5 Regenerating AGENT_INDEX.md"
"$KIT/regen-index.sh"

cat > "$CODEX_PROMPTS_DIR/README.md" <<'EOF'
# Universal Kit Prompts for Codex

Codex does not currently load Claude Code slash commands directly. These files
are the same workflow prompts from `~/.claude/universal-kit/commands/`.

Use them by asking Codex naturally:

- "Use the universal-kit onboard workflow for this repo."
- "Use the universal-kit task workflow: <task>"
- "Use the universal-kit ship workflow."

Keep project memory in `.claude/CODEBASE_MAP.md` and `.claude/SESSION_LOG.md`
so Claude Code and Codex can share the same repository context.
EOF

echo ""
echo "Done. Codex can now discover:"
echo "  - $(ls -d "$KIT"/skills/*/ | wc -l | tr -d ' ') kit skills -> ~/.codex/skills/"
echo "  - workflow prompts -> ~/.codex/prompts/universal-kit/"
echo "  - shared project memory remains in .claude/CODEBASE_MAP.md and .claude/SESSION_LOG.md"
echo ""
echo "Restart Codex to refresh the available skill list."
