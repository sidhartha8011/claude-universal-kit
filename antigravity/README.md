# Antigravity adapter

Ports the universal kit to Google Antigravity, which uses a **project-level**
`.agent/` directory (unlike Claude Code's user-level `~/.claude/`):

| Kit concept | Antigravity location |
|---|---|
| Hard rules + map contract | `.agent/rules/map-first.md` |
| Slash commands | `.agent/workflows/{onboard,task,rootcause,ship,genesis}.md` |
| Curated agents | `.agent/skills/*.md` |

## Install (per project)

```bash
~/.claude/universal-kit/antigravity/install-antigravity.sh /path/to/project
```

Then open the project in Antigravity — workflows show up as slash commands,
rules apply automatically.

## Differences from the Claude Code kit

- **No /build orchestrator.** The orchestrator relies on Claude Code's Agent
  tool and the AGENT_INDEX roster. Antigravity has its own Agent Manager for
  multi-agent work — use that instead.
- **Project-level, not global.** Run the installer once per project.
- **Map lives at `.agent/CODEBASE_MAP.md`** (next to the config), not
  `.claude/`. Both kits use the same map format, so a project used from both
  tools can symlink one to the other.

## Setup on a new machine

Antigravity needs no global setup — clone the kit repo and run the installer
against each project:

    git clone https://github.com/sidhartha8011/claude-universal-kit.git ~/.claude/universal-kit
    ~/.claude/universal-kit/antigravity/install-antigravity.sh /path/to/project
