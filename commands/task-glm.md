---
description: Delegate the COMPLETE task to GLM (Z.AI billing) — Claude briefs, verifies, and routes fixes back
argument-hint: <task description>
---

Goal: planning AND execution of the task below run on GLM via
`~/.claude/universal-kit/glm-worker.sh`. GLM's work bills to Z.AI, not the
Claude plan. Your cost is the brief plus one full-diff review per round
(up to 3) — roughly a third to half of doing it yourself, not a twentieth.

**0 — Resolve paths.** Use `.agent/` if it exists, else `.claude/`. Call it
`$A` below and substitute the real path everywhere — never emit a literal
`.agent/` into the brief without checking. Read `$A/CODEBASE_MAP.md` and
recent `$A/SESSION_LOG.md`. No map → tell me to run /onboard and stop.

**1 — Compose the brief** (where your intelligence goes). Write
`$A/glm-brief-r1.md` — round-numbered, so fix rounds never overwrite the
brief you verified against. It must be fully self-contained; the worker
shares the filesystem, not this conversation. Include:
- the task restated precisely, with acceptance criteria you define
- exact file paths, plus **the map's conventions and gotchas for those
  files** — unshown rules get violated
- scope boundary: which directories/files are in play, and that satisfying
  the goal by other means (side effects, moving behaviour elsewhere) is a
  violation, not a solution
- write `$A/plan.md` first — numbered steps, files touched, verification
  command each; append-only, never rewritten to look complete
- minimal diff, reuse-first ladder, no narration comments, and 3 lines
  appended to `$A/SESSION_LOG.md` at the end
- the overall acceptance check command whose output proves the task works
- write briefs at T3 scaffolding level: explicit steps, named paths

**2 — Dispatch in the background.** A whole-task run exceeds the Bash tool's
10-minute ceiling, so never call it in the foreground:
`~/.claude/universal-kit/glm-worker.sh -f $A/glm-brief-r1.md > $A/glm-run-r1.log 2>&1; echo "EXIT=$?" >> $A/glm-run-r1.log`
Run that with `run_in_background: true`, then poll the log until it ends.
Use `-f` (or stdin) — never pass a brief inline; briefs contain backticks
and `$` that your shell would expand or execute before the worker sees them.

**3 — Check the exit code first.** Non-zero, or no `EXIT=` line, means the
run died (missing key, 401, z.ai quota exhausted — Lite is ~80 prompts/5h,
network drop). Do not interpret a half-applied diff as delivered work:
report the failure with `git status` and stop.

**4 — Verify independently.** The worker's self-report is a claim, not
evidence — it has been observed asserting compliance for files it never
created, and satisfying goals via workarounds that pass every automated
check. So: `ls` the required artifacts, `git diff` for what actually
changed, re-run the acceptance checks yourself, and **read the diff** for
missing requirements, scope creep, dropped conventions, and
security-sensitive touches. The diff review is the only thing that catches
a workaround.

**5 — Done gate.** Dispatch `spec-verifier` (fresh context, strongest model)
with `$A/plan.md` and the full diff. This is mandatory here, not optional:
the whole task was authored by a T3-tier model with no per-step checkpoint.

**6 — Route fixes.** Trivial (a few lines) — fix yourself. Otherwise write
`$A/glm-brief-r2.md` quoting the exact failing output/finding, and dispatch
again. Max 3 rounds total, then stop and surface what remains.

Don't commit unless I ask. Final report: what GLM built, your verification
evidence, rounds used, what you fixed by hand, and the verifier verdict.

TASK: $ARGUMENTS
