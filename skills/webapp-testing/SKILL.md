---
name: webapp-testing
description: Load when you need to drive or verify a local web app in a real browser — checking frontend behavior, capturing screenshots, or reading browser console logs — via ad-hoc Python Playwright scripts (not a committed Playwright test suite).
license: Complete terms in LICENSE.txt
---

# Web Application Testing

Write native Python Playwright scripts (`sync_playwright`, chromium, `headless=True`).

## with_server.py — use as a black box

`scripts/with_server.py` manages server lifecycle around your automation script. Run it with `--help` first; do NOT read its source — it is large and exists to be invoked, not ingested.

```bash
# Single server
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py

# Multiple servers (backend + frontend)
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

Your automation script contains only Playwright logic — the server is already up when it runs.

## Approach

- **Static HTML**: read the file directly to get selectors, then script against a `file://` URL.
- **Dynamic app, server not running**: wrap your script with `with_server.py`.
- **Dynamic app, server already running**: reconnaissance-then-action — navigate, `page.wait_for_load_state('networkidle')`, then screenshot / `page.content()` / `page.locator('button').all()` to discover selectors from the *rendered* DOM, then act.

The one pitfall that actually bites: inspecting the DOM before `networkidle` on a JS-rendered app — you'll see the empty shell. Always wait first.

## Reference examples

`examples/` — `element_discovery.py` (find buttons/links/inputs), `static_html_automation.py` (file:// URLs), `console_logging.py` (capture console output).
