---
name: model-adaptation
description: Model-tier routing for delegated work — loaded by /worker, /build, and /genesis. Detects the running model tier and selects which boost skills and prompt snippets apply; weaker tiers get explicit process scaffolding, frontier tiers get it stripped. Also defines the worker brief contract and cross-provider (GLM) delegation. Not needed for plain /task.
---

# Model Adaptation

Scaffolding is compensation for a capability gap. Apply it exactly where the gap exists — the same scaffold that lifts a mid-tier model degrades a frontier one.

## Tier table

| Tier | Models | Load | Suppress |
|---|---|---|---|
| **T1 frontier** | Fable 5 / Mythos class, **Opus 5** | universal invariants **+ the T1 restraint block below** | all step-enumeration scaffolding, and every self-verification instruction |
| **T2 literal** | Opus 4.7/4.8, Sonnet 5 | `planned-execution` (non-trivial tasks), `grounded-loops` (on any failure), `spec-verifier` dispatch before done (multi-step tasks only) | emphatic tool triggers, forced-summary cadence, CoT tags |
| **T3 legacy / open-weight** | Opus ≤4.6, Sonnet 4.x, Haiku, GLM-4.x **and GLM-5.x**, Kimi K2.x, DeepSeek V3.x/R1, Qwen3-Coder | everything in T2 **plus** CoT tags, forced summaries, plan-first always, named file paths in every instruction, best-of-N on high-stakes steps | nothing |

Detection: read the model name from the system prompt/environment. If unsure, assume T2. Non-Anthropic models arrive via an Anthropic-compatible endpoint and report a Claude-shaped alias, so the model string lies — **check the endpoint**. One Bash call settles it:

```bash
echo "${ANTHROPIC_BASE_URL:-api.anthropic.com}"
```

Anything other than `api.anthropic.com` (z.ai, moonshot, …) is a third-party model: **treat as T3** regardless of what the model claims to be. Worth running at Step 0 of any session that might be routed. These tiers degrade on long autonomous runs and tool-call chains well before they degrade on single edits: shorten steps rather than adding prose.

## Universal invariants (all tiers — apply verbatim)

- **Evidence-grounded progress**: Before reporting progress, audit each claim against a tool result from this session. Only report work you can point to evidence for; if something is not yet verified, say so. If tests fail, say so with the output; if a step was skipped, say that.
- **Investigate before answering**: Never speculate about code you have not opened. If the user references a specific file, read it before answering.
- **Anti-early-stopping**: Before ending your turn, check your last paragraph. If it is a plan, a question, a list of next steps, or a promise about work not yet done ("I'll…"), do that work now with tool calls.
- **Anti-overengineering — the ladder**: before writing code, climb it and stop at the first rung that holds:
  1. Does this need to exist? → skip it (YAGNI)
  2. Already in this codebase? → reuse it, don't rewrite it
  3. Stdlib / language builtin does it? → use it
  4. Native platform feature (WordPress core, browser API, framework)? → use it
  5. Already-installed dependency? → use it
  6. One line? → write one line
  7. Only then: the minimum implementation that satisfies the requirement

  Lazy about solutions, never about reading — the ladder applies *after*
  understanding the problem: read the affected code and trace the real flow
  before choosing a rung. Rung 2 requires an actual search, not a guess.
  Never lazy on: trust-boundary validation, data-loss handling, security,
  accessibility. A bug fix doesn't need surrounding code cleaned up. Don't
  create helpers or abstractions for one-time operations.
- **Parallel tool calls**: When multiple independent reads/searches are needed, issue them in one batch, not sequentially.

## Token discipline (all tiers — the lowest-cost path to the same result)

**Cache shape beats token count.** Measured across ~2,900 billed agent runs
(arXiv 2607.12161): cache create+read is ~**87%** of the bill, output ~10%,
uncached input ~1%. One arm cut tokens 38.4% and still cost **more**. So:

- **Don't churn the stable prefix mid-session.** `CLAUDE.md`, the map, and
  loaded skills sit at the front of context; editing them mid-task
  invalidates the cache and re-bills everything after. Batch such edits at
  a natural break, or accept the re-read knowingly.
- **Stable context first, volatile last.** Read the map and conventions
  early; keep churning output (`git status`, logs, test runs) later in the
  turn so it doesn't sit in front of everything else.
- **Judge a change by cost, not token count.** Fewer tokens ≠ cheaper —
  verify with `ccusage`, and treat any tool claiming a token-percentage win
  without a cost number as unproven.

- **Map, not codebase**: answer from `.claude/CODEBASE_MAP.md` first; open source files only for the parts you're changing. Read excerpts (offset/limit), not whole files.
- **Delegate reading-heavy exploration** to a subagent (Explore-type) — conclusions come back, raw file contents never enter the main context. *T2/T3 only:* on T1 see the restraint block — those models already delegate readily and the nudge compounds.
- **Library APIs: resolve, don't guess** — append "use context7" for any unfamiliar/current API (WP hooks, Next.js, package signatures). One doc lookup is cheaper than one wrong-signature retry loop.
- **Never re-read what you just wrote or edited** — the edit result already confirms it. Never re-verify what's already evidenced this session.
- **CLI over MCP when both exist** (`gh`, `git`, `psql`): zero tool-definition overhead.
- **Lean replies**: don't restate diffs, don't summarize unchanged plans, don't narrate tool calls. Findings and decisions only.
- **Retries are bounded**: on failure, `grounded-loops` — quoted evidence, 3-attempt cap, then switch strategy. Flailing is the single biggest token sink.

## Tier-conditional snippets

### T1 restraint block (Opus 5 and later frontier models)

T1 used to be purely subtractive. Opus 5 is the first tier where the
frontier branch has to *add* constraints back — its failure mode is
over-reach, not under-performance. Anthropic documents four tendencies:
it self-verifies unprompted, delegates readily, narrates and corrects
more, and expands scope on its own judgment. Counter each:

- **Delete every verification instruction.** Explicit "verify each step",
  "double-check before responding", or "dispatch a subagent to verify"
  compounds with behaviour the model already has: pure cost, no quality
  gain. **This is a deletion, not a replacement** — see the verification
  note below for the one case that survives.
- **Delegation cap**: "Delegate only for large tasks that are genuinely
  independent and parallelizable. Don't delegate work you can finish in a
  handful of tool calls, and never use a subagent to verify your own work.
  If one subagent suffices, use one; keep spawn counts low."
  Fan-out measures at **2.6–5.9× the tokens and is never faster** (metered
  logs, Systima Jul 2026) — delegate for coverage you can't get serially,
  never for speed.
- **Scope discipline**: "Deliver what was asked, at the scope intended.
  Make routine judgment calls yourself; check in only when different
  readings would lead to materially different work. If the request seems
  mistaken, say so in a sentence and continue as asked rather than quietly
  narrowing, widening, or transforming it."
- **Corrections**: "Only correct an earlier statement when the error would
  change the user's code, conclusions, or decisions. Otherwise make the fix
  and move on without noting it."
- **Length**: conversational output and written files both run longer than
  on prior models, and lowering effort does *not* shorten them. For skills
  that write documents: "Match document length to what the task needs;
  don't pad with filler sections, redundant summaries, or boilerplate."

**The verification carve-out.** "Don't verify your own work" is about the
*same* model checking what it just produced. Verifying a **different**
model's output is not self-verification and still pays — keep the
`spec-verifier` gate wherever a GLM or worker-tier model wrote the code
(`/task-glm`, `/task-glm-support`, mixed-tier `/worker` runs). Drop it when
a T1 model did the work itself.

Anthropic's own page cuts both ways here: its capability notes praise
"effective writer-verifier patterns" for multi-agent work while the
subagent snippet forbids verification subagents — which reads as a *cost*
objection to verifying trivial work, not a quality finding. So scope the
gate rather than deleting it: end of task, never per-step, and not on small
diffs. External deterministic gates (build, tests, type-check) are the part
every source agrees on — those are checks, not instructions to be diligent.

**Planning**
- T2/T3: "Before making any changes, read the relevant files and write a step-by-step implementation plan. Do not modify files until the plan is confirmed." *Gate: skip when the diff can be described in one sentence.*
- T1 (inverse): "When you have enough information to act, act. Do not re-derive established facts, re-litigate decided questions, or narrate options you will not pursue."

**Reasoning**
- T3 only: "Reason through the problem inside `<thinking>` tags, then give your final result inside `<answer>` tags."
- T2: no CoT scaffolding — control depth with the effort parameter, not prompt wording.
- T1: thinking is **on by default**; `high` is the default effort. Reach for `low`/`medium` liberally as the primary cost lever wherever quality holds, and `xhigh` only for demanding agentic work. Effort governs *thinking*, not response length — to shorten output, ask for it explicitly. Never add a rule telling the model not to think or reason; on Opus 5 that increases tag leakage.
- The "with thinking off, avoid the word think" workaround applies **only to T3 / third-party endpoints** now.

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

## Worker mode (inverted sandwich) — when Sonnet-as-driver struggles

Sonnet holding a whole multi-step task drifts: dropped constraints, wrong
files, shallow fixes. If execution shows 2+ spec-verifier rejections, 2+
grounded-loops escalations, or visible quality problems — invert:

1. Session runs on the **strongest model** (it holds `plan.md` and all
   judgment).
2. For each mechanical step, the driver writes a **self-contained brief** —
   exact files, exact change intent, acceptance check, all needed context
   inline (the worker reads nothing else) — and dispatches it to a
   **`sonnet` subagent** via the Agent tool.
3. The driver verifies each result against the step's check before
   dispatching the next. Any brief that fails twice, the driver executes
   itself.

Same economics as the sandwich (cheap tokens still do the labor) but the
weak model never holds the task — only a brief it cannot drift from.

**Routing is a plan-time decision, not an in-flight choice.** Every step
carries a `route:` (glm | sonnet | opus | driver) in `plan.md`, approved at
the confirmation gate. `glm` = a cross-provider worker (see below). Sonnet = scoped single-file mechanical work. Opus
worker = multi-file coherence, careful edits. Driver = genuine judgment
only, justified per step, ≤~20% of steps — a driver that "just does it
itself" is the failure mode: frontier tokens doing labor a worker handles.
Failure reroutes upward (sonnet → opus → driver), never silently.

**Worker brief contract** — every brief includes these four guards, and the
driver rejects any result that violates one:

1. **File allowlist** (vs wrong files): the exact paths the worker may
   touch. If the goal can't be reached within them, return
   `BLOCKED: needs <file>` — never improvise.

   **Workers route around impossible constraints rather than blocking.**
   Observed: told to change `app.py`'s behaviour but allowed only
   `store.py`, a worker left `app.py` untouched (guard held) and instead
   added import-time side effects to `store.py` — violating a project
   convention it was never shown. Tests, acceptance check, and allowlist
   all passed. Only reading the diff caught it. So: state anti-workaround
   explicitly in briefs, and always include the map's relevant conventions
   and gotchas — the worker shares the filesystem, not the map.
2. **Constraint echo** (vs ignored constraints): the brief's constraints
   listed at the end; the worker restates each with how the result
   satisfies it. Missing echo = automatic reject. For code steps, the echo
   states which ladder rung the solution stopped at and why higher rungs
   didn't hold — a worker that skipped to rung 7 without ruling out reuse
   gets rejected.

   **The echo is a claim, not evidence — verify it.** Observed in practice:
   a worker reported "wrote plan.md first, then edited ✓" for a file it
   never created. Before accepting any step, the driver checks the claims
   that leave traces: `ls` the artifacts the brief required, `git status`
   / `git diff` for the actual files touched. Only the acceptance-check
   output (step 4) is self-proving; everything else needs a look.
3. **Diff scope** (vs collateral damage): worker returns the full diff;
   any hunk outside the allowlist = reject. No reformatting, no
   drive-by refactors, no "improvements". No narration comments — a
   comment survives only if it states a constraint the code can't show
   (why, never what); comments describing the change itself = reject.
4. **Runnable acceptance check** (vs false "done"): the brief includes the
   exact command; the worker returns its verbatim output. A completion
   claim without command output is not done.

### Cross-provider workers (Claude drives, GLM executes)

Subagents inherit the session's API endpoint, so a Claude session cannot
spawn a GLM subagent directly. Instead, shell out — the driver calls, via
Bash, from the project directory:

```bash
~/.claude/universal-kit/glm-worker.sh -f brief.md          # always -f or stdin
printf '%s' "$brief" | ~/.claude/universal-kit/glm-worker.sh -
GLM_WORKER_MODEL=glm-4.7   # cheaper tier for trivial steps
GLM_WORKER_CONTRACT=task   # whole-task scope instead of a file allowlist
```

**Never pass a brief inline.** Briefs contain backticks and `$` — the
driver's own shell expands or executes them before the worker ever runs
(verified: an inline brief executed its acceptance command in the driver's
shell, then aborted on `bad substitution`). Long runs exceed the Bash
tool's 10-minute ceiling: redirect to a log, dispatch in the background,
and poll. Check the exit code before interpreting any diff — a run killed
by exhausted z.ai quota leaves a half-applied diff that reads as delivered
work.

It runs the brief headlessly on GLM-5.2 (Z.AI billing, off the Claude
plan) with the four guards above enforced in its system prompt, and
returns the diff summary, the acceptance-check output, and the constraint
echo. The driver verifies that output before dispatching the next brief;
two failures on one brief and the driver does it itself.

Use it when the plan has many mechanical steps and Claude quota is scarce.
Briefs must be fully self-contained — the worker shares the filesystem,
not the conversation.

**Never let a worker-tier model orchestrate its own fan-out.** Cheap tiers
degrade specifically on sub-agent delegation (0.42–0.45 vs 0.85 for
Sonnet-class, arXiv 2607.06906) while staying near-parity on grounding and
retrieval. So: frontier plans and orchestrates, GLM executes and retrieves.
A GLM brief that says "spawn subagents to…" is the one shape to avoid —
`glm-worker.sh` blocks the Agent/Task/Workflow tools for exactly this reason.

The split is not a compromise: on an independent 211-task benchmark
(Faros, Jun–Jul 2026) Claude Code driving GLM-5.2 scored **0.568 at
$0.92/task** against **0.521 at $1.76** for the same harness on Opus 4.8 —
the harness mattered more than the model.

## De-prescription rule

On every model upgrade, re-run a representative task with the lower-tier layer removed and keep whichever output is better. Prune any static instruction that fails the test: *would removing it cause mistakes?*

Prune on a calendar too, not only on upgrades — Claude Code's own system prompt shed >80% of its length across model generations. An audit of 74 real `CLAUDE.md` files found the dominant debt was **length and duplication**, not wrong rules: most contained no stale verification instructions at all. So when trimming, hunt repetition and dead weight first — deleting one wrong rule is rarer than deleting three copies of a right one.
