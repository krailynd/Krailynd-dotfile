---
name: affine
description: Create, list, count, search, move, and append to notes in the self-hosted AFFiNE instance (draw.sahacloud.dpdns.org), inside the TEMP folder, for quick capture from WhatsApp and other connected channels.
platforms: [linux]
---

# AFFiNE quick notes — the "knowledge" half of capture

This skill is deliberately narrow: it only handles **knowledge** (notes,
ideas, article summaries, research) landing in AFFiNE. Reminders, tasks,
to-do lists, and anything actionable ("recuérdame...", "agrega X a mi lista
de pendientes") are **not** this skill's job — Hermes already has `todo`,
`kanban`, and `cron` tools for that; use those instead of inventing a
parallel task system here. When a message is ambiguous between the two,
default to treating it as a note (safer: worst case it's a note that could
have been a task, not a task silently swallowed with no record).

Use this skill when the user asks (via WhatsApp or any connected channel) to
capture, create, list, count, search, move, or append to notes/apuntes in
AFFiNE. This is the quick-capture inbox: notes created through this skill
land in a folder called `TEMP` inside the `Krailynd` workspace at
`https://draw.sahacloud.dpdns.org`, and can later be moved to a topical
folder (e.g. `Youtube`) once they're no longer "inbox".

There is no safe direct API for writing AFFiNE content (its real write API
expects binary CRDT/Yjs updates, not plain text). - [AFFiNE Workspace Reference](references/affine-workspace.md) — Current workspace structure, user preferences, and integration notes for SahaCloud instance

## How to invoke it

Use the `terminal` tool to run the CLI at:
```
/home/sahacloud/sahacloud-infra/automations/hermes-affine/scripts/cli.js
```

Working directory must be `/home/sahacloud/sahacloud-infra/automations/hermes-affine`
(it resolves `node_modules` and the local state file relative to itself).

```bash
cd /home/sahacloud/sahacloud-infra/automations/hermes-affine
node scripts/cli.js create "<título>" "<contenido>" [--folder=TEMP] [--template=<nombre>]
node scripts/cli.js append "<título exacto>" "<texto a agregar>"
node scripts/cli.js list [--folder=TEMP]
node scripts/cli.js count [--folder=TEMP]
node scripts/cli.js exists "<título exacto>"
node scripts/cli.js search "<consulta aproximada>" [--limit=5]
node scripts/cli.js recent [--limit=10]
node scripts/cli.js move "<título exacto>" --from=TEMP --to=<carpeta destino>
```

`recent` reads only the local auxiliary index (no browser, near-instant) —
prefer it for "qué he capturado últimamente" style questions. Every other
command drives a real browser against the live instance.

Every command prints exactly one line of JSON to stdout, e.g.
`{"ok":true,"title":"...","pageId":"...","folder":"TEMP"}` or
`{"ok":true,"notes":["Nueva idea YouTube","ideas shorts"]}` or
`{"ok":false,"error":"..."}`. Parse that JSON to decide what to tell the user.

Each command takes roughly 10-30 seconds (it drives a real headless browser
against the live AFFiNE instance) — this is expected, not a hang.

## Mapping user intent to commands

| User says (WhatsApp, es/en) | Command |
|---|---|
| "crea un apunte llamado X" / "create a note called X" | `create "X" ""` |
| "crea un apunte X con este contenido: ..." | `create "X" "..."` |
| "guarda esto como apunte" / dictated text with no title | `create "Nota <fecha y hora>" "<texto dictado>" --template=nota-temporal` |
| "agrega esto al apunte X" / "add this to X" | `append "X" "<texto>"` — if `exists "X"` is false first, tell the user the note wasn't found instead of silently creating one |
| "qué apuntes hay" / "what notes exist" | `list --folder=TEMP` |
| "cuántos apuntes hay" | `count --folder=TEMP` |
| "existe el apunte X" | `exists "X"` |
| "crea una idea de video sobre X" | `create "X" "" --template=idea-youtube` |
| "busca mi nota sobre X" / "encuentra apuntes de X" | `search "X"` — if multiple matches score close together, list the titles and ask the user which one before opening/appending to any of them |
| "dime los últimos N apuntes" / "qué he capturado hoy" | `recent --limit=N` |
| "mueve/clasifica X a la carpeta Y" / "ya no es TEMP, va en Y" | `move "X" --from=TEMP --to=Y` |
| PDF/image/voice attachment arrives, or a link is shared | see "Attachments and links" below |

Available `--template=` values: `idea-youtube`, `guion-corto`, `idea-rapida`,
`nota-temporal`, `investigacion`, `tarea-proyecto`, `diario-aprendizaje`,
`documentacion-tecnica`, `lista-referencias`. Full template bodies are in
`scripts/lib/templates.js` in that same project — read that file if you need
to know exactly what a template inserts before choosing one.

## Title matching and collisions

`append` opens a note by *exact* title text — it does not fuzzy-match. Before
calling `append`, if you are not fully sure of the exact title, call
`search "<what the user said>"` first:

- No match above ~0.3 score → the note doesn't exist; tell the user and ask
  whether to create it instead of guessing.
- One clear top match → use its exact `title` for `append`.
- Multiple close scores → list the candidate titles and ask the user which
  one they meant before touching anything.

Two notes can legitimately share the same exact title in AFFiNE (it doesn't
enforce uniqueness). `append`/`search` operate on whichever one the UI
surfaces first — if the user reports it edited the wrong one, that's why;
suggest renaming one of them to disambiguate.

## Attachments and links

Hermes already has tools for turning attachments into text — use those
first, then hand the resulting text to this skill's `create` (or `append`):

- **Voice notes**: already transcribed to text by Hermes's own
  `transcription_tools` before you see the message — treat the transcript as
  regular dictated text (`create ... --template=nota-temporal` if no clear
  title, or ask the user for one if the content is substantial).
- **Images**: use Hermes's `vision_tools` (`vision_analyze_tool`) to get a
  description/OCR of the image first, then save that description as a note
  content (mention in the note that it came from an image, and keep the
  original image path if the user might want it later — this skill does not
  upload images into AFFiNE itself, it only writes text).
- **PDFs**: `read_extract.py` does not yet support `.pdf` on this system, and
  `poppler-utils` (which provides `pdftotext`, free/local) is **not
  installed**. Until it is, do not attempt to guess PDF content — tell the
  user PDF summarization isn't available yet rather than fabricating a
  summary. (Fix, requires the user's `sudo`: `sudo apt install poppler-utils`;
  after that, `pdftotext file.pdf -` via the `terminal` tool gives you real
  extracted text to summarize and save.)
- **Links/URLs**: if Hermes's web/browser tools can fetch and summarize the
  page, do that and save the summary as a note (template `investigacion` or
  `lista-referencias` fit well); if fetching fails, save the raw URL as the
  note content rather than losing the capture.

## Reliability notes

- Login/session setup against the live AFFiNE instance occasionally needs a
  retry due to normal sync timing (roughly 1 in 4-5 calls) — the CLI already
  retries login internally. If a command still returns `{"ok":false,...}`,
  retry the exact same command once before telling the user something failed.
- On failure, a screenshot is saved under
  `/home/sahacloud/sahacloud-infra/automations/hermes-affine/logs/failure_*.png`
  — mention its path if the user asks why something didn't work, but don't
  try to open/view it yourself unless asked.
- Never run any other script inside `scripts/_explore/` — those are one-off
  diagnostics from building this integration, not part of the supported CLI.
- `move` is idempotent about the source: if the note wasn't actually in
  `--from` (already moved, or never was), it still proceeds to add it to
  `--to` rather than failing — the end state ("is it in the destination
  folder now") is what matters, not the exact starting state.

## What this skill does not do (by design)

## What this skill does not do (by design)

- Does not create reminders, tasks, or to-dos — use Hermes's own `todo` /
 `kanban` / `cron` tools for anything actionable.
- Does not write to AFFiNE's Postgres database or call `applyDocUpdates`
 directly, ever, under any circumstance.
- Does not delete or trash notes — there is no `delete` command in this CLI.
 If the user wants something removed, tell them to do it from the AFFiNE UI
 themselves rather than improvising a deletion path.

## User Preferences (Krailynd)
- **Format preference**: Rejects disorganized or plain text format for deliverables. Prefers structured tables, organized lists, and professional PDF formatting.
- **Workspace check**: When asked to list workspace contents, **first query PostgreSQL directly** via `docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "SELECT page_id, title, summary, published_at FROM workspace_pages WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' ORDER BY published_at DESC NULLS LAST, title ASC;"` to get the **complete and accurate list** of all documents. Browser-based navigation alone may miss hidden or nested content.
- **Database access**: For accurate and complete workspace listings, **always query PostgreSQL directly** using:
  ```bash
  docker exec sahacloud-affine-postgres psql -U affine -d affine_db -c "
  SELECT page_id, COALESCE(title, '(Sin título)') as title, COALESCE(summary, '') as summary, published_at
  FROM workspace_pages 
  WHERE workspace_id = '4ace6ac3-7518-41d6-9672-85f08c8eafa1' 
  ORDER BY published_at DESC NULLS LAST, title ASC;"
  ```
  This ensures **all documents are captured**, including those not visible in browser snapshots due to lazy loading or UI limitations.
- **Workspace ID**: Krailynd's persistent workspace ID is `4ace6ac3-7518-41d6-9672-85f08c8eafa1`. Use this for all PostgreSQL queries.
- **Browser limitation**: Browser-based navigation may miss documents due to pagination, lazy loading, or React state. **Database queries are authoritative** for workspace content.
- **Blobs vs. Pages**: Document content is stored in the `blobs` table (binary JSON), while metadata (title, summary) is in `workspace_pages`. Use both tables for complete document retrieval.
