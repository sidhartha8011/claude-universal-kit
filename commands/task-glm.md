---
description: Run the task on GLM from here (no terminal switching) — GLM uses the full kit, Claude verifies
argument-hint: <task description>
---

Goal: the task below runs end-to-end on GLM via
`~/.claude/universal-kit/glm-worker.sh`, driven from this session — you never
switch to a terminal. GLM's work bills to Z.AI, not the Claude plan.

The worker is itself a full Claude Code session: same commands, skills,
agents, and project files. So do **not** summarise the codebase into the
brief — hand it `/task` and let it read the map itself. Your cost is the
dispatch plus the review, not a briefing.

**0 — Resolve paths.** Use `.agent/` if it exists, else `.claude/`; call it
`$A`. Confirm `$A/CODEBASE_MAP.md` exists; if not, tell me to run /onboard
and stop. Note the current git state so you can diff against it later.

**1 — Write the dispatch file** `$A/glm-run-r1.md` containing exactly:

```
/task <the task, verbatim from my request>
```

Add lines below it only for what the map does not already say — lane
boundaries, files that must not be touched, an unusual acceptance command.
Anything already in `CODEBASE_MAP.md` or `CLAUDE.md` is redundant: the
worker reads them itself.

**2 — Dispatch in the background.** A real task exceeds the Bash tool's
10-minute ceiling, so never run it in the foreground:

```
GLM_WORKER_CONTRACT=task ~/.claude/universal-kit/glm-worker.sh -f $A/glm-run-r1.md > $A/glm-run-r1.log 2>&1; echo "EXIT=$?" >> $A/glm-run-r1.log
```

Run with `run_in_background: true`, then poll the log until an `EXIT=` line
appears. Tell me it started and what it's doing; don't sit silent.

**3 — Check the exit code first.** Non-zero, or no `EXIT=` line, means the
run died (missing key, 401, z.ai quota exhausted — Lite is ~80 prompts/5h,
network drop). A half-applied diff is not delivered work: report the failure
with `git status` and stop.

**4 — Verify independently.** The worker's report is a claim, not evidence —
it has been observed asserting compliance for files it never wrote, and
satisfying goals via workarounds that passed every automated check. So:
`git diff` for what actually changed, `ls` any artifact it claims to have
created, re-run the acceptance checks yourself, and **read the diff** for
missing requirements, scope creep, dropped conventions, and
security-sensitive touches. The diff read is the only thing that catches a
workaround.

**5 — Done gate.** Dispatch `spec-verifier` (fresh context, strongest model)
with `$A/plan.md` and the full diff. Mandatory here: the task was authored
by a T3-tier model, and any verifier it ran on itself was also GLM.

**6 — Route fixes.** Trivial (a few lines) — fix yourself. Otherwise write
`$A/glm-run-r2.md` quoting the exact failing output, and dispatch again.
Max 3 rounds, then stop and surface what remains.

Don't commit unless I ask. Final report: what GLM built, your verification
evidence, rounds used, what you fixed by hand, and the verifier verdict.

TASK: $ARGUMENTS
