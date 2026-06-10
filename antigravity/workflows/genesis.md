---
description: Start a brand-new project from scratch in this directory
---

Goal: take the given idea from zero to a working, verified MVP.

Two process requirements:

1. Before scaffolding, present a requirements brief — MVP vs deferred,
   stack with one-line reasons, data model sketch, milestone plan — and ask
   any architecture-changing questions in ONE batch. That is the only
   approval gate; after approval, build autonomously.

2. Write `.agent/CODEBASE_MAP.md` from the approved architecture BEFORE
   feature code, and keep it current. Create `.agent/SESSION_LOG.md`
   alongside it.

Build milestone by milestone; each must run end-to-end before the next
starts. Anything outside the approved MVP goes in the map's v2 list, not
into code. Prefer boring, well-documented stack choices. Suggest commit
points at milestone ends; don't commit unless asked.
