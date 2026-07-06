---
name: deep-research
description: Multi-source deep research using firecrawl and exa MCPs. Use when the user says "research", "deep dive", "investigate", or wants competitive analysis, due diligence, or any synthesis across multiple web sources — deliverable is a cited report.
---

# Deep Research

Produce thorough, cited research reports from multiple web sources.

## Tools

At least one of (both together give best coverage; configure in `~/.claude.json`):
- **firecrawl** — `firecrawl_search`, `firecrawl_scrape`, `firecrawl_crawl`
- **exa** — `web_search_exa`, `web_search_advanced_exa` (supports `startPublishedDate`), `crawling_exa` (`tokensNum` ~5000)

## Approach

Ask 1–2 clarifying questions (goal + angle) unless the user says "just research it" — then use defaults. Break the topic into 3–5 sub-questions and research each.

Coverage targets:
- 2–3 keyword variations per sub-question, mixing general and news queries
- 15–30 unique sources total; prioritize academic/official/reputable news > blogs > forums
- Deep-read 3–5 key sources in full — never rely only on search snippets

For broad topics, parallelize with subagents (e.g. 3 agents splitting the sub-questions; main session synthesizes).

## Quality Rules

1. Every claim needs a source — no unsourced assertions.
2. Single-source claims get flagged as unverified.
3. Prefer sources from the last 12 months.
4. Acknowledge gaps explicitly; say "insufficient data found" rather than filling in.
5. Label estimates, projections, and opinions as inference, not fact.

## Report Format

```markdown
# [Topic]: Research Report
*Generated: [date] | Sources: [N] | Confidence: [High/Medium/Low]*

## Executive Summary
[3-5 sentences]

## 1..N. [Major Themes]
[Findings with inline citations: Key point ([Source Name](url))]

## Key Takeaways
- [Actionable insights]

## Sources
1. [Title](url) — one-line summary

## Methodology
Queries run, sources analyzed, sub-questions investigated.
```

Delivery: short topics — full report in chat. Long reports — executive summary + takeaways in chat, full report saved to a file.
