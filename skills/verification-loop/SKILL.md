---
name: verification-loop
description: The pre-merge gate checklist — build, type-check, lint, tests, security scan, diff review — for /ship, before a PR, or when explicitly asked to verify. Frontier models already verify as they work; do not load this as a routine after-every-change step.
---

# Verification Loop

No change is "done" until verified with evidence. Run the project's real gates and report actual output — never claim a pass you didn't observe.

## Gates (in order)

1. **Build** — must compile. If it fails, stop and fix before anything else.
2. **Types** — `tsc --noEmit` / `pyright`. Fix critical errors before continuing.
3. **Lint** — project's linter (`npm run lint`, `ruff check`).
4. **Tests** — with coverage. Meet the project's configured threshold; if it has none, don't invent a number — report the figure and flag genuinely untested paths.
5. **Security scan** — a real secret scanner (gitleaks/trufflehog) over the diff, not just a grep for `sk-`/`api_key`. This one **blocks**: a leaked credential is not a warning.
6. **Diff review** — `git diff --stat`; check each changed file for unintended changes, missing error handling, edge cases.

An architectural rule that only exists in prose will drift. Where the project
supports it, make the invariant executable and add it here:
- **Import boundaries** — dependency-cruiser / ArchUnit-style check that the
  layering (handler → service → repository) actually holds, so violations fail
  CI rather than waiting for a reviewer to notice.
- **Query counts** — assert the number of queries in tests covering list and
  detail endpoints; an N+1 reintroduced by a refactor is invisible to every
  other gate here.

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

## Long sessions

Run the full suite at meaningful boundaries — a finished milestone, before a PR — not after every function. Frontier models verify their own work as they go; adding checkpoint re-verification on top compounds with that and costs tokens without improving results. On T3/worker-tier models, where self-verification is unreliable, checkpoint more often. PostToolUse hooks are the cheap continuous layer; this skill is the deeper, full-suite pass.
