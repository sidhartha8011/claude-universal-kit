---
description: Work on a task using the codebase map and the universal task loop
argument-hint: <task description>
---

Read .claude/CODEBASE_MAP.md, the project CLAUDE.md, and the last 10 entries
of .claude/SESSION_LOG.md (skip any that don't exist — if the map is missing,
tell me to run /onboard first and stop).

Then follow the Phase 4 task loop from ~/.claude/universal-kit/prompts/01-onboarding.md
(restate → plan → implement → security gate → verify → self-review →
report + append to SESSION_LOG.md) for this task:

TASK: $ARGUMENTS
