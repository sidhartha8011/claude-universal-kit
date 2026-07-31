---
name: production-runtime
description: Load when a change touches something that can only fail under concurrency, rollout, or partial failure — DB migrations and schema changes, transactions, connection pools or serverless DB clients, a write path that reads-then-writes, webhook receivers, queue/stream consumers, cron or background jobs, retry/timeout/circuit-breaker code, process shutdown, health probes, or graceful-degradation paths. Also before a first production deploy. Do NOT load for UI work, pure functions, read-only endpoints, test-only changes, or refactors that introduce no new I/O.
---

# Production Runtime

Failures that types, lint, unit tests, and code review cannot see. Each rule
is a check, not a philosophy.

## Concurrent writes

- Never `SELECT` then `INSERT`/`UPDATE` across two round-trips to decide a
  write. Use one atomic statement: `UPDATE … WHERE <guard>` and check the
  affected-row count, `INSERT … ON CONFLICT DO UPDATE`, or `SELECT … FOR UPDATE`.
- Back every uniqueness invariant with a DB unique/exclusion constraint. An
  application-level existence check is never the enforcement mechanism.
- Money, quota, and counters: change by delta in SQL (`SET n = n - 1 WHERE n > 0`),
  never read-modify-write in application code.

## Schema changes

- Schema and code ship as **separate deploys**, in order:
  expand → dual-write → backfill → migrate reads → contract.
- Every migration must be N-1 compatible: during a rolling deploy, old and new
  code run against one schema.
- No in-place column rename. Dropping a column is two deploys (ORM ignore-list
  first, drop second).
- `CREATE INDEX CONCURRENTLY`, outside a DDL transaction. Add FK/CHECK/NOT NULL
  as `NOT VALID`, then validate in a separate migration — the naive forms take
  table locks that were instant in staging and are minutes of downtime in prod.
- No volatile defaults, stored generated columns, or drop-and-recreate on an
  existing large table.
- Write **and execute** the `down` migration before merge.

## Transactions and connections

- No network I/O between BEGIN and COMMIT — no HTTP, payment call, queue
  publish, S3 put, or email. Batch reads before; keep only the minimum atomic
  SQL inside.
- Serverless/edge: instantiate the DB client once at module scope, route through
  a transaction-mode pooler, `connection_limit=1`.
- Size pools from downstream capacity, not expected concurrency:
  `pool_size × max_instances < downstream max_connections`.

## Retries and deadlines

- Retries live at **exactly one layer**; every other layer fails fast and
  propagates. Layered retries multiply — 3 attempts at 3 layers is 27 requests
  against an already-degraded dependency.
- Max 3 attempts, full jitter: `sleep = random(0, min(cap, base·2^n))`.
  Un-jittered backoff synchronises the herd and re-kills the dependency on
  recovery.
- Retry only connection failures, timeouts, 429, and 5xx. Never 400/401/403/404/422.
  Honour `Retry-After`.
- Retry only what is idempotent or carries an idempotency key; otherwise a
  timeout is an ambiguous failure, and retrying a POST double-charges.
- Every outbound call sets connect **and** overall deadlines, derived from the
  dependency's observed p99.9 — not a round number.

## Webhooks and consumers

- Verify the HMAC over **raw request bytes**, constant-time compare, *before*
  any JSON body parser — mount the raw-body parser on that route specifically,
  never globally. If a signature won't verify, fix the byte handling; never
  weaken verification.
- Dedupe on the provider's event ID, in a store whose TTL outlives the
  provider's full retry window. Every provider is at-least-once.
- Ack fast (200/202); push real work to a durable queue.
- Never assume ordering. Apply changes via state-transition guards ("only if
  current state is X"), not arrival order.

## Jobs and cron

- Every consumer: max-attempt cap, dead-letter queue, poison-message handling,
  idempotent execution.
- Every scheduled job: overlap protection (advisory lock or lease), and it must
  tolerate running twice.
- Enqueue transactionally — write the job row inside the state-change
  transaction and drain after commit. Never `await db.save(); await queue.publish()`:
  if the publish fails, the intent was never durably recorded.

## Lifecycle and probes

- SIGTERM order is fixed: fail readiness → stop accepting work → drain in-flight
  under a bounded deadline → close pool/workers/Redis gracefully (`worker.close()`,
  `quit()` — not kill/disconnect) → exit 0.
- `terminationGracePeriodSeconds` must exceed the total drain budget; add a
  `preStop` sleep of 5–15s.
- **Readiness checks only whether this instance can serve. Liveness checks only
  self-deadlock.** Neither may check a downstream dependency — a DB-checking
  readiness probe turns a 2-second blip into a full outage by pulling every
  replica at once.

## Bounds and degradation

- Classify each dependency **hard** or **soft**. Soft dependencies get an
  explicit degraded path (stale cache, default, partial response) and never
  propagate their error to the user.
- Every in-memory queue, channel, and buffer has a maximum. When full, shed load
  (429/503) — never buffer without bound.
- Every list endpoint and repository method enforces a server-side max page size
  and validates the client `limit`. A bare `.all()` / `findAll()` / `fetchall()`
  is a blocking finding.
- Validate the whole env/config schema at process start and exit non-zero on a
  missing required var. No `process.env.X || default` for required config.

## Before first production deploy

Runtime behaviour is not verified by a green build. Confirm by observation:
the service starts from a cold config, a rollback actually rolls back, the
degraded path has been exercised with the soft dependency down, and one real
request has been traced end to end.
