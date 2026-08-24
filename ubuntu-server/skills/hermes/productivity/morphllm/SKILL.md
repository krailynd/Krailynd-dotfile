---
name: morphllm
description: "MorphLLM Integration: Ultra-fast general models (morph-v3-fast), Fast Apply (10,500 tok/s code edit), Model Router, WarpGrep, Context Compression (33,000 tok/s), Reflex classification, and Glance preview testing."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Morph, MorphLLM, Fast-Models, Fast-Apply, WarpGrep, Compact, Reflex, Glance, AI, High-Speed]
prerequisites:
  commands: [curl, python3]
---

# /morphllm — Morph High-Speed AI Architecture

Complete integration skill for **MorphLLM** (`https://api.morphllm.com/v1`). High-speed OpenAI-compatible inference suite designed for code generation, instant file edits, codebase search, and context compression.

---

## 1. Morph Provider Configuration

- **Provider Name**: `morph` / `morphllm`
- **Default Model**: `morph-v3-fast`
- **API Endpoint**: `https://api.morphllm.com/v1`
- **Environment Key**: `MORPH_API_KEY` (configured in `~/.hermes/.env`)

---

## 2. Core Morph Components & Products

| Component | Description | Performance / Endpoint |
|---|---|---|
| **Fast General Models** | Primary agent loop on high-speed models (`morph-v3-fast`, Kimi K3 2.8T, GLM-5.2, DeepSeek V4 Flash, MiniMax M3, Qwen 3.6). | Up to 200 tok/s via `/v1/chat/completions` |
| **Fast Apply** | Apply code diffs/edit snippets to files instantly without rewrite overhead. | **10,500 tok/s** |
| **Model Router** | Auto-select cheapest model per prompt dynamically. | ~50ms classification latency |
| **WarpGrep** | Deep codebase search subagent (#1 on SWE-Bench Pro). | Parallel code structure indexing |
| **Compact** | Ultra-fast context compression. | **33,000 tok/s** |
| **Reflex** | Real-time classifier for frustration, loops, and policy checks. | <90ms per turn |
| **Glance** | Diff-powered visual browser testing on PR preview deploys. | Automated video + screenshot posts |

---

## 3. Fast Execution Snippets

### A. Direct API Call (`morph-v3-fast`)
```bash
curl -s -X POST https://api.morphllm.com/v1/chat/completions \
  -H "Authorization: Bearer $MORPH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "morph-v3-fast",
    "messages": [{"role": "user", "content": "Explain the fast apply pattern"}]
  }'
```

### B. Fast Apply Example (Instant Code Edit)
```bash
curl -s -X POST https://api.morphllm.com/v1/chat/completions \
  -H "Authorization: Bearer $MORPH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "morph-v3-fast",
    "messages": [{
      "role": "user",
      "content": "<instruction>Add error handling</instruction>\n<code>async function fetchUser(id) {\n const res = await fetch(\"/api/users/\" + id);\n return res.json();\n}</code>"
    }]
  }'
```

---

## 4. Best Practices & Unlimited Flow

1. Use **Fast Apply** for quick file edits to skip generating full file contents.
2. Combine with **WarpGrep** and **CodeGraph** for instant project-wide refactoring.
3. For heavy long-running agent tasks, routing to `morph-v3-fast` eliminates token bottlenecks.
