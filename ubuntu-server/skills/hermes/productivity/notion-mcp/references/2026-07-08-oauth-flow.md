# Notion MCP OAuth Flow — Krailynd Setup (2026-07-08)

## Context
- **Date**: 2026-07-08
- **User**: Krailynd (YOUR_NAME)
- **Goal**: Connect Hermes to Notion via MCP server for full read/write access.

## Initial Setup
1. **MCP Server Added**: `notion` server configured in `~/.hermes/config.yaml`:
   ```yaml
   mcp_servers:
     notion:
       url: https://mcp.notion.com/mcp
       auth:
         oauth: true
       enabled: true
   ```
2. **OAuth Flow Initiated**: `hermes mcp login notion` generated a URL for authorization.

## Key Findings

### 1. Token Expiry
- **Issue**: The initial token (`db76318f-01f2-4df2-9c2d-9351f1e677d3:I6ebDa5mFLo8Aco2:...`) **expired** after ~1 hour, causing `401 Unauthorized` errors when calling the Notion API.
- **Root Cause**: Notion MCP tokens are **short-lived** (1 hour by default). The `code_verifier` for PKCE is **not stored** in the system, so the token cannot be refreshed without re-running the OAuth flow.

### 2. PKCE Requirement
- **Issue**: Attempting to exchange the OAuth `code` for a token failed with:
  ```json
  {"error":"invalid_grant","error_description":"Invalid PKCE code_verifier"}
  ```
- **Root Cause**: The `code_verifier` (required for PKCE) was **not saved** during the initial OAuth flow. Without it, the token cannot be refreshed or regenerated from the authorization code.

### 3. Solution: Restart OAuth Flow
- **Step 1**: Delete the expired token:
  ```bash
  rm -f ~/.hermes/mcp-tokens/notion.json
  ```
- **Step 2**: Regenerate the OAuth URL:
  ```bash
  hermes mcp login notion
  ```
- **Step 3**: Open the URL in a browser, authorize, and **copy the full redirect URL** (including `code` and `state`) from the address bar when it fails to redirect to `127.0.0.1:PORT/callback`.
- **Step 4**: Paste the URL back to Hermes to complete the flow.

## Working Example
- **OAuth URL**:
  ```
  https://mcp.notion.com/authorize?response_type=code&client_id=GeOqRFM4Kr0hMevf&redirect_uri=http%3A%2F%2F127.0.0.1%3A17051%2Fcallback&state=fO9qtqQceT-LHZnXQAunTNnLxEhKUcQLtql0BXQy4Ko&code_challenge=2em8hAXRfZlW5wUC08CI5vrOdNDqxdUjXwH5_a2DU0o&code_challenge_method=S256&resource=https%3A%2F%2Fmcp.notion.com%2Fmcp
  ```
- **Redirect URL (Copy This)**:
  ```
  http://127.0.0.1:17051/callback?code=db76318f-01f2-4df2-9c2d-9351f1e677d3%3AIqPi5E6F5SXcH-Ru%3A1a-p9Y4UHPOVtURc9ONK3tE-YroWYvLY&state=fO9qtqQceT-LHZnXQAunTNnLxEhKUcQLtql0BXQy4Ko
  ```

## Verification
- **Check Token**: `cat ~/.hermes/mcp-tokens/notion.json` (should show `access_token`, `refresh_token`, etc.).
- **Test API Call**: Use the token to call the Notion API:
  ```bash
  curl -H "Authorization: Bearer $(jq -r '.access_token' ~/.hermes/mcp-tokens/notion.json)" \
    -H "Notion-Version: 2022-06-28" \
    "https://api.notion.com/v1/search"
  ```

## Lessons Learned
1. **Token Lifespan**: Notion MCP tokens expire after **1 hour**. Plan for re-authorization if sessions exceed this duration.
2. **PKCE Limitation**: The `code_verifier` is **ephemeral**. If the token expires, you **must** restart the OAuth flow.
3. **Redirect Handling**: The OAuth redirect to `localhost` **will always fail** in a remote session. Copy the URL manually.
4. **MCP Server Status**: Even if `hermes mcp list` shows `notion` as `enabled`, the token may still be expired. Always check the token's validity.

## Files Modified
- `~/.hermes/config.yaml`: Added `notion` MCP server.
- `~/.hermes/mcp-tokens/notion.json`: OAuth tokens (auto-generated).
- `~/.hermes/mcp-tokens/notion.client.json`: Client metadata (auto-generated).
- `~/.hermes/mcp-tokens/notion.meta.json`: OAuth endpoint metadata (auto-generated).

## Commands Used
```bash
# Start OAuth flow
hermes mcp login notion

# Verify MCP server
hermes mcp list

# Delete expired token
rm -f ~/.hermes/mcp-tokens/notion.json

# Test API call (manual)
curl -H "Authorization: Bearer <TOKEN>" -H "Notion-Version: 2022-06-28" "https://api.notion.com/v1/search"
```
