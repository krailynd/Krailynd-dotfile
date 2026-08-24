# Recent Activity Audit — "What's new in my Notion"

When the user asks "qué hay de nuevo en mi Notion", "qué se creó hoy", "qué
cambió recientemente" — this is a **time-filtered variant** of the workspace
audit. Instead of mapping the full hierarchy, you sort by `created_time` or
`last_edited_time` descending and filter for today/recent window.

## Core technique

`POST /v1/search` with `query: ""` returns everything the integration can see,
including `created_time` and `last_edited_time` for every item. Paginate to
exhaust the full set (can be 1000+ items — use `page_size: 100` and loop
`start_cursor` until `has_more: false`).

Sort results by `created_time` (when the item was first created) or
`last_edited_time` (when it was last touched) descending. Filter for
`created_time.startswith(today_date)` to isolate today's new items.

## Radar pages: content lives in properties, NOT in blocks

The n8n content engine creates "Radar" consolidation pages (e.g.
"Radar IA/Tech - 23 jul. 2026", "Radar Fútbol", "Radar Gaming"). These pages
have **zero child blocks** — `GET /v1/blocks/{id}/children` returns an empty
results array. All their content is stored in **page properties** as
`rich_text` fields:

| Property | Contains |
|----------|----------|
| `Resumen` | Bullet-point list of sources (`• [Blog Oficial] Title...`) |
| `Mini Guion (Skeleton)` | Structured guion: HOOK → CONTEXTO → PUNTO 1/2/3 → CTA |
| `Hook` | One-line hook for content |
| `Nicho` | select: "IA / Herramientas / Open Source", "Gaming", "Fútbol", etc. |
| `Validación Editorial` | select: "Sin revisar" by default |
| `Fuentes` | relation array — links to Content Sources entries |
| `Origen de la Idea` | select: "Noticia", "Tendencia", "Polémica", etc. |
| `Tipo Temporal` | select: "Noticia", "Tendencia", "Aprendimiento Aplicable" |
| `Related to Guiones Maestros (Idea Origen)` | relation — present when a Guion Maestro exists |

To read a Radar page's content, use `GET /v1/pages/{id}` and iterate
`properties.*.rich_text[].plain_text` — do NOT waste a call on
`/blocks/{id}/children` (it returns nothing).

## "Guion Maestro" pages

Some Radar pages have a companion page with "— Guion Maestro" appended to the
title (e.g. "Radar IA/Tech - 23 jul. 2026, 4:01 a. m. — Guion Maestro"). These
DO have child blocks with the full script (B-ROLL cues, paragraphs, graficos).
Use `/blocks/{id}/children` for these — the blocks contain the structured
guion text directly.

## Grouping sources

After filtering for today's items, separate them:
1. **Consolidated pages** — titles starting with "Radar" (or similar
   pattern). These are the user-facing deliverables.
2. **Individual source pages** — everything else, typically created inside a
   Content Sources database (`parent.database_id` matches a DB ID).

Group individual sources by `parent.database_id` to show which database they
belong to and how many new entries each DB received.

## Reproducible script (execute_code)

The audit can be done entirely from `execute_code` using Python stdlib
(`urllib.request`, `json`, `dotenv`). No `ntn` or `curl` needed — load the
token from `~/.hermes/.env` via `dotenv.load_dotenv()` and call the API
directly. This is faster and more reliable than `hermes chat -z` or MCP for
read-heavy operations.

```python
import os, json, urllib.request, urllib.error
from dotenv import load_dotenv
from datetime import datetime, date, timezone, timedelta
from collections import defaultdict

load_dotenv(os.path.expanduser("~/.hermes/.env"))
TOKEN = os.environ.get("NOTION_API_KEY", "")
LIMA_TZ = timezone(timedelta(hours=-5))  # adjust per user timezone

def notion_api(endpoint, method="POST", body=None):
    url = f"https://api.notion.com/v1{endpoint}"
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method, headers={
        "Authorization": f"Bearer {TOKEN}",
        "Notion-Version": "2022-06-28",
        "Content-Type": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return {"error": e.code, "msg": e.read().decode()[:200]}

def get_title(item):
    if item["object"] == "page":
        props = item.get("properties", {})
        for val in props.values():
            if val.get("type") == "title" and val.get("title"):
                return val["title"][0]["plain_text"]
        return "(sin título)"
    elif item["object"] == "database":
        titles = item.get("title", [])
        return titles[0]["plain_text"] if titles else "(DB sin título)"
    return "?"

# Paginate full workspace
all_results = []
start_cursor = None
for _ in range(10):  # up to 1000 items
    body = {"page_size": 100, "query": ""}
    if start_cursor:
        body["start_cursor"] = start_cursor
    r = notion_api("/search", "POST", body)
    if "error" in r:
        break
    all_results.extend(r.get("results", []))
    if not r.get("has_more"):
        break
    start_cursor = r.get("next_cursor")

# Filter for today
today = date.today().isoformat()  # "2026-07-23"
today_items = [i for i in all_results if i.get("created_time", "").startswith(today)]

# Separate Radar (consolidated) from sources
radar = [i for i in today_items if get_title(i).lower().startswith("radar")]
sources = [i for i in today_items if not get_title(i).lower().startswith("radar")]

# Read Radar page properties for content
for rp in radar:
    page_data = notion_api(f"/pages/{rp['id']}", "GET", None)
    props = page_data.get("properties", {})
    for key, val in props.items():
        if val.get("type") == "rich_text":
            text = "".join(rt.get("plain_text", "") for rt in val.get("rich_text", []))
            if text.strip():
                print(f"  [{key}]: {text[:500]}...")
```

## Output format for the user

Present as a summary table of consolidated pages (Radar) with:
- Title (with Lima/local timestamp)
- Niche (from the `Nicho` select property)
- Source count (from the `Fuentes` relation array length)
- Whether a Guion Maestro companion exists

Then a grouped count of individual sources by database parent:
```
Content Sources DB: 352 new entries
Companies/Assets/Risks DB: 8 new entries
```
