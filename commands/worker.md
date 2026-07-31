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

Budget: at most ~20% of steps route to `driver`. This is a **cost control,
not a quality bar** — fan-out measures at 2.6–5.9× the tokens and is never
faster, so it only pays when worker tokens are meaningfully cheaper than
driver tokens (sonnet/GLM absorbing labor). If quota isn't the constraint,
say so and recommend plain /task instead of forcing the split. Present
`plan.md` with the routing column; I approve before any edit.

Execute as the driver: you hold `plan.md` and all judgment; you never
delegate planning, review, or debugging. Dispatch each step to its routed
worker (Agent tool, `model:` per route) with a self-contained brief under
the **worker brief contract**: file allowlist, constraints to echo,
full-diff return, runnable acceptance check with verbatim output. Derive
the allowlist from `graphify affected "<symbol>"` when `graphify-out/`
exists (see `codebase-graph`) — that is the real blast radius, and a
worker told exactly which files are in play cannot wander into ones that
aren't. Briefs
name the specialist skills the worker must load (e.g. `taste-skill` +
`gsap-scrolltrigger` for an animated section; `threejs-*` for 3D) — a
worker doesn't know the roster, the brief tells it. Verify
each result against its check before the next; reject guard violations.
Reroute on failure: sonnet fails twice → re-dispatch to opus; opus fails
twice → driver executes. Never quietly take over a step that hasn't
failed — mid-flight route changes go through an updated plan.md.

If any check fails, retry per `grounded-loops` — max 3, evidence-quoted.
Done gate: dispatch `spec-verifier` with `plan.md` and the full diff **when
workers wrote the code** — verifying another model's output is not
self-verification and still pays. If you executed the steps yourself on a
frontier model, skip it: you already verify as you go, and a subagent that
re-checks your own work is pure cost (`model-adaptation` → T1 restraint).
Either way, address P0/P1 findings, max 3 rounds, then surface what remains.

Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. Report per the evidence-grounded-progress invariant: what
changed, the actual routing split (planned vs executed, with any reroutes),
and verification proof. Append a short entry to `.agent/SESSION_LOG.md` (or `.claude/SESSION_LOG.md`).

TASK: $ARGUMENTS
