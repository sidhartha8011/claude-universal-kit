---
description: Start a brand-new project from scratch
argument-hint: <what you want to build>
---

Goal: take the idea below from zero to a working, verified MVP in this
directory.

Two things I care about in the process:

1. Before scaffolding, present a requirements brief — MVP vs deferred,
   stack with one-line reasons, data model sketch, milestone plan — and ask
   any architecture-changing questions in ONE batch. That is the only
   approval gate; after I approve, build autonomously.

2. Write `.claude/CODEBASE_MAP.md` (template in
   `~/.claude/universal-kit/templates/`) from the approved architecture
   BEFORE feature code, and keep it current. Create the project CLAUDE.md
   and SESSION_LOG.md alongside it.

Build milestone by milestone; each must run end-to-end before the next
starts. Anything outside the approved MVP goes in the map's v2 list, not
into code. Prefer boring, well-documented stack choices. Use the /build
orchestration pattern (AGENT_INDEX.md roster) when work is parallel or
reading-heavy. Suggest commit points at milestone ends; don't commit unless
I ask.

PROJECT IDEA: $ARGUMENTS
