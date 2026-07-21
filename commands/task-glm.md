---
description: Delegate the COMPLETE task to GLM (Z.AI billing) — Claude only verifies at the end and routes fixes back
argument-hint: <task description>
---

Goal: the entire task below — planning AND execution — runs on GLM via
`~/.claude/universal-kit/glm-worker.sh`. You (Claude) spend tokens only on
composing the brief and on the final check. GLM's work bills to Z.AI, not
the Claude plan.

Read `.agent/CODEBASE_MAP.md` (or `.claude/CODEBASE_MAP.md`) and recent
`SESSION_LOG.md` entries. If there is no map, tell me to run /onboard and stop.

**1 — Compose the brief** (this is where your intelligence goes). Write a
fully self-contained brief to `.agent/glm-brief.md` containing:
- the task, restated precisely, with acceptance criteria you define
- the relevant map excerpts: exact file paths, conventions, gotchas — the
  worker shares the filesystem, not this conversation
- the kit contract, stated inline: write `.agent/plan.md` first (numbered
  steps, each with files + verification command), execute one step at a
  time, evidence-grounded completion, minimal diff, the reuse-first ladder,
  no narration comments, append 3 lines to `.agent/SESSION_LOG.md` when done
- the overall acceptance check command(s) whose output proves the task works

**2 — Dispatch once**, from the project root:
`~/.claude/universal-kit/glm-worker.sh -f .agent/glm-brief.md`
This blocks until GLM finishes the whole task headlessly.

**3 — Quick check** (you, on return). GLM's self-report is a claim, not
evidence — it has been observed claiming to write files it never created.
Verify independently: `ls` the artifacts the brief required (plan.md,
SESSION_LOG entry), `git status` / `git diff` for what actually changed,
and re-run the acceptance checks yourself. Then scan the diff against the
task — missing requirements, scope creep, dropped constraints,
security-sensitive touches.

**4 — Route fixes**: trivial issues (a few lines) — fix them yourself.
Anything more — write a fix brief quoting the exact failing output/finding
and dispatch to glm-worker.sh again. Max 3 rounds total; then stop and
surface what remains to me.

Constraints: don't commit unless I ask. Final report: what GLM built, your
verification evidence, rounds used, and what (if anything) you fixed by
hand. Ensure SESSION_LOG got its entry.

TASK: $ARGUMENTS
