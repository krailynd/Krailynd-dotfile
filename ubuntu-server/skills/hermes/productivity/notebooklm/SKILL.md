---
name: notebooklm
description: "NotebookLM Integration: Create notebooks, upload study PDFs/URLs, generate audio overviews (study podcasts), study guides, FAQs, and deep research synthesis."
version: 1.0.0
author: sahacloud
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [NotebookLM, Google, Study, Podcasts, Audio-Overview, Research, PDFs, University, Synthesis]
prerequisites:
  commands: [npx]
  mcp_servers: [notebooklm]
---

# /notebooklm — Google NotebookLM Integration for Hermes

Integration with **Google NotebookLM** via MCP server (`notebooklm-mcp-server`). Enables Hermes to create study notebooks, upload academic PDFs, generate audio overviews (study podcasts), produce FAQs, and conduct grounded research synthesis.

---

## 1. Authentication & Setup

Run authentication once to connect Google NotebookLM credentials:

```bash
npx -y notebooklm-mcp-server auth
```

---

## 2. University & Study Workflows

### A. Creating a Study Notebook
- Upload lecture PDFs, research papers, or syllabus URLs.
- NotebookLM grounds all responses strictly in the provided source material (zero hallucinations).

### B. Audio Overview Generation (Study Podcasts)
- Generate a two-host conversational podcast summary of uploaded course materials.
- Ideal for listening while commuting or reviewing before exams.

### C. Study Guide & FAQ Extraction
- Extract structured flashcards, key terms, exam practice questions, and timeline summaries.

---

## 3. Command Syntax & MCP Tools

| Task | Tool / Command |
|---|---|
| Create Notebook | `create_notebook` |
| Add Source (PDF/URL/Text) | `add_source` |
| Grounded Query | `query_notebook` |
| Generate Audio Briefing | `generate_audio_overview` |
| Extract Study Guide | `get_study_guide` |
