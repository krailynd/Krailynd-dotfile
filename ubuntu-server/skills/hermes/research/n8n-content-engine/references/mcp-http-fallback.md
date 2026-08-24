# MCP Streamable HTTP — Fallback cuando el MCP server n8n está disabled

## Contexto

El MCP server `n8n` en `~/.hermes/config.yaml` puede estar `enabled: false`.
Cuando lo está, Hermes no puede invocar los tools nativamente (no aparecen
como funciones disponibles). El endpoint sigue vivo y callable vía HTTP.

## Cómo obtener URL y token

```python
import yaml
with open('~/.hermes/config.yaml') as f:
    cfg = yaml.safe_load(f)
mcp = cfg['mcp_servers']['n8n']
url = mcp['url']                                    # https://n8n.sahacloud.dpdns.org/mcp/hermes-tools
token = mcp['headers']['Authorization'].split(' ')[1]  # Bearer xxx
```

## Protocolo MCP Streamable HTTP (3 pasos)

### Paso 1 — Initialize (crea sesión)

```bash
curl -s -D /tmp/mcp_headers.txt -X POST <URL> \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"hermes","version":"1.0"}}}'
```

El header `Accept` con **ambos** `application/json, text/event-stream` es
obligatorio — sin él el server devuelve `Not Acceptable`.

Extraer el session ID:
```bash
grep -i "mcp-session-id" /tmp/mcp_headers.txt | tr -d '\r' | awk '{print $2}'
```

### Paso 2 — notifications/initialized (handshake)

```bash
curl -s -X POST <URL> \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Mcp-Session-Id: <SESSION_ID>" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}'
```

### Paso 3 — tools/call (invocar un tool)

```bash
# Escribir el payload a archivo (evita problemas de escaping en curl -d)
cat > /tmp/mcp_payload.json << 'ENDJSON'
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_academic_overview","arguments":{}}}
ENDJSON

curl -s -X POST <URL> \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Mcp-Session-Id: <SESSION_ID>" \
  -d @/tmp/mcp_payload.json
```

La respuesta viene como SSE (`event: message\ndata: {json}`).
El dato real está en `result.content[0].text` (es un string JSON anidado).

## Notas

- **Session ID expira**: cada sesión tiene vida limitada. Si una llamada
  devuelve `Bad Request: Server not initialized`, crear una sesión nueva.
- **Una sesión por batch**: no reusar la misma sesión para más de ~3-4
  calls sin esperar entre ellas (rate limiting del server n8n).
- `tools/list` también funciona con el mismo patrón (útil para verificar
  qué tools hay disponibles).
- El `N8N_API_KEY` en `~/.hermes/.env` NO es el mismo token — el correcto
  está en `config.yaml` bajo `mcp_servers.n8n.headers.Authorization`.
