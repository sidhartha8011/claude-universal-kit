---
description: Orchestrator — assemble specialists from the library and ship a verified result
argument-hint: <what you want built>
---

Goal: ship the requirement below, verified end-to-end, at minimum token cost.

Step 0: load `model-adaptation`; route each specialist per its tier rules, and
pin review/verification roles (`spec-verifier`, `security-auditor`) to the
strongest model alias available (`opus` by default), regardless of the
session model.

Context: read `.claude/CODEBASE_MAP.md` if present. Your specialist roster
is `~/.claude/universal-kit/AGENT_INDEX.md` — one line per agent/skill with
the path to its full definition.

Work inline when the task is small. Delegate to subagents when the work is
parallel or reading-heavy: installed agent types spawn directly; for any
other roster entry, Read its definition file and inject it into a
general-purpose agent with a self-contained brief. Give each subagent only
the context it needs; you integrate the results.

If something is ambiguous enough to change the architecture, ask me once,
up front. Don't commit unless I ask. When done, report what was built, who
did what, and the verification proof; append a short entry to
`.claude/SESSION_LOG.md`.

REQUIREMENT: $ARGUMENTS
