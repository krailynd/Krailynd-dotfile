---
name: content-idea-audit
description: "Audit notes/databases for content ideas, especially YouTube ideas; score which are worth developing and suggest next writing angles."
platforms: [linux, macos, windows]
---

# Content Idea Audit

## When to use

Use when the user asks to search their notes, Notion, Obsidian, AFFiNE, saved links, or other knowledge base for good content ideas, YouTube ideas, video topics, hooks, scripts, or ideas worth continuing to write.

Typical prompts:
- "busca notas buenas para YouTube"
- "revisa mis ideas y dime cuáles sirven"
- "qué ideas debería seguir escribiendo"
- "encuentra temas para videos en mi Notion"

## Workflow

1. **Search broadly first.** Query obvious terms (`YouTube`, `video`, `guion`, `contenido`, `idea`, `ideas`, `script`, `shorts`) and also search for databases/collections named like `Ideas`, `Contenido`, `Proyectos`, `Inbox`.
2. **Inspect structured collections.** If a database/data source is found, query it and extract at least: title, status, date, description, related project, and URL.
3. **Do not stop at exact keyword misses.** If no explicit "YouTube" pages appear, evaluate general ideas for content potential instead of reporting nothing.
4. **Score for content potential.** Judge each idea by:
   - clarity of problem/story
   - audience fit
   - visual/demo potential
   - uniqueness or opinion angle
   - ability to become a series
   - feasibility for the user's current workflow
5. **Separate verdicts.** Mark ideas as:
   - **Buena para seguir escribiendo**
   - **Buena, pero necesita enfoque**
   - **Técnica/nicho**
   - **Regular / necesita caso real**
   - **No es idea directa, pero sirve como metodología/plantilla**
6. **Give continuation prompts.** For each promising idea, suggest concrete next sections to write: problem, target audience, hook, title, outline, MVP/demo, differentiator, example scene.
7. **Recommend a top 3.** End with the strongest ideas and one concrete starting sentence or title the user can continue immediately.

## Output style for Krailynd

Respond in Spanish when the user asks in Spanish. Be direct and practical. The user wants an actionable judgment, not just a list. Use clear headings and short bullets.

Good final structure:

```markdown
## Encontré estas ideas
1. ...

## Mejores para YouTube
### 1. [Idea]
Veredicto: ...
Por qué sirve: ...
Ángulos: ...
Qué seguir escribiendo: ...
Nota: ...

## Descartaría o dejaría para después
...

## Recomendación concreta
Empieza con: "..."
```

## Notion-specific notes

When using Hermes native Notion tools:
- `notion_search` can return databases as `object: "data_source"`.
- To query a returned data source, use `notion_databases` with `action: "query"` and `data_source_id`.
- If a Notion tool action fails, do not repeat the same argument shape; adjust based on the error.
- Query database properties first. Only read page blocks when the body likely contains important long-form content missing from the database properties.

## Pitfalls

- Do not conclude "no ideas" only because there are no pages named YouTube/video; many good YouTube topics are hidden as project/product notes.
- Do not overvalue generic business features unless there is a case study, visual demo, or clear audience pain.
- Distinguish "good product idea" from "good video idea"; a weak product idea can still make a strong analysis video, and vice versa.
- Keep discarded/status labels visible but do not blindly accept them; a Notion item marked discarded can still be useful as content.
