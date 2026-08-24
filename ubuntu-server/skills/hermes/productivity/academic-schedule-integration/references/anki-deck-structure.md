# Anki Deck Structure for Academic Schedule Integration

Reference for `academic-schedule-integration` skill. Used in Output Artifacts.

## Deck Hierarchy

```
📚 UPSJB + Roadmap (Master Deck)
├── 🎓 UPSJB::Estadística Básica I (2411050412)
│   ├── Distribuciones
│   ├── Inferencia
│   ├── Pruebas de Hipótesis
│   └── Teorema Central del Límite
├── 🎓 UPSJB::Cálculo Numérico (2411050413)
│   ├── Optimización (GD, SGD, Momentum)
│   ├── Métodos Iterativos (Newton-Raphson, Jacobi)
│   ├── Convexidad & LR Schedules
│   └── Error Numérico
├── 🎓 UPSJB::Ingeniería de Software (2411050414)
│   ├── Patrones (SOLID, Factory, Strategy, Observer)
│   ├── Testing (Unit, Integration, Property-based)
│   ├── CI/CD & Git Workflow
│   └── Clean Architecture
├── 🎓 UPSJB::Modelamiento BD (2411050415)
│   ├── SQL Avanzado (CTE, Window Functions, Recursive)
│   ├── ETL & Pipelines
│   ├── Data Quality & Leakage
│   └── Normalización & ER
├── 🎓 UPSJB::Taller Web (2411050416)
│   ├── Flask/FastAPI Basics
│   ├── API Design (REST, GraphQL intro)
│   ├── Docker & Deploy
│   └── Serving Models
├── 🎓 UPSJB::Ciudadanía Global (2411CG0411)
│   ├── Ética IA
│   ├── Impacto Social
│   └── Comunicación Técnica
├── 🧠 Roadmap::Período 1 - Fundamentos
│   ├── PY-101 Python Científico
│   ├── GIT-101 Git para Experimentos
│   ├── MA-101 Álgebra Lineal + Cálculo
│   ├── PD-101 Pandas + Matplotlib
│   └── EXP-101 Notebooks Reproducibles
├── 🧠 Roadmap::Período 2 - Matemáticas & ML Teórico
│   ├── MA-201 Probabilidad & Estadística
│   ├── MA-202 Optimización
│   ├── DS-201 Curaduría Datasets
│   ├── ML-201 ML Clásico (ISL)
│   └── ML-202 Diseño Experimentos
├── 🧠 Roadmap::Período 3 - Deep Learning Core
│   ├── DL-301 Redes desde Cero (NumPy)
│   ├── DL-302 PyTorch + Autograd
│   ├── DL-303 CNNs + Transfer Learning
│   ├── MA-301 Mates para DL
│   └── DL-304 Training Dynamics
├── 🧠 Roadmap::Período 4 - Transformers & LLMs
│   ├── NLP-401 Transformers desde Cero
│   ├── RES-401 Reproducción Paper
│   ├── NLP-402 Fine-tuning (LoRA/QLoRA)
│   └── OPS-401 MLOps para Research
└── 🧠 Roadmap::Período 5 - Práctica Investigadora
    ├── RES-501 Interpretabilidad Mecanicista
    ├── RES-502 Reproducción Papers
    ├── RES-503 Puentes Formales (MATS/ARENA)
    ├── RES-504 Open Source Research
    └── CAR-501 Perfil Investigador
```

## Card Types per Deck

### 1. Basic (Front → Back)
**Use for**: Definitions, formulas, single concepts
```
Front: ¿Qué es el gradiente descendente?
Back: Algoritmo de optimización que itera θ ← θ - α∇J(θ) para minimizar J(θ). α = learning rate.
Tags: #MA-202 #optimización #definición
```

### 2. Cloze Deletion (Fill in the blank)
**Use for**: Formulas, multi-step processes, code snippets
```
Text: El {{c1::gradiente}} apunta en la dirección de {{c2::máximo crecimiento}} de la función. El gradient descendente usa {{c3::-α∇J(θ)}} para ir en dirección opuesta.
Tags: #MA-202 #optimización #fórmula
```

### 3. Image Occlusion (for diagrams/architectures)
**Use for**: Network architectures, computational graphs, pipeline diagrams
- Import diagram → mask labels → create cards per masked region

### 4. Code Card (Custom: front = problem, back = solution)
**Use for**: Deliberate practice sub-skills, implementation patterns
```
Front: Implementa SGD con momentum en NumPy (sin ver solución)
Back: 
```python
def sgd_momentum(params, grads, lr=0.01, momentum=0.9):
    if not hasattr(sgd_momentum, 'velocity'):
        sgd_momentum.velocity = [np.zeros_like(p) for p in params]
    for i, (p, g) in enumerate(zip(params, grads)):
        sgd_momentum.velocity[i] = momentum * sgd_momentum.velocity[i] - lr * g
        p += sgd_momentum.velocity[i]
```
Tags: #DL-302 #PyTorch #implementación #deliberate-practice
```

### 5. Feynman Card (Front = concept, Back = "Explain aloud in 60s")
**Use for**: Conceptual depth, teaching test
```
Front: Explica backpropagation a un compañero que sabe Python pero no DL
Back: [Grabar audio 60s o escribir explicación. Verificar: ¿usé jerga sin definir? ¿Salté pasos?]
Tags: #DL-301 #Feynman #backprop
```

## FSRS Configuration (Recommended)

```json
{
  "desired_retention": 0.90,
  "learning_steps": "10m 1h 6h 1d 3d",
  "relearning_steps": "10m 1h 4h",
  "maximum_interval": 36500,
  "easy_bonus": 1.3,
  "hard_interval": 1.2,
  "new_interval": 0.5,
  "lapse": {
    "mult": 0.1,
    "min_int": 1,
    "leech_threshold": 8
  }
}
```

## Daily Review Targets

| Deck Category | Morning Cards | Evening Cards | Total/Day |
|---------------|---------------|---------------|-----------|
| UPSJB Active (2-3 courses) | 15 | 10 | 25 |
| Roadmap Current Period (1-2 courses) | 10 | 5 | 15 |
| **Total** | **25** | **15** | **40** |

**Time**: ~15 min morning + 10 min evening = 25 min/day

## Tagging System (for filtered decks)

| Tag | Purpose |
|-----|---------|
| `#upsjb` | All university courses |
| `#roadmap` | All roadmap courses |
| `#period-1` through `#period-5` | Roadmap period filter |
| `#core` | ⭐ mapped courses (priority) |
| `#support` | ⚡ mapped courses |
| `#feynman` | Feynman-type cards |
| `#code` | Code implementation cards |
| `#formula` | Math formula cards |
| `#leech` | Auto-tagged by FSRS after 8 lapses |

## Filtered Deck Examples (Create in Anki)

1. **Daily Morning Review**: `tag:upsjb OR tag:roadmap` + `is:due` + `limit:25`
2. **Weekend Deep Review**: `tag:core` + `prop:ivl<7` (cards due within a week)
3. **Pre-Exam Cram**: `tag:upsjb` + `tag:period-2` + `is:due` (before partials)
4. **Leech Hunt**: `tag:leech` (weekly 15min session to fix/rephrase)

## Integration with Schedule

- **Morning Anki (12:00-12:20)**: UPSJB cards due + Roadmap current period
- **Evening Anki (21:00-21:15)**: Failed cards relearning + new cards from day's study
- **Sunday Review**: Filtered deck "Weekly Leech Hunt" + stats check (retention >85%)

## Adding New Cards (Workflow)

1. **During class**: Note → "Anki candidate" tag in Notion
2. **Post-class (15min)**: Create 3-5 cards from notes (Basic + Cloze + Feynman)
3. **During deep work**: When implementing → create Code card for pattern
4. **Paper reading**: 1 Feynman card per paper (explain core contribution)
5. **Weekly review**: Audit new cards, tag correctly, move to appropriate subdeck

## Quality Rules

- **One fact per card** (atomic)
- **Front: question only, no hints** (except Cloze context)
- **Back: minimal answer, no fluff**
- **Code cards: runnable snippet, <15 lines**
- **Feynman cards: trigger oral/written explanation, not recognition**
- **Images: only for spatial/architectural knowledge**