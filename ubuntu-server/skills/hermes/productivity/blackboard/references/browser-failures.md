# Browser automation failure modes — Blackboard access

Reproduction recipes for failures encountered when trying to reach `upsjb.blackboard.com` via browser automation tools.

## Failure 1: Browserbase (built-in browser tools) — 502 Bad Gateway

**Session:** 2026-07-18  
**Tool chain:** `browser_navigate` → `browser_click` (cookie dialog) → `browser_snapshot`

**Sequence:**
1. `browser_navigate("https://upsjb.blackboard.com/")` → success, page loaded with cookie dialog
2. `browser_click(ref="e17")` (Accept cookies) → "Unknown ref: e17"
3. `browser_snapshot()` → "Auto-launch failed: CDP WebSocket connect failed: HTTP error: 502 Bad Gateway"

**Suspected cause:** Transient Browserbase infrastructure issue. The 502 came from the CDP WebSocket layer, not from Blackboard itself. Snapshot showed "(empty page)" before the 502 — the cookie dialog dismissal may have triggered a redirect that the CDP connection couldn't follow.

**Resolution:** Not resolved in-session. Options: retry later, or fall back to Playwright MCP.

## Failure 2: Playwright MCP — Chrome binary not found

**Session:** 2026-07-18  
**Tool:** `mcp__playwright__browser_navigate`

**Error:**
```
Error: async initializeServer: Chromium distribution 'chrome' is not found at /opt/google/chrome/chrome
Run "npx playwright install chrome"
```

**Attempted fix:** `npx playwright install chrome`
**Result:** Failed — Playwright detected no npm project in the current directory:
```
Please install your dependencies first, and then run Playwright's install command
```

**Root cause:** Playwright MCP requires a Chromium browser binary installed either:
- Via `npx playwright install chrome --with-deps` (needs `@playwright/test` as a project dependency)
- Or a system-level Chromium at `/opt/google/chrome/chrome`

**Resolution:** Not resolved in-session. Requires:
1. `cd /tmp && npm init -y && npm install @playwright/test && npx playwright install chrome`
2. Or `sudo apt install chromium-browser` and symlink to expected path

## Failure 3: Ref IDs becoming stale after browser_type

**Session:** 2026-07-18  

**Sequence:**
1. `browser_type(ref="e6", text="YOUR_UNI_EMAIL")` → Success
2. `browser_click(ref="e9")` → "Unknown ref: e9"

**Root cause:** After a `browser_type` operation that modifies the DOM, the snapshot refs can become stale. A new `browser_snapshot()` call is needed to get fresh refs before further interactions.

**Prevention:** Always call `browser_snapshot()` after `browser_type()` and before clicking any button. The ref IDs are regenerated on each snapshot.