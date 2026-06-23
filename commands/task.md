---
description: Work on a task with the codebase map as context
argument-hint: <task description>
---

Read `.claude/CODEBASE_MAP.md`, the project CLAUDE.md, and recent entries of
`.claude/SESSION_LOG.md`. If there is no map, tell me to run /onboard and stop.

Do the task below to mergeable quality, following the project's conventions.
Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. If reality contradicts the map, update the map.

**Specialist selection — activate the right expert for the work:**
- Frontend / UI / components → use `frontend-developer` + `ui-visual-validator` to build and visually verify
- Styling, UX, design quality → also apply `ui-ux-pro-max` for layout and interaction patterns
- New feature with non-trivial architecture → consult `architect-review` before writing code
- Auth, payments, user data, file uploads, or any external input → run `security-auditor` alongside
- Database schema or query work → use `sql-pro`
- Performance concern → use `performance-engineer`
- PHP/WordPress → use `php-pro`
- Testing required → use `test-automator` to write tests alongside the change
- Blog posts, LinkedIn, Twitter/X, newsletters, carousels, brand copy → use `content-marketing` skill (research → draft → repurpose → checklist pipeline)

For small single-file changes work inline. For anything touching 3+ files or
needing visual verification, spawn the relevant specialist as a subagent.

When done, report what changed, which specialists were used, and how you verified it.
Append a short entry to `.claude/SESSION_LOG.md`.

TASK: $ARGUMENTS
