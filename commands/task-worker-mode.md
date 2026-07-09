---
description: Worker-mode task — strong model drives, Sonnet subagents execute armored briefs
argument-hint: <task description>
---

Step 0: load `model-adaptation`. This command assumes the session runs on a
strong model (Fable/Opus) — if the current model is Sonnet-tier, say so and
ask me to switch before proceeding.

Read `.claude/CODEBASE_MAP.md`, the project CLAUDE.md, and recent
`.claude/SESSION_LOG.md` entries. If there is no map, tell me to run
/onboard and stop.

Plan per `planned-execution`: write `plan.md`, present it, wait for my
confirmation.

Then execute in worker mode (`model-adaptation` → inverted sandwich):
you are the driver — you hold `plan.md` and all judgment, and you never
delegate planning, review, or debugging. For each mechanical step,
dispatch a `sonnet` subagent with a self-contained brief following the
**worker brief contract**: file allowlist, constraints to echo, full-diff
return, runnable acceptance check with verbatim output. Verify each result
against its check before dispatching the next; reject any guard violation.
A brief that fails twice, execute yourself. Steps needing multi-file
coherence or judgment: execute yourself, don't delegate.

If any check fails, retry per `grounded-loops` — max 3, evidence-quoted.
Done gate: dispatch `spec-verifier` with `plan.md` and the full diff;
address P0/P1 findings, max 3 rounds, then surface what remains.

Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. Report per the evidence-grounded-progress invariant: what
changed, which steps were delegated vs done by you, verification proof.
Append a short entry to `.claude/SESSION_LOG.md`.

TASK: $ARGUMENTS
