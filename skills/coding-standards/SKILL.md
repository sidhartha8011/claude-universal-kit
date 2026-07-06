---
name: coding-standards
description: Load for cross-project code conventions — naming, file/folder layout, immutability, comment policy, test naming — when starting a module, reviewing code quality, or enforcing consistency. For framework specifics use frontend-patterns, backend-patterns, or api-design instead.
---

# Coding Standards

The shared floor across projects. Framework-specific guidance lives in `frontend-patterns`, `backend-patterns`, and `api-design`; the shortest reusable rule layer is `rules/common/coding-style.md`.

## Non-negotiable defaults

- **Immutability**: spread, never mutate — `{ ...user, name }`, `[...items, newItem]`. Direct mutation (`items.push`, `user.name =`) only with a comment justifying it (e.g. measured perf on large arrays).
- **No `any`**: every exported function has typed params and return. Union literals over string types (`status: 'active' | 'resolved' | 'closed'`).
- **Parallel awaits**: independent async calls go through `Promise.all`, not sequential `await`s.
- **Functional state updates** in React when next state depends on previous: `setCount(prev => prev + 1)`.
- **Early returns over nesting**: guard clauses, never 3+ levels of `if`.
- **Named constants for magic numbers**: `const MAX_RETRIES = 3`, `DEBOUNCE_DELAY_MS = 500` — units in the name.

## Naming

- Functions: verb-noun (`fetchMarketData`, `calculateSimilarity`); booleans/predicates read as questions (`isValidEmail`, `isUserAuthenticated`).
- Files: `components/Button.tsx` (PascalCase), `hooks/useAuth.ts`, `lib/formatDate.ts` (camelCase), `types/market.types.ts` (`.types` suffix).
- Tests: name the behavior and condition — `'returns empty array when no markets match query'`, `'falls back to substring search when Redis unavailable'`. AAA structure (Arrange / Act / Assert).

## Project layout (Next.js baseline)

```
src/
├── app/            # App Router (api/, pages, (auth) route groups)
├── components/     # ui/, forms/, layouts/
├── hooks/
├── lib/            # api/ clients, utils/, constants/
├── types/
└── styles/
```

## Comments

Comment WHY, never WHAT. Good: `// Exponential backoff to avoid overwhelming the API during outages`. Bad: `// increment counter`. JSDoc (with `@throws` and `@example`) only on public/exported APIs.

## Review heuristics

Flag on sight: functions past ~50 lines (split by phase: validate → transform → save); `select('*')` on hot queries; swallowed errors (`catch` that neither rethrows nor logs with context); ternary chains for conditional rendering (use stacked `{cond && <X />}`); copy-paste duplication that should be a shared util.

Bias: KISS and YAGNI beat DRY — don't abstract until the third occurrence, and don't build for hypothetical requirements.
