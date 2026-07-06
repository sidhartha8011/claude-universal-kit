---
name: content-marketing
description: Content marketing pipeline — research trending angles, draft platform-specific copy (blog, LinkedIn, Twitter/X, newsletter, carousel), repurpose long-form across channels, and pre-publish review. Use for any marketing content drafting or multi-platform repurposing request.
---

# Content Marketing

Pipeline: research → draft → repurpose → review. Discrete stages, clean handoffs.

## Stage 1 — Trend Research

Find 3–5 angles with evidence of current traction (search volume, recent coverage, engagement). Skip sources older than 90 days. Deliver: one-line hook per angle, a ranked recommendation with reason, structured (JSON) so drafting can consume it. **Approval gate: confirm the chosen angle with the user before drafting; run the rest autonomously.**

## Stage 2 — Platform Format Profiles (enforce strictly)

| Platform | Length | Tone | Structure |
|---|---|---|---|
| Blog post | 1,500–2,500 words | Educational, authoritative | H2/H3 headers, 1 CTA |
| LinkedIn article | 800–1,200 words | Professional, personal | Short paras, no headers |
| LinkedIn post | 150–300 words | Conversational, punchy | Hook line, 3–5 bullets, CTA |
| Twitter/X thread | 8–12 tweets, ≤280 chars each | Direct, engaging | Hook → value → CTA |
| Newsletter | 400–700 words | Warm, direct | Greeting, 3 sections, sign-off |
| Social carousel | 5–7 slides, 1 idea per slide | Bold, scannable | Headline + 2-line body per slide |

Every draft needs: brand voice loaded before writing, a defined audience and goal (inform / convert / nurture / build authority), hard adherence to the length limits, and one specific CTA matched to the goal.

## Stage 3 — Repurposing (two-pass, never one-shot)

One-shot repurposing degrades quality. Always split:

**Pass 1 — Extract** from the long-form piece, as structured JSON:
1. Core argument (1 sentence)
2. Top 5 data points or statistics
3. 3–5 quotable sentences (standalone, punchy)
4. 5–7 actionable tips (imperative form)
5. 3 engagement questions for social

**Pass 2 — Generate** each target format from the extracted elements, applying the Stage 2 profiles. Keep the core argument identical across formats; vary the hook per platform — same idea, different entry point.

## Stage 4 — Pre-Publish Review

Verdict is APPROVED or a list of specific fixes (never vague feedback). Check:
1. Brand voice — flag any off-tone sentences
2. Facts — flag claims needing a source
3. CTA — one clear, specific action
4. Platform fit — matches the format profile (length, structure)
5. Hook — would someone stop scrolling for the first line?

## Brand Voice Block

Capture once, paste at the top of every drafting prompt:

```
BRAND VOICE CONFIGURATION

Tone: [e.g. direct, warm, no-fluff, expert but approachable]
We sound like: [2 sentences]
We never say: [3–5 phrases or patterns to avoid]
Reference content: [2–3 examples of on-brand copy]
Audience: [who reads this, their job, their pain point]
CTA style: [e.g. "soft nudge" vs "direct ask"]
```

## Failure Modes

- Generic prompts → always include brand voice + format profile
- One-shot repurposing → always two-pass
- Publishing without the Stage 4 review
- Same hook reused across platforms
- Skipping the angle approval gate
