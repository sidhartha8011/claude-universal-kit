---
description: Onboard Claude to this project — build the codebase map, then wait for go-ahead
---

Goal: produce `.claude/CODEBASE_MAP.md` so future sessions can work in this
codebase without re-exploring it.

If the map exists and is under 7 days old, read it, confirm it still matches
the codebase, and report ready.

Otherwise explore the codebase and write the map using
`~/.claude/universal-kit/templates/CODEBASE_MAP.md.template` — fill what
exists, omit what doesn't. Record every external surface (routes, handlers,
jobs, pages) with file:line and required auth — that table is what future
sessions rely on most. Ensure the project CLAUDE.md points to the map and
captures the project's hard rules.

Then give me a short summary with any open questions, and wait before
editing anything outside `.claude/`.

$ARGUMENTS
