# Codex Adapter

This kit can stay in `~/.claude/universal-kit` and still be used by Codex.
The adapter exposes the same curated skills to Codex without changing the
project memory layout.

## Install for Codex

```bash
chmod +x ~/.claude/universal-kit/*.sh
~/.claude/universal-kit/codex-bootstrap.sh
```

What it does:

- Keeps `~/.claude/universal-kit` as the canonical source.
- Symlinks kit skills into `~/.codex/skills/` so Codex can discover them.
- Keeps agents and command prompts in `~/.claude/agents` and
  `~/.claude/commands`.
- Mirrors command prompts into `~/.codex/prompts/universal-kit/` as reference
  prompts, since Codex does not load Claude Code slash commands directly.
- Leaves project memory in `.claude/CODEBASE_MAP.md` and
  `.claude/SESSION_LOG.md` so Claude Code and Codex can share context.

## How to Use in Codex

Ask Codex naturally instead of typing Claude slash commands:

```text
Use the universal-kit onboard workflow for this repo.
Use the universal-kit task workflow: add a settings page.
Use the universal-kit ship workflow.
```

Codex skills are loaded by description, so the symlinked `SKILL.md` files are
discoverable after restarting Codex.

## Compatibility Notes

Claude-only MCP/plugin setup from `bootstrap.sh` is intentionally skipped by
the Codex adapter. Use Codex plugins/connectors through Codex itself.

Subagent prompts in `agents/` remain useful as reference material, but Codex
does not treat Claude Code agent markdown files as native agent definitions.
