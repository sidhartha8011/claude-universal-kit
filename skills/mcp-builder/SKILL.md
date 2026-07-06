---
name: mcp-builder
description: Guide for creating high-quality MCP (Model Context Protocol) servers in TypeScript (MCP SDK) or Python (FastMCP). Use when building an MCP server to wrap an external API or service — covers tool design, SDK idioms, transport choice, and evaluation.
license: Complete terms in LICENSE.txt
---

# MCP Server Development

Quality bar: an MCP server is good if an LLM can accomplish real-world tasks with it — not if it merely mirrors the API.

## Opinionated Defaults

- **Language**: TypeScript. Best SDK support, works in MCPB and most execution environments, models generate it well.
- **Transport**: Streamable HTTP with **stateless JSON** for remote servers (avoid stateful sessions/streaming — harder to scale). stdio for local servers.
- **Coverage vs. workflow tools**: when uncertain, prioritize comprehensive API coverage over bespoke workflow tools — agents can compose primitives; some clients combine them via code execution.
- **Naming**: consistent service prefix + action-oriented names (`github_create_issue`, `github_list_repos`).
- **Context economy**: concise descriptions; tools should support filtering/pagination and return focused data, not dumps.
- **Errors**: actionable — tell the agent what to try next, not just what failed.

## Tool Design Contracts

Per tool:
- Input schema in Zod (TS) or Pydantic (Python), with constraints and examples in field descriptions.
- Define `outputSchema` and return `structuredContent` alongside text where the SDK supports it (TS: `server.registerTool`; Python: `@mcp.tool`).
- Set annotations: `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`.
- Pagination wherever the API paginates.

Shared infrastructure: one API client with auth, common error-handling helpers, consistent response formatting (JSON vs Markdown per the best-practices doc).

## Reference Material

- Protocol spec: sitemap at `https://modelcontextprotocol.io/sitemap.xml`; fetch pages with `.md` suffix (e.g. `/specification/draft.md`).
- SDK READMEs: `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md` and `.../python-sdk/main/README.md`.
- Bundled guides (load as needed):
  - [MCP Best Practices](./reference/mcp_best_practices.md) — naming, response formats, pagination, transport, security.
  - [TypeScript Guide](./reference/node_mcp_server.md) — project structure, Zod patterns, registration, quality checklist.
  - [Python Guide](./reference/python_mcp_server.md) — FastMCP init, Pydantic models, `@mcp.tool`, quality checklist.
  - [Evaluation Guide](./reference/evaluation.md) — question creation, verification, runner scripts.

## Verify

- TS: `npm run build` must pass. Python: `python -m py_compile`.
- Exercise tools with MCP Inspector: `npx @modelcontextprotocol/inspector`.

## Evaluations (required deliverable)

Create 10 eval questions testing whether an LLM can answer realistic questions using only the server. Process: inspect tools → explore data (read-only) → write questions → solve each yourself to verify the answer.

Each question must be: independent, read-only, complex (multiple tool calls), realistic, verifiable by string comparison, and stable over time.

Output format:

```xml
<evaluation>
  <qa_pair>
    <question>Find discussions about AI model launches with animal codenames. One model needed a safety designation in the format ASL-X. What number X was being determined for the model named after a spotted wild cat?</question>
    <answer>3</answer>
  </qa_pair>
</evaluation>
```
