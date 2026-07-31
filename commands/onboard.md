---
description: Onboard Claude to this project — build the codebase map, then wait for go-ahead
---

Goal: produce `.agent/CODEBASE_MAP.md` (or `.claude/CODEBASE_MAP.md`) so future sessions can work in this
codebase without re-exploring it.

If the map exists and is under 7 days old, read it, confirm it still matches
the codebase, and report ready. Before reporting, if `graphify` is on PATH
but `graphify-out/` is missing, run `graphify update .` and add
`graphify-out/` to `.gitignore` — the index is seconds and free, and every
other command checks for it.

Otherwise, first build a structural index for free — if `graphify` is on
PATH, run `graphify update .` (seconds, no LLM), then `graphify god-nodes
--top 15` to get the architectural hubs. That gives you the skeleton
without reading a line of source; add `graphify-out/` to `.gitignore`.
Skip silently if graphify isn't installed.

Then explore via read-only subagents (parallel, one per area) so raw file
contents stay out of this context — the map is the only artifact that
matters. Use the hubs to aim that exploration at what matters instead of
sweeping everything. Write the map using
`~/.claude/universal-kit/templates/CODEBASE_MAP.md.template` — fill what
exists, omit what doesn't. Record every external surface (routes, handlers,
jobs, pages) with file:line and required auth — that table is what future
sessions rely on most. Ensure the project CLAUDE.md points to the map and
captures the project's hard rules.

Then give me a short summary with any open questions, and wait before
editing anything outside `.claude/`. Flag anything in the map you inferred
rather than confirmed, and ask me to check it — measured on 438 tasks,
auto-generated context files cost ~3% success while human-corrected ones
gained ~4%. The map is worth a few minutes of my attention once.

$ARGUMENTS
