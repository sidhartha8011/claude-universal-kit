#!/usr/bin/env bash
# GLM worker — runs one self-contained brief on GLM-5.2, headlessly.
#
# The point: a Claude session (driver, Max plan) delegates mechanical labor to
# GLM (Z.AI billing) by calling this via Bash. Claude keeps the judgment, GLM
# does the typing, and the work happens in the same project directory.
#
# Usage:
#   glm-worker.sh "the brief text"
#   glm-worker.sh -f brief.md
#   GLM_WORKER_MODEL=glm-4.7 glm-worker.sh "..."     # cheaper tier
#   GLM_WORKER_MODE=bypassPermissions glm-worker.sh "..."   # full autonomy
set -euo pipefail

KEYFILE="$HOME/.claude/.glm-key"
MODEL="${GLM_WORKER_MODEL:-glm-5.2}"
MODE="${GLM_WORKER_MODE:-acceptEdits}"
TOOLS="${GLM_WORKER_TOOLS:-Read Edit Write Grep Glob Bash}"

usage() { echo "Usage: glm-worker.sh \"brief\"  |  glm-worker.sh -f brief.md" >&2; exit 1; }

if [ "${1:-}" = "-f" ]; then
  [ -f "${2:-}" ] || { echo "No such brief file: ${2:-}" >&2; exit 1; }
  BRIEF="$(cat "$2")"
elif [ -n "${1:-}" ]; then
  BRIEF="$*"
else
  usage
fi

[ -f "$KEYFILE" ] || { echo "Missing $KEYFILE — put your Z.AI key in it (chmod 600)." >&2; exit 1; }
KEY="$(tr -d '[:space:]' < "$KEYFILE")"
[ -n "$KEY" ] || { echo "$KEYFILE is empty." >&2; exit 1; }

# The worker brief contract, enforced at the system-prompt level so every
# delegated brief is armored whether or not the driver remembered to say so.
CONTRACT='You are a worker executing one scoped brief inside an existing project.

Rules you must follow:
1. FILE ALLOWLIST — touch only the files the brief names. If the change seems
   to need another file, stop and output "BLOCKED: needs <file>". Never improvise.
2. CONSTRAINT ECHO — end your output by restating each constraint from the brief
   and how your work satisfies it. For code, state which rung of the ladder you
   stopped at (exists? / reuse? / stdlib? / native? / installed dep? / one line?
   / minimum impl) and why higher rungs did not hold.
3. DIFF SCOPE — no reformatting, no drive-by refactors, no "improvements"
   outside the brief. No narration comments: a comment survives only if it
   states a constraint the code cannot show (why, never what).
4. ACCEPTANCE CHECK — run the verification command the brief gives you and
   include its verbatim output. A completion claim without command output is
   not done. If it fails, say so with the output; never edit tests to pass.

Be concise. Report what changed, the check output, and the constraint echo.'

# The Desktop app injects OAuth-refresh vars into child processes; if they
# survive, the subprocess authenticates with OAuth and sends it to z.ai (401).
exec env \
  -u CLAUDE_CODE_SDK_HAS_OAUTH_REFRESH \
  -u CLAUDE_CODE_SDK_HAS_HOST_AUTH_REFRESH \
  -u CLAUDE_CODE_OAUTH_SCOPES \
  -u CLAUDE_CODE_ENTRYPOINT \
  -u CLAUDE_CODE_CHILD_SESSION \
  -u CLAUDECODE \
  -u ANTHROPIC_AUTH_TOKEN \
  ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
  ANTHROPIC_API_KEY="$KEY" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$MODEL" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$MODEL" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7" \
  API_TIMEOUT_MS="3000000" \
  claude -p "$BRIEF" \
    --append-system-prompt "$CONTRACT" \
    --permission-mode "$MODE" \
    --allowedTools $TOOLS
