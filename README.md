# Claude Universal Kit

A curated, opinionated working system for **Claude Code** — built so that any
project, on any machine, starts with the same battle-tested agents, skills,
slash commands, and a memory discipline that survives context resets.

> One install. Six commands. A map-first workflow that means Claude never
> re-explores your codebase from scratch.

---

## Why this exists

Out of the box, Claude Code is powerful but stateless across sessions and
generic across projects. Three problems show up fast:

1. **Re-exploration tax** — every new session relearns your codebase, burning
   tokens and time.
2. **Tool sprawl** — hundreds of community agents/skills exist, but loading
   them all poisons your context window.
3. **Inconsistency** — prompts and conventions drift between projects and
   machines.

This kit fixes all three:

- **A map on disk, not in chat.** `/onboard` writes `.claude/CODEBASE_MAP.md`
  once; every later session reads it instead of re-exploring.
- **A lean default loadout + a just-in-time library.** 17 agents and 12 skills
  are always installed; 175+ more live in `AGENT_INDEX.md` and are loaded only
  when a task actually needs them.
- **Portable, version-controlled config.** Clone the repo, run one script, and
  any machine matches.

---

## What's inside

```
agents/      17 curated specialist subagents (always installed)
skills/      12 skills: verification-loop, tdd-workflow, security-review,
             coding-standards, backend/frontend-patterns, api-design,
             e2e-testing, strategic-compact, deep-research, webapp-testing,
             mcp-builder
commands/    6 global slash commands (the daily interface)
prompts/     verbose paste-able versions of the workflows
templates/   CODEBASE_MAP.md + SESSION_LOG.md skeletons
AGENT_INDEX.md   one-line roster of all 175+ library agents/skills with paths
bootstrap.sh     full setup for a new machine
install.sh       symlink agents+skills globally or into one project
regen-index.sh   rebuild AGENT_INDEX.md after pulling source repos
```

### The 17 agents

Architecture & review — `backend-architect`, `architect-review`,
`code-reviewer`, `legacy-modernizer`
Security — `security-auditor`, `backend-security-coder`
Quality — `debugger`, `test-automator`, `performance-engineer`
Ops — `deployment-engineer`, `devops-troubleshooter`
Stack specialists — `frontend-developer`, `typescript-pro`, `python-pro`,
`php-pro`, `sql-pro`, `ui-visual-validator`

These are curated from a 192-agent library (wshobson/agents). The rest aren't
installed — they're indexed and loaded on demand by `/build`.

---

## The six commands

| Command | When | What it does |
|---|---|---|
| `/onboard` | First time in a codebase | Explores once, writes `.claude/CODEBASE_MAP.md`, waits for your go-ahead |
| `/task <desc>` | Daily work | Reads the map + log, does the task to mergeable quality, updates the log |
| `/build <req>` | Big multi-part features | Decomposes the requirement, pulls specialists from `AGENT_INDEX.md`, delegates to subagents, integrates, verifies |
| `/genesis <idea>` | Brand-new project from zero | Requirements brief → one architecture approval gate → scaffold + map → milestone builds |
| `/rootcause <symptom>` | Something's broken | Finds the mechanism before fixing; leaves a regression test |
| `/ship [branch]` | Pre-merge | Diff audit, review, security pass, tests, end-to-end verification |

All commands are **goal-style**, not step-by-step playbooks — they state the
outcome and the constraints, then let Claude plan the path. (See "Design
notes" below for why.)

---

## Install

### New machine (recommended)

```bash
git clone https://github.com/sidhartha8011/claude-universal-kit.git ~/.claude/universal-kit
chmod +x ~/.claude/universal-kit/*.sh
~/.claude/universal-kit/bootstrap.sh
```

`bootstrap.sh` clones the four source libraries, symlinks the agents and
skills into `~/.claude/`, installs the slash commands, and regenerates
`AGENT_INDEX.md` with this machine's paths. Restart Claude Code afterwards so
the commands register.

Prefer pasting a prompt? Use [SETUP_PROMPT.md](SETUP_PROMPT.md) — drop it into
a fresh Claude Code session and it runs the whole setup for you.

### Already have the source repos

```bash
~/.claude/universal-kit/install.sh global              # available everywhere
~/.claude/universal-kit/install.sh project /path/to/x  # scoped to one project
```

---

## Daily workflow

```
/onboard                          # once per project — builds the map
/task add a settings page         # 90% of work — inline, fast
/build a booking system w/ Stripe # big features — orchestrated specialists
/rootcause checkout returns 500   # debugging
/ship                             # harden before merge
```

The map (`.claude/CODEBASE_MAP.md`) and session log are the system's memory.
They live in each project's `.claude/` and are the reason a fresh session is a
warm start, not a cold one.

---

## How `/build` stays cheap

The orchestrator never loads all 175+ specialists. It reads `AGENT_INDEX.md`
(one line each), picks the few that fit the task, and only then reads those
definitions — injecting non-installed specialists into general-purpose
subagents at runtime. Each subagent gets only the context it needs; the
orchestrator integrates the results. You pay for a specialist's definition
only when it's actually used.

---

## Keeping machines in sync

```bash
# after changing the kit on one machine
cd ~/.claude/universal-kit && git add -A && git commit -m "update" && git push

# on another machine
cd ~/.claude/universal-kit && git pull && ./bootstrap.sh
```

---

## Design notes

- **Goal over steps.** The commands describe outcomes and your policies
  (minimal diff, don't commit unasked, ask before new deps), not procedures.
  Modern Claude models review their own work and plan paths better when given
  a goal than when walked through a checklist.
- **Constraints in, process out.** The only things hard-coded are facts the
  model can't infer: your map, your conventions, the agent index. Everything
  procedural is left to the model.
- **Lean context.** Installing 200+ always-on agents/skills would bloat every
  session. The kit keeps a small loadout and treats the rest as a library.

---

## Sources

Curated from:
[anthropics/skills](https://github.com/anthropics/skills) ·
[wshobson/agents](https://github.com/wshobson/agents) ·
[affaan-m/ecc](https://github.com/affaan-m/ecc) ·
[hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)

## Sibling kit

Using Google Antigravity too?
[**antigravity-universal-kit**](https://github.com/sidhartha8011/antigravity-universal-kit)
ports the same workflow to Antigravity's `.agent/` convention and shares the
same map format.

## License

MIT. Bundled source components retain their own licenses (see individual
`LICENSE.txt` files under `skills/`).
