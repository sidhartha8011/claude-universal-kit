---
name: verification-loop
description: Run before declaring any code change done, before creating a PR, or after a refactor — execute build, type-check, lint, tests, and a diff review, and back every "it works" claim with command output as evidence.
---

# Verification Loop

No change is "done" until verified with evidence. Run the project's real gates and report actual output — never claim a pass you didn't observe.

## Gates (in order)

1. **Build** — must compile. If it fails, stop and fix before anything else.
2. **Types** — `tsc --noEmit` / `pyright`. Fix critical errors before continuing.
3. **Lint** — project's linter (`npm run lint`, `ruff check`).
4. **Tests** — with coverage. Target: 80% minimum.
5. **Security scan** — grep the diff for leaked secrets (`sk-`, `api_key`) and stray `console.log` in src.
6. **Diff review** — `git diff --stat`; check each changed file for unintended changes, missing error handling, edge cases.

Use the project's actual commands (check package.json scripts / Makefile) rather than guessing.

## Report Format

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
```

## Continuous Mode

In long sessions, re-verify at checkpoints — after each completed function/component, before moving to the next task — rather than once at the end. PostToolUse hooks catch issues instantly; this skill is the deeper, full-suite pass.
