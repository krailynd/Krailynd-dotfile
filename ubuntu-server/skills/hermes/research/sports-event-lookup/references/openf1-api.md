# OpenF1 REST API — Reference (verified 2026-07-16)

Base URL: `https://api.openf1.org/v1/`
Auth: **None required**. Free public API.
Use `curl -s` from terminal — `web_extract` does NOT work on API URLs.

---

## Core Endpoints

### Meetings (one per race weekend)
```
GET /v1/meetings?year=2026
```
Returns: `meeting_key`, `meeting_name`, `date_start`, `country_name`
⚠️ `meeting_round` is always `null` in 2026 — derive round from sorted order yourself.

### Sessions (P1, P2, P3, Qualifying, Sprint, Race)
```
GET /v1/sessions?year=2026&session_type=Race
GET /v1/sessions?meeting_key=1290
```
Returns: `session_key`, `session_name`, `date_start`, `date_end`, `meeting_key`

### Session Result (final classified order)
```
GET /v1/session_result?session_key=11326
```
Returns per driver: `position`, `driver_number`, `number_of_laps`, `points`, `gap_to_leader`, `duration`, `dnf`, `dns`, `dsq`
⚠️ `position` is `None` for unclassified retirements (use `dnf=True` flag instead).
⚠️ Returns `[]` for some races (Bahrain R4, Saudi R5 in 2026) — mark as `Incomplete`, never invent.

### Drivers (name map for a session)
```
GET /v1/drivers?session_key=11326
```
Returns: `driver_number`, `full_name`, `name_acronym`, `team_name`
Use to build a `{driver_number: "ACRONYM (Full Name / Team)"}` dict for display.

### Stints (tyre data)
```
GET /v1/stints?session_key=11326
GET /v1/stints?session_key=11326&driver_number=16
```
Returns per stint: `stint_number`, `compound`, `lap_start`, `lap_end`, `tyre_age_at_start`, `driver_number`
Compounds: `SOFT`, `MEDIUM`, `HARD`, `INTERMEDIATE`, `WET`

### Pit Stops
```
GET /v1/pit?session_key=11326&driver_number=16
```
Returns: `lap_number`, `pit_duration`, `lane_duration`, `date`, `driver_number`

### Race Control (flags, SC, VSC, penalties, incidents)
```
GET /v1/race_control?session_key=11326
GET /v1/race_control?session_key=11326&category=SafetyCar
GET /v1/race_control?session_key=11326&flag=RED
```
Returns: `date`, `category`, `flag`, `message`
Categories: `Flag`, `SafetyCar`, `Other`, `SessionStatus`
A full race typically has 200+ events — always filter.
SC/VSC detection: filter `category=SafetyCar`, check `message` for "VSC" vs "SAFETY CAR".

### Weather
```
GET /v1/weather?session_key=11326
```
Returns: `air_temperature`, `track_temperature`, `rainfall`, `wind_speed`, `date`
Take first and last records for start/end conditions.

### Position (live classification)
```
GET /v1/position?session_key=11326&position=1
```
Useful for verifying final P1 driver at race end.

---

## 2026 Season Key Map (verified)

| Round | Grand Prix | Meeting Key | Race Session Key | Race Date UTC |
|-------|-----------|-------------|-----------------|---------------|
| R1 | Australian GP | 1279 | 11234 | 2026-03-08 04:00 |
| R2 | Chinese GP (Sprint) | 1280 | 11245 | 2026-03-15 07:00 |
| R3 | Japanese GP | 1281 | 11253 | 2026-03-29 05:00 |
| R4 | Bahrain GP | 1282 | 11261 | 2026-04-12 15:00 |
| R5 | Saudi Arabian GP | 1283 | 11269 | 2026-04-19 17:00 |
| R6 | Miami GP (Sprint) | 1284 | 11280 | 2026-05-03 17:00 |
| R7 | Canadian GP (Sprint) | 1285 | 11291 | 2026-05-24 20:00 |
| R8 | Monaco GP | 1286 | 11299 | 2026-06-07 13:00 |
| R9 | Spanish GP | 1287 | 11307 | 2026-06-14 13:00 |
| R10 | Austrian GP | 1288 | 11315 | 2026-06-28 13:00 |
| R11 | British GP (Sprint) | 1289 | 11326 | 2026-07-05 14:00 |
| R12 | Belgian GP | 1290 | 11334 | 2026-07-19 13:00 |
| R13 | Hungarian GP | 1291 | 11342 | 2026-07-26 13:00 |
| R14 | Dutch GP (Sprint) | 1292 | 11353 | 2026-08-23 13:00 |
| R15 | Italian GP | 1293 | 11361 | 2026-09-06 13:00 |

Sprint weekends (confirmed): R2 China, R6 Miami, R7 Canada, R11 British, R14 Dutch.
Pre-Season Testing: mkey=1304 (Feb 11), mkey=1305 (Feb 18) — both in Bahrain.

British GP (R11) sessions:
- P1: 11316 | Sprint Qualifying: 11317 | Sprint: 11321 | Qualifying: 11322 | Race: 11326

Belgian GP (R12) sessions:
- P1: 11327 (17 Jul 11:30) | P2: 11328 (17 Jul 15:00) | P3: 11329 (18 Jul 10:30) | Quali: 11330 (18 Jul 14:00) | Race: 11334 (19 Jul 13:00)

---

## 2026 Race Results Summary (verified from OpenF1)

| R | Winner | P2 | P3 | SC | VSC | DNF |
|---|--------|----|----|-----|-----|-----|
| R1 | Russell (Mercedes) | Antonelli (Mercedes) | Leclerc (Ferrari) | ❌ | ✅ | 3 |
| R2 | Antonelli (Mercedes) | Russell (Mercedes) | Hamilton (Ferrari) | ✅ | ❌ | 3 |
| R3 | Antonelli (Mercedes) | Piastri (McLaren) | Leclerc (Ferrari) | ✅ | ❌ | 2 |
| R4 | Unknown | — | — | — | — | — (no OpenF1 data) |
| R5 | Unknown | — | — | — | — | — (no OpenF1 data) |
| R6 | Antonelli (Mercedes) | Norris (McLaren) | Piastri (McLaren) | ✅ | ❌ | 4 |
| R7 | Antonelli (Mercedes) | Hamilton (Ferrari) | Verstappen (Red Bull) | ❌ | ✅ | 5 |
| R8 | Antonelli (Mercedes) | Hamilton (Ferrari) | Gasly (Alpine) | ✅ | ❌ | 7 |
| R9 | Hamilton (Ferrari) | Russell (Mercedes) | Norris (McLaren) | ❌ | ✅ | 7 |
| R10 | Russell (Mercedes) | Verstappen (Red Bull) | Antonelli (Mercedes) | ❌ | ✅ | 4 |
| R11 | Leclerc (Ferrari) | Russell (+0.427s) | Hamilton (+0.772s) | ✅ | ✅ | 3 (VER, ALB, HUL) |

Kimi Antonelli (Mercedes) leads 2026 with 5 wins (R2,3,6,7,8) — historic rookie season.

---

## 2026 Driver Grid (from British GP session 11326)

| # | Acronym | Full Name | Team |
|---|---------|-----------|------|
| 1 | NOR | Lando Norris | McLaren |
| 3 | VER | Max Verstappen | Red Bull Racing |
| 5 | BOR | Gabriel Bortoleto | Audi |
| 6 | HAD | Isack Hadjar | Red Bull Racing |
| 10 | GAS | Pierre Gasly | Alpine |
| 11 | PER | Sergio Perez | Cadillac |
| 12 | ANT | Kimi Antonelli | Mercedes |
| 14 | ALO | Fernando Alonso | Aston Martin |
| 16 | LEC | Charles Leclerc | Ferrari |
| 18 | STR | Lance Stroll | Aston Martin |
| 23 | ALB | Alexander Albon | Williams |
| 27 | HUL | Nico Hulkenberg | Audi |
| 30 | LAW | Liam Lawson | Racing Bulls |
| 31 | OCO | Esteban Ocon | Haas F1 Team |
| 41 | LIN | Arvid Lindblad | Racing Bulls |
| 43 | COL | Franco Colapinto | Alpine |
| 44 | HAM | Lewis Hamilton | Ferrari |
| 55 | SAI | Carlos Sainz | Williams |
| 63 | RUS | George Russell | Mercedes |
| 77 | BOT | Valtteri Bottas | Cadillac |
| 81 | PIA | Oscar Piastri | McLaren |
| 87 | BEA | Oliver Bearman | Haas F1 Team |

New teams in 2026: Audi (replaced Alfa Romeo), Cadillac (new entry).

---

## Python pattern: bulk result fetch

```python
import urllib.request, json

def openf1(endpoint, **params):
    qs = "&".join(f"{k}={v}" for k,v in params.items())
    url = f"https://api.openf1.org/v1/{endpoint}?{qs}"
    with urllib.request.urlopen(url, timeout=10) as r:
        return json.loads(r.read())

# Build driver name map
drivers = openf1("drivers", session_key=11326)
drv_map = {d["driver_number"]: f"{d['name_acronym']} ({d['full_name']} / {d['team_name']})" for d in drivers}

# Get results
results = openf1("session_result", session_key=11326)
for r in sorted(results, key=lambda x: (x.get("position") or 99)):
    print(f"P{r['position']} | {drv_map.get(r['driver_number'], f'#{r[\"driver_number\"]}')} | dnf={r['dnf']}")
```
