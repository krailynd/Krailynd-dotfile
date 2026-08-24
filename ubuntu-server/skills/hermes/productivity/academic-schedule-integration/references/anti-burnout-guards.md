# Anti-Burnout Guards — Definitions & Automation Rules

Reference for `academic-schedule-integration` skill. Used in Procedure Step 5.

## Guard Definitions

### 1. Sleep Gate
**Purpose**: Protect memory consolidation and next-day cognitive capacity.
- **Metric**: In bed (lights out, phone away) by 22:15
- **Tracking**: Sleep tracker (Oura/Whoop/Apple Watch) or manual log in Notion `Hábitos Diarios`
- **Trigger**: Sleep onset > 22:15 OR < 7h actual sleep (tracker)
- **Consequence (next day)**:
  - Cancel ALL evening deep work blocks (post-17:00)
  - Replace with: admin only (email, calendar, Anki review)
  - Morning deep work (pre-class) PRESERVED — it's the highest leverage
  - Log in `Seguimiento Semanal`: "Sleep gate triggered — evening DW cancelled"

### 2. Exercise Gate
**Purpose**: Ensure BDNF boost for learning, maintain physical adaptation signal.
- **Metric**: 3 sessions/week (Mon/Wed/Fri default), 30-45min, HR zone 2-3
- **Tracking**: Strava/Garmin/Apple Health → Notion sync or manual log
- **Trigger**: Missed scheduled session (no make-up same day)
- **Consequence (same day)**:
  - Cancel ALL deep work blocks for that day
  - Replace with: light reading (dev personal), admin, Anki only
  - Next scheduled session becomes "must-do" (no skip twice)
  - Log: "Exercise gate triggered — DW cancelled, recovery day"

### 3. Commit Gate
**Purpose**: Ensure consistent code output (research currency), prevent Friday crunch.
- **Metric**: ≥1 commit with semantic message by Thursday 17:00 local time
- **Tracking**: GitHub contributions graph + `git log --oneline --since="Monday 00:00" --author="krailynd"`
- **Trigger**: 0 commits by Thu 17:00
- **Consequence (Friday)**:
  - Friday 07:30-09:30: MANDATORY code session (before main deep work)
  - Session goal: 1 commit + push (any size: fix, doc, test, experiment)
  - Only AFTER commit: proceed to planned Friday deep work
  - Log: "Commit gate triggered — Fri 07:30 recovery session executed"

### 4. Free Day Gate
**Purpose**: Enforce default mode network recovery, prevent chronic stress accumulation.
- **Metric**: 24h+ continuous zero academic/code work (Sat 20:30 → Sun 20:00 default)
- **Tracking**: Calendar check + self-report in Sunday review
- **Trigger**: Any work (code, paper, Anki, Notion study DB) during free window
- **Consequence (next week)**:
  - Remove 1 deep work block from weekly schedule (replace with recovery: walk, nap, hobby)
  - Add 1 extra wind-down session (NSDR 20min)
  - Log: "Free day gate triggered — next week -1 DW block"

### 5. Pomodoro Start Guard
**Purpose**: Overcome initiation resistance (procrastination) with micro-commitment.
- **Metric**: Resistance felt (urge to check phone, "I'll start in 5 min", anxiety)
- **Tracking**: Subjective — user invokes manually
- **Trigger**: User notices resistance before any deep work block
- **Consequence (immediate)**:
  - Phone → another room (physical barrier)
  - Website blocker ON (Freedom/Cold Turkey) for block duration
  - Physical timer (not phone) set to 25 min
  - Mantra: "Just 25 minutes. Then I can stop."
  - If continue after 25min → great. If stop → still logged 25min.

## Automation Rules (Calendar + Notion)

### Calendar Reminders (set on each recurring event)
| Event | Reminder | Message |
|-------|----------|---------|
| Sleep window start (21:30) | 30min before | "Wind-down: screens off, NSDR, journal" |
| Sleep window end (22:00) | 0min | "Lights out. Sleep gate active." |
| Exercise (Mon/Wed/Fri 05:45) | 10min before | "Exercise gate: 30min zone 2. No skip." |
| Thu Commit Checkpoint | 17:00 | "Commit gate: 0 commits? Fri 07:30 recovery." |
| Free Day Start (Sat 20:30) | 0min | "Free day begins. Zero work until Sun 20:00." |
| Free Day End (Sun 20:00) | 0min | "Free day ends. Review + plan week." |

### Notion Automation (via `notion` skill or manual template)
**Daily Log Template** (in `Hábitos Diarios` DB):
```markdown
## {{date}} — Habits
- [ ] Sleep: in bed by 22:15? (Y/N) → if N: Sleep Gate log
- [ ] Exercise: completed? (Y/N) → if N: Exercise Gate log
- [ ] Deep Work blocks: ___/4 completed
- [ ] Anki: morning ___ cards, evening ___ cards
- [ ] Commits: ___ (semantic messages)
- [ ] Free day respected? (Y/N) → if N: Free Day Gate log
- [ ] Pomodoro starts used: ___
- Mood/Focus (1-10): ___
- Notes: 
```

**Weekly Review Template** (in `Seguimiento Semanal` DB):
```markdown
## Week {{monday_date}} - {{sunday_date}}

### Guard Triggers This Week
- Sleep Gate: ___ times → Evening DW cancelled: ___ blocks
- Exercise Gate: ___ times → DW cancelled: ___ blocks  
- Commit Gate: triggered? (Y/N) → Fri recovery session? (Y/N)
- Free Day Gate: triggered? (Y/N) → Next week adjustment: -1 DW block
- Pomodoro Starts used: ___ times

### Metrics
- Deep Work hours: ___ / 15 target
- Commits: ___ / 5 min
- Papers read: ___ (Feynman notes in Notion)
- Anki retention: ___% (target >85%)
- Exercise sessions: ___ / 3
- Sleep avg: ___h

### 3 MITs Next Week
1. [Technique + Roadmap Course + Deliverable]
2. [Technique + Roadmap Course + Deliverable]
3. [Technique + Roadmap Course + Deliverable]
```

## Guard Hierarchy (Priority Order)

When multiple gates trigger, apply consequences in this order:
1. **Sleep Gate** (highest — affects all next-day cognition)
2. **Exercise Gate** (affects same-day cognition)
3. **Commit Gate** (affects Friday only)
4. **Free Day Gate** (affects next week planning)
5. **Pomodoro Start** (micro, per-block)

**Never stack consequences** — if Sleep + Exercise both triggered, apply Sleep consequence only (covers Exercise). Log both triggers.

## Recovery Protocols (Post-Guard)

### After Sleep Gate Trigger
- Next day: 20min NSDR at 13:00 (post-lunch)
- Prioritize protein + hydration
- No caffeine after 12:00
- Evening: 21:00 wind-down strict

### After Exercise Gate Trigger
- Immediate: 10min walk (any movement)
- Next scheduled session: treat as "must-do" (no negotiation)
- Log barriers: time? energy? motivation? → address root cause Sunday

### After Commit Gate Trigger
- Friday 07:30 session: smallest possible commit (fix typo, add test, update README)
- Goal: break inertia, not produce masterpiece
- Reflect Sunday: why 0 commits Mon-Thu? (blocked? unclear? overwhelmed?)

### After Free Day Gate Trigger
- Acknowledge without shame: "I worked. System noticed. Adjusting."
- Next week: lighter by design, not by accident
- Sunday review: what pulled me in? (excitement? anxiety? habit?)