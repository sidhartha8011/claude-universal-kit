---
name: security-review
description: Load when writing or reviewing code that touches auth, sessions, user input, file uploads, API endpoints, secrets, or payments, and before any production deploy. Defines the mandated patterns and the pass/fail checks.
---

# Security Review

These are the checks that MUST pass and the patterns we mandate. Examples assume Next.js + Supabase — map them to the project's actual stack (e.g. WordPress: nonce + capability check + `$wpdb->prepare()` + escape-on-output on every handler).

## Mandated patterns (non-negotiable)

- **Secrets**: env vars only; fail fast at startup if a required secret is missing. `.env.local` gitignored; production secrets live in the hosting platform (Vercel/Railway). Check git history, not just the working tree.
- **Input validation**: Zod schemas on every external input, whitelist not blacklist. File uploads: enforce size cap (default 5MB), MIME type, AND extension — all three.
- **SQL**: parameterized queries / query builder only. Any string interpolation into SQL is an automatic fail.
- **Tokens**: httpOnly + Secure + SameSite=Strict cookies. Tokens in `localStorage` are an automatic fail.
- **Authorization**: explicit role/ownership check at the top of every mutating handler — never rely on the UI hiding the button. Supabase: RLS enabled on ALL tables, with per-operation policies; an unprotected table is a fail even if the API layer checks.

  ```sql
  ALTER TABLE users ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Users view own data"   ON users FOR SELECT USING (auth.uid() = id);
  CREATE POLICY "Users update own data" ON users FOR UPDATE USING (auth.uid() = id);
  ```
- **XSS**: user-provided HTML goes through DOMPurify with an explicit `ALLOWED_TAGS` whitelist before any `dangerouslySetInnerHTML`. CSP header set in `next.config.js`; baseline policy:

  ```
  default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;
  font-src 'self'; connect-src 'self' <your-api-origins>
  ```
- **CSRF**: SameSite=Strict on all cookies plus CSRF token verification on state-changing routes.
- **Rate limiting**: on every API route. Default 100 req/15min; expensive endpoints (search, AI, email) get ~10 req/min. Both IP-based and per-user for authenticated routes.
- **Error/log hygiene**: generic error messages to clients, details only to server logs. Never log passwords, tokens, card data (log `last4` at most). No stack traces in responses.
- **Dependencies**: `npm audit` clean, lockfile committed, `npm ci` in CI.

## Required security tests

Every protected surface ships with tests asserting:
- unauthenticated request → 401
- authenticated-but-wrong-role → 403
- malformed input → 400
- burst past the rate limit → at least one 429

## Pre-deploy gate

All of the mandated patterns above verified, plus: HTTPS enforced, CORS restricted to known origins, security headers (CSP, X-Frame-Options) present. Any single failure blocks the deploy.

References: [OWASP Top 10](https://owasp.org/www-project-top-ten/), [Next.js Security](https://nextjs.org/docs/security), [Supabase Auth](https://supabase.com/docs/guides/auth).
