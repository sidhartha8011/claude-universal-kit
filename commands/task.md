---
description: Work on a task with the codebase map as context
argument-hint: <task description>
---

Read `.claude/CODEBASE_MAP.md`, the project CLAUDE.md, and recent entries of
`.claude/SESSION_LOG.md`. If there is no map, tell me to run /onboard and stop.

Do the task below to mergeable quality, following the project's conventions.
Constraints: minimal diff; ask before adding dependencies; don't commit
unless I ask. If reality contradicts the map, update the map.

When done, report what changed and how you verified it, and append a short
entry to `.claude/SESSION_LOG.md`.

TASK: $ARGUMENTS
