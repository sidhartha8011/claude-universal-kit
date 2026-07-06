---
name: tdd-workflow
description: Load when implementing a new feature, fixing a bug, or refactoring — before writing any implementation code. Defines this project's TDD contract: tests first, 80% coverage gate, test placement, and mocking conventions.
---

# TDD Workflow

Non-negotiable contract: tests are written and failing BEFORE implementation. Red → green → refactor, then verify coverage.

## The bar

- **80% minimum** on branches, functions, lines, and statements — enforced via Jest `coverageThresholds` (global: 80 across the board). Run `npm run test:coverage` before declaring done.
- Three layers, all required for a feature: unit (functions/components), integration (API routes, DB ops), E2E (Playwright, critical user flows only).
- No skipped or disabled tests in a finished change. Unit suite stays under ~30s; individual unit tests under ~50ms.
- Start from a user journey ("As a X, I want Y, so that Z"), derive test cases from it — including empty input, fallback paths (e.g. Redis down → substring search), and error paths, not just the happy path.

## File placement

- Unit tests co-located: `Button/Button.test.tsx` next to `Button.tsx`.
- Integration tests co-located with routes: `app/api/markets/route.test.ts`.
- E2E specs in top-level `e2e/` (`markets.spec.ts`, `auth.spec.ts`, ...).

## Conventions

- **Next.js route tests**: import the handler (`GET`/`POST`) from `route.ts` directly and call it with a `NextRequest` — don't spin up a server.
- **Selectors in E2E**: `data-testid` or role/text selectors only. CSS-class selectors are a review fail.
- **Assert user-visible behavior**, never internal state (`component.state.x` is a fail; `screen.getByText(...)` is the pattern).
- **Isolation**: every test creates its own fixtures; no test depends on another's side effects.
- **Mock all external services** in unit/integration tests. House patterns:

```typescript
jest.mock('@/lib/supabase', () => ({
  supabase: { from: jest.fn(() => ({ select: jest.fn(() => ({
    eq: jest.fn(() => Promise.resolve({ data: [/* fixture */], error: null })
  })) })) }
}))

jest.mock('@/lib/openai', () => ({
  generateEmbedding: jest.fn(() => Promise.resolve(new Array(1536).fill(0.1)))
}))
```

(Redis mocks follow the same shape: mock `searchMarketsByVector` and `checkRedisHealth` from `@/lib/redis`.)

## Automation

- Pre-commit hook runs `npm test && npm run lint`.
- CI runs `npm test -- --coverage` and uploads to Codecov; the coverage threshold failing fails the build.

Done means: tests written first, all green, 80%+ coverage, no skips, E2E covers the critical flow.
