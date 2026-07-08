---
name: model-adaptation
description: Load at session start (referenced by /task, /build, /genesis). Detects the running model tier and selects which boost skills and prompt snippets apply — weaker tiers get explicit process scaffolding, frontier tiers get it stripped.
---

# Model Adaptation

Scaffolding is compensation for a capability gap. Apply it exactly where the gap exists — the same scaffold that lifts a mid-tier model degrades a frontier one.

## Tier table

| Tier | Models | Load | Suppress |
|---|---|---|---|
| **T1 frontier** | Fable 5 / Mythos class | universal invariants only | all step-enumeration scaffolding |
| **T2 literal** | Opus 4.7/4.8, Sonnet 5 | `planned-execution` (non-trivial tasks), `grounded-loops` (on any failure), `spec-verifier` dispatch before done (multi-step tasks only) | emphatic tool triggers, forced-summary cadence, CoT tags |
| **T3 legacy** | Opus ≤4.6, Sonnet 4.x, Haiku | everything in T2 **plus** CoT tags, forced summaries, plan-first always, best-of-N on high-stakes steps | nothing |

Detection: read the model name from the system prompt/environment. If unsure, assume T2.

## Universal invariants (all tiers — apply verbatim)

- **Evidence-grounded progress**: Before reporting progress, audit each claim against a tool result from this session. Only report work you can point to evidence for; if something is not yet verified, say so. If tests fail, say so with the output; if a step was skipped, say that.
- **Investigate before answering**: Never speculate about code you have not opened. If the user references a specific file, read it before answering.
- **Anti-early-stopping**: Before ending your turn, check your last paragraph. If it is a plan, a question, a list of next steps, or a promise about work not yet done ("I'll…"), do that work now with tool calls.
- **Anti-overengineering**: Only make changes that are directly requested or clearly necessary. A bug fix doesn't need surrounding code cleaned up. Only validate at system boundaries. Don't create helpers or abstractions for one-time operations.
- **Parallel tool calls**: When multiple independent reads/searches are needed, issue them in one batch, not sequentially.

## Token discipline (all tiers — the lowest-cost path to the same result)

- **Map, not codebase**: answer from `.claude/CODEBASE_MAP.md` first; open source files only for the parts you're changing. Read excerpts (offset/limit), not whole files.
- **Delegate reading-heavy exploration** to a subagent (Explore-type) — conclusions come back, raw file contents never enter the main context.
- **Library APIs: resolve, don't guess** — append "use context7" for any unfamiliar/current API (WP hooks, Next.js, package signatures). One doc lookup is cheaper than one wrong-signature retry loop.
- **Never re-read what you just wrote or edited** — the edit result already confirms it. Never re-verify what's already evidenced this session.
- **CLI over MCP when both exist** (`gh`, `git`, `psql`): zero tool-definition overhead.
- **Lean replies**: don't restate diffs, don't summarize unchanged plans, don't narrate tool calls. Findings and decisions only.
- **Retries are bounded**: on failure, `grounded-loops` — quoted evidence, 3-attempt cap, then switch strategy. Flailing is the single biggest token sink.

## Tier-conditional snippets

**Planning**
- T2/T3: "Before making any changes, read the relevant files and write a step-by-step implementation plan. Do not modify files until the plan is confirmed." *Gate: skip when the diff can be described in one sentence.*
- T1 (inverse): "When you have enough information to act, act. Do not re-derive established facts, re-litigate decided questions, or narrate options you will not pursue."

**Reasoning**
- T3 only: "Reason through the problem inside `<thinking>` tags, then give your final result inside `<answer>` tags."
- T2: no CoT scaffolding — raise reasoning effort to high/xhigh instead of prompting around it. With thinking off, avoid the word "think"; use consider/evaluate/reason through.

**Progress updates**
- T3: "After completing a task that involves tool use, provide a quick summary of the work done."
- T1/T2: default to silence between tool calls. Only write text when you find something, change direction, or hit a blocker — one sentence each.

**Tool triggers**
- T3: keep emphatic triggers ("You MUST use X when…").
- T2: plain conditionals ("Call this when…"). Never reintroduce shouting on 4.7+.

**Scope literalism (T1/T2)**
- When an instruction should apply broadly, say so explicitly ("Apply this to every section, not just the first").
- Review tasks: "Report every issue you find, including low-severity and uncertain ones, with confidence + severity — a downstream filter will rank them."

**Long tasks (compaction-capable harnesses)**
- "Your context window is compacted automatically as it approaches its limit. Do not stop tasks early due to token budget concerns."

## The frontier sandwich (routing, not scaffolding)

For big tasks on a budget, route by phase — deep reasoning concentrates in
planning and review, not execution:

1. **Plan on the strongest model** (~10% of tokens): run /task or /build on
   Fable/Opus until `plan.md` is written and confirmed. The plan turns the
   task into steps small enough that a T2 model executes each at its ceiling.
2. **Execute on Sonnet** (~80%): switch the session model (`/model`); the
   plan file carries the intelligence across the switch. Follow
   `planned-execution` Phase 4 — one step at a time, verify each.
3. **Verify on the strongest model** (~10%): `spec-verifier` is already
   pinned to the strongest alias; dispatch it at the done gate as usual.

Switch points: after plan confirmation (strongest → Sonnet), and only switch
back if execution hits the `grounded-loops` escalation ladder step 4.
Expected economics: ~90% of frontier quality at ~30% of the cost on
multi-step tasks. Skip the sandwich for small tasks — the model switch
overhead isn't worth it under ~5 plan steps.

## De-prescription rule

On every model upgrade, re-run a representative task with the lower-tier layer removed and keep whichever output is better. Prune any static instruction that fails the test: *would removing it cause mistakes?*
