# Krailynd's Notion Roadmap — "Roadmap AI Engineer"

YOUR_NAME built a personal 10-phase AI engineering roadmap in Notion. This reference
captures its structure and how to evaluate it against the framework in this skill.

## Where it lives

- **Notion page title:** "Roadmap AI Engineer — Ingeniero Investigador en IA"
- **Page ID:** `3a7dfc0a-a985-81ca-a0cf-d9c52e1f08e0`
- **Parent:** a database (likely "Universidad - Tareas" or similar task DB)
- **Properties:** Descripción, Lenguajes (Python, SQL, Bash, Docker, Spring Boot,
  Java, C++, Rust), Estado (Pendiente), Prioridad (🔥 Crítica), Categoría (IA / ML)

## Structure (as of 2026-07-26)

The page is a meta-roadmap containing:

1. **10 phases** in a child database "Fases del Roadmap" (`3a7dfc0a-a985-81cc-a387-ec7597533b00`):
   - Fase 0: Entorno (1 sem) — WSL2, Docker, Git, VS Code
   - Fase 1: Fundamentos Matemáticos (2-3 meses) — Álgebra lineal, cálculo, probabilidad
   - Fase 2: Lenguajes (3-4 meses) — Python, Java+Spring Boot, C/C++, Rust
   - Fase 3: ML Clásico (6 meses) — Scikit-Learn
   - Fase 4: Deep Learning + PyTorch (6-8 meses)
   - Fase 5: NLP + Transformers (4-6 meses)
   - Fase 6: MLOps + Infra (6-12 meses)
   - Fase 7: Investigación + Research Taste (6-12 meses)
   - Fase 8: Carrera + Visibilidad (6-12 meses)
   - Fase 9: Empleo / Empresa Propia (6-12 meses)

   Each phase row has: Enfoque, Entregable clave, Criterio de salida, Recursos
   clave, Errores comunes, Proyecto F1, Prioridad, Estado.

2. **8 child databases** covering detail per area:
   - Lenguajes de Programación
   - Matemáticas para IA
   - ML y Deep Learning
   - Infraestructura y MLOps
   - Carrera y Empleo en IA (empresas objetivo, links de aplicación, comp)
   - Data Engineering
   - Biblioteca Maestra de Recursos
   - Proyectos Formula 1 (F1-themed exercises for each phase)

3. **Checklist maestro** of 10 projects (image classifier → MLP from scratch →
   CNN PyTorch → Transformer from scratch → LoRA fine-tuning → MLOps pipeline →
   paper reproduction with TransformerLens → Rust CLI for model serving)

4. **Rutina semanal** — 15-20h/semana, 2h/día L-V

5. **Recursos limitados** — workarounds for no-GPU (Colab, Kaggle, Lambda Labs,
   RunPod, mixed precision, gradient accumulation)

## How to evaluate it — what this roadmap does right (and wrong)

### Strong points (doesn't need softening):
- **Measurable exit criteria** per phase (accuracy thresholds, perplexity targets)
- **Projects as proof** — not "learn X" but "build Y with measurable success"
- **F1-themed practice** keeps motivation and produces public artifacts
- **Anticipated pitfalls** per phase (data drift vs concept drift, interpreting
  large models before small ones)
- **No-GPU workarounds** are pragmatic, not defeatist
- **Phase 7 includes TransformerLens + Anthropic circuits** — real research taste

### Gaps to flag when reviewing:
1. **Java's role is ambiguous.** The roadmap lists Java/Spring Boot in Fase 2
   as "backend/enterprise" but frontier lab research roles don't use Java. If
   the goal is Research Engineer, Java is a career-sustenance skill (pays bills
   now), not a research-track skill. If the goal is ML Infrastructure Engineer,
   Java/Spark/Kafka IS the entry — but the roadmap should say that explicitly.
   **Decision YOUR_NAME needs to make:** is Java sustenance + IA the scientific track,
   or both as simultaneous priority A? The roadmap dodges this.

2. **Fases 1-2 can be compressed.** YOUR_NAME already has Java, Python, Bash, Docker,
   Linux experience. The roadmap budgets 5-7 months for Fases 1-2 combined;
   3 months is more realistic given existing skills.

3. **Fase 0 is likely already done.** YOUR_NAME has SahaCloud (Docker, Caddy, CF
   Tunnel, Tailscale) operational. WSL2/Docker/Git/VS Code are all deployed.
   Mark it done and advance.

4. **No connection to the content engine.** YOUR_NAME already has a Notion content
   system (Biblioteca de Contenido, Content Sources, Research Packs) that
   produces research material for his YouTube channel. Fase 7 (Investigación)
   should explicitly leverage those research packs as input — the synergy is
   obvious but the roadmap doesn't mention it.

5. **Timeline assumes 15-20h/week but doesn't validate against university load.**
   YOUR_NAME is in Ingeniería de Sistemas at UPSJB with cálculo integral and física
   demanding time. The roadmap should confront whether 15-20h/week is viable
   during exam periods.

## Analysis pattern (for future sessions)

When YOUR_NAME asks to review/analyze his Notion roadmap:

1. **Read the Notion page** via direct API (`GET /v1/pages/{id}`) + child blocks
   (`GET /v1/blocks/{id}/children`) + query each child database.
2. **Map against the 3-layer framework** (application / infra / research) from
   this skill's main body.
3. **Check for measurable exit criteria** — are phases pass/fail or vague?
4. **Check Java's role** — is it sustenance or research-track? Flag the ambiguity.
5. **Check timeline realism** against existing skills and university load.
6. **Check synergy with existing systems** (content engine, SahaCloud infra).
7. **Deliver analysis in Spanish** (YOUR_NAME's language) with concrete adjustment
   suggestions, not generic advice.
