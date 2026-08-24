# Course Type → Study Technique Mapping

Reference for `academic-schedule-integration` skill. Used in Procedure Step 2.

## Mapping Table (Extended)

| Course Category | Example Courses | Primary Technique | Secondary Technique | Tertiary | Session Structure | Deliverable Template |
|-----------------|-----------------|-------------------|---------------------|----------|-------------------|---------------------|
| **Math/Stats Theory** | Estadística, Cálculo, Probabilidad, Álgebra Lineal | Feynman (explain concept aloud) | Active Recall (Anki) | Interleaving (mix topics) | 1. Pre-class: 3Blue1Brown/StatQuest (25min)<br>2. Class: active notes as questions<br>3. Post-class (15min): Feynman audio 3min + Anki 10 cards<br>4. Evening block: practice problems with interleaving | 1-page Feynman note + Anki deck (formulas, definitions, when-to-use) |
| **Programming/CS Core** | Ing. Software, Estructuras, Algoritmos, Bases de Datos | Deliberate Practice (isolate sub-skill) | Pomodoro (25/5 for coding) | Feynman (explain pattern) | 1. Identify ONE weak sub-skill (e.g., "recursive CTEs")<br>2. 25min focused practice with immediate feedback (tests/compiler)<br>3. 5min break → repeat or Feynman explain pattern<br>4. Commit with semantic message | GitHub commit + 3-line Feynman note in Notion |
| **Lab/Practical** | Prácticas de Cálculo, BD, Talleres | Deliberate Practice (project-based) | Project-based (real problem) | Feynman (document decision) | 1. Pre-lab: read procedure, predict outcomes (5min)<br>2. Lab: execute, note deviations/failures<br>3. Post-lab (20min): Feynman why each step, what failed<br>4. Evening: extend with variation (change param, predict) | Lab report + "what I'd change next time" section |
| **Conceptual/Reading** | Ciudadanía Global, Ética, Teoría General | Active Recall (closed-book summary) | Feynman (teach imaginary peer) | Spaced Repetition (Anki) | 1. Read section → close book → write 3 key points (5min)<br>2. Feynman audio: explain to 12yo (3min)<br>3. Anki: 3 cards (concept, implication, counter-example)<br>4. Weekly: interleaved review of all week's concepts | 3-point summary + 3 Anki cards + 1 Feynman audio |
| **Low Priority / Compliance** | Electivas genéricas, requisitos admin | Pomodoro (compliance only) | — | — | 1. Single 25min block to complete required artifact<br>2. No deep processing — minimum viable output | Submitted artifact only |

## UPSJB-Specific Mapping (from session)

| UPSJB Course | Code | Roadmap Mapping | Priority | Technique Assignment |
|--------------|------|-----------------|----------|---------------------|
| Estadística Básica I | 2411050412 | MA-201 ⭐ | Core | Feynman + Active Recall + Interleaving |
| Cálculo Numérico | 2411050413 | MA-202 ⭐ | Core | Feynman + Deliberate Practice (implement GD/SGD) |
| Ingeniería de Software | 2411050414 | GIT-101 ⚡ / OPS-401 ⚡ | Support | Deliberate Practice (refactor with SOLID) + Pomodoro |
| Modelamiento de BD | 2411050415 | DS-201 ⚡ | Support | Deliberate Practice (SQL/ETL pipelines) + Feynman |
| Taller Programación Web | 2411050416 | OPS-401 ⚡ / PRY-301 | Support | Project-based (Flask/FastAPI for model serving) |
| Ciudadanía Global | 2411CG0411 | CAR-501 ⚡ | Low | Active Recall (3 takeaways/class) only |

## Technique Decision Rules

1. **If course maps to ⭐ roadmap course** → Full technique stack (Primary + Secondary + Tertiary)
2. **If course maps to ⚡ roadmap course** → Primary + Secondary only
3. **If course not mapped** → Pomodoro compliance only (protect deep work time)
4. **If class > 3h in day** → No evening deep work; only 15min post-class review + Anki
5. **If free day (Friday)** → 3× 90min Deep Work blocks with single technique focus each