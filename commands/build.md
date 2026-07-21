---
description: Orchestrator — assemble specialists from the library and ship a verified result
argument-hint: <what you want built>
---

Goal: ship the requirement below, verified end-to-end, at minimum token cost.

Step 0: load `model-adaptation`; route each specialist per its tier rules, and
pin review/verification roles (`spec-verifier`, `security-auditor`) to the
strongest model alias available (`opus` by default), regardless of the
session model.

Context: read `.agent/CODEBASE_MAP.md` (or `.claude/CODEBASE_MAP.md`) if present. Your specialist roster
is `~/.claude/universal-kit/AGENT_INDEX.md` — one line per agent/skill with
the path to its full definition.

Work inline when the task is small. Delegate to subagents when the work is
parallel or reading-heavy: installed agent types spawn directly; for any
other roster entry, Read its definition file and inject it into a
general-purpose agent with a self-contained brief. Give each subagent only
the context it needs; you integrate the results.

Every brief that edits files follows the worker brief contract
(`model-adaptation`): file allowlist, constraints to echo, full-diff
return, runnable acceptance check. Route worker models per step —
mechanical/scoped → `sonnet`; multi-file coherence → `opus` worker;
review/verification → strongest (per Step 0). The orchestrator edits
files itself only after a delegated brief fails twice. Verify each delegated
result against its check before integrating; a brief that fails twice,
execute yourself.

If something is ambiguous enough to change the architecture, ask me once,
up front. Don't commit unless I ask. When done, report what was built, who
did what, and the verification proof; append a short entry to
`.agent/SESSION_LOG.md` (or `.claude/SESSION_LOG.md`).

REQUIREMENT: $ARGUMENTS
