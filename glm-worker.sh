#!/usr/bin/env bash
# GLM worker — runs a brief on GLM-5.2 headlessly, in the current directory.
#
# A Claude session (driver, Max plan) delegates labor to GLM (Z.AI billing)
# by calling this via Bash. Claude keeps the judgment; GLM does the typing.
#
# Usage — prefer a FILE or STDIN; briefs contain backticks, $ and quotes that
# the CALLER's shell would expand before this script ever runs:
#   glm-worker.sh -f brief.md
#   glm-worker.sh - < brief.md          # or: heredoc | glm-worker.sh -
#   glm-worker.sh "short single-line brief"    # only when it has no ` $ " \
#
# Env:
#   GLM_WORKER_MODEL     glm-5.2 (default) | glm-4.7
#   GLM_WORKER_CONTRACT  step (default) — one scoped brief, file allowlist
#                        task           — whole task, directory scope + plan
#   GLM_WORKER_MODE      acceptEdits (default) | bypassPermissions | manual
#   GLM_WORKER_TOOLS     override the allowed-tool list
#   GLM_WORKER_TIMEOUT   seconds; 0 = none (default 0)
set -euo pipefail

KEYFILE="$HOME/.claude/.glm-key"
MODEL="${GLM_WORKER_MODEL:-glm-5.2}"
MODE="${GLM_WORKER_MODE:-acceptEdits}"
KIND="${GLM_WORKER_CONTRACT:-step}"
TIMEOUT="${GLM_WORKER_TIMEOUT:-0}"
read -r -a TOOLS <<< "${GLM_WORKER_TOOLS:-Read Edit Write Grep Glob Bash}"
[ "${#TOOLS[@]}" -gt 0 ] || { echo "GLM_WORKER_TOOLS is empty." >&2; exit 2; }

# Capabilities a scoped worker must never reach: spawning its own subagents,
# scheduling, or spending money through MCP media/generation servers.
# --strict-mcp-config drops every inherited MCP server.
# --allowedTools is an auto-approve list, NOT a sandbox: anything absent from
# it still exists. --disallowedTools is the real boundary, so name everything
# a scoped worker must not reach. --strict-mcp-config separately drops every
# inherited MCP server (paid media/generation ones included).
DISALLOWED=(
  Agent Task Workflow                                   # no spawning its own fleet
  TaskCreate TaskGet TaskList TaskOutput TaskStop TaskUpdate Monitor
  CronCreate CronDelete CronList ScheduleWakeup RemoteTrigger
  EnterWorktree ExitWorktree DesignSync NotebookEdit
  SendMessage PushNotification ReportFindings
)

usage() { sed -n '4,12p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

case "${1:-}" in
  -f) [ -f "${2:-}" ] || { echo "No such brief file: ${2:-}" >&2; exit 2; }
      BRIEF="$(cat "$2")" ;;
  -)  BRIEF="$(cat)" ;;
  "") usage ;;
  *)  BRIEF="$*" ;;
esac
[ -n "${BRIEF//[[:space:]]/}" ] || { echo "Brief is empty." >&2; exit 2; }

[ -f "$KEYFILE" ] || { echo "Missing $KEYFILE — put your Z.AI key in it (chmod 600)." >&2; exit 2; }
KEY="$(tr -d '[:space:]' < "$KEYFILE")"
[ -n "$KEY" ] || { echo "$KEYFILE is empty." >&2; exit 2; }

COMMON='
2. CONSTRAINT ECHO — end your output by restating each constraint from the
   brief and how your work satisfies it. For code, state which rung of the
   ladder you stopped at (needed at all? / reuse existing? / stdlib? /
   native platform? / installed dep? / one line? / minimum impl) and why
   higher rungs did not hold. Claims you cannot back with a command are
   claims, not evidence — say so plainly rather than asserting compliance.
3. DIFF SCOPE — no reformatting, no drive-by refactors, no "improvements"
   beyond the brief. No narration comments: a comment survives only if it
   states a constraint the code cannot show (why, never what).
4. ACCEPTANCE CHECK — run the verification command the brief gives you and
   include its verbatim output. A completion claim without command output is
   not done. If it fails, say so with the output; never edit tests to pass.
Be concise. Report what changed, the check output, and the constraint echo.'

if [ "$KIND" = "task" ]; then
  CONTRACT="You are executing a complete task inside an existing project, from a brief.

1. SCOPE — work only inside this project directory and only on what the brief
   asks for. Write the plan file the brief names FIRST (numbered steps, each
   with files touched and its verification command), then execute step by
   step, marking a step done only after its check passes. The plan file is
   append-only: never delete or rewrite earlier steps to make state look
   complete. If the task cannot be done within the stated scope, stop and
   output \"BLOCKED: <what you need>\" — do not satisfy the goal by other
   means (no import-time side effects, no moving behaviour into another
   module, no creative workarounds). An unstated convention is not
   permission.$COMMON"
else
  CONTRACT="You are a worker executing one scoped brief inside an existing project.

1. FILE ALLOWLIST — touch only the files the brief names. If the goal cannot
   be achieved within them, stop and output \"BLOCKED: needs <file>\" with one
   line on why. Do NOT satisfy the goal by other means: no import-time side
   effects, no moving behaviour into a different module, no creative
   workarounds. Routing around the constraint is a violation, not a solution.
   An unstated convention is not permission — if the brief does not say you
   may add output, logging, or startup behaviour to a module, you may not.$COMMON"
fi

# The Desktop app injects OAuth-refresh vars into child processes; if they
# survive, the subprocess authenticates with OAuth and z.ai rejects it (401).
run() {
  env \
    -u CLAUDE_CODE_SDK_HAS_OAUTH_REFRESH \
    -u CLAUDE_CODE_SDK_HAS_HOST_AUTH_REFRESH \
    -u CLAUDE_CODE_OAUTH_SCOPES \
    -u CLAUDE_CODE_ENTRYPOINT \
    -u CLAUDE_CODE_CHILD_SESSION \
    -u CLAUDE_CODE_SESSION_ID \
    -u CLAUDECODE \
    -u ANTHROPIC_AUTH_TOKEN \
    -u ANTHROPIC_MODEL \
    ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
    ANTHROPIC_API_KEY="$KEY" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="$MODEL" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="$MODEL" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="$MODEL" \
    API_TIMEOUT_MS="3000000" \
    claude -p "$BRIEF" \
      --model "$MODEL" \
      --append-system-prompt "$CONTRACT" \
      --permission-mode "$MODE" \
      --strict-mcp-config \
      --allowedTools "${TOOLS[@]}" \
      --disallowedTools "${DISALLOWED[@]}" \
      < /dev/null
}

if [ "${TIMEOUT:-0}" -gt 0 ] 2>/dev/null; then
  run & pid=$!
  ( sleep "$TIMEOUT"; kill -TERM "$pid" 2>/dev/null ) & watchdog=$!
  wait "$pid"; rc=$?
  kill "$watchdog" 2>/dev/null || true
  exit "$rc"
fi
run
