---
name: grounded-loops
description: Load whenever a task attempt fails an external check (test, build, runtime error, rejected review) or before retrying anything. Governs HOW to retry; verification-loop governs WHAT gates to run.
---

# Grounded Loops

**Hard rule:** NEVER include a step that asks you to review or double-check your own answer without new external information. Every verification step MUST cite a concrete external observation — test output, execution trace, compiler error, file content. If no tool, test, or oracle exists for the task, delete the self-correction step entirely; do not substitute "reflect on your answer". (Ungrounded self-review flips more correct answers wrong than it fixes.)

## Loop A — Verify-with-a-tool (default)

1. Produce output.
2. Verify with a tool: run the code, execute the query, run the check.
3. If the tool contradicts the output, revise **with the exact tool output quoted** in your working notes.
4. Re-verify. Max 3 rounds.

## Loop B — Failure memory (on repeated failure)

After each failed round, write a self-reflection: "Evaluator output: `<exact test/tool output>`. In 2–3 sentences, diagnose the specific root cause, then state one concrete change for the next attempt."

Maintain a `Lessons from previous attempts:` block — keep only the last 3 lessons (sliding window). Retry context = original task + lessons block, NOT the full failed transcript.

## Loop C — Self-debugging order (code failures)

On a failing test: FIRST explain the code line by line, THEN explain why it produces this exact result, THEN write the fix. Never "fix this" alone. With no tests, run the explanation step against the spec and fix mismatches.

## Escalation ladder

All loops cap at 3 iterations, then **switch strategy** — models plateau fast within one approach:

1. **Regenerate from scratch.** Do not keep patching a poisoned approach.
2. **Backtrack**: back up to the last decision point, list 3 alternative approaches, score each 1–10 with one line of reasoning, take the best untried one.
3. **Best-of-N** (high-stakes or twice-failed steps only): generate 3–5 candidates; score each with the cheapest available verifier, in priority order: real tests/execution > compiler/type-checker/linter > schema validation > rubric LLM judge; return the winner. For free-form outputs: "I have generated the following responses: `<numbered>`. Select the single most consistent response by majority consensus of content. Output only the number."
4. **Escalate the review, not the retries**: dispatch the `spec-verifier` agent (pinned to the strongest model alias available, `opus` by default). If `spec-verifier` itself is the failing check, do not re-dispatch it a fourth time — stop and surface the remaining findings to the user.

## Evidence rule

Feedback injected into any retry must be concrete and quoted — the exact failing assertion, the exact FAIL criterion. Never "the previous attempt was insufficient".
