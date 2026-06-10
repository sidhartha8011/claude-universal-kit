# Universal Project Onboarding Prompt

Paste this at the start of any new project session. Works for any stack.

---

```
You are working on this codebase. Two rules govern this whole session:

  (1) The map is the source of truth. Build it once, then trust it.
  (2) Nothing ships unverified. Every change is proven before declared done.

────────────────────────────────────────────────────────────────────────
PHASE 1 — MAP THE PROJECT
────────────────────────────────────────────────────────────────────────

If `.claude/CODEBASE_MAP.md` exists and was updated in the last 7 days,
read it and skip to Phase 3.

Otherwise explore the codebase. Investigate only what actually exists —
don't invent sections for features the project doesn't have. Use the
Explore agent for lookups, Plan agent for synthesis.

Answer exactly these questions:

  IDENTITY     what this project is, version, language(s), framework(s)
  BOOTSTRAP    how it starts — entry points, build, dev vs prod commands
  SURFACES     every way the outside world reaches this code:
                 routes/endpoints, CLI commands, jobs/cron, webhooks,
                 UI pages, public APIs, event handlers
  DATA         storage layer, schema location, migration pattern,
                 keys/config it owns
  ASSETS       frontend build tool (if any), source vs built paths
  EXTERNAL     third-party services, SDKs, credential locations
  CONVENTIONS  coding standard, naming, error handling, validation
                 pattern as actually used in this code
  COMMANDS     exact strings to run tests, a single test, lint, build,
                 start local env
  RISK         security-sensitive paths, large/churny files, TODO/FIXME,
                 anything load-bearing but undocumented

For each SURFACE record: name, file:line, auth/permission required,
one-line purpose. This table is the most important output.

────────────────────────────────────────────────────────────────────────
PHASE 2 — WRITE THE MAP
────────────────────────────────────────────────────────────────────────

Write `.claude/CODEBASE_MAP.md` (use the template in
~/.claude/universal-kit/templates/ if present). Omit sections that
don't apply. Include a "Where to add a <thing>" section covering only
the extension points this project actually has.

Ensure `CLAUDE.md` at the project root points to the map and lists the
project's hard rules (validation, escaping, no raw SQL, don't touch
built artifacts, don't bump versions unasked, ask before new deps).

────────────────────────────────────────────────────────────────────────
PHASE 3 — CHECKPOINT
────────────────────────────────────────────────────────────────────────

Post a ≤150-word summary: what the project does, how it's organized,
top 3 risks. List Open Questions. Stop and wait.

────────────────────────────────────────────────────────────────────────
PHASE 4 — TASK LOOP
────────────────────────────────────────────────────────────────────────

For every task after the checkpoint:

  1. RESTATE the task in one sentence; name the surfaces it touches.
     If a surface isn't in the map, update the map first.
  2. PLAN — Plan agent if >2 files or a new surface; else 3-5 bullets
     inline.
  3. IMPLEMENT per the map's conventions. Reuse helpers. Minimal diff.
     No drive-by refactors.
  4. SECURITY GATE — for every handler/input path touched, state:
     authn/authz ✅, input validation ✅, output encoding ✅,
     injection-safe queries ✅. If N/A, say why.
  5. VERIFY — narrowest test that proves it; lint changed files; for
     UI changes drive the actual screen.
  6. SELF-REVIEW with /code-review (medium); /security-review for any
     auth, input, SQL, or permission change.
  7. REPORT what changed, what you verified, what you deferred, and
     append 3 lines to `.claude/SESSION_LOG.md`
     (date · task · files · decisions · deferred).

────────────────────────────────────────────────────────────────────────
CONTEXT MANAGEMENT
────────────────────────────────────────────────────────────────────────

- Prefer the Explore agent over reading files into this conversation —
  ask for file:line + 2-line summaries, not contents.
- If /compact runs mid-task, keep the active plan, drop file dumps.
- If the map is stale (paths missing, commands fail), fix the map
  BEFORE the task. A stale map is worse than no map.
- Prune SESSION_LOG.md entries older than 30 days when it exceeds
  200 lines.

Start Phase 1 now. Don't edit any file outside `.claude/` until the
map is on disk and I've answered your Open Questions.
```
