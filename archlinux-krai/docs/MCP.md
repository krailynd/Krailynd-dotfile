# MCP servers in this profile

The `config/opencode/opencode.json.example` file wires up 17 MCP servers. Below
is the list, what each one does, and whether it needs a `YOUR_*` token from you
before it will activate. **No real tokens live in this repo.**

| # | Server                | Type   | Purpose                                                            | Token needed?                          |
|---|-----------------------|--------|--------------------------------------------------------------------|----------------------------------------|
| 1 | `codegraph`           | local  | SQLite knowledge graph of a codebase — symbol/edge exploration     | No (needs `codegraph` binary)          |
| 2 | `context7`            | remote | Up-to-date library/framework documentation                         | No                                     |
| 3 | `docker`              | local  | Inspect/manage local Docker containers                             | No                                     |
| 4 | `engram`              | local  | Persistent memory that survives across sessions/compactions        | No                                     |
| 5 | `filesystem`          | local  | Read/write/move files on disk                                      | No                                     |
| 6 | `git`                 | local  | Repo operations (status, diff, log, commit)                        | No                                     |
| 7 | `github`              | remote | GitHub API — issues, PRs, code search, releases                    | **Yes** — `YOUR_GITHUB_TOKEN`          |
| 8 | `jetbrains-intellij`  | remote | Connect to a running IntelliJ IDE                                  | No                                     |
| 9 | `jetbrains-pycharm`   | remote | Connect to a running PyCharm IDE                                   | No                                     |
| 10| `playwright`          | local  | Headless browser automation and web interaction                    | No                                     |
| 11| `postgres`            | local  | Read-only SQL queries against a Postgres instance                  | No (per-query credentials)             |
| 12| `searxng`             | local  | Web search via a self-hosted SearXNG instance (env: `SEARXNG_URL`) | No                                     |
| 13| `sequential-thinking` | local  | Structured, revisable step-by-step reasoning                       | No                                     |
| 14| `sqlite`              | local  | Query local SQLite databases                                       | No                                     |
| 15| `testsprite`          | local  | AI-driven test plan generation & execution (env: `API_KEY`)        | **Yes** — `YOUR_TESTSRITE_API_KEY`     |
| 16| `winbridge`           | remote | Headless PowerShell on the Windows host (Bearer auth)              | **Yes** — `YOUR_WINBRIDGE_TOKEN`       |
| 17| `winremote`           | remote | Windows desktop control, files, registry, services (Bearer auth)   | **Yes** — `YOUR_WINREMOTE_TOKEN`       |

## Provisioning

1. Copy `config/opencode/opencode.json.example` to `~/.config/opencode/opencode.json`.
2. For each **token**-gated server above, create the matching file under
   `~/.config/opencode/secrets/` (see `docs/SECRETS.md`) and reference it with
   `{file:...}`, or export the value as an environment variable and reference it
   with `${ENV_VAR}`.
3. The `provider` blocks for `bai`, `nvidia`, and `tokenrouter` (model routing)
   also expect `YOUR_BAI_API_KEY`, `YOUR_NVIDIA_API_KEY`, and
   `YOUR_TOKENROUTER_API_KEY` respectively — same provisioning flow.

Servers without a token activate as soon as their underlying binary/server is
installed and running (e.g. `codegraph`, SearXNG on `127.0.0.1:8888`).
