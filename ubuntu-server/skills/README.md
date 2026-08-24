# Skills

Curated, sanitized snapshot of skills installed on the SahaCloud Ubuntu Server. Total **215 skills**: **192 Hermes** + **23 OpenCode**. No secrets, no tokens, no binary blobs.

## Layout

```
skills/
├── README.md          # this file
├── hermes/            # Hermes skills (category → skill → SKILL.md + templates/*.md)
│   ├── _shared/       # shared conventions (SDD, persistence, resolver)
│   ├── apple/         # Apple ecosystem (notes, reminders, findmy, imessage)
│   ├── productivity/  # 51 skills: gdrive, notion, canvas, latex, etc.
│   ├── creative/      # image, video, media generation
│   ├── github/        # codebase-inspection, pr workflow, issues
│   └── ...            # 40+ categories
└── opencode/          # OpenCode-native skills (23, includes _shared)
```

Hermes categories mirror `~/.hermes/skills/*` (category → skill). OpenCode mirrors `~/.config/opencode/skills/*` (flat). Only `SKILL.md`, top-level `*.md` docs, `templates/*.md` and `references/*.md` are copied; `node_modules`, `__pycache__`, `*.db`, `*.token`, `*.log`, binaries are excluded.

## Install

Copy to your machine:
```bash
# Hermes skills (requires Hermes CLI)
cp -r skills/hermes/* ~/.hermes/skills/
# OpenCode skills
cp -r skills/opencode/* ~/.config/opencode/skills/
# Reload
hermes skills list   # or: opencode --help
```
Or symlink for live sync: `ln -s $(pwd)/skills/hermes/productivity ~/.hermes/skills/productivity`

## Catalog

| Category | Skill | Description | Origin |
|---|---|---|---|
|  Shared | `_shared` | Shared SDD references for installed skills. Not invokable. | hermes |
| Apple | `apple-notes` | Manage Apple Notes via memo CLI: create, search, edit. | hermes |
| Apple | `apple-reminders` | Apple Reminders via remindctl: add, list, complete. | hermes |
| Apple | `findmy` | Track Apple devices/AirTags via FindMy.app on macOS. | hermes |
| Apple | `imessage` | Send and receive iMessages/SMS via the imsg CLI on macOS. | hermes |
| Autonomous Ai Agents | `claude-code` | Delegate coding to Claude Code CLI (features, PRs). | hermes |
| Autonomous Ai Agents | `codex` | Delegate coding to OpenAI Codex CLI (features, PRs). | hermes |
| Autonomous Ai Agents | `computer-use` | Drive the desktop in the background without stealing focus. | hermes |
| Autonomous Ai Agents | `hermes-agent` | Configure, extend, or contribute to Hermes Agent. | hermes |
| Autonomous Ai Agents | `merge-reconciler` | Neutral third-party resolution of agent merge conflicts. | hermes |
| Autonomous Ai Agents | `opencode` | Delegate coding to OpenCode CLI (features, PR review). | hermes |
| Branch Pr | `branch-pr` | Create Gentle AI pull requests with issue-first checks. Trigger: creating, opening, or preparing PRs for review. | hermes |
| Chained Pr | `chained-pr` | Trigger: PRs over 400 lines, stacked PRs, review slices. Split oversized changes into chained PRs that protect review focus. | hermes |
| Cognitive Doc Design | `cognitive-doc-design` | Design docs that reduce cognitive load. Trigger: writing guides, READMEs, RFCs, onboarding, architecture, or review-facing docs. | hermes |
| Comment Writer | `comment-writer` | Write warm, direct collaboration comments. Trigger: PR feedback, issue replies, reviews, Slack messages, or GitHub comments. | hermes |
| Creative | `ai-to-pixel-art` | Use when the user asks for pixel art of something that doesn't exist as an image yet — 'haz un pirata', 'dibuja un dragón pixel art', 'make a pixel art chara... | hermes |
| Creative | `architecture-diagram` | Dark-themed SVG architecture/cloud/infra diagrams as HTML. | hermes |
| Creative | `ascii-art` | ASCII art: pyfiglet, cowsay, boxes, image-to-ascii. | hermes |
| Creative | `ascii-video` | ASCII video: convert video/audio to colored ASCII MP4/GIF. | hermes |
| Creative | `baoyu-infographic` | Infographics: 21 layouts x 21 styles (信息图, 可视化). | hermes |
| Creative | `claude-design` | Design one-off HTML artifacts (landing, deck, prototype). | hermes |
| Creative | `design-md` | Author/validate/export Google's DESIGN.md token spec files. | hermes |
| Creative | `excalidraw` | Hand-drawn Excalidraw JSON diagrams (arch, flow, seq). | hermes |
| Creative | `humanizer` | Humanize text: strip AI-isms and add real voice. | hermes |
| Creative | `imagen` | Generación universal de imágenes por IA gratis e ilimitada (Flux.1 / SDXL / Realismo / Anime) con local-image-gen.py. | hermes |
| Creative | `imagen-escena` | Generación de escenas épicas, entornos y fondos artísticos con Pollinations Flux.1. | hermes |
| Creative | `imagen-pixelart` | Pixel art y arte retro estilo Aseprite: sprites, tilesets, fondos y personajes con paletas históricas (NES, Game Boy, PICO-8, C64). Cubre el escalado sin des... | hermes |
| Creative | `imagen-retrato` | Generación de retratos de personajes (anime, fotorrealismo, fantasy) con Pollinations Flux. | hermes |
| Creative | `imagen-tecnica` | Imágenes técnicas, conceptuales y educativas: diagramas, esquemas, cortes transversales, infografías, láminas para clase y presentaciones. Distingue cuándo g... | hermes |
| Creative | `manim-video` | Manim CE animations: 3Blue1Brown math/algo videos. | hermes |
| Creative | `p5js` | p5.js sketches: gen art, shaders, interactive, 3D. | hermes |
| Creative | `pixel-art` | Use when converting a photo or image into pixel art, creating sprites, character portraits, comic panels or backgrounds in retro style, applying Game Boy / N... | hermes |
| Creative | `popular-web-designs` | 54 real design systems (Stripe, Linear, Vercel) as HTML/CSS. | hermes |
| Creative | `pretext` | Build creative browser demos with DOM-free text layout. | hermes |
| Creative | `sketch` | Throwaway HTML mockups: 2-3 design variants to compare. | hermes |
| Creative | `songwriting-and-ai-music` | Songwriting craft and Suno AI music prompts. | hermes |
| Creative | `touchdesigner-mcp` | Control TouchDesigner via twozero MCP. | hermes |
| Data Science | `jupyter-live-kernel` | Iterative Python via live Jupyter kernel (hamelnb). | hermes |
| Devops | `docker-management` | Manage Docker containers, images, volumes, networks, and Compose stacks — lifecycle ops, debugging, cleanup, and Dockerfile optimization. | hermes |
| Devops | `sdlc-review` | Review Kanban handoffs and route verified outcomes. | hermes |
| Devops | `server-administration` | Server health audits, process management, service lifecycle, resource diagnostics, and host-level administration — everything outside Docker containers. | hermes |
| Devops | `windows-remote` | SSH al PC Windows de krailynd y gestion de proyectos ahi. | hermes |
| Email | `agentmail` | Give the agent its own dedicated email inbox via AgentMail. Send, receive, and manage email autonomously using agent-owned email addresses (e.g. hermes-agent... | hermes |
| Email | `email-inbox-triage` | Triage an inbox: prioritize threads, draft replies safely. | hermes |
| Email | `himalaya` | Himalaya CLI: IMAP/SMTP email from terminal. | hermes |
| Email | `krailynd-email` | Email operations for Krailynd's connected inboxes: vivaldi.net via Himalaya IMAP and Gmail via Google Workspace OAuth. Covers listing, reading, monitoring, a... | hermes |
| Github | `codebase-inspection` | Inspect codebases w/ pygount: LOC, languages, ratios. | hermes |
| Github | `github-auth` | GitHub auth setup: HTTPS tokens, SSH keys, gh CLI login. | hermes |
| Github | `github-code-review` | Review PRs: diffs, inline comments via gh or REST. | hermes |
| Github | `github-issue-to-pr` | Carry a GitHub issue to a verified PR with honest CI state. | hermes |
| Github | `github-issues` | Create, triage, label, assign GitHub issues via gh or REST. | hermes |
| Github | `github-pr-workflow` | GitHub PR lifecycle: branch, commit, open, CI, merge. | hermes |
| Github | `github-repo-management` | Clone/create/fork repos; manage remotes, releases. | hermes |
| Go Testing | `go-testing` | Trigger: Go tests, go test coverage, Bubbletea teatest, golden files. Apply focused Go testing patterns. | hermes |
| Graphify | `graphify` | Use for any question about a codebase, its architecture, file relationships, or project content — especially when graphify-out/ exists, where the question sh... | hermes |
| Hermes Desktop Plugins | `hermes-desktop-plugins` | Write desktop app plugins that add UI panes and commands. | hermes |
| Hermes Themes | `hermes-themes` | Author a Hermes color theme that skins every surface. | hermes |
| Issue Creation | `issue-creation` | Create and triage GitHub issues from repository evidence. Trigger: issue creation, bug reports, feature requests, or issue approval. | hermes |
| Judgment Day | `judgment-day` | Trigger: judgment day, dual review, adversarial review, juzgar. Run explicit blind dual review with at most two scoped fix/re-judgment rounds. | hermes |
| Media | `content-idea-audit` | Audit notes/databases for content ideas, especially YouTube ideas; score which are worth developing and suggest next writing angles. | hermes |
| Media | `data-charts` | Gráficos estadísticos con datos EXACTOS: barras, líneas, dispersión, histogramas, mapas de calor, tartas y gráficos combinados, renderizados con matplotlib. ... | hermes |
| Media | `gif-search` | Search/download GIFs from Tenor via curl + jq. | hermes |
| Media | `heartmula` | HeartMuLa: Suno-like song generation from lyrics + tags. | hermes |
| Media | `hermes-video-watch` | Analyze videos, YouTube links, screen recordings, and educational clips in Hermes Agent by extracting transcripts, focused screenshots, contact sheets, and t... | hermes |
| Media | `image-downloader` | Descargar imágenes: una URL directa, o todas las imágenes de una página web. Usa el comando `imgdl`, que parsea el HTML de verdad (img, source, srcset, lazy-... | hermes |
| Media | `image-gallery` | Organizar imágenes: listar con dimensiones, generar miniaturas, montar hojas de contacto, redimensionar en lote, convertir formatos y detectar duplicados por... | hermes |
| Media | `imagen-postproceso` | Mejorar imágenes ya existentes o recién generadas: ampliar resolución, corregir color y contraste, afilar, recortar a proporción y ampliar lienzo. Usa el com... | hermes |
| Media | `imagen-verifica` | Skill de inspección y visión técnica de imágenes sin fallos de API key (local-vision-ocr.py + Pillow + OCR Tesseract). | hermes |
| Media | `social-downloader` | Download videos, photos, and GIFs from YouTube, X/Twitter, Instagram, Facebook, TikTok via yt-dlp. | hermes |
| Media | `songsee` | Audio spectrograms/features (mel, chroma, MFCC) via CLI. | hermes |
| Media | `youtube-content` | YouTube transcripts to summaries, threads, blogs. | hermes |
| Media | `youtube-download` | Download YouTube videos using yt-dlp with Deno runtime for JavaScript extraction. Optimized for Krailynd's workflow (Vector, tutorials, offline viewing). | hermes |
| Media | `youtube-full` | Use when YouTube is or could be relevant — even if not mentioned: pasted video/channel/playlist links, video IDs, @handles, creator lookups, video summaries,... | hermes |
| Mlops | `audiocraft-audio-generation` | AudioCraft: MusicGen text-to-music, AudioGen text-to-sound. | hermes |
| Mlops | `evaluating-llms-harness` | lm-eval-harness: benchmark LLMs (MMLU, GSM8K, etc.). | hermes |
| Mlops | `huggingface-hub` | HuggingFace hf CLI: search/download/upload models, datasets. | hermes |
| Mlops | `llama-cpp` | llama.cpp local GGUF inference + HF Hub model discovery. | hermes |
| Mlops | `segment-anything-model` | SAM: zero-shot image segmentation via points, boxes, masks. | hermes |
| Mlops | `serving-llms-vllm` | vLLM: high-throughput LLM serving, OpenAI API, quantization. | hermes |
| Mlops | `weights-and-biases` | W&B: log ML experiments, sweeps, model registry, dashboards. | hermes |
| Note Taking | `affine` | Create, list, count, search, move, and append to notes in the self-hosted AFFiNE instance (draw.sahacloud.dpdns.org), inside the TEMP folder, for quick captu... | hermes |
| Opencode | `opencode` | Delegate coding to OpenCode CLI (features, PR review). | hermes |
| Opencode Ensemble | `opencode-ensemble` | Use when coordinating multiple coding agents, delegating independent software work, managing OpenCode Ensemble teams, choosing teammate roles or models, revi... | hermes |
| Opencode Memory | `opencode-memory` | Browse local OpenCode history: sessions, messages, plans, prompt history, and prior decisions. Use when the user says history, previous session, last time, r... | hermes |
| Productivity | `academic-deliverables` | Generate academic deliverables (reports, solved problems, study guides, LaTeX, PDF) with proper formatting and delivery via WhatsApp. | hermes |
| Productivity | `academic-research` | Academic & Scientific Research skill: search ArXiv, PubMed, Semantic Scholar, download PDFs, extract text, summarize papers, and generate APA/IEEE citations. | hermes |
| Productivity | `academic-schedule-integration` | Integrate class schedule with roadmap, assign techniques. | hermes |
| Productivity | `agy-cli` | Skill de Antigravity CLI (agy 1.1.10) para Hermes. Generación de imágenes, análisis visual y razonamiento con Gemini 3.1 Pro en Ubuntu o Windows. | hermes |
| Productivity | `airtable` | Airtable REST API via curl. Records CRUD, filters, upserts. | hermes |
| Productivity | `big-data-spark` | Skill de Big Data y Procesamiento Masivo con PySpark 4.1.1 en Windows (E:\entornos\spark). Pipelines ETL, Spark SQL y procesado distribuido. | hermes |
| Productivity | `blackboard` | Blackboard Learn LMS access for UPSJB — course announcements, assignments, and content via browser automation or REST API. | hermes |
| Productivity | `box` | Box manages cloud files, sharing, search, and metadata. | hermes |
| Productivity | `canvas` | Canvas LMS integration — fetch enrolled courses and assignments using API token authentication. | hermes |
| Productivity | `caveman` | Ultra-compressed communication mode. Cuts output tokens 65% (measured) by speaking like caveman while keeping full technical accuracy. Supports intensity lev... | hermes |
| Productivity | `context7` | Skill oficial de Context7 MCP. Consulta documentación actualizada de librerías con acceso directo por Library ID (/org/proyecto) para ahorro de latencia y to... | hermes |
| Productivity | `data-science-analytics` | Skill de Ciencia de Datos y Análisis de Negocios en Windows (E:\entornos\data-science). Análisis exploratorio (EDA), Polars, Pandas, Scikit-Learn y dashboards. | hermes |
| Productivity | `data-science-spark-win` | Data Science, Machine Learning, Deep Learning Research Engineering, PySpark, Predictions & Windows PC (windows-krai) Integration. | hermes |
| Productivity | `deep-learning-research` | Skill de Deep Learning y Research Engineering en Windows (E:\entornos\deep-learning). Entrenamiento de modelos, PyTorch, TensorFlow, Transformers y Visión Co... | hermes |
| Productivity | `document-to-action-items` | Extract cited obligations, deadlines, tasks from documents. | hermes |
| Productivity | `docx` | Create, read, edit, template, and review Word .docx files. | hermes |
| Productivity | `engram` | Use for Engram memory: save, search, cloud sync, agents. | hermes |
| Productivity | `estudio-examen` | Skill de Modo Estudio Examen: Convierte PDFs, vídeos de YouTube o notas en guías de estudio, simulacros de examen, diagramas y audio-podcasts de NotebookLM en el Vault de Obsidian. | hermes |
| Productivity | `github` | Unified GitHub integration for @krailynd and @sahahacking organization: search repos, create PRs, manage issues, releases, and CI/CD via gh CLI. | hermes |
| Productivity | `google-calendar-automation` | Bulk-create scientific schedules in Google Calendar. | hermes |
| Productivity | `google-workspace` | Gmail, Calendar, Drive, Docs, Sheets via gws CLI or Python. | hermes |
| Productivity | `hsade-engine` | Hermes Scientific Animation & Document Engine (HSADE). Integración nativa de ManimCE 0.20.1, compilador LaTeX autónomo (200-300 págs), diagramas de ingenierí... | hermes |
| Productivity | `image-ocr-pytesseract` | Extracción de texto local OCR desde imágenes o documentos PDF con Tesseract 5.5. | hermes |
| Productivity | `jupyter-notebook-creator` | Skill para creación autónoma, ejecución headless y exportación de Jupyter Notebooks (.ipynb) en Windows Anaconda/Jupyter Lab. | hermes |
| Productivity | `krailynd-google-workspace` | Quick Calendar/Drive/Sheets/Docs via google-workspace. | hermes |
| Productivity | `latex-paper-writer` | Skill de Redacción Agéntica de Documentos Académicos y Libros Masivos (200-300 págs) en LaTeX. Modularización (\include), RAG con NotebookLM, referencias bib... | hermes |
| Productivity | `local-vision-draw` | Skill de Generación de Imágenes por IA Gratis e Ilimitada (Flux.1 / Pollinations) y Visión por Computadora (OCR + Análisis Técnico Visual). | hermes |
| Productivity | `manim-scientific-animator` | Skill de Animación Científica y Matemática 2D/3D con ManimCE 0.20.1. Arco narrativo pedagógico (3Blue1Brown), cero errores geométricos, renderizado nativo en... | hermes |
| Productivity | `manim-video` | Generador y renderizador automático de vídeos de animación ManimCE (0.20.1). Ejecución nativa directa en Ubuntu Server y entrega del archivo MP4 en ACCESOS_R... | hermes |
| Productivity | `maps` | Geocode, POIs, routes, timezones via OpenStreetMap/OSRM. | hermes |
| Productivity | `math-solver-sympy` | Resolución de problemas matemáticos, álgebra lineal, cálculo diferencial/integral y matrices mediante Python SymPy y NumPy. | hermes |
| Productivity | `meeting-action-items` | Turn meeting notes into cited decisions, owners, tickets. | hermes |
| Productivity | `morphllm` | MorphLLM Integration: Ultra-fast general models (morph-v3-fast), Fast Apply (10,500 tok/s code edit), Model Router, WarpGrep, Context Compression (33,000 tok... | hermes |
| Productivity | `nano-pdf` | Edit text in existing PDFs via natural-language prompts. | hermes |
| Productivity | `navegador` | Operar el navegador Chrome principal del usuario en tiempo real mediante la extensión Hermes Browser Operator: abrir páginas, leer DOM, pulsar elementos, rel... | hermes |
| Productivity | `notebooklm` | NotebookLM Integration: Create notebooks, upload study PDFs/URLs, generate audio overviews (study podcasts), study guides, FAQs, and deep research synthesis. | hermes |
| Productivity | `notion` | Notion API + ntn CLI: pages, databases, markdown, Workers. | hermes |
| Productivity | `notion-database-creation` | Notion API techniques: database creation with custom properties, workspace structure auditing, and hierarchy reconstruction via REST API v2025-09-03. Complem... | hermes |
| Productivity | `notion-mcp` | Hermes MCP Integration for Notion (Krailynd Setup) — Full Notion management via MCP server with OAuth. | hermes |
| Productivity | `notion-workspace-audit` | Full inventory and structure mapping of a Notion workspace — find every page, database, and their hierarchy. | hermes |
| Productivity | `obsidian-second-brain` | Sistema maestro del Segundo Cerebro para Obsidian (E:\YOUR_VAULT\ en Windows), NotebookLM MCP y Hermes vía SSH Tailscale. Integración de notas, Podcasts de... | hermes |
| Productivity | `ocr-and-documents` | Extract text from PDFs/scans (pymupdf, marker-pdf). | hermes |
| Productivity | `pdf` | Create, read, merge, fill, and secure PDF files. | hermes |
| Productivity | `petdex` | Install and select animated petdex mascots for Hermes. | hermes |
| Productivity | `powerpoint` | Create, read, edit .pptx decks with python-pptx. | hermes |
| Productivity | `product-price-monitor` | Watch product, flight, or listing prices; alert on target. | hermes |
| Productivity | `session-librarian` | Organize sessions by prompt: find, rename, archive, prune. | hermes |
| Productivity | `teams-meeting-pipeline` | Teams meeting summaries, job replay, Graph subscriptions. | hermes |
| Productivity | `tui-widgets` | Author live widget apps for the Hermes TUI dock. | hermes |
| Productivity | `weekly-review-planning` | Weekly reset: commitments, stalled work, next-week plan. | hermes |
| Productivity | `xlsx` | Create, read, edit Excel .xlsx workbooks and CSVs. | hermes |
| Research | `arxiv` | Search arXiv papers by keyword, author, category, or ID. | hermes |
| Research | `blocked-page-recovery` | Recover blocked/paywalled/WAF'd pages via fallbacks. | hermes |
| Research | `blogwatcher` | Monitor blogs and RSS/Atom feeds via blogwatcher-cli tool. | hermes |
| Research | `competitor-news-monitor` | Watch named companies for material news; cited digests. | hermes |
| Research | `frontier-ai-career-paths` | Evaluate and plan careers at frontier AI labs (Anthropic, OpenAI, DeepMind). Distinct from "AI Engineer" roadmap-of-the-day content. Covers the three real ca... | hermes |
| Research | `grounded-citations` | Ground answers and documents in cited, verifiable sources. | hermes |
| Research | `investiga` | Enrutador de investigación web. Detecta el tipo de fuente (Reddit, X, YouTube, web genérica), elige el método correcto (API oficial, MCP, extracción HTTP o n... | hermes |
| Research | `investment-research` | Research and analyze investment opportunities across all asset classes, capital tiers, and platforms. Covers traditional markets, alternatives, crypto, fract... | hermes |
| Research | `llm-wiki` | Karpathy's LLM Wiki: build/query interlinked markdown KB. | hermes |
| Research | `n8n-content-engine` | Operate and audit the n8n-based content/research engine: 12+ workflow tools for content idea generation (IA, vendehumos, gaming, fútbol, F1), company risk si... | hermes |
| Research | `onlyfans-business-intelligence` | Research, analyze, and identify opportunities in the OnlyFans and adult content creator market. Includes competitive intelligence, creator discovery, and ser... | hermes |
| Research | `polymarket` | Query Polymarket: markets, prices, orderbooks, history. | hermes |
| Research | `scrapling` | Web scraping with Scrapling - HTTP fetching, stealth browser automation, Cloudflare bypass, and spider crawling via CLI and Python. | hermes |
| Research | `sports-event-lookup` | Search and extract real-time or scheduled sports event information (fixtures, results, standings) from authoritative sources like FIFA, UEFA, ESPN, or major ... | hermes |
| Research | `steam-gaming-research` | Research and analyze Steam game deals, open-world games with mods, and content creation opportunities for YouTube. Focused on budget-conscious recommendation... | hermes |
| Sdd Apply | `sdd-apply` | Implement SDD tasks from specs and design. Trigger: orchestrator launches apply for one or more change tasks. | hermes |
| Sdd Archive | `sdd-archive` | Archive a completed SDD change by syncing delta specs. Trigger: orchestrator launches archive after implementation and verification. | hermes |
| Sdd Design | `sdd-design` | Create the SDD technical design and architecture approach. Trigger: orchestrator launches design for a change. | hermes |
| Sdd Explore | `sdd-explore` | Explore SDD ideas before committing to a change. Trigger: orchestrator launches exploration or requirement clarification. | hermes |
| Sdd Init | `sdd-init` | Trigger: sdd init, iniciar sdd, openspec init. Initialize SDD context, testing capabilities, registry, and persistence. | hermes |
| Sdd Onboard | `sdd-onboard` | Walk users through the SDD workflow on the real codebase. Trigger: orchestrator launches onboarding for the full SDD cycle. | hermes |
| Sdd Propose | `sdd-propose` | Create an SDD change proposal with intent, scope, and approach. Trigger: orchestrator launches proposal work for a change. | hermes |
| Sdd Spec | `sdd-spec` | Write SDD delta specs with requirements and scenarios. Trigger: orchestrator launches spec work for a change. | hermes |
| Sdd Tasks | `sdd-tasks` | Break an SDD change into implementation tasks. Trigger: orchestrator launches task planning for a change. | hermes |
| Sdd Verify | `sdd-verify` | Trigger: SDD verification phase, verify change. Execute tests and prove implementation matches specs, design, and tasks. | hermes |
| Skill Creator | `skill-creator` | Trigger: new skills, agent instructions, documenting AI usage patterns. Create LLM-first skills with valid frontmatter. | hermes |
| Skill Improver | `skill-improver` | Trigger: improve skills, audit skills, refactor skills, skill quality. Audit and upgrade existing LLM-first skills. | hermes |
| Skill Registry | `skill-registry` | Trigger: update skills, skill registry, actualizar skills, after skill changes. Index available skills by trigger and path. | hermes |
| Smart Home | `homeassistant` | Control Home Assistant (luces, switches, sensores, escenas, scripts) vía su REST API con el comando `hass`. | hermes |
| Smart Home | `openhue` | Control Philips Hue lights, scenes, rooms via OpenHue CLI. | hermes |
| Smart Home | `tv-youtube-casting` | Buscar, filtrar por criterio (idioma, duración mínima, subtitulado) y reproducir un video de YouTube en la TV Hyundai de SahaCloud vía Home Assistant (`hass ... | hermes |
| Social Media | `genviral-poster` | Publicar y programar contenido en Instagram, TikTok, Facebook, YouTube, Pinterest, X, Threads, Bluesky y LinkedIn mediante la API de Genviral. ESTADO: pendie... | hermes |
| Social Media | `postproxy` | Publicar en varias redes sociales a la vez (Facebook, Instagram, TikTok, LinkedIn, YouTube, X, Threads, Pinterest, Bluesky, Telegram) mediante la API de Post... | hermes |
| Social Media | `reddit-reader` | Leer Reddit con la API oficial vía PRAW: posts, comentarios, subreddits, tendencias, imágenes y vídeos. Extrae título, autor, subreddit, fecha, score, número... | hermes |
| Social Media | `x-lector` | Leer publicaciones, hilos, media y respuestas de X (Twitter): texto, autor, fecha, métricas visibles, media adjunta, enlaces, contexto del hilo y URL del pos... | hermes |
| Social Media | `xurl` | X/Twitter via xurl CLI: raw post search, posting, DM, media. | hermes |
| Software Development | `devforge` | Ingeniería de software de alto nivel: diseñar e implementar programas complejos, elegir arquitectura según el tipo de proyecto (hexagonal, clean, vertical sl... | hermes |
| Software Development | `dogfood` | Exploratory QA of web apps: find bugs, evidence, reports. | hermes |
| Software Development | `hermes-agent-skill-authoring` | Author in-repo SKILL.md files: frontmatter and structure. | hermes |
| Software Development | `inspecting-hermes-desktop-dom` | Read the live Hermes desktop DOM/CSS over CDP. | hermes |
| Software Development | `java-windows-remote` | Compila/corre Java en el Windows de YOUR_NAME por SSH Tailscale. | hermes |
| Software Development | `node-inspect-debugger` | Debug Node.js via --inspect + Chrome DevTools Protocol CLI. | hermes |
| Software Development | `plan` | Write a markdown plan to .hermes/plans/; no execution. | hermes |
| Software Development | `python-debugpy` | Debug Python: pdb REPL + debugpy remote (DAP). | hermes |
| Software Development | `requesting-code-review` | Pre-commit review: security scan, quality gates, auto-fix. | hermes |
| Software Development | `rust-review` | Review a Rust crate: gate, choke points, safety, tests, CI. | hermes |
| Software Development | `simplify-code` | Parallel 4-agent cleanup of recent code changes. | hermes |
| Software Development | `spike` | Throwaway experiments to validate an idea before build. | hermes |
| Software Development | `systematic-debugging` | 4-phase root cause debugging: understand bugs before fixing. | hermes |
| Software Development | `test-driven-development` | TDD: enforce RED-GREEN-REFACTOR, tests before code. | hermes |
| Video | `frame-video` | Convertir secuencias de imágenes en vídeo con FFmpeg, y producir esas secuencias manteniendo coherencia de personaje, fondo y estilo entre fotogramas. Cubre ... | hermes |
| Web | `browser-use` | Use when browser automation needs Playwright (CLI/MCP/script), Camoufox anti-fingerprint Firefox, or attaching to an existing Chrome session — headed browsin... | hermes |
| Web | `firecrawl-search` | Búsqueda web y scraping estructurado con Firecrawl: convierte URLs a markdown limpio, rastrea sitios enteros y extrae datos con esquema. Requiere FIRECRAWL_A... | hermes |
| Web | `websearch-local` | Búsqueda web sin API key ni coste, contra la instancia SearXNG self-hosted de SahaCloud. Devuelve JSON con título, URL y snippet. Útil para buscar en la web,... | hermes |
| Web | `zen` | Operar el navegador Zen Browser real como si fueras un usuario: abrir paginas, leerlas, pulsar, escribir, desplazarte, capturar pantalla y descargar ficheros... | hermes |
| Work Unit Commits | `work-unit-commits` | Plan commits as reviewable work units. Trigger: implementation, commit splitting, chained PRs, or keeping tests and docs with code. | hermes |
| Yuanbao | `yuanbao` | Yuanbao (元宝) groups: @mention users, query info/members. | hermes |
| Development | `_shared` | Shared SDD references for installed skills. Not invokable. | opencode |
| Development | `comment-writer` | Write warm, direct collaboration comments. Trigger: PR feedback, issue replies, reviews, Slack messages, or GitHub comments. | opencode |
| Development | `go-testing` | Trigger: Go tests, go test coverage, Bubbletea teatest, golden files. Apply focused Go testing patterns. | opencode |
| Development | `graphify` | Use for any question about a codebase, its architecture, file relationships, or project content — especially when graphify-out/ exists, where the question sh... | opencode |
| Development | `issue-creation` | Create and triage GitHub issues from repository evidence. Trigger: issue creation, bug reports, feature requests, or issue approval. | opencode |
| Development | `judgment-day` | Trigger: judgment day, dual review, adversarial review, juzgar. Run explicit blind dual review with at most two scoped fix/re-judgment rounds. | opencode |
| Documentation | `cognitive-doc-design` | Design docs that reduce cognitive load. Trigger: writing guides, READMEs, RFCs, onboarding, architecture, or review-facing docs. | opencode |
| Git / PR | `branch-pr` | Create Gentle AI pull requests with issue-first checks. Trigger: creating, opening, or preparing PRs for review. | opencode |
| Git / PR | `chained-pr` | Trigger: PRs over 400 lines, stacked PRs, review slices. Split oversized changes into chained PRs that protect review focus. | opencode |
| Git / PR | `work-unit-commits` | Plan commits as reviewable work units. Trigger: implementation, commit splitting, chained PRs, or keeping tests and docs with code. | opencode |
| Meta / Skills | `skill-creator` | Trigger: new skills, agent instructions, documenting AI usage patterns. Create LLM-first skills with valid frontmatter. | opencode |
| Meta / Skills | `skill-improver` | Trigger: improve skills, audit skills, refactor skills, skill quality. Audit and upgrade existing LLM-first skills. | opencode |
| Meta / Skills | `skill-registry` | Trigger: update skills, skill registry, actualizar skills, after skill changes. Index available skills by trigger and path. | opencode |
| SDD Workflow | `sdd-apply` | Implement SDD tasks from specs and design. Trigger: orchestrator launches apply for one or more change tasks. | opencode |
| SDD Workflow | `sdd-archive` | Archive a completed SDD change by syncing delta specs. Trigger: orchestrator launches archive after implementation and verification. | opencode |
| SDD Workflow | `sdd-design` | Create the SDD technical design and architecture approach. Trigger: orchestrator launches design for a change. | opencode |
| SDD Workflow | `sdd-explore` | Explore SDD ideas before committing to a change. Trigger: orchestrator launches exploration or requirement clarification. | opencode |
| SDD Workflow | `sdd-init` | Trigger: sdd init, iniciar sdd, openspec init. Initialize SDD context, testing capabilities, registry, and persistence. | opencode |
| SDD Workflow | `sdd-onboard` | Walk users through the SDD workflow on the real codebase. Trigger: orchestrator launches onboarding for the full SDD cycle. | opencode |
| SDD Workflow | `sdd-propose` | Create an SDD change proposal with intent, scope, and approach. Trigger: orchestrator launches proposal work for a change. | opencode |
| SDD Workflow | `sdd-spec` | Write SDD delta specs with requirements and scenarios. Trigger: orchestrator launches spec work for a change. | opencode |
| SDD Workflow | `sdd-tasks` | Break an SDD change into implementation tasks. Trigger: orchestrator launches task planning for a change. | opencode |
| SDD Workflow | `sdd-verify` | Trigger: SDD verification phase, verify change. Execute tests and prove implementation matches specs, design, and tasks. | opencode |

## Notes

- Descriptions are taken from each `SKILL.md` frontmatter (`description:`). Truncated to one line.
- `hermes-desktop-plugins` and `hermes-themes` are included as skills (desktop plugin/theme helpers).
- No secrets are committed: `grep -R "SECRET_PATTERN" skills/` returns 0 hits (placeholders only).
- For MCP setup see `../mcp/README.md`.
