---
description: Work on a task with the codebase map as context
argument-hint: <task description>
---

Step 0: load the `model-adaptation` skill and note the active tier (T1/T2/T3).
Apply its universal invariants for the rest of this session.

Read `.claude/CODEBASE_MAP.md`, the project CLAUDE.md, and recent entries of
`.claude/SESSION_LOG.md`. If there is no map, tell me to run /onboard and stop.

On T2/T3: if the change is not describable in one sentence, load
`planned-execution` and produce `plan.md` before editing any file. On T1:
state goal, constraints, and per-change verification, then act.

If the task says "plan only": produce `plan.md` (per `planned-execution`
Phase 1–2, on any tier), present it, and stop — this is the
frontier-sandwich handoff; I may switch the session to a cheaper model
before saying continue. "Continue executing plan.md" resumes at Phase 4.

Do the task below to mergeable quality, following the project's conventions.
Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. If reality contradicts the map, update the map.

**Specialist selection — activate the right expert for the work:**
- Frontend / UI / components → use `frontend-developer` + `ui-visual-validator` to build and visually verify
- Styling, UX, design quality → apply `taste-skill` (anti-generic design taste) + `ui-ux-pro-max`; polish pass with `baseline-ui`
- Accessibility or animation-heavy UI → `fixing-accessibility` / `fixing-motion-performance` before done
- New feature with non-trivial architecture → consult `architect-review` before writing code
- Auth, payments, user data, file uploads, or any external input → run `security-auditor` alongside
- Database schema or query work → use `sql-pro`
- Performance concern → use `performance-engineer`
- PHP/WordPress → use `php-pro`
- Testing required → use `test-automator` to write tests alongside the change
- Blog posts, LinkedIn, Twitter/X, newsletters, carousels, brand copy → use `content-marketing` skill (research → draft → repurpose → checklist pipeline)

For small single-file changes work inline. For anything touching 3+ files or
needing visual verification, spawn the relevant specialist as a subagent.

If any check fails, load `grounded-loops` before retrying — no ungrounded
second attempts. If execution on a T2 model accumulates 2+ verifier
rejections or escalations, stop and recommend worker mode
(`model-adaptation` → inverted sandwich) instead of grinding.

Done gate (multi-step tasks, T2/T3; on T1 only for high-stakes changes): the
task is not done when the implementer says so. Dispatch the `spec-verifier`
agent with the plan/spec excerpt and the diff; address every P0/P1 finding
and re-dispatch — max 3 rounds, then stop and surface the remaining findings
to me.

Apply the evidence-grounded-progress invariant to the final report: what
changed, which specialists were used, and how you verified it. Append a
short entry to `.claude/SESSION_LOG.md`.

TASK: $ARGUMENTS
