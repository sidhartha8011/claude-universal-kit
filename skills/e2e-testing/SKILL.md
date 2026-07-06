---
name: e2e-testing
description: Load when writing, configuring, or stabilizing Playwright E2E suites — new spec files, playwright.config.ts changes, CI wiring, flaky-test triage, or testing financial/irreversible flows. Carries the config defaults and quarantine policy.
---

# E2E Testing (Playwright)

Opinionated defaults for stable, maintainable Playwright suites. Structure: specs grouped by domain under `tests/e2e/` (`auth/`, `features/`, `api/`), shared fixtures in `tests/fixtures/`, Page Objects for any page touched by 2+ specs. Selectors are `data-testid` — CSS-class selectors are a fail.

## Config defaults (use unless overridden)

```typescript
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['junit', { outputFile: 'playwright-results.xml' }],
    ['json', { outputFile: 'playwright-results.json' }]
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },
  projects: [chromium, firefox, webkit, 'Pixel 5'], // Desktop 3 + mobile-chrome
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
})
```

## Flakiness policy

- Reproduce first: `--repeat-each=10` on the suspect spec. Don't "fix" what you can't reproduce.
- Quarantine, don't delete: `test.fixme(true, 'Flaky - Issue #123')` or `test.skip(process.env.CI, '... - Issue #123')`. A quarantine without a linked issue is a fail.
- `page.waitForTimeout(...)` is banned in committed tests. Wait on the actual condition: `waitForResponse(resp => resp.url().includes('/api/...'))`, locator auto-waits, `waitFor({ state: 'visible' })`, or `waitForLoadState('networkidle')` before interacting with animated elements.
- Prefer `page.locator(...).click()` (auto-wait) over `page.click(...)`.

## CI

GitHub Actions: `npm ci` → `npx playwright install --with-deps` → `npx playwright test` with `BASE_URL` from vars, then `upload-artifact` of `playwright-report/` with `if: always()` and `retention-days: 30`. Artifacts (screenshots, videos, traces) go under `artifacts/`.

## Financial / irreversible flows

- Hard-skip on production: `test.skip(process.env.NODE_ENV === 'production', ...)` — real money.
- Assert the preview state (amount, direction) before confirming.
- Mock third-party providers (payment SDKs, browser extensions) via `context.addInitScript` before navigation — never drive a real extension or live payment rail in CI.
- Slow external confirmations (payments, webhooks): wait on the API response with an explicit `{ timeout: 30000 }`, not the default.
