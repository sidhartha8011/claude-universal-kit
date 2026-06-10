# Universal Kit

Curated best-of from four sources, assembled 2026-06-10:

- **anthropics/skills** — official Anthropic skills
- **wshobson/agents** — 192 subagents across 82 plugins (took the top 15)
- **affaan-m/ecc** — cross-harness operator system (took the 10 strongest skills)
- **hesreallyhim/awesome-claude-code** — patterns informed the prompts

Source clones live in `~/.claude/skills/{anthropic-skills-repo,wshobson-agents,ecc,awesome-claude-code}`.

## Layout

```
agents/     15 subagent definitions (architecture, review, security,
            debugging, testing, deploy, frontend, TS/Python specialists)
skills/     12 skills (verification-loop, tdd-workflow, security-review,
            coding-standards, backend/frontend-patterns, api-design,
            strategic-compact, deep-research, e2e-testing,
            webapp-testing, mcp-builder)
prompts/    01-onboarding   — full project onboarding (map → checkpoint → task loop)
            02-task-loop    — short returning-session prompt
            03-review-and-ship — harden a finished feature before merge
            04-debug        — systematic root-cause debugging
templates/  CODEBASE_MAP.md and SESSION_LOG.md skeletons
install.sh  symlinks agents+skills globally or into one project
AGENT_INDEX.md  one-line index of ALL 175+ library agents/skills with paths —
            the /build orchestrator's roster (regenerate: ./regen-index.sh)
```

## Slash commands (global, in ~/.claude/commands/)

- `/onboard` — build the codebase map for the current project
- `/task <desc>` — task loop using the map
- `/ship [branch]` — harden a finished feature
- `/rootcause <symptom>` — systematic debugging
- `/build <requirement>` — SUPREME ORCHESTRATOR: decomposes the requirement,
  picks specialists from AGENT_INDEX.md, delegates to subagents with only
  the context they need, integrates, runs quality gates, ships verified.
- `/genesis <idea>` — NEW project from scratch: requirements brief →
  architecture decision (one approval gate) → scaffold + map-as-contract →
  milestone builds via the /build orchestration.

## Install

```bash
# everywhere
~/.claude/universal-kit/install.sh global

# one project only
~/.claude/universal-kit/install.sh project /path/to/project
```

## Use

1. New project → paste `prompts/01-onboarding.md` (the code block) as the
   first message. It builds `.claude/CODEBASE_MAP.md` and waits for your
   go-ahead.
2. Every later session → paste `prompts/02-task-loop.md` with your task.
3. Feature done → `prompts/03-review-and-ship.md`.
4. Bug → `prompts/04-debug.md`.

Agents are invoked automatically by Claude when their description matches
the work, or explicitly: "use the security-auditor agent on this diff."
Skills trigger by description, or explicitly: "apply the verification-loop
skill."

## Notes

- Skills already active via the `anthropic-skills:` plugin (docx, pdf,
  pptx, xlsx, frontend-design, skill-creator, claude-api) are NOT
  duplicated here.
- ECC's `security-review` skill is included as a skill; the
  `security-auditor` agent covers the same ground as a subagent — both
  can coexist (skill = checklist in-context, agent = delegated audit).
- Update the source clones with `git -C ~/.claude/skills/<repo> pull`,
  then re-copy anything you want refreshed.
