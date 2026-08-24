---
name: academic-schedule-integration
description: "Integrate class schedule with roadmap, assign techniques."
version: 0.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Academic-Planning, Schedule-Integration, Deep-Work, Study-Techniques, Google-Calendar, Anti-Burnout]
    related_skills: [weekly-review-planning, estudio-examen, notion, google-workspace, obsidian-second-brain]
---

# Academic Schedule Integration & Deep Work Planning

**Class-level skill** for integrating fixed university timetables with self-directed research roadmaps, applying cognitive science-backed study techniques to each course, and producing a complete, Google Calendar-importable weekly schedule that balances classes, deep work, exercise, sleep, personal development, and recovery.

## When to Use

- "Plan my semester: here's my class schedule and my research roadmap"
- "Integrate UPSJB/Blackboard/Canvas schedule with my Notion roadmap"
- "Create a Google Calendar weekly plan with Pomodoro blocks, exercise, and study techniques per course"
- "Map each university course to my research roadmap topics and assign study techniques"
- "Generate an ICS file or Calendar events for my integrated schedule"
- "Build anti-burnout guards (sleep gate, exercise gate, commit gate, free day) into my schedule"

**Don't use for:** generic productivity planning without a fixed class schedule, or single-course study guides (use `estudio-examen`).

---

## Core Philosophy

> **Fixed commitments first, deep work around them, recovery as infrastructure.**

1. **University classes are immutable anchors** — build everything around them
2. **Each course maps to research roadmap topics** — extract maximum transfer value
3. **Evidence-based techniques per cognitive demand** — match technique to material type
4. **Recovery is scheduled, not hoped for** — sleep, exercise, free day are non-negotiable events
5. **Output > input** — commits, papers read, Feynman explanations > hours logged

---

## Input Requirements

| Input | Source | Format |
|-------|--------|--------|
| Class schedule | Blackboard/Canvas/PDF/Notion | Day, time (12h/24h), course name, code, type (theory/lab), room, professor, credits |
| Research roadmap | Notion/Obsidian/Markdown | Phases, courses, deliverables, prerequisites, priority (⭐/⚡) |
| Study techniques library | Notion/skill `estudio-examen` | Active Recall, Feynman, Interleaving, Spaced Repetition, Deliberate Practice, Pomodoro |
| Personal constraints | User interview | Wake/sleep target, exercise days, free day preference, commute time, meal timing |
| Current phase | Roadmap tracker | Which period/courses are active now |

---

## Procedure

### 1. Ingest & Normalize Class Schedule

- Parse schedule into structured table: `Day | Time (12h) | Course | Code | Type | Room | Professor | Credits`
- Detect conflicts (should be zero — flag if not)
- Identify **free days** (zero classes) — these become Deep Work anchors
- Identify **heavy days** (>4h classes) — limit evening deep work
- Convert to 12-hour format for Calendar import

### 2. Map Courses → Roadmap Topics

For each university course, determine:
- **Roadmap Period** (1-5) and **Course Code** (e.g., MA-201, ML-201)
- **Priority** (⭐ Core research skill / ⚡ Support skill / — Not mapped)
- **Transfer value** — what specific concepts/skills feed the research goal
- **Study technique assignment** based on cognitive demand:

| Course Type | Primary Technique | Secondary | Rationale |
|-------------|-------------------|-----------|-----------|
| Math/Stats (theory-heavy) | Feynman + Active Recall | Interleaving | Conceptual depth, formula retention |
| Programming/CS (skill-heavy) | Deliberate Practice + Pomodoro | Interleaving | Sub-skill isolation, feedback loops |
| Lab/Practical (application) | Deliberate Practice + Project-based | Feynman | Transfer to real problems |
| Theory/Reading (conceptual) | Active Recall + Feynman | Spaced Repetition | Long-term retention |
| Low-priority/General | Pomodoro (compliance only) | — | Minimal viable effort |

### 3. Design Weekly Template (Ultradian-Aligned)

**Core blocks (non-negotiable):**
- **Sleep**: 7.5-8h fixed window (e.g., 22:00-5:30)
- **Exercise**: 3×/week fixed days, 30-45min, ideally pre-study for BDNF boost
- **Free Day**: 1 day/week zero academic/code work (Saturday night → Sunday evening)
- **Deep Work Blocks**: 90-120min (ultradian cycles), max 4×/day, phone in another room
- **Meals**: Fixed windows, protein-forward for cognitive stability
- **Wind-down**: 60-90min pre-sleep, no screens, NSDR/meditation/journaling

**Block placement rules:**
- Morning deep work (pre-classes) for hardest roadmap topic
- Post-class immediate review (15-20min) for retention
- Evening deep work only on light class days (<3h classes)
- Friday = sacred Deep Work day if free
- Weekend: Saturday research/paper, Sunday review/planning

### 4. Assign Techniques per Time Block

Each study block in the schedule gets explicit technique annotation:

```
07:00-09:00 | Estadística Básica I + MA-201 Probabilidad
   Technique: Feynman (explain Bayes theorem aloud) → Active Recall (Anki 20 cards)
   Deliverable: 1-page Feynman note + Anki review
```

### 5. Build Anti-Burnout Guards (System-Level)

| Guard | Trigger | Consequence |
|-------|---------|-------------|
| **Sleep Gate** | Not in bed by 22:15 | Next day: no evening deep work, only admin |
| **Exercise Gate** | Missed Mon/Wed/Fri session | That day: no deep work, only admin/light reading |
| **Commit Gate** | Thursday 17:00 = 0 commits | Friday 07:30: mandatory code session before deep work |
| **Free Day Gate** | Any work on Free Day | Next week: -1 deep work block, +1 recovery block |
| **Pomodoro Start** | Resistance to begin | "Just 25 min" timer, phone in other room, blocker ON |

### 6. Generate Google Calendar Structure

Create **separate calendars** (color-coded):
- `Classes` (blue) — immutable, recurring weekly
- `Deep Work` (green) — recurring weekly, technique-annotated in description
- `Exercise` (orange) — recurring Mon/Wed/Fri
- `Personal Dev` (purple) — recurring daily/weekly
- `Meals/Sleep` (red/gray) — recurring daily
- `Admin/Review` (yellow) — recurring Sun + Thu checkpoint

**Event description template:**
```
Technique: [Feynman / Active Recall / Deliberate Practice / Interleaving / Pomodoro / Spaced Repetition]
Roadmap Course: [MA-201 Probabilidad]
Deliverable: [1-page Feynman note + Anki 20 cards]
Pre-req: [3Blue1Brown playlist watched]
Post-action: [Commit to GitHub / Log in Notion]
```

### 7. Weekly Review Integration (Sunday 2h)

Connects to `weekly-review-planning`:
- Metrics: Deep Work hours, commits, papers, Anki retention, exercise, sleep avg
- Honest logging: bad weeks recorded too
- Next week: 3 MITs (Most Important Tasks) with technique + deliverable
- Calendar adjustments: ±30min max per block based on evidence

---

## Output Artifacts

1. **Integrated Weekly Schedule** — markdown table (this skill's primary output)
2. **Google Calendar ICS** — importable file with all calendars, events, descriptions
3. **Notion Templates** — `Seguimiento Semanal`, `Planificación Diaria`, `Paper de la Semana`
4. **Anki Deck Structure** — one deck per mapped course + roadmap topic
5. **Technique Cheatsheet** — one-page reference for the week
6. **Anti-Burnout Guard Checklist** — weekly verification

---

## Pitfalls (Learned from Session)

- ❌ **Overloading evening blocks** after 4h+ class days → cognitive fatigue, poor retention
- ❌ **Vague block labels** ("Study ML") → no technique, no deliverable, low intensity
- ❌ **No free day** → guaranteed burnout by week 3
- ❌ **Sleep as variable** → destroys consolidation, compounds exponentially
- ❌ **Mapping courses once** — re-map each semester as roadmap phase advances
- ❌ **Ignoring commute/transition time** — 15-20min buffers between blocks
- ❌ **Treating all courses equal** — prioritize ⭐ mapped courses for prime blocks
- ❌ **No Sunday review** → drift compounds, no course correction

---

## Verification Checklist

- [ ] All university classes imported as immutable recurring events
- [ ] Every deep work block has: Technique + Roadmap Course + Deliverable + Pre-req
- [ ] Sleep window 7.5-8h fixed, recurring
- [ ] Exercise 3×/week fixed days, recurring
- [ ] One full free day (24h+), recurring
- [ ] Anti-burnout guards documented and automated (Calendar reminders)
- [ ] ICS file validates in Google Calendar import preview
- [ ] Notion templates created and linked in schedule
- [ ] Anki decks match mapped courses
- [ ] User can explain the "why" of each block assignment (Feynman test)

---

## References

- `references/course-technique-mapping.md` — detailed mapping table per course type
- `references/anti-burnout-guards.md` — guard definitions, automation rules
- `references/calendar-ics-template.md` — ICS generation spec
- `references/notion-templates.md` — template markdown for 3 databases
- `references/anki-deck-structure.md` — deck hierarchy and card types