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

Transient external calls (APIs, upstreams) retry with exponential backoff: 3 attempts, delays 1s/2s/4s.

## Auth

JWT in `Authorization: Bearer`; `requireAuth(request)` verifies and returns the typed payload `{ userId, email, role }`, throwing `ApiError(401)`. RBAC via a static role→permissions map and a `requirePermission('delete')(handler)` HOF — never inline role string checks in handlers.

## Rate limiting

Sliding-window per identifier (IP from `x-forwarded-for`, or userId). In-memory Map is fine single-instance; use Redis when horizontally scaled. Return 429 per api-design conventions.

## Background work

Don't block request handlers on slow work (indexing, embeddings, email). Enqueue and return `202`-style success immediately. In-process queue is acceptable for non-durable work; anything that must survive a restart needs a real queue (e.g. pg-boss, BullMQ).

## Logging

Structured JSON lines only — `{ timestamp, level, message, requestId, userId, ...context }`. Generate a `requestId` per request and thread it through every log entry. `console.log` of bare strings doesn't ship.
