---
description: Claude drives, GLM executes the mechanical steps via glm-worker.sh — worker mode with Z.AI-billed labor
argument-hint: <task description>
---

Worker mode (`model-adaptation` → inverted sandwich), with GLM as the
worker pool: you (Claude) hold the plan and all judgment; every mechanical
step is dispatched to `~/.claude/universal-kit/glm-worker.sh` and bills to
Z.AI instead of the Claude plan.

Read `.agent/CODEBASE_MAP.md` (or `.claude/CODEBASE_MAP.md`) and recent
`SESSION_LOG.md` entries. If there is no map, tell me to run /onboard and stop.

Plan per `planned-execution` — every step in `plan.md` gets a `route:` field:
- `glm` — the default: scoped, mechanical, describable as a self-contained brief
- `driver` — genuine judgment calls only, one-line justification each,
  ≤~20% of steps

Present the plan with routing; I approve before any edit.

Execute: for each `glm` step, write a brief under the **worker brief
contract** (file allowlist, constraints to echo, runnable acceptance check
with expected output, all needed context inline) and run:
`~/.claude/universal-kit/glm-worker.sh "<brief>"` (or `-f` for long briefs;
`GLM_WORKER_MODEL=glm-4.7` for trivial steps). Verify each step before
dispatching the next — the worker's constraint echo is a claim, not
evidence (it has been observed claiming to write files it never created).
Check `git diff` for what actually changed and `ls` any artifact the brief
required; re-run the acceptance command yourself if it matters. Reject
guard violations. A step that fails twice on GLM, execute yourself — never
quietly take over a step that hasn't failed.

If any check fails, retry per `grounded-loops` — quoted evidence, max 3.
Done gate: dispatch `spec-verifier` with `plan.md` and the full diff;
address P0/P1 findings, max 3 rounds, then surface what remains.

Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. Report: routing split (planned vs executed), verification
proof, and what was delegated vs done by you. Append to SESSION_LOG.

TASK: $ARGUMENTS
