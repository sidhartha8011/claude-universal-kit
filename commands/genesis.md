---
description: Start a brand-new project from scratch
argument-hint: <what you want to build>
---

Goal: take the idea below from zero to a working, verified MVP in this
directory.

Step 0: load the `model-adaptation` skill and apply its universal invariants
and tier rules for the whole build.

**Phase 1 — Architecture gate (one approval, then autonomous)**
Before scaffolding, present a requirements brief — MVP vs deferred, stack
with one-line reasons, data model sketch, milestone plan — and ask any
architecture-changing questions in ONE batch. That is the only approval
gate; after I approve, build autonomously.

Engage `architect-review` for this phase to validate the design before any
code is written.

**Phase 2 — Map before code**
Write `.claude/CODEBASE_MAP.md` (template in
`~/.claude/universal-kit/templates/`) from the approved architecture BEFORE
feature code, and keep it current. Create the project CLAUDE.md and
SESSION_LOG.md alongside it.

**Phase 3 — Build milestone by milestone**
Each milestone must run end-to-end before the next starts. Use the right
specialist for each layer of work:

- Backend / API design → `backend-architect` + `api-design` skill
- Frontend / UI → `frontend-developer` + `taste-skill` + `ui-ux-pro-max` for every screen; `baseline-ui` polish pass
- Animation / 3D → `motion-dev-animations` or `gsap-*` skills; `threejs-*` / `shader-dev` for WebGL; `modern-web-guidance` for view transitions and scroll-driven CSS
- Visual quality check → `ui-visual-validator` after each UI milestone
- Auth, payments, user input, file handling → `security-auditor` reviews before milestone closes
- Database schema → `sql-pro`
- PHP/WordPress stack → `php-pro`
- Tests alongside every feature → `test-automator`
- Pre-ship hardening → run `/ship` on the completed MVP

Use `AGENT_INDEX.md` roster when work is parallel or reading-heavy — spawn
specialists as subagents, integrate results.

Anything outside the approved MVP goes in the map's v2 list, not into code.
Prefer boring, well-documented stack choices. Suggest commit points at
milestone ends; don't commit unless I ask.

PROJECT IDEA: $ARGUMENTS
