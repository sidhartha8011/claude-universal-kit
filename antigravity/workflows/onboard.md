---
description: Build the codebase map so future sessions skip re-exploration
---

Goal: produce `.agent/CODEBASE_MAP.md` so future sessions can work in this
codebase without re-exploring it.

If the map exists and is under 7 days old, read it, confirm it still matches
the codebase, and report ready.

Otherwise explore the codebase and write the map with these sections (omit
what doesn't apply): Identity · Stack & build · Commands (run/test/lint,
exact strings) · Bootstrap flow · Directory layout · Surfaces (every route,
handler, job, page — with file:line and required auth) · Data · External
services · Conventions · Where to add a thing · Risks · Open questions.

The Surfaces table matters most — it's what future sessions rely on.

Then give a short summary with any open questions, and wait for go-ahead
before editing anything outside `.agent/`.
