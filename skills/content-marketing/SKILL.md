---
name: content-marketing
description: Full content marketing pipeline — research trending angles, draft platform-specific copy, repurpose across channels, and publish. Covers blogs, LinkedIn, Twitter/X, newsletters, and social carousels.
---

# Content Marketing Skill

A modular pipeline: research → draft → repurpose → (publish). Each stage is discrete so you get clean handoffs and consistent quality across platforms.

---

## Stage 1 — Trend Research

Goal: find 3–5 angles on a topic that are currently resonating.

```
Research trending angles on: [TOPIC]

Return a structured brief with:
- 3–5 subtopics with evidence of traction (search volume, recent coverage, engagement signals)
- One-line hook for each angle
- Freshness flag — skip sources older than 90 days
- Recommended angle ranked #1 with reason

Format: JSON so the next stage can consume it directly.
Output: research_brief.json
```

---

## Stage 2 — Platform-Specific Drafting

Goal: produce copy matched exactly to each platform's format and the brand's voice.

**Format profiles (enforce strictly):**
| Platform | Length | Tone | Structure |
|---|---|---|---|
| Blog post | 1,500–2,500 words | Educational, authoritative | H2/H3 headers, 1 CTA |
| LinkedIn article | 800–1,200 words | Professional, personal | Short paras, no headers |
| LinkedIn post | 150–300 words | Conversational, punchy | Hook line, 3–5 bullets, CTA |
| Twitter/X thread | 8–12 tweets, ≤280 chars each | Direct, engaging | Hook → value → CTA |
| Newsletter | 400–700 words | Warm, direct | Greeting, 3 sections, sign-off |
| Social carousel | 5–7 slides, 1 idea per slide | Bold, scannable | Headline + 2-line body per slide |

```
Draft [FORMAT] on this angle: [ANGLE FROM RESEARCH BRIEF]

Brand voice: [PASTE BRAND VOICE DESCRIPTION OR "professional and clear"]
Audience: [WHO IS READING THIS]
Goal: [inform / convert / nurture / build authority]

Follow the format profile for [FORMAT] exactly — length, structure, tone.
Load brand voice before writing. Do not exceed the word/character limits.
End with a specific CTA relevant to the goal.
```

---

## Stage 3 — Repurposing Pipeline

Goal: extract maximum content from one long-form piece across all platforms.

Two-pass approach (do NOT do this in one shot — quality degrades):

**Pass 1 — Extract:**
```
Analyze this content and extract:
1. Core argument (1 sentence)
2. Top 5 data points or statistics
3. 3–5 quotable sentences (standalone, punchy)
4. 5–7 actionable tips (imperative form)
5. 3 engagement questions for social

CONTENT: [PASTE BLOG POST OR ARTICLE]

Return as structured JSON.
```

**Pass 2 — Generate per platform:**
```
Using these extracted elements: [PASTE PASS 1 OUTPUT]

Generate all of the following (run each through the drafting skill format profiles):
- LinkedIn post
- Twitter/X thread (8 tweets)
- Newsletter section (400 words)
- 6-slide carousel outline

Keep the core argument consistent across all formats.
Vary the hook for each platform — same idea, different entry point.
```

---

## Stage 4 — Pre-Publish Checklist

Before any content goes out, verify:

```
Review this [FORMAT] before publishing:

1. Brand voice — does it sound like us? Flag any off-tone sentences.
2. Facts — are all claims accurate? Flag anything that needs a source.
3. CTA — is there one clear action? Is it specific?
4. Platform fit — does it match the format profile (length, structure)?
5. Hook — would someone stop scrolling for this first line?

CONTENT: [PASTE DRAFT]

Return: APPROVED or a list of specific fixes needed (not vague feedback).
```

---

## Orchestrator — Full Pipeline

Run all stages in sequence for a single topic:

```
Run the full content marketing pipeline for: [TOPIC]

Step 1: Research 3–5 trending angles. Pick the best one.
Step 2: Draft a 1,500-word blog post on the chosen angle.
Step 3: Repurpose into LinkedIn post, Twitter thread, newsletter section, carousel outline.
Step 4: Run pre-publish checklist on each piece.

Brand voice: [DESCRIPTION]
Audience: [TARGET READER]
Goal: [inform / convert / nurture]

Approval gate: after Step 1, show me the chosen angle and wait for confirmation before drafting. After that, run Steps 2–4 autonomously.

Deliver: all pieces in separate clearly labelled sections.
```

---

## Brand Voice Setup

Store once, reference everywhere:

```
BRAND VOICE CONFIGURATION

Tone: [e.g. direct, warm, no-fluff, expert but approachable]
We sound like: [describe in 2 sentences]
We never say: [list 3–5 phrases or patterns to avoid]
Reference content: [paste 2–3 examples of on-brand copy]
Audience: [who reads this, their job, their pain point]
CTA style: [e.g. "soft nudge" vs "direct ask"]
```

Paste this block at the start of any drafting prompt.

---

## Common Mistakes to Avoid

- Generic prompts → always include brand voice + format profile
- One-shot repurposing → always use the two-pass extraction method
- Publishing without review → always run the pre-publish checklist
- Same hook across platforms → vary the entry point per platform
- Skipping the approval gate → always confirm the angle before drafting
