---
name: sports-event-lookup
title: Sports Event Lookup
description: "Search and extract real-time or scheduled sports event information (fixtures, results, standings) from authoritative sources like FIFA, UEFA, ESPN, or major news outlets. For Formula 1: OpenF1 REST API (free, no auth) is the primary technical data source."
version: 1.1.0
author: Hermes Agent (SahaCloud)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [research, sports, FIFA, World Cup, fixtures, results, live scores, Formula 1, F1, OpenF1]
    category: research
    requires_toolsets: [web, browser]

---

# Sports Event Lookup

## Purpose
Retrieve accurate, up-to-date sports event information (fixtures, results, standings, team details) from authoritative sources. Specialized for time-sensitive queries where official data is critical (e.g., FIFA World Cup, UEFA Champions League, Olympics, **Formula 1**).

For Formula 1 specifically, **OpenF1** is the primary technical data API — free, no auth required, REST JSON. It provides meetings, sessions, session results, drivers, stints, pit stops, race control events, weather, and more. See `references/openf1-api.md` for the full endpoint map, data shapes, and 2026-specific key mapping.

## When to Load
- User asks for **live or scheduled sports event details** (e.g., "Who plays today in the World Cup?", "What are the fixtures for July 1, 2026?", "próxima carrera de F1").
- User requests **historical results** or **standings** for a specific tournament or season.
- User needs **cross-validated data** from multiple sources (e.g., FIFA.com + CNN + BBC, or formula1.com + OpenF1).
- User asks about **F1 race results, stints, pit stops, race control events, or driver data** — use OpenF1 directly.

## Best Practices

### 1. Source Selection
- **Priority 1:** Official sources (e.g., [FIFA.com](https://www.fifa.com) for World Cup, [UEFA.com](https://www.uefa.com) for European competitions).
- **Priority 2:** Major news outlets (CNN, BBC, ESPN, Marca, AS) for real-time updates and analysis.
- **Priority 3:** Aggregators (Flashscore, SofaScore) for live scores and odds.
- **Avoid:** Unverified blogs, social media posts, or forums unless cross-validated.

### 2. Search Queries
- **Include specific dates and event names:**
  - `"FIFA World Cup 2026 fixtures July 1 2026"`
  - `"Mundial 2026 partidos 1 de julio 2026"` (for Spanish-language sources).
  - `site:fifa.com "World Cup 2026" "July 1"` (to restrict to official FIFA site).
- **Use event-specific keywords:**
  - `"octavos de final"` (Round of 16), `"fase de grupos"` (Group Stage), `"cuartos de final"` (Quarterfinals).
- **Add year for time-sensitive queries:** Always include the year (e.g., `2026`) to avoid outdated results.

### 3. Data Extraction
- **Cross-validate:** Compare data from at least **2 independent sources** (e.g., FIFA + CNN) to confirm accuracy.
- **Extract key details:**
  - Teams playing
  - Date and time (convert to user's timezone if possible)
  - Venue (stadium and city)
  - Competition stage (Group Stage, Round of 16, etc.)
  - Scores (if available)
  - Broadcast information (where to watch)

### 4. Handling Dynamic Pages
- **FIFA.com and similar sites:** Use `browser_navigate` + `browser_click` to access fixtures/results pages.
  - Example: Navigate to [FIFA World Cup 2026 fixtures](https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026/scores-fixtures).
  - Click on "MATCHES" or "FIXTURES" menu items.
  - Use `browser_scroll` to reveal more content if the page loads dynamically.
  - Use `browser_snapshot` to extract structured data from the page.
- **Filter by date:** Look for date filters or calendars on the page to isolate the specific day's matches.

### 5. Language Handling
- **For non-English queries:** Use the user's language in search queries (e.g., `"Mundial 2026"` for Spanish-speaking users).
- **Translate results:** If the source is in a different language, translate key details (team names, dates, venues) into the user's language.

### 6. Output Formatting
- **For WhatsApp:** Keep responses concise (≤1500 characters). Use bullet points for clarity.
  - Example:
    ```
    📅 1 de julio de 2026 (Octavos de final)
    - México vs. Inglaterra (12:00 ET)
    - Francia vs. Paraguay (15:00 ET)
    - Brasil vs. Noruega (18:00 ET)
    - Canadá vs. Marruecos (21:00 ET)
    ```
- **For detailed requests:** Provide a structured list with teams, times, venues, and sources.

## Pitfalls
- **Dynamic content:** Some sports sites (e.g., FIFA.com) load data dynamically via JavaScript. Use `browser_snapshot` after scrolling to ensure all content is captured.
- **Timezone confusion:** Always specify the timezone for match times (e.g., ET, GMT, local time).
- **Outdated caches:** Search engines may return outdated fixtures. Prioritize live pages (e.g., FIFA's "Scores & Fixtures" page).
- **Paywalls:** Some news outlets (e.g., ESPN) may have paywalls. Use alternative sources if access is blocked.
- **Rate limits:** Avoid rapid-fire requests to the same site. Use `web_search` for initial discovery, then `browser_navigate` for detailed extraction.

## Example Workflows

### Example 1: World Cup 2026 Fixtures for July 1
1. **Search:** `web_search(query="FIFA World Cup 2026 fixtures July 1 2026", limit=5)`.
2. **Extract:** Use `web_extract` or `browser_navigate` to open the most relevant result (e.g., FIFA.com or CNN).
3. **Validate:** Cross-check with a second source (e.g., BBC or ESPN).
4. **Output:** List matches with teams, times, and venues.

### Example 2: Live Scores for Today
1. **Search:** `web_search(query="FIFA World Cup 2026 live scores today", limit=5)`.
2. **Navigate:** Open the official FIFA live scores page.
3. **Extract:** Use `browser_snapshot` to capture the current scores and match statuses.
4. **Output:** Provide live updates with scores and next fixtures.

## Tools to Use
| Task | Tool | Notes |
|------|------|-------|
| Initial search | `web_search` | Use filters (site:, date ranges) |
| Page navigation | `browser_navigate` | For dynamic or JS-heavy sites |
| Content extraction | `browser_snapshot` | Capture full page content |
| Scrolling | `browser_scroll` | Reveal hidden/dynamic content |
| Clicking | `browser_click` | Access sub-pages (e.g., fixtures tab) |
| Data validation | `web_search` | Cross-check with multiple sources |

## Linked Files
- `references/fifa-world-cup-2026-fixtures-july-1.md` (Extracted fixtures for July 1, 2026, Round of 16)
- `references/openf1-api.md` (OpenF1 REST API endpoint map, data shapes, 2026 session/meeting key table, pitfalls)
- `scripts/extract_fifa_fixtures.py` (Script to automate FIFA fixture extraction)

## Formula 1 — Source Hierarchy

| Data need | Source |
|-----------|--------|
| Official calendar, race status, circuit pages | formula1.com |
| Session results, stints, pits, race control, weather, drivers | OpenF1 REST API (free, no auth) — see `references/openf1-api.md` |
| Conflict between sources | Keep formula1.com as truth; mark OpenF1 data as `Derived` |
| OpenF1 returns empty data | Mark record as `Incomplete`; never invent result |

## F1 — Operational Modes (for automated sync jobs)

Determine mode at start of each execution based on system date vs. calendar:

| Mode | Condition | What to do |
|------|-----------|-----------|
| `LOW_ACTIVITY` | No race in next 7 days, no active session | Validate calendar, fix metadata, avoid writes |
| `PRE_RACE` | Next race ≤7 days away | Confirm race details, session keys, circuit, mark `Active Weekend` |
| `RACE_WEEKEND` | Active session detected | Track stints, pits, race control, weather in near-real-time |
| `POST_RACE` | Race finished ≤48h ago | Consolidate results, enrich stints+strategy, update Finalizados |
| `NO_CHANGES` | Verified, nothing changed | Short summary only; do not spam Notion writes |

## F1 — Key API call sequence (PRE_RACE / POST_RACE)

```bash
# 1. Get meetings for year
curl -s "https://api.openf1.org/v1/meetings?year=2026"

# 2. Get sessions for a specific meeting
curl -s "https://api.openf1.org/v1/sessions?meeting_key=1290"

# 3. Fetch race result
curl -s "https://api.openf1.org/v1/session_result?session_key=11334"

# 4. Get driver name map for the session
curl -s "https://api.openf1.org/v1/drivers?session_key=11334"

# 5. Stints for a driver
curl -s "https://api.openf1.org/v1/stints?session_key=11334&driver_number=16"

# 6. Pit stops for a driver
curl -s "https://api.openf1.org/v1/pit?session_key=11334&driver_number=16"

# 7. Race control (SC, VSC, flags, penalties)
curl -s "https://api.openf1.org/v1/race_control?session_key=11334"
curl -s "https://api.openf1.org/v1/race_control?session_key=11334&category=SafetyCar"
curl -s "https://api.openf1.org/v1/race_control?session_key=11334&flag=RED"

# 8. Weather (start and end conditions)
curl -s "https://api.openf1.org/v1/weather?session_key=11334"
```

## F1 — Pitfalls

- **`meeting_round` is always `None` in 2026** — OpenF1 does not populate this field. Derive round from sorted calendar order or maintain your own mapping.
- **OpenF1 returns empty array `[]` for some races** (observed: Bahrain R4, Saudi R5 in 2026) — unknown root cause, possibly data embargo or delayed ingestion. Mark as `Incomplete`, never invent.
- **`session_result` position field can be `None`** for retirements not classified — handle with `if pos is None: dnf = True`.
- **Race control has 200+ events** for a typical race — filter by `category=SafetyCar` or `flag=RED` for targeted queries instead of grabbing everything and grepping.
- **`web_extract` fails on OpenF1 URLs** — always hit the API with `terminal` + `curl`, not `web_extract`.
- **formula1.com dynamic pages** — `web_search` for calendar overview works; individual race pages are JS-heavy and need browser tools or scraping.
