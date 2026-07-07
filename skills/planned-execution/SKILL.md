---
name: planned-execution
description: Load for any multi-file or multi-step task on T2/T3-tier models (per model-adaptation) before touching any file. Skip when the diff can be described in one sentence.
---

# Planned Execution

**Rule 0 — gate:** if you could describe the complete diff in one sentence, skip this skill and just make the change.

## Phase 1 — Explore (read-only)

Read the relevant files; no edits. Output a short problem reflection as bullets: goal, inputs, outputs, constraints, edge cases. For hard problems, list 2–3 candidate approaches and rank them before committing — postpone direct decisions until the options are on the table.

## Phase 2 — Plan as an external artifact

Write `plan.md` — never keep the plan only in prose. Each numbered step carries:

- files touched
- exact change intent
- the verification command for that step
- status: `[todo|doing|done]`

**Hard guard:** it is unacceptable to remove or edit plan items or tests to make the state look complete.

Decomposition rules:

- **Least-to-most**: if the task has more than ~2 dependent parts, forbid one-shot attempts. Order subproblems simplest-to-hardest where each may depend on earlier answers; solve sequentially, appending each solved sub-answer before the next.
- **Upfront blueprint (ReWOO)**: when the tool sequence is predictable from the task, write the full blueprint upfront with evidence placeholders (`#E1 = Tool[input]`, `#E2 = Tool[uses #E1]`) and execute mechanically. Fall back to step-by-step only when later steps genuinely depend on unpredictable observations.

## Phase 3 — Confirm

Present `plan.md` to the user — or, in autonomous runs, to the `spec-verifier` agent — before modifying any file. Autonomy calibration: for minor choices (naming, formatting, defaults, equivalent approaches), pick a reasonable option and note it rather than asking. For scope changes or destructive actions, ask first.

## Phase 4 — Implement

Execute one plan step at a time. Run that step's verification command; mark `[done]` only on evidence; re-print remaining steps. If the command mandates a `spec-verifier` pass, only the verifier's APPROVED verdict marks a step complete — never your own claim.

## Phase 5 — Compact at boundaries

At the research→plan and plan→implement boundaries, if context utilization is climbing past ~50%, write findings into the artifact (`research.md` / `plan.md`) and continue fresh, reading only that artifact. Reviewing a 200-line plan is cheaper than a 2,000-line transcript. Pairs with `strategic-compact`.

## Tier note

On T1/frontier models, collapse all of this to goal + constraints + per-change verification criteria; drop step enumeration entirely.
