---
description: Work on a task with the codebase map as context
argument-hint: <task description>
---

Read `.agent/CODEBASE_MAP.md` (or `.claude/CODEBASE_MAP.md`), the project
CLAUDE.md, and recent entries of `.agent/SESSION_LOG.md` (or
`.claude/SESSION_LOG.md`). If there is no map, tell me to run /onboard and stop.

Do the task below to mergeable quality, following the project's conventions.
Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. If reality contradicts the map, update the map.

**Specialist selection — activate the right expert for the work:**
- Frontend / UI / components → use `frontend-developer` + `ui-visual-validator` to build and visually verify
- Styling, UX, design quality → apply `taste-skill` (anti-generic design taste) + `ui-ux-pro-max`; polish pass with `baseline-ui`
- Accessibility or animation-heavy UI → `fixing-accessibility` / `fixing-motion-performance` before done
- Animation authoring → `motion-dev-animations` (React/Motion), `gsap-*` skills (timelines, ScrollTrigger), `modern-web-guidance` (view transitions, scroll-driven CSS)
- 3D / WebGL → `threejs-*` skills (fundamentals through postprocessing); shaders/generative → `shader-dev`
- New feature with non-trivial architecture → consult `architect-review` before writing code
- Auth, payments, user data, file uploads, or any external input → run `security-auditor` alongside
- Database schema or query work → use `sql-pro`
- Performance concern → use `performance-engineer`
- PHP/WordPress → use `php-pro`
- Testing required → use `test-automator` to write tests alongside the change
- Blog posts, LinkedIn, Twitter/X, newsletters, carousels, brand copy → use `content-marketing` skill (research → draft → repurpose → checklist pipeline)

For small single-file changes work inline. For anything touching 3+ files or
needing visual verification, spawn the relevant specialist as a subagent.

If a check fails, load `grounded-loops` before retrying — quote the exact
failing output into the next attempt, and cap at 3 before changing approach.

Back every "it works" claim with the command output that proves it. Report
what changed, which specialists were used, and how you verified it. Append a
short entry to `.agent/SESSION_LOG.md` (or `.claude/SESSION_LOG.md`).

TASK: $ARGUMENTS
