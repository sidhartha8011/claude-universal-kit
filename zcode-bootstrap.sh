#!/usr/bin/env bash
# Install the universal kit's skills (and commands, best-effort) into ZCode.
# ~/.claude/universal-kit stays the canonical source; ZCode gets symlinks, so
# a `git pull` here updates ZCode too.
# Usage: ~/.claude/universal-kit/zcode-bootstrap.sh
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
ZDIR="$HOME/.zcode"
ZSKILLS="$ZDIR/skills"
ZCMDS="$ZDIR/commands"
CLAUDE_SKILLS="$HOME/.claude/skills"

[ -d "$ZDIR" ] || { echo "No $ZDIR — install ZCode first (zcode.z.ai)." >&2; exit 1; }
mkdir -p "$ZSKILLS" "$ZCMDS"

echo "==> Skills -> $ZSKILLS"
n=0
# Kit-owned skills
for d in "$KIT"/skills/*/; do
  [ -f "${d}SKILL.md" ] || continue
  ln -sfn "${d%/}" "$ZSKILLS/$(basename "$d")"; n=$((n+1))
done
# Frontend animation / 3D sets pulled in by bootstrap.sh (skip if absent)
for d in "$CLAUDE_SKILLS"/gsap-skills-repo/skills/*/ \
         "$CLAUDE_SKILLS"/threejs-skills-repo/skills/*/ \
         "$CLAUDE_SKILLS"/chrome-web-repo/skills/modern-web-guidance/ \
         "$CLAUDE_SKILLS"/motion-dev-repo/ \
         "$CLAUDE_SKILLS"/minimax-skills-repo/skills/shader-dev/; do
  [ -f "${d}SKILL.md" ] || continue
  ln -sfn "${d%/}" "$ZSKILLS/$(basename "${d%/}")"; n=$((n+1))
done
# Skills that arrived as Claude Code plugins (taste-skill etc.) — still plain
# SKILL.md dirs, so ZCode can use them directly.
while IFS= read -r f; do
  d="$(dirname "$f")"
  ln -sfn "$d" "$ZSKILLS/$(basename "$d")"; n=$((n+1))
done < <(find "$HOME/.claude/plugins/cache" -maxdepth 7 -name SKILL.md 2>/dev/null)
echo "    $n skills linked"

echo "==> Commands -> $ZCMDS (best-effort; ZCode's command path is undocumented)"
cp "$KIT"/commands/*.md "$ZCMDS/" 2>/dev/null && \
  echo "    $(ls "$ZCMDS"/*.md | wc -l | tr -d ' ') copied" || echo "    none copied"

cat <<EOF

Done.
  Skills:   $ZSKILLS  ($n)   — confirmed path, SKILL.md format
  Commands: $ZCMDS            — unverified path; if ZCode ignores them, add the
                                ones you want through its Settings -> Commands UI

In ZCode: Settings -> Skills -> Refresh, then check the skills appear and are enabled.

Note: /task-glm and /task-glm-support are Claude-side commands (they shell out
to GLM). Inside ZCode you are already on GLM, so use /task directly.
EOF
