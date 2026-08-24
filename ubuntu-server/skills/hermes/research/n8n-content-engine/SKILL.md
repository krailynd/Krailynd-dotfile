---
name: n8n-content-engine
description: "Operate and audit the n8n-based content/research engine: 12+ workflow tools for content idea generation (IA, vendehumos, gaming, fútbol, F1), company risk signals, market digest, academic overview (Blackboard/Notion), and ad-hoc research packs. Use when triggering, scheduling, debugging, or batch-verifying these tools."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [n8n, content-engine, research, automation, scheduling, rate-limit]
    related_skills: [notion, google-workspace, content-idea-audit, investment-research]
---

# n8n Content Engine — Orquestación y verificación

Sistema editorial + académico + financiero de YOUR_NAME/Krailynd expuesto como MCP server `n8n` (12+ tools). Cada tool es un workflow independiente dentro de n8n que puede correr en cron interno (4h, 6h, 12h) O ejecutarse a demanda desde Hermes.

## Cuando usar este skill

- Usuario pide verificar si los workflows de n8n están funcionando
- Usuario quiere disparar manualmente un research engine (ej. "busca ideas de gaming")
- Usuario pregunta qué hay de nuevo en mercados / Blackboard / academia
- Auditoría general del motor de contenido/noticias
- Debug de un workflow específico de n8n que falla

## Catálogo de tools (referencia rápida)

### Research engines — content vertical A
- `generate_content_ideas_ia` — IA, Open Source, herramientas (OpenAI, Google, DeepMind, HF, HN, GitHub Trending). Cron: 5h.
- `generate_content_ideas_vendehumos` — Vendehumos + Disciplina real (Cal Newport, Farnam School). Hasta 2 páginas radar. Cron: 6h.

### Research engines — verticales B/C/D/E
- `generate_content_ideas_gaming` — IGN, PC Gamer, Eurogamer, RPS. Cron: 6h.
- `generate_content_ideas_futbol` — ESPN, BBC, Marca + Liga 1 Perú (TheSportsDB). Cron: 6h.
- `generate_content_ideas_f1` — NO ingiere datos nuevos; lee `F1 Finalizados` Notion ya mantenida por otro sistema, crea ideas solo si hay carreras sin fuente. Cron: 12h.
- `check_company_risk_signals` — 8 entidades (OpenAI, Anthropic, Google DeepMind, MS, Meta, DeepSeek, BTC, ETH). Severidad Alta → crea radar. Cron: 6h. **Solo informativo, NUNCA asesoría financiera.**

### Mercados
- `get_market_digest` — top 5 cripto + S&P/Nasdaq/Dow/BVL/USD-PEN + titulares real-time. Cron: 4h. **Solo datos, NUNCA recomendación.**
- `get_market_chart` — gráfico + comparación histórica de UN activo (bitcoin/ethereum/sp500/nasdaq/dow/bvl).

### Académico UPSJB

**Tools que devuelven datos inline** (usar estas para construir resúmenes):
- `get_academic_overview` — vista completa por curso: tareas pendientes, notas recientes, contenido nuevo. Devuelve JSON con `cursos[].tareas_pendientes`, `calificaciones_recientes`, `contenido_reciente`.
- `get_course_averages` — promedio ponderado por curso (PC1-4 15% c/u, EP 20%, EF 20%, mín 11/20). Devuelve JSON con `promedios_por_componente`, `promedio_actual_renormalizado_sobre_20`, `componentes_faltantes`, `bajo_el_minimo`.

**Tools que solo entregan a WhatsApp** (NO devuelven datos al caller — envían notificación push):
- `check_blackboard_grades_and_content` — devuelve `{"status":"delivered","target":"whatsapp"}`. Para ver el detalle, usar `get_academic_overview` en su lugar.
- `check_blackboard_updates` — igual, push a WhatsApp.
- `check_upsjb_financial_status` — igual, push a WhatsApp.
- `get_academic_daily_briefing` — igual, push a WhatsApp.

**Tools de escritura**:
- `create_task_note` / `save_class_notes` — escriben a Notion. Reciben parámetros (`curso`, `titulo`, etc.).

⚠️ **Para un resumen académico completo**: usar `get_academic_overview` + `get_course_averages` (inline). NO depender de las tools que hacen push a WhatsApp para construir un resumen — solo devuelven `{"status":"delivered"}` sin datos.

### Ad-hoc
- `build_research_pack` — recibe `tema`, junta fuentes Notion + Google News, arma documento en `Research Packs`. A demanda.
- `schedule_reminder` — recordatorio one-shot WhatsApp vía n8n.

## Procedimiento — verificar que funcionan

### 1. Confirmar que n8n está vivo
Llamar `get_n8n_health` con `{"input": {}}`. Si devuelve `{"result":[{"status":"ok"}]}` → operacional.

### 2. Verificar qué corre en intervalo de 4h+
`cronjob action=list` → buscar jobs locales. Recordar: **los research engines de n8n NO están como cronjobs de Hermes** — los dispara el scheduler interno de n8n. Los cronjobs de Hermes son ortogonales (email, F1 sync, etc.).

### 3. Disparar tools a demanda (auditoría batch)

⚠️ **PITFALL CRÍTICO — Rate limiting.** Las 7+ tools pesadas hacen web scraping a APIs externas (Google News, RSS, CoinGecko, Yahoo). Disparo en paralelo masivo:

```
✗ Mal — dispara 7 a la vez → algunas devuelven "service receiving too many requests"
  y eventualmente el MCP server cae con "MCP server 'n8n' is unreachable after 3
  consecutive failures".

✓ Bien — semi-paralelo controlado: 1-3 por turno, ~60s entre reintentos.
  Las "safe" (que solo leen datos cacheados o Yahoo/CoinGecko generous limits)
  primero: get_market_digest, get_academic_*, get_market_chart.
  Después las costosas: generate_content_ideas_*, check_company_risk_signals.
```

Ordenamiento sugerido para una auditoría rápida:

| Turno | Tools |
|---|---|
| 1 | `get_market_digest`, `get_market_chart` (si aplica), `get_n8n_health` |
| 2 | `generate_content_ideas_f1` (más barata — solo lee Notion), `check_company_risk_signals` |
| 3 | `generate_content_ideas_ia`, `generate_content_ideas_gaming` |
| 4 (después de 60s) | `generate_content_ideas_vendehumos`, `generate_content_ideas_futbol` |

Si una tool devuelve rate-limit, **NO reintentar inmediatamente** — esperar 60s+ o warning explícito del MCP "Auto-retry available in ~55s".

### 4. Interpretar respuestas

| Tool | Respuesta cuando está OK |
|---|---|
| Content ideas | `{"status": "delivered", "target": "whatsapp"}` (se entrega a WhatsApp) o `{"skip": true}` (ya corrió hoy, no notifica spam) o `{"should_create": false, "should_notify": false}` (no hay material nuevo) |
| Risk signals | `{"skip": true}` cuando ya corrió — correcto |
| Market digest | `{"status": "delivered", "target": "whatsapp"}` siempre (es informativo puro) |
| Health | `{"status": "ok"}` |

Si devuelve error desconocido → revisar logs de n8n directamente (fuera de alcance de este skill).

## Reglas duras (NUNCA romper)

1. **Nunca usar `browser_use`/Playwright para Blackboard/Office 365.** Las tools de n8n ya tienen sesión autenticada persistida. Solo usar las 12 tools listadas.
2. **Nunca pedir credenciales de Blackboard/MS365.** Si una tool devuelve `login_required`, comunicárselo al usuario y parar.
3. **NUNCA dar recomendaciones de inversión propias.** `get_market_digest` y `get_market_chart` son solo informativos. Presentar datos y noticias con su URL de fuente tal cual vienen. Si el usuario pide "debería invertir en X", aclarar que no eres asesor financiero.
4. **NUNCA redactar la opinión final del creador.** Las tools de content organizan fuentes; YOUR_NAME escribe la opinión. Solo opinar si pide explícitamente "dame tu opinión".
5. **NUNCA auto-enviar emails a partir de los datos de n8n.** Usar solo para lectura académica o de mercado.

## Pitfalls

- **MCP server `n8n` puede estar `enabled: false` en `~/.hermes/config.yaml`.** Cuando lo está, Hermes NO puede invocar los tools nativamente. Workaround: llamar el endpoint MCP Streamable HTTP directamente via curl (ver `references/mcp-http-fallback.md` para el procedimiento completo). El endpoint URL y el Bearer token están en `config.yaml` bajo `mcp_servers.n8n`.
- **Disparo batch = rate limit hell.** Ya documentado arriba. NUNCA 7+ tools en un solo turn batch.
- **Generate_content_ideas_f1 devuelve skip la mayoría del tiempo** — es correcto, está esperando carreras nuevas. No significa error.
- **El campo `deliver` de cronjobs en Hermes** es local-only por defecto; los research engines de n8n entregan vía WhatsApp por sí mismos (route: `n8n-notify-whatsapp`).
- **Timezone UTC vs Lima.** `next_run_at` viene en UTC. Perú = UTC-5. Sumar 5h para hora local.
- **Las tools académicas leen Blackboard que es blackboard.com** (UPSJB), NO Canvas. Skill `canvas` (CANVAS_API_TOKEN) no aplica para UPSJB.

## Verificación

Smoke test mínimo:

```
get_n8n_health(input={})
get_market_digest(input={})
```

Si ambos devuelven OK → motor funcional.

Para test batch controlado, seguir el procedimiento de 4 turnos arriba.

## Referencias

- `references/mcp-http-fallback.md` — cómo llamar los tools de n8n vía HTTP cuando el MCP server está `enabled: false` en config.yaml (protocolo MCP Streamable HTTP completo).
- `~/n8n-stack/CONTENT_ARCHITECTURE.md` — arquitectura detallada del sistema editorial (Notion).
- `~/n8n-stack/NOTION_SCHEMA.md` — schema de las bases Notion (Biblioteca de Contenido, Content Sources, Research Packs).
- Bases Notion clave: `Biblioteca de Contenido` (bajo "Proyectos YouTube"), `Content Sources`, `Research Packs`, `Companies / Assets / Risks`, `F1 Fechas`, `F1 Finalizados`, `Universidad - Tareas`, `Actividad Blackboard`, `Apuntes de Clase`.
