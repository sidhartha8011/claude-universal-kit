---
description: Start a brand-new project from scratch — requirements, architecture, scaffold, map, then build with the orchestrator
argument-hint: <what you want to build>
---

You are starting a NEW project from zero in the current (empty or nearly
empty) directory. The map-first system still applies — but here you WRITE
the map before the code, as the architecture contract.

PROJECT IDEA: $ARGUMENTS

────────────────────────────────────────────────────────────────────────
STEP 1 — REQUIREMENTS (one batched conversation, then never again)
────────────────────────────────────────────────────────────────────────
From the idea, draft your understanding of:
  - Core user-facing features (MVP) vs explicitly deferred (v2)
  - Users/actors and what each can do
  - Platform & constraints (web/mobile/plugin/CLI; hosting; budget)
  - Integrations needed (payments, auth providers, email, APIs)
  - Non-functional needs that change architecture (multi-tenant? offline?
    realtime? heavy SEO? expected scale?)

Present this as a short brief with your assumptions marked. Ask me ONE
batched set of questions for anything that changes the architecture.
Wait for answers.

────────────────────────────────────────────────────────────────────────
STEP 2 — ARCHITECTURE DECISION
────────────────────────────────────────────────────────────────────────
Read ~/.claude/universal-kit/AGENT_INDEX.md. If the stack choice is
non-obvious, consult the backend-architect agent (and frontend-developer
for UI-heavy projects) for a recommendation. Decide and present:

  - Stack: language, framework, DB, styling, testing, build tooling
    (prefer boring, well-documented choices over novel ones)
  - Directory layout
  - Data model sketch (entities + relations)
  - Surfaces list (pages/endpoints/jobs) for the MVP
  - Milestone plan: 3-6 milestones, each independently runnable/testable

State WHY for each major choice in one line. Get my approval before
scaffolding. This is the last approval gate — after this you build.

────────────────────────────────────────────────────────────────────────
STEP 3 — SCAFFOLD + MAP
────────────────────────────────────────────────────────────────────────
  1. Initialize: git init, package manager, framework scaffold, linter,
     formatter, test runner, .gitignore, .env.example.
  2. Write `.claude/CODEBASE_MAP.md` from the template at
     ~/.claude/universal-kit/templates/CODEBASE_MAP.md.template —
     filled with the DECIDED architecture (commands, layout, surfaces,
     conventions, "where to add a thing"). The map is now the contract:
     code that contradicts the map is wrong, or the map gets updated
     deliberately.
  3. Write project CLAUDE.md: stack, hard rules, pointer to the map.
  4. Create `.claude/SESSION_LOG.md` from its template.
  5. Verify the empty scaffold runs (dev server starts / hello-world
     test passes) before writing any feature code.

────────────────────────────────────────────────────────────────────────
STEP 4 — BUILD BY MILESTONE
────────────────────────────────────────────────────────────────────────
For each milestone, run the /build orchestration (decompose → delegate
to specialists from the index → integrate → quality gates → verify).
After each milestone:
  - The project must RUN end-to-end (no "it'll work once X lands")
  - Update the map if surfaces/layout changed
  - Append to SESSION_LOG.md
  - Give me a 5-line status: done, verified-how, next milestone

Don't start milestone N+1 until N is verified. If I'm not responding,
continue through milestones — the approval gate was Step 2.

────────────────────────────────────────────────────────────────────────
RULES
────────────────────────────────────────────────────────────────────────
- MVP discipline: anything not in the Step 1 MVP list is deferred. Note
  it in the map's "Open questions / v2", don't build it.
- Working software over completeness: a thin vertical slice that runs
  beats a wide layer that doesn't.
- Quality gates from /build apply to every milestone (review, security
  on surfaces, tests, verification).
- Don't commit unless I ask; suggest commit points at milestone ends.
