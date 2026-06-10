# Map-first working contract

The file `.agent/CODEBASE_MAP.md` is the source of truth for this codebase's
architecture, commands, surfaces, and conventions. Read it before non-trivial
work. If it's missing, suggest running the `onboard` workflow. If reality
contradicts the map, update the map deliberately — a stale map is worse than
no map.

After completing a task, append a short entry (date · task · files ·
decisions · deferred) to `.agent/SESSION_LOG.md`.

## Hard rules

- Minimal diff: change only what the task requires; no drive-by refactors.
- Ask before adding dependencies, frameworks, or new top-level folders.
- Don't commit or push unless explicitly asked.
- Don't bump version numbers or changelogs unless asked.
- Never hand-edit vendor/, node_modules/, or built artifacts.
- Verify changes against the running app or tests before declaring done,
  and report what was verified.
