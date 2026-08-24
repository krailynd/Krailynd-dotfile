# Notion Templates for Academic Schedule Integration

Reference for `academic-schedule-integration` skill. Used in Output Artifacts.

## Database 1: Seguimiento Semanal (Weekly Tracking)

**Location**: Notion workspace → Pages → `📊 Seguimiento Semanal — Progreso DL Researcher`
**Type**: Table database with weekly entries (one row per week)

### Properties

| Property Name | Type | Options / Format | Purpose |
|---------------|------|------------------|---------|
| Semana | Title | `Semana del {{Monday}} al {{Sunday}}` | Primary identifier |
| Fecha Inicio | Date | Start date (Monday) | Sorting, filtering |
| Fecha Fin | Date | End date (Sunday) | Range queries |
| Horas Deep Work | Number | Decimal (e.g., 12.5) | Target: 15h/week |
| Bloques DW Completados | Number | Integer (0-28) | 4 blocks/day × 7 days |
| Commits | Number | Integer | Target: 5+/week |
| Papers Leídos | Number | Integer | Target: 1-2/week |
| Paper Título | Text | Paper title + arXiv link | Reference |
| Paper Notas Feynman | URL | Link to Notion page | Deep link |
| Ejercicio Sesiones | Number | Integer (0-7) | Target: 3/week |
| Sueño Promedio (h) | Number | Decimal (1 decimal) | Target: 7.5h |
| Anki Retención % | Number | Percent (0-100) | Target: >85% |
| Sleep Gate Activado | Checkbox | — | Guard tracking |
| Exercise Gate Activado | Checkbox | — | Guard tracking |
| Commit Gate Activado | Checkbox | — | Guard tracking |
| Free Day Gate Activado | Checkbox | — | Guard tracking |
| Bloqueo Principal | Text | One sentence | Honest bottleneck |
| 3 MITs Próxima Semana | Text | Bulleted list | Planning output |
| Insight Semanal | Text | 1-2 paragraphs | Feynman-style synthesis |
| Estado | Select | `En progreso`, `Completada`, `Revisada` | Workflow |

### View: "Esta Semana" (Filtered: Fecha Inicio = this Monday)
### View: "Historial" (Table, sorted by Fecha Inicio desc)
### View: "Guard Triggers" (Board by Estado, grouped by gate checkboxes)

---

## Database 2: Planificación Diaria (Daily Planning)

**Location**: Notion workspace → Pages → `📅 Planificación Diaria`
**Type**: Table database with daily entries (one row per day)

### Properties

| Property Name | Type | Options / Format | Purpose |
|---------------|------|------------------|---------|
| Fecha | Title | `{{Date}}` (YYYY-MM-DD) | Primary key |
| Día Semana | Select | `Lunes`, `Martes`, `Miércoles`, `Jueves`, `Viernes`, `Sábado`, `Domingo` | Grouping |
| MIT 1 (Bloque Profundo AM) | Text | `Técnica + Curso Roadmap + Entregable` | Morning focus |
| MIT 2 (Bloque Profundo PM / Práctica) | Text | `Técnica + Curso Roadmap + Entregable` | Afternoon focus |
| MIT 3 (Admin / Físico / Aprendizaje) | Text | `Técnica + Curso Roadmap + Entregable` | Third priority |
| Riesgos Hoy | Text | Bulleted list | Proactive mitigation |
| Preparación Noche Anterior | Checkbox | 4 sub-items (see template) | Friction reduction |
| Sleep Gate OK | Checkbox | — | Guard check |
| Exercise Gate OK | Checkbox | — | Guard check |
| Commit Gate OK | Checkbox | — | Guard check (Thu only) |
| Free Day Gate OK | Checkbox | — | Guard check (Sat/Sun) |
| Pomodoro Inicios Usados | Number | Integer | Resistance tracking |
| Horas Deep Work Real | Number | Decimal | Actual vs planned |
| Commits Hoy | Number | Integer | Daily output |
| Anki Mañana | Number | Integer | Spaced repetition |
| Anki Noche | Number | Integer | Spaced repetition |
| Notas / Observaciones | Text | Free form | Context capture |
| Completado | Checkbox | — | Day closure |

### Template Content (for new day entry)

```markdown
## {{Fecha}} — {{Día Semana}}

### 3 MITs (Most Important Tasks)

#### MIT 1 — Bloque Profundo Mañana (07:00-09:00 / 09:15-11:15)
- **Qué**: 
- **Técnica**: 
- **Curso Roadmap**: 
- **Entregable (Definición de Terminado)**: 

#### MIT 2 — Bloque Profundo Tarde / Práctica (17:30-19:30 / Viernes 07:30-15:45)
- **Qué**: 
- **Técnica**: 
- **Curso Roadmap**: 
- **Entregable**: 

#### MIT 3 — Admin / Físico / Aprendizaje Libre
- **Qué**: 
- **Técnica**: 
- **Entregable**: 

### ⚠️ Riesgos Hoy
- [ ] 
- [ ] 

### 🎒 Preparación Noche Anterior (✓ = listo)
- [ ] Ropa lista
- [ ] Mochila / escritorio listo
- [ ] Paper / proyecto abierto en pantalla
- [ ] Alarma 5:30 configurada

### 🛡️ Guard Checks
- [ ] Sleep Gate: en cama 22:15
- [ ] Exercise Gate: sesión completada (L/M/V)
- [ ] Commit Gate: ≥1 commit para Jueves 17:00
- [ ] Free Day Gate: cero trabajo Sáb 20:30 - Dom 20:00

### 📊 Métricas Día
- Horas Deep Work real: 
- Commits: 
- Anki mañana / noche: / 
- Pomodoro inicios usados: 
- Estado ánimo/foco (1-10): 

### 📝 Notas
```

### View: "Hoy" (Filtered: Fecha = today)
### View: "Esta Semana" (Filtered: Fecha = this week)
### View: "Pendientes" (Filtered: Completado = false)

---

## Database 3: Paper de la Semana (Weekly Paper Reading)

**Location**: Notion workspace → Pages → `📄 Paper de la Semana`
**Type**: Table database with weekly entries

### Properties

| Property Name | Type | Options / Format | Purpose |
|---------------|------|------------------|---------|
| Semana | Title | `Semana {{Monday}} - {{Paper Title[:40]}}` | Identifier |
| Fecha | Date | Saturday of that week | Timeline |
| Paper Título | Text | Full title | Reference |
| arXiv / DOI | URL | Link to paper | Source |
| Roadmap Período | Select | `Período 1`, `Período 2`, `Período 3`, `Período 4`, `Período 5` | Mapping |
| Roadmap Curso | Text | e.g., `DL-301`, `NLP-401` | Specific course |
| Pass 1 (15min) | Checkbox | Abstract + Figures + Conclusion | First pass done |
| Pass 2 (60min) | Checkbox | Deep read with pencil | Second pass done |
| Notas Feynman | URL | Link to Notion page (1 page max) | Core output |
| Dudas → Preguntas Investigación | Text | Bulleted list | Feeds ❓ DB |
| Conexión Proyecto F1 | Text | How this applies to F1 projects | Transfer |
| Próximo Paper Candidato | Text | Reference from citations | Pipeline |
| Estado | Select | `Pendiente`, `Pass 1`, `Pass 2`, `Feynman Done`, `Archivado` | Workflow |
| Tiempo Total (min) | Number | Integer | Tracking |

### Template Content

```markdown
## {{Paper Título}} — {{Fecha}}

### PASS 1 (15 min): Abstract + Figuras + Conclusión
- **Problema que resuelve**: 
- **Aporte principal**: 
- **Resultado clave**: 
- **¿Vale lectura profunda?**: SÍ / NO

### PASS 2 (60 min): Lectura profunda con lápiz
- **Metodología**: 
- **Experimentos clave**: 
- **Limitaciones que ELLOS admiten**: 
- **Mis dudas (→ ❓ Preguntas Investigación)**: 

### NOTAS FEYNMAN (1 página máximo)
[Explica el paper como si se lo contaras a un compañero de UPSJB que sabe Python pero NO DL]

### CONEXIÓN CON MI ROADMAP
- Período actual: 
- Curso relacionado: 
- ¿Cómo uso esto en mi proyecto F1?: 

### PRÓXIMO PAPER CANDIDATO
[Referencia del paper que citan y quiero leer]
```

### View: "Por Leer" (Estado = Pendiente)
### View: "En Progreso" (Estado = Pass 1 / Pass 2)
### View: "Completados" (Estado = Feynman Done / Archivado)

---

## Integration Notes

1. **Cross-database relations** (Notion):
   - `Seguimiento Semanal` → `Planificación Diaria` (rollup: avg Deep Work hours)
   - `Planificación Diaria` → `Paper de la Semana` (relation: paper read that day)
   - `Seguimiento Semanal` → `Paper de la Semana` (rollup: count papers/week)

2. **Automation via `notion` skill**:
   - Daily: Create next day's `Planificación Diaria` entry at 21:00 (template applied)
   - Weekly: Create `Seguimiento Semanal` entry Sunday 08:00
   - Weekly: Create `Paper de la Semana` entry Saturday 08:00

3. **Templates stored in Notion** as "Default template" for each database — user duplicates via "New with template"