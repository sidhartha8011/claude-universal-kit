---
description: Claude drives, GLM executes the mechanical steps via glm-worker.sh — worker mode with Z.AI-billed labor
argument-hint: <task description>
---

Worker mode (`model-adaptation` → inverted sandwich) with GLM as the worker
pool: you hold the plan and all judgment; mechanical steps are dispatched to
`~/.claude/universal-kit/glm-worker.sh` and bill to Z.AI, not the Claude plan.

Step 0: use `.agent/` if it exists, else `.claude/` — call it `$A` and
substitute the real path throughout. Read `$A/CODEBASE_MAP.md` and recent
`$A/SESSION_LOG.md`. No map → tell me to run /onboard and stop.

Plan per `planned-execution`; every step in `$A/plan.md` gets a `route:`:
- `glm` — the default: scoped, mechanical, describable as a self-contained brief
- `opus` — multi-file coherence or careful edits (an opus worker, not you)
- `driver` — genuine judgment only, one-line justification each, ≤~20% of steps

Present the plan with routing; I approve before any edit.

Execute each `glm` step by writing its brief to `$A/brief-step<N>.md` under
the **worker brief contract**: file allowlist, the map's conventions and
gotchas for those files (the worker shares the filesystem, not the map, and
will otherwise break rules it was never shown), constraints to echo, and a
runnable acceptance check with expected output. Then:

`~/.claude/universal-kit/glm-worker.sh -f $A/brief-step<N>.md`

Always `-f` or stdin — never inline: briefs contain backticks and `$` that
your shell would execute or mangle before the worker runs. Use
`GLM_WORKER_MODEL=glm-4.7` for trivial steps. Long steps: dispatch in the
background to a log and poll, since the Bash tool caps at 10 minutes.

Verify every step before dispatching the next — check the exit code, then
`git diff` for what actually changed and `ls` any artifact the brief
required. The constraint echo is a claim, not evidence. Reject guard
violations. Escalate upward, never silently: a step that fails twice on GLM
goes to an `opus` worker; twice more, you execute it.

If any check fails, retry per `grounded-loops` — quoted evidence, max 3.
Done gate: dispatch `spec-verifier` with `$A/plan.md` and the full diff;
address P0/P1 findings, max 3 rounds, then surface what remains.

Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. Report: routing split (planned vs executed, with reroutes),
verification proof, and what was delegated vs done by you. Append to
`$A/SESSION_LOG.md`.

TASK: $ARGUMENTS
