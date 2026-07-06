---
name: strategic-compact
description: Suggests manual /compact at logical task boundaries (research→plan, plan→implement, post-debug) instead of arbitrary auto-compaction. Load when sessions run long, when switching phases or tasks, or when configuring the suggest-compact hook.
---

# Strategic Compact

Auto-compaction fires at arbitrary points — often mid-task, destroying working state. Compact deliberately at phase boundaries instead, where the distilled output (a plan, a commit, a todo list) has already replaced the bulky context that produced it.

## Decision Guide

| Phase transition | Compact? | Why |
|-----------------|----------|-----|
| Research → Planning | Yes | Research context is bulky; plan is the distilled output |
| Planning → Implementation | Yes | Plan is in TodoWrite or a file; free up context for code |
| Implementation → Testing | Maybe | Keep if tests reference recent code; compact if switching focus |
| Debugging → Next feature | Yes | Debug traces pollute context for unrelated work |
| Mid-implementation | No | Losing variable names, file paths, and partial state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning before trying a new approach |

## What Survives Compaction

| Persists | Lost |
|----------|------|
| CLAUDE.md instructions | Intermediate reasoning and analysis |
| TodoWrite task list | File contents previously read |
| Memory files (`~/.claude/memory/`) | Multi-step conversation context |
| Git state (commits, branches) | Tool call history and counts |
| Files on disk | Nuanced user preferences stated verbally |

Before compacting: write anything important to files or memory. Steer the summary with a message: `/compact Focus on implementing auth middleware next`.

## Hook Setup

`suggest-compact.js` runs on PreToolUse (Edit/Write), counts tool calls, and suggests compaction at a threshold (default 50, then every 25). The hook tells you *when*; you decide *if*.

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{ "type": "command", "command": "node ~/.claude/skills/strategic-compact/suggest-compact.js" }]
      },
      {
        "matcher": "Write",
        "hooks": [{ "type": "command", "command": "node ~/.claude/skills/strategic-compact/suggest-compact.js" }]
      }
    ]
  }
}
```

Config: `COMPACT_THRESHOLD` env var — tool calls before first suggestion (default 50).

## Related

- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) — token optimization section
- `continuous-learning` skill — extracts patterns before session ends
