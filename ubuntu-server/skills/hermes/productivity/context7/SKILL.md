---
name: context7
description: Skill oficial de Context7 MCP. Consulta documentación actualizada de librerías con acceso directo por Library ID (/org/proyecto) para ahorro de latencia y tokens.
---

# Context7 MCP Integration Skill (Ahorro de Tokens & Latencia)

Skill para consultar documentación oficial y ejemplos de código usando el servidor MCP de **Context7**.

---

## 1. OPTIMIZACIÓN DE TOKENS Y LATENCIA

Para ahorrar hasta **14,000 tokens** y evitar llamadas redundantes a `resolve-library-id`:

Usar directamente el **Library ID (`/org/proyecto`)** conocido en las consultas de `get-library-docs`:

### Ejemplos de Library IDs Comunes:
- Next.js: `/vercel/next.js`
- React: `/facebook/react`
- Supabase: `/supabase/supabase`
- Tailwind CSS: `/tailwindlabs/tailwindcss`
- Express: `/expressjs/express`
- Cloudflare D1: `/llmstxt/developers_cloudflare_com-d1-llms-full.txt`
- Cloudflare Durable Objects: `/llmstxt/developers_cloudflare-durable-objects-llms-full.txt`
- Python PyTorch: `/pytorch/pytorch`
- Spring Boot: `/spring-projects/spring-boot`

---

## 2. FLUJO DE USO EN HERMES

1. **Si se conoce el Library ID**:
   Llamada directa a `get-library-docs(context7CompatibleLibraryID: "/org/proyecto", topic: "tema")`.
2. **Si NO se conoce el Library ID**:
   Llamada previa a `resolve-library-id(libraryName: "nombre")` para obtener la coincidencia con mayor puntuación de confianza y cobertura.
