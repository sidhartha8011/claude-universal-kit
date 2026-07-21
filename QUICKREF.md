# Quick reference — what to run when

## Commands (9)

| Command | When | What it does |
|---|---|---|
| `/onboard` | First time in a project | Explores via read-only subagents, writes `CODEBASE_MAP.md`, waits |
| `/task <desc>` | 90% of work | Reads map + log, picks the right specialists, does it, verifies |
| `/worker <desc>` | Big task, want frontier quality at lower cost | Strong model plans + routes each step to opus/sonnet workers |
| `/build <req>` | Multi-part feature, parallel domains | Decomposes, pulls specialists from AGENT_INDEX, integrates |
| `/genesis <idea>` | Brand-new project from zero | Requirements → one approval gate → scaffold + map → milestones |
| `/rootcause <sym>` | Something's broken | Finds the mechanism before fixing; leaves a regression test |
| `/ship [branch]` | Before merge | Diff audit, security, tests, end-to-end verification |
| `/task-glm <desc>` | Offload a whole task to GLM | Dispatches `/task` to a GLM subprocess; Claude verifies + spec-verifier |
| `/task-glm-support <desc>` | Offload, but keep judgment per-step | Claude plans and routes; GLM executes each step; verify between steps |

## Picking between the task-style commands

```
Is it a one-sentence change?           → /task
Is quality worth full Claude cost?     → /task  (or /worker for big ones)
Want to save Claude quota?
   … and it's near risky/shared code?  → /task-glm-support   (verify each step)
   … and it's bounded, your own lane?  → /task-glm           (verify at the end)
Brand new project?                     → /genesis
Multiple parallel domains?             → /build
Broken?                                → /rootcause
Done and merging?                      → /ship
```

## Scripts

| Script | Purpose |
|---|---|
| `bootstrap.sh` | Set up a new machine — clones sources, symlinks, installs commands + plugins |
| `install-project.sh <dir>` | Make any repo tool-agnostic (AGENTS.md + `.agent/` + pointer files) |
| `migrate.sh` | Clean up an old install (removes ECC) |
| `regen-index.sh` | Rebuild `AGENT_INDEX.md` after pulling sources |
| `claude-glm.sh` | Launch an interactive GLM session (terminal) — alias `claude-glm` |
| `glm-worker.sh` | Run one brief on GLM headlessly (what the `/task-glm*` commands call) |
| `model-toggle.sh` | Global provider toggle — alias `ccm`, `ccm status` |
| `codex-bootstrap.sh` | Expose the kit to Codex under `~/.codex` |

## The two ways to use GLM

**From here (no terminal):** `/task-glm <task>` — Claude dispatches and verifies.

**In a terminal (zero Claude cost):** `claude-glm` then `/task <task>` — GLM
does everything with the full kit. Add a Claude verification pass afterwards
if the work matters.

## Non-negotiable habit

GLM's self-report is a claim, not evidence. Both `/task-glm*` commands verify
with `git diff` and by re-running acceptance checks — that is the only thing
that catches a worker satisfying the goal through a workaround.
