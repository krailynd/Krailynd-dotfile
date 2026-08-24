---
name: google-calendar-automation
description: "Bulk-create scientific schedules in Google Calendar."
version: 1.0.0
author: krailynd
license: MIT
platforms: [linux, macos, windows]
dependencies:
  - productivity/google-workspace
  - productivity/krailynd-google-workspace
metadata:
  hermes:
    tags: [google, calendar, automation, time-blocking, scheduling, scientific]
    related_skills: [productivity/google-workspace, productivity/krailynd-google-workspace, productivity/weekly-review-planning]
---

# Google Calendar Automation — Scientific Time-Blocking

Class-level skill for programmatically creating and managing scientifically-grounded schedules in Google Calendar via the Google Workspace API.

## When to Use

- Creating a full weekly schedule from a time-blocking plan (Deep Work, classes, exercise, meals, sleep, reviews)
- Bulk-creating recurring events with descriptions, locations, and metadata
- Applying color-coding by category (UPSJB, Deep Work, Exercise, Personal, Meals/Sleep, Admin)
- Syncing schedule with Notion databases via n8n webhooks
- Setting up "Heavy Day" blocks (e.g., Friday 3h Deep Work + commits + review)

## Prerequisites

1. `google-workspace` skill authenticated (`setup.py --check` → AUTHENTICATED)
2. `krailynd-google-workspace` wrapper available (provides `calendar.py` CLI)
3. Zone: `America/Lima` (UTC-5) — adjust `--tz` if needed

## Core Concepts

### Scientific Scheduling Parameters (Embedded in Templates)

| Parameter | Value | Source |
|-----------|-------|--------|
| Sleep window | 22:00–5:30 (7.5h) | Walker 2017; 5 complete 90-min cycles |
| Cortisol peak | 6:00–8:00 | CAR window — analytical focus max |
| Ultradian cycles | 90–120 min focus + 20–30 min break | Kleitman 1961; basic rest-activity cycle |
| Caffeine cutoff | 14:00 (Mon–Thu) | t½=5–6h; avoids sleep fragmentation |
| Exercise gate | Mon/Wed/Fri 5:45–6:15 | BDNF ↑, neurogenesis; no exercise → no Deep Work night |
| Commit gate | Thu 17:00 checkpoint | 0 commits → Fri 7:30 urgent code session |
| Free day | Sat 20:30 – Sun 20:00 | Zero work; recovery theory (Meijman) |

### Color-Coding Scheme (Google Calendar Color IDs)

| ColorId | Category | Use For |
|---------|----------|---------|
| 9 (Blue) | UPSJB Clases | Official classes — immutable |
| 10 (Green) | DL Research | Deep Work, projects, paper reading, video editing |
| 6 (Orange) | Ejercicio | HIIT, strength, mobility, active recovery |
| 3 (Purple) | Desarrollo Personal | Books, courses, podcasts, hobbies |
| 11 (Red) | Comidas/Sueño | Sleep, meals, wind-down, NSDR, meditation |
| 5 (Yellow) | Admin/Review | Weekly Review, time-blocking, mise en place |

## Pitfalls & Gotchas

### 1. `calendar.py` Does Not Support `--colorId`

The wrapper script `krailynd-google-workspace/scripts/calendar.py` does **not** accept a `--colorId` argument. Passing it causes `unrecognized arguments` error.

**Workaround**: Create events without color, then batch-edit colors in Google Calendar UI (view → Week → click each event → pencil → Color). Or use the lower-level `google_api.py` directly with the Calendar API `colorId` field.

### 2. Recurrence Must Be Set Manually or Via API

The `calendar.py create` command does not expose `--recurrence`. For true recurring events (RRULE), either:
- Create single instances for a base week, then edit each in UI → "Repeat weekly"
- Use `google_api.py calendar create` with the API's `recurrence` field (requires raw API call or `gws` CLI)

### 3. Timezone Must Be Explicit in ISO Strings

Always use `America/Lima` offset (`-05:00`) in start/end datetimes:
```
2026-08-25T07:00:00-05:00
```
Not UTC (`Z`) unless you want UTC storage.

### 4. Batch Creation Rate Limits

Creating 40+ events sequentially hits quota. The script in `templates/bulk_create_schedule.py` runs sequentially with no backoff — for large batches, add `time.sleep(0.2)` between calls or use batch requests.

## Templates

### `templates/bulk_create_schedule.py`

Complete, runnable script that creates a full scientific weekly schedule (47 events) from a structured data definition. Adapts the methodology from the Deep Learning Researcher roadmap + UPSJB timetable.

**Usage**:
```bash
# Edit WEEK_START, TZ, and event definitions as needed
python templates/bulk_create_schedule.py
```

**Key Sections to Customize**:
- `WEEK_START` — Monday of the first week (ISO date)
- `TZ` — timezone offset (e.g., `-05:00` for Lima)
- `CALENDARS` — color mapping (reference only; colorId not applied via API)
- Event arrays: `dw_blocks`, `upsjb_classes`, `dl_practice`, `fri_blocks`, `sat_blocks`, `sun_blocks`

**Output**: Creates all events in `primary` calendar. Returns count of created vs errors.

## Integration Points

### Notion Sync (via n8n)

1. n8n workflow: "Google Calendar → Notion" (trigger: event created/updated)
2. Map fields: `summary` → Title, `description` → Details, `start/end` → Date property, `colorId` → Select property
3. Notion DB: `Horario Maestros` with views by category, day, type

### n8n → Calendar (Reverse)

Workflow: "Notion `Ideas Content` → Google Calendar" to block recording/editing slots when a video idea moves to "En producción".

### Anki/FSRS Reminders

Add calendar events for Anki reviews (12:15, 21:00) with description linking to deck names.

## References

- `references/scientific-scheduling-methodology.md` — Full rationale: ultradian, circadian, BDNF, adenosine, sleep architecture
- `references/color-coding-guide.md` — Visual guide for manual color assignment in Calendar UI
- `references/api-limitations.md` — Known gaps in `krailynd-google-workspace` wrapper vs raw API

## Scripts

- `scripts/verify_schedule.py` — Read back a week and validate coverage (no gaps >30 min during waking hours, all categories present)
- `scripts/export_ics.py` — Export a week to .ics for import into Notion, Outlook, Obsidian

## Example: Quick One-Off Event

```bash
python ~/.hermes/skills/productivity/google-workspace/scripts/google_api.py calendar create \
  --summary "🧠 Deep Work: PyTorch Chapter 3" \
  --start "2026-08-25T07:00:00-05:00" \
  --end "2026-08-25T09:00:00-05:00" \
  --description "Karpathy micrograd → nn.Module. Feynman audio after." \
  --calendar primary
```

## Maintenance

- Run `verify_schedule.py` each Sunday during Weekly Review
- Update `WEEK_START` in template when new academic cycle begins
- Adjust `upsjb_classes` array when timetable changes (ciclo 2026-2 → 2027-1)