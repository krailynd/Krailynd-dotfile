# Secrets policy — never commit these

This profile is public/student-safe by design. A hard rule: **no credentials of
any kind are committed**. Everything sensitive ships as a `.example` template
with `YOUR_*` placeholders.

## Never-commit list (absolute rule)

| Path (on the source machine)                     | Why                                              |
|--------------------------------------------------|--------------------------------------------------|
| `~/.config/opencode/secrets/*`                   | Raw API keys referenced by `opencode.json`       |
| `~/.ssh/id_*` (and `id_*.pub` is borderline)     | Private SSH keys                                |
| `~/.fx/auth.json`                                | Codeium/auth credentials                         |
| `~/.dsh/.credentials.yaml`                       | Dashlane / secrets yaml                          |
| `~/.config/gh/hosts.yml`                         | Real `gh` oauth tokens                           |
| `~/.engram/engram.db` (+ `-shm`/`-wal`)          | Full persistent-memory database                  |
| `~/.pi/agent/auth.json`                          | Any agent auth file                              |

This repo also ships a `.gitignore` that blocks common secret shapes
(`*.env`, `*.key`, `*.pem`, `auth.json`, `hosts.yml`, `secrets/`, `*.db`).
The `config/opencode/secrets/.gitignore` blocks everything in that directory
even if a real key is dropped there by accident.

## Placeholder convention

- Sensitive/personalized files ship as `*.example` with `YOUR_*` placeholders:
  `YOUR_GITHUB_TOKEN`, `YOUR_OPENAI_API_KEY`, `YOUR_BAI_API_KEY`,
  `YOUR_NVIDIA_API_KEY`, `YOUR_TOKENROUTER_API_KEY`, `YOUR_TESTSRITE_API_KEY`,
  `YOUR_WINBRIDGE_TOKEN`, `YOUR_WINREMOTE_TOKEN`, `YOUR_PRIVATE_KEY`.
- Non-sensitive configs ship as plain files (`.zshrc`, `.tmux.conf`,
  `btop.conf`, `alacritty.toml`, the nvim tree, skills, prompts, plugins).
- `install.sh` copies `*.example` → real file **only when the destination does
  not exist** (never overwrites).

## Which files are templated in this profile

| File                                     | Placeholder(s) used                          |
|------------------------------------------|----------------------------------------------|
| `config/opencode/opencode.json.example`  | `YOUR_BAI_API_KEY`, `YOUR_NVIDIA_API_KEY`, `YOUR_TOKENROUTER_API_KEY`, `YOUR_GITHUB_TOKEN`, `YOUR_TESTSRITE_API_KEY`, `YOUR_WINBRIDGE_TOKEN`, `YOUR_WINREMOTE_TOKEN` |
| `config/gh/hosts.yml.example`            | `YOUR_GITHUB_TOKEN`                          |
| `config/ssh/config.example`              | `YOUR_PRIVATE_KEY`                           |
| `gentle-stack/pi/mcp.json.example`       | none (structure only)                        |
| `gentle-stack/gentle-ai/state.json.example` | none (structure only)                      |

## Post-change check

Run `scripts/verify.sh` before any commit. It greps the whole profile for
token-shaped strings (`sk-`, `ghp_`, `gho_`, `hf_`, `AKIA`) and for leaked
`/home/krailynd` paths, and confirms every `.example` still has a placeholder.
