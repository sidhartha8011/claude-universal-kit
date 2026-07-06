---
name: frontend-patterns
description: Load when writing React/Next.js UI code — components, custom hooks, state management (Context/reducer), data fetching, forms, memoization/virtualization/code-splitting, Framer Motion animation, or keyboard/focus accessibility work.
---

# Frontend Patterns

House conventions for React/Next.js UIs. These encode specific choices — match them rather than inventing parallel patterns.

## Data boundaries

Examples and fixtures use synthetic data only. Never add analytics, tracking pixels, or third-party scripts without explicit approval. No credentials, tokens, or PII in client state, logs, or localStorage unless the user explicitly scopes such a feature.

## Component conventions

- Composition over configuration: multi-part UIs export sub-components (`Card` / `CardHeader` / `CardBody`), not a mega-component with a dozen props.
- Stateful multi-part widgets (tabs, accordions) use the compound-component pattern: context provider in the parent, sub-components read it and `throw new Error('X must be used within Y')` when used outside.
- Context consumers are always wrapped in a typed custom hook (`useMarkets()`) that throws on missing provider — never raw `useContext` at call sites.

## Hooks

Prefer SWR/React Query for real apps. If hand-rolling a fetch hook, the non-obvious part is stability: keep `fetcher` and `options` in refs so `refetch` stays referentially stable when callers pass inline functions — otherwise the effect that calls `refetch` re-runs every render and you get an infinite fetch loop:

```typescript
const fetcherRef = useRef(fetcher)
const optionsRef = useRef(options)
useEffect(() => {
  fetcherRef.current = fetcher
  optionsRef.current = options
})

const refetch = useCallback(async () => {
  // read fetcherRef.current / optionsRef.current here
}, [])
```

Debounce inputs with a `useDebounce(value, delay)` hook (setTimeout + cleanup), standard delay 500ms for search.

## State

Local first (`useState`), `useReducer` + Context for a feature-scoped store with typed action unions, external store (Zustand) only when Context re-renders become a measured problem. Always functional updates when next state depends on previous: `setCount(prev => prev + 1)`.

## Performance

- `useMemo` for expensive derivations; copy before sorting — `[...markets].sort(...)` — because `Array.prototype.sort` mutates in place.
- `React.memo` + `useCallback` only where profiling shows re-render cost; default is no memoization.
- `lazy()` + `Suspense` for heavy components (charts, 3D backgrounds); give charts a skeleton fallback, decorative components `fallback={null}`.
- Lists over ~100 items: virtualize with `@tanstack/react-virtual` (absolute-positioned rows, `overscan: 5`).

## Forms

Controlled inputs; single `formData` object + `errors` object keyed by field; validate on submit, render field errors inline next to the input. Zod schemas when the shape is shared with an API route.

## Errors

One class-based `ErrorBoundary` (there is no hook equivalent) with a retry button that resets `hasError`. Wrap at route/feature level, not around every component.

## Animation (Framer Motion)

Lists: `<AnimatePresence>` with per-item `motion.div`, enter `{ opacity: 0, y: 20 }` → `{ opacity: 1, y: 0 }`, exit `y: -20`, duration 0.3. Modals: separate overlay fade and content scale-up (`scale: 0.9 → 1`), both inside `AnimatePresence` so exit animations run.

## Accessibility

- Custom dropdowns/comboboxes handle ArrowUp/ArrowDown (clamped index), Enter (select + close), Escape (close), with `role="combobox"`, `aria-expanded`, `aria-haspopup="listbox"`.
- Modals: `role="dialog"`, `aria-modal="true"`, `tabIndex={-1}`; on open, save `document.activeElement` in a ref and focus the modal; on close, restore focus to the saved element. Escape closes.
