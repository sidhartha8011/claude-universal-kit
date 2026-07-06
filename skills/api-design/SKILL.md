---
name: api-design
description: Load when designing or reviewing REST API contracts — new endpoints, pagination, filtering/sorting params, error envelope shape, versioning, or rate limiting. Defines this project's opinionated conventions (envelope format, cursor pagination, URL naming, deprecation policy).
---

# API Design Conventions

Opinionated defaults for REST APIs. Follow these unless the codebase already does otherwise — consistency with existing endpoints wins.

## URLs

Plural nouns, lowercase, kebab-case: `/api/v1/team-members`. Nested one level for ownership (`/users/:id/orders`). Verbs only for non-CRUD actions: `POST /orders/:id/cancel`, `POST /auth/login`.

## Status codes — house rules

- `201` + `Location` header for creates; `204` for deletes.
- `400` malformed request/JSON; `422` valid JSON, semantically invalid (validation details in body).
- `409` for duplicates/state conflicts (e.g. email taken).
- Never `200` with `"success": false` — the HTTP status is the source of truth.
- `500` bodies never leak internals (stack traces, SQL).

## Response envelope (canonical shapes)

Success:

```json
{ "data": { ... }, "meta": { ... }, "links": { ... } }
```

Error — every error, every endpoint:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Must be a valid email address", "code": "invalid_format" }
    ]
  }
}
```

`code` is a stable machine-readable snake_case string; `details` is per-field and optional. Internal-only APIs may drop the `data` wrapper and return resources flat, but the error shape stays.

## Pagination

| Use case | Type |
|----------|------|
| Admin dashboards, <10K rows, search results | Offset (`?page=2&per_page=20`) |
| Feeds, infinite scroll, large datasets, public APIs | Cursor (default) |

Offset meta: `{ "total", "page", "per_page", "total_pages" }` plus `links.self/next/last`.
Cursor meta: `{ "has_next", "next_cursor" }` — cursor is opaque base64; fetch limit+1 rows to compute `has_next`. Offset breaks past ~100K rows and under concurrent inserts; don't offer it on public list endpoints.

## Filtering, sorting, sparse fields

```
?status=active&customer_id=abc            # equality
?price[gte]=10&price[lte]=100             # comparisons via brackets
?category=electronics,clothing            # OR via comma
?customer.country=US                      # nested via dots
?sort=-featured,price                     # minus = descending, comma = multi
?q=wireless+headphones                    # full-text search
?fields=id,name,email                     # sparse fieldsets
```

## Auth and rate limiting

Bearer tokens for users, `X-API-Key` for server-to-server. Every authenticated resource read checks ownership (404 if missing, 403 if not yours) — no unscoped `findById`.

Rate-limit headers: `X-RateLimit-Limit/-Remaining/-Reset`; on 429 include `Retry-After` and the standard error envelope. Default tiers: anonymous 30/min per IP, authenticated 100/min per user, premium 1000/min per key, internal 10000/min per service.

## Versioning

URL-path versioning (`/api/v1/`). Rules:

- Max 2 live versions (current + previous).
- Additive changes (new fields, new optional params, new endpoints) do NOT bump the version. Removing/renaming fields, type changes, URL or auth changes DO.
- Deprecation: 6 months notice for public APIs, send `Sunset: <http-date>` header, return `410 Gone` after sunset.

## Reference implementation (Next.js route)

Validate with a schema library (Zod/Pydantic); map its issues into the `details` array:

```typescript
const parsed = createUserSchema.safeParse(await req.json());
if (!parsed.success) {
  return NextResponse.json({
    error: {
      code: "validation_error",
      message: "Request validation failed",
      details: parsed.error.issues.map(i => ({
        field: i.path.join("."), message: i.message, code: i.code,
      })),
    },
  }, { status: 422 });
}
const user = await createUser(parsed.data);
return NextResponse.json({ data: user }, {
  status: 201,
  headers: { Location: `/api/v1/users/${user.id}` },
});
```

## Ship gate

An endpoint is done when it: uses the envelope above, validates input via schema, checks authz (ownership or role), paginates list responses, is rate-limited, and matches the field-naming convention (camelCase vs snake_case) of existing endpoints.
