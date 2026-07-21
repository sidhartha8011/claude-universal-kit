---
description: Worker-mode task — strong model drives, delegates labor to opus/sonnet workers by plan-time routing
argument-hint: <task description>
---

Step 0: load `model-adaptation`. This command assumes the session runs on a
strong model (Fable/Opus) — if the current model is Sonnet-tier, say so and
ask me to switch before proceeding.

Read `.agent/CODEBASE_MAP.md` (or `.claude/CODEBASE_MAP.md`), the project CLAUDE.md, and recent
`.agent/SESSION_LOG.md` (or `.claude/SESSION_LOG.md`) entries. If there is no map, tell me to run
/onboard and stop.

Plan per `planned-execution`, and **route every step at plan time** — each
step in `plan.md` gets a `route:` field:

- `sonnet` — scoped, mechanical, single-file (the default)
- `opus` — multi-file coherence or careful edits (an opus WORKER, not you)
- `driver` — only for genuine judgment calls, and each needs a one-line
  justification in the plan

Hard budget: at most ~20% of steps route to `driver`. If more, the
decomposition is too coarse — split steps until they're delegable. Present
`plan.md` with the routing column; I approve the split before any edit.

Execute as the driver: you hold `plan.md` and all judgment; you never
delegate planning, review, or debugging. Dispatch each step to its routed
worker (Agent tool, `model:` per route) with a self-contained brief under
the **worker brief contract**: file allowlist, constraints to echo,
full-diff return, runnable acceptance check with verbatim output. Briefs
name the specialist skills the worker must load (e.g. `taste-skill` +
`gsap-scrolltrigger` for an animated section; `threejs-*` for 3D) — a
worker doesn't know the roster, the brief tells it. Verify
each result against its check before the next; reject guard violations.
Reroute on failure: sonnet fails twice → re-dispatch to opus; opus fails
twice → driver executes. Never quietly take over a step that hasn't
failed — mid-flight route changes go through an updated plan.md.

If any check fails, retry per `grounded-loops` — max 3, evidence-quoted.
Done gate: dispatch `spec-verifier` with `plan.md` and the full diff;
address P0/P1 findings, max 3 rounds, then surface what remains.

Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. Report per the evidence-grounded-progress invariant: what
changed, the actual routing split (planned vs executed, with any reroutes),
and verification proof. Append a short entry to `.agent/SESSION_LOG.md` (or `.claude/SESSION_LOG.md`).

TASK: $ARGUMENTS
