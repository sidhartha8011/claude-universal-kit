# Efficiency Stack — measured, lean, no bloat

The curated add-on layer around the kit: five tools that earn their context
cost, a watch list to trial, and a skip list of hyped tools that don't.
Rule of the stack: **measure first (ccusage), adopt only what the numbers
justify, prefer invoked-on-demand over always-on.**

---

## The five (adopt now)

### 1. ccusage — measure everything first

Reads your local session transcripts; costs zero context (runs outside
Claude). No install needed:

```bash
npx ccusage@latest daily      # per-day tokens + cost, by model
npx ccusage@latest session    # per-session breakdown — find the burners
npx ccusage@latest blocks --live   # live burn-rate dashboard
```

Use it to: find which projects/workflows burn quota, verify any
"token-saving" tool before trusting it, and check the model-boost layer's
frontier-sandwich economics on your real tasks.

### 2. Context7 — current docs on demand

MCP server that pulls version-correct library docs (WordPress hooks,
Next.js APIs, any package) into context only when asked.

```bash
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
```

Usage: append **"use context7"** to any prompt that touches a library API:

```
/task add a REST route for license activation — use context7 for the WP REST API signatures
```

Zero cost until invoked. Optional API key (higher rate limits) via
`CONTEXT7_API_KEY` header — free tier is fine for solo use.

### 3. Official LSP plugins — real diagnostics, not grep-guessing

From Anthropic's vetted marketplace (`claude-plugins-official`,
pre-configured in recent Claude Code):

```bash
claude plugin install --scope user typescript-lsp@claude-plugins-official
claude plugin install --scope user php-lsp@claude-plugins-official
```

Nothing to do day-to-day — Claude silently gains go-to-definition, find-
references, and live type/syntax diagnostics in TS and PHP. First use in a
project may download the language server binary; let it.

Only install the LSPs for languages you use. The marketplace has 14
(`claude plugin marketplace` → anthropics/claude-plugins-official).

### 4. Chrome DevTools MCP — Claude sees the real browser

Google's official MCP: live console errors, network requests, DOM from a
real Chrome instance. Claude reproduces the bug, reads the actual error,
verifies its own fix.

**Project scope only** (it adds ~26 tool definitions per session — don't
pay that in backend projects):

```bash
cd /path/to/frontend-project
claude mcp add --scope project chrome-devtools -- npx -y chrome-devtools-mcp@latest
```

Usage: "open localhost:3000, click checkout, and read the console errors" —
then let it fix and re-verify.

### 5. Native /loop + Routines — automation with nothing installed

Already built in:

- `/loop 5m <prompt>` — recurring in-session task (babysit a PR, poll a deploy)
- `/schedule` — cloud agents on cron (nightly content-pipeline run, weekly dep audit)

And run `claude update` monthly — recent releases keep shipping free
efficiency wins.

---

## Watch list (trial with ccusage before adopting)

| Tool | What | Adopt when |
|---|---|---|
| Serena | LSP-powered semantic retrieval via MCP | you inherit a multi-thousand-file repo |
| RTK | compresses git/test/lint output 60–90% before context | trial on one project; keep only if ccusage shows a real delta |
| Dynamic Workflows / ultracode | native multi-agent orchestration, 16 concurrent subagents | one big bounded task (full refactor); it's a token furnace as a default |

## Skip list (the traps, so future-you doesn't reinstall them)

- **ECC / mega-bundles** — one install = every skill taxes every session forever. Already ran this experiment; killed it.
- **Memory plugins (claude-mem, Mem0)** — hooks-on-every-turn is context poisoning in a memory costume. MEMORY.md + the codebase map already solve session amnesia.
- **Terse output styles** — viral 75% claims; measured ~8.5%, and output tokens are a minority of spend.
- **Compression proxies (Headroom-class)** — MITM between you and the API; unverifiable claims, debugging nightmare. The honest core (lean context, subagent isolation, /clear between tasks) is free discipline.
- **GitHub MCP** — `gh` CLI does the same job with zero per-session tool-definition cost.

---

## The daily loop, with the stack in place

```
/onboard                         # once per project
/task <thing> — use context7     # library APIs stay current
   (LSPs feed diagnostics silently; chrome-devtools verifies frontend fixes)
/ship                            # before merge
npx ccusage@latest daily         # weekly: check the burn, prune what doesn't earn
```

Pairs with the model-boost layer (`skills/model-adaptation/SKILL.md`):
frontier sandwich for big tasks, this stack for everything, ccusage to
prove both are working.
