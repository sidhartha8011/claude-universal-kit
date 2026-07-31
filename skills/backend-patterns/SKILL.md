---
name: backend-patterns
description: Load when building or refactoring server-side code — API route handlers, repository/service layers, auth middleware, caching, background jobs, query optimization (N+1, transactions), or structured logging — in Node.js, Express, Next.js API routes, or Supabase-backed apps.
---

# Backend Patterns

House conventions for server-side code. For endpoint contract details (envelope, pagination, status codes) defer to `api-design`.

## Layering

Handler → Service → Repository. Handlers parse/validate and format responses; services hold business logic; repositories are the only layer that touches the DB, behind an interface:

```typescript
interface MarketRepository {
  findAll(filters?: MarketFilters): Promise<Market[]>
  findById(id: string): Promise<Market | null>
  create(data: CreateMarketDto): Promise<Market>
  update(id: string, data: UpdateMarketDto): Promise<Market>
  delete(id: string): Promise<void>
}
```

Cross-cutting concerns (auth, logging, rate limiting) go in HOF middleware wrappers (`withAuth(handler)`), not inline in handlers.

## Database rules

- Select explicit columns, never `select('*')`, on hot paths.
- N+1: batch-fetch related rows by collected IDs into a `Map`, then join in memory. Any `await` inside a loop over query results is a red flag.
- Multi-table writes that must be atomic go in a Postgres function called via `supabase.rpc(...)` — Supabase's JS client has no client-side transactions.

## Caching

Cache-aside via a decorating repository (`CachedMarketRepository` wraps the base repo). Conventions: key = `entity:id` (e.g. `market:${id}`), TTL 300s default, explicit `invalidateCache(id)` on writes. Cache misses fall through to the base repo and backfill.

## Errors

One `ApiError` class carrying `statusCode`, thrown from services; one `errorHandler(error)` at the handler boundary that maps:

- `ApiError` → its status + message
- `ZodError` → 400 with `details: error.errors`
- anything else → log full error server-side, return generic 500 (never leak internals)

Transient external calls retry at **exactly one layer** — every other layer fails fast and propagates, since layered retries multiply (3 attempts at 3 layers = 27 requests hitting an already-degraded dependency). Max 3 attempts with full jitter, `random(0, min(cap, base·2^n))` — fixed 1s/2s/4s synchronises the herd and re-kills the dependency the moment it recovers. Retry only connection failures, timeouts, 429 and 5xx, never 4xx; honour `Retry-After`; and only when the call is idempotent or carries an idempotency key. Set connect *and* overall deadlines on every outbound call, from the dependency's observed p99.9. Concurrency, rollout and partial-failure rules live in `production-runtime`.

## Auth

JWT in `Authorization: Bearer`; `requireAuth(request)` verifies and returns the typed payload `{ userId, email, role }`, throwing `ApiError(401)`. RBAC via a static role→permissions map and a `requirePermission('delete')(handler)` HOF — never inline role string checks in handlers.

## Rate limiting

Sliding-window per identifier (IP from `x-forwarded-for`, or userId). Limiter state belongs in Redis or the gateway — an in-memory Map across N replicas enforces N× the documented tier, so it is single-instance only. Return 429 per api-design conventions.

## Background work

Don't block request handlers on slow work (indexing, embeddings, email). Enqueue and return `202`-style success immediately. In-process queue is acceptable for non-durable work; anything that must survive a restart needs a real queue (e.g. pg-boss, BullMQ).

## Logging

Structured JSON lines only — `{ timestamp, level, message, requestId, trace_id, span_id, userId, ...context }`. Generate a `requestId` per request and thread it through every log entry. `console.log` of bare strings doesn't ship.

Propagate W3C `traceparent` across every service **and queue** boundary — put it in async job payloads too, or traces dead-end at the queue and cross-service requests can only be reconstructed by grepping timestamps. Emit RED metrics (rate/errors/duration) per endpoint *and per outbound dependency call, at the call site*. Metric label values must come from bounded sets (method, status class, route template, service, region) — never user ID, request ID, email, order ID, raw path, or timestamp: unbounded labels are a cardinality explosion that takes down the metrics backend.
