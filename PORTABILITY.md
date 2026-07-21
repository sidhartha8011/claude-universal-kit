# Portability — one repo layout, every agent

The kit's project-level workflow is tool-agnostic. Artifacts live in a
neutral `.agent/` folder; each tool gets a small pointer file at the path
it already reads. Nothing is duplicated — pointers reference the contract,
they don't copy it.

Install into any project: `./install-project.sh /path/to/project`

---

## The layout

```
<project>/
  AGENTS.md                          # the contract — canonical, tool-agnostic
  .agent/
    CODEBASE_MAP.md                  # the map (written once, read every session)
    SESSION_LOG.md                   # 3 lines per task
    plan.md                          # present during multi-step work
  CLAUDE.md                          # pointer: @AGENTS.md
  GEMINI.md                          # pointer
  .github/copilot-instructions.md    # pointer
  .cursor/rules/agents.mdc           # pointer (frontmatter required)
  .clinerules                        # pointer
```

## Why pointers, not copies

| Tool | Reads | Native AGENTS.md? |
|---|---|---|
| Codex CLI, opencode, Zed, Amp, Devin, Jules, Kimi CLI, Cursor, Roo, Antigravity | `AGENTS.md` | Yes |
| **Claude Code** | `CLAUDE.md` | **No** — needs `@AGENTS.md` import |
| Gemini CLI | `GEMINI.md` | Only via `.gemini/settings.json` |
| GitHub Copilot | `.github/copilot-instructions.md` | Partial |
| Cline | `.clinerules` | Version-dependent |

Claude Code not reading `AGENTS.md` is the one gotcha worth knowing — its
docs state it plainly, despite many blog posts claiming otherwise. The
`CLAUDE.md` pointer (`@AGENTS.md`) solves it.

## Skills are the portable layer

`SKILL.md` (spec: agentskills.io) is supported by ~40 clients — more than
AGENTS.md. The kit's skills work unmodified in Claude Code, Codex, Cursor,
Copilot, Gemini CLI, opencode, Amp, Goose, Roo, Kimi and others. Install
them per that tool's convention; the files themselves need no changes.

Commands (`commands/*.md`) are the least portable layer — Claude Code
slash commands. Antigravity equivalents live in the sibling
antigravity-universal-kit as workflows. Other tools: paste the command
body as a prompt, or wrap it in that tool's own command format.

---

## Non-Anthropic models

GLM (Zhipu), Kimi (Moonshot), DeepSeek and Qwen are typically run *inside*
Claude Code via an Anthropic-compatible endpoint, so they inherit this
whole setup — including `model-adaptation`, which classifies them T3 and
loads the full scaffolding they need.

```jsonc
// ~/.claude/settings.json
{ "env": {
  "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",  // GLM (intl)
  //                    "https://api.moonshot.ai/anthropic"   Kimi
  "ANTHROPIC_AUTH_TOKEN": "<key>",
  "API_TIMEOUT_MS": "3000000"
}}
```

Both vendors also expose OpenAI-compatible endpoints for opencode, Cline,
and Roo. Moonshot's Anthropic shim rescales temperature (`real = request
* 0.6`) — worth knowing if output feels flatter than expected.

**Scaffolding, not vibes**: these tiers measurably benefit from explicit
plans, checklists, named file paths, and verification gates — the same
scaffolding that is noise on a frontier model. That asymmetry is what
`model-adaptation`'s tier table exists to manage. Don't hand-tune prompts
per model; set the tier and let the skill do it.
