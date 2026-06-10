# Review & Ship Prompt

Use when a feature/branch is "done" and you want it hardened before merge.

---

```
The work on <branch/feature> is functionally complete. Harden it for
shipping. Use the universal-kit agents where they fit
(~/.claude/universal-kit/agents/).

1. DIFF AUDIT — list every file changed vs main and its purpose in one
   line each. Flag anything that doesn't belong to this feature.

2. CODE REVIEW — run /code-review at high effort. Apply the
   code-reviewer agent's standards: correctness first, then
   simplification, then style. Fix what you find.

3. SECURITY PASS — run /security-review. For each surface touched,
   verify the security gate (authn/authz, validation, encoding,
   injection-safe queries, secrets not hardcoded).

4. TEST PASS — run the test suite for affected areas. If coverage of
   the new code is thin, add the missing tests (test-automator agent
   patterns). State the final pass/fail counts.

5. VERIFICATION LOOP — build, typecheck, lint, then drive the actual
   feature end-to-end (webapp-testing for UI, curl/CLI for APIs).
   Capture proof.

6. SHIP REPORT — summarize: what this change does, what was reviewed
   and fixed, test results, verification proof, known limitations.
   Do NOT commit or push unless I say so.
```
