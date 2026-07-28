---
name: codebase-graph
description: Query a deterministic code graph instead of grepping — use for "what calls X", "what breaks if I change X", "where is this wired", impact analysis before edits, and finding architectural hubs. Requires graphify; build/refresh with `graphify update .`.
---

# Codebase Graph

`graphify` parses the repo into a graph with tree-sitter — no LLM, no
embeddings, no vector store. Build is seconds and costs nothing. Queries
return `file:line` sets with a token budget, replacing multi-turn
grep→read→follow-imports exploration.

**This does not replace `CODEBASE_MAP.md`.** The map holds what a parser
cannot know: conventions, gotchas, lane ownership, why things are the way
they are. The graph answers structural questions. Use both.

## Build and refresh

```bash
graphify update .            # ~4s on a 400-file repo; no LLM
```

Refresh after any branch switch, pull, or your own multi-file change — a
stale graph confidently reports the old structure, which is worse than no
graph. Cheap enough to re-run whenever in doubt.

Output lands in `graphify-out/` (graph.json ≈ 0.5 MB). Never read that file
into context — query it. Add `graphify-out/` to `.gitignore`.

## The three queries worth knowing

```bash
graphify query "how does login auth work" --budget 2000
graphify affected "useLanguage()" --depth 2
graphify god-nodes --top 10
```

- **`query`** — BFS from matched symbols; returns nodes with `file:line`.
  Start here instead of grep when you don't know where something lives.
  Raise `--budget` if it reports truncation; narrow the question if it
  returns noise.
- **`affected`** — reverse traversal: everything that would break if you
  change X. Run this **before editing any shared symbol**, and before
  touching code near a boundary you don't own. It is the cheapest way to
  catch a change whose blast radius exceeds its diff.
- **`god-nodes`** — most-connected symbols. Architectural hubs; changes here
  are high-risk by definition. Useful when writing or refreshing the map.

Also available: `path "A" "B"` (how two things connect) and `explain "X"`.

## When to use it vs reading files

Graph first for *where* and *what connects*. Read the actual file once the
graph has told you which one — the graph gives structure, not logic. Never
answer a behavioural question from node names alone.

## Delegation

Give workers the query, not the exploration: a brief that says
`run: graphify affected "X"` costs a fraction of a worker grepping its way
through a repo, and on a metered provider that is real money.
