#!/usr/bin/env bash
# Install the universal working contract into any project, for any agent.
# Creates .agent/ artifacts + AGENTS.md + per-tool pointer files.
# Usage: ./install-project.sh [/path/to/project]   (defaults to cwd)
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
PROJ="$(cd "${1:-$PWD}" && pwd)"
cd "$PROJ"

mkdir -p .agent

# --- Canonical contract ---
if [ -f AGENTS.md ]; then
  echo "  AGENTS.md exists — left untouched"
else
  cp "$KIT/templates/AGENTS.md.template" AGENTS.md
  echo "  AGENTS.md created (fill in the Project specifics section)"
fi

# --- Neutral artifacts ---
[ -f .agent/CODEBASE_MAP.md ] || { cp "$KIT/templates/CODEBASE_MAP.md.template" .agent/CODEBASE_MAP.md; echo "  .agent/CODEBASE_MAP.md stub created — run /onboard to fill it"; }
[ -f .agent/SESSION_LOG.md ]  || { cp "$KIT/templates/SESSION_LOG.md.template"  .agent/SESSION_LOG.md;  echo "  .agent/SESSION_LOG.md created"; }

# --- Per-tool pointers (never overwrite an existing file) ---
point() {  # path, content
  if [ -f "$1" ]; then
    grep -q 'AGENTS.md' "$1" || echo "  ! $1 exists and does not reference AGENTS.md — add a pointer manually"
  else
    mkdir -p "$(dirname "$1")"
    printf '%s\n' "$2" > "$1"
    echo "  $1"
  fi
}

point CLAUDE.md '@AGENTS.md

Project instructions live in AGENTS.md (shared by every agent).
Artifacts: `.agent/CODEBASE_MAP.md`, `.agent/SESSION_LOG.md`, `.agent/plan.md`.'

point GEMINI.md 'See AGENTS.md for the working contract — it is the canonical
instruction file for this repo. Artifacts live in `.agent/`.'

point .github/copilot-instructions.md 'Follow the working contract in AGENTS.md at the repo root.
Read `.agent/CODEBASE_MAP.md` before exploring the codebase.'

point .clinerules 'Follow AGENTS.md at the repo root. Artifacts live in `.agent/`.'

point .cursor/rules/agents.mdc '---
description: Project working contract
alwaysApply: true
---

Follow AGENTS.md at the repo root. Read `.agent/CODEBASE_MAP.md` before
exploring; append to `.agent/SESSION_LOG.md` when done.'

echo ""
echo "Installed into $PROJ"
echo "Next: fill the 'Project specifics' section of AGENTS.md, then run /onboard"
echo "      (or ask any agent to build .agent/CODEBASE_MAP.md per AGENTS.md)."
