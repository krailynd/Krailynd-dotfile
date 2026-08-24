# ReportLab PDF Text Extraction Guide

## Problem
ReportLab-generated PDFs (identified by header `%PDF-1.4` + `ReportLab Generated PDF document`) store text in compressed streams, which makes standard text extraction tools fail.

## Solution
Use `pymupdf` with the `"text"` extraction mode:

```python
import sys
sys.path.insert(0, "/home/sahacloud/.hermes/hermes-agent/venv/lib/python3.11/site-packages")
import pymupdf

doc = pymupdf.open("reportlab_document.pdf")
for page in doc:
    content = page.get_text("text")  # Raw text extraction
    print(content)
doc.close()
```

## Installation
If `pymupdf` is not available in the current environment:
```bash
/home/sahacloud/.hermes/hermes-agent/venv/bin/python3 -m pip install pymupdf -q
```

## Verification
ReportLab PDFs will have these characteristics:
- Small file size (typically <10KB for text-only documents)
- Header contains: `%PDF-1.4` and `ReportLab Generated PDF document (opensource)`
- Text appears as compressed binary data when viewed raw

## Alternative Methods (Less Reliable)
1. **pdftotext**: May work but sometimes misses formatting
   ```bash
   pdftotext reportlab_doc.pdf - | head -50
   ```

2. **PyPDF2**: Often fails on ReportLab PDFs due to compression

## Best Practice
Always try `pymupdf` first for ReportLab documents. If text extraction returns empty or garbled content, the PDF may be image-based (OCR required) rather than text-based.

## Example: Extracting from Hermes-Generated PDFs
Hermes uses `reportlab` for PDF generation via `hermes_pdf_academic.py`. To extract text from these:

```python
import sys
sys.path.insert(0, "/home/sahacloud/.hermes/hermes-agent/venv/lib/python3.11/site-packages")
import pymupdf

pdf_path = "/home/sahacloud/.hermes/cache/documents/doc_XXXXXX_hermes_guia_*.pdf"
doc = pymupdf.open(pdf_path)
full_text = ""
for page in doc:
    full_text += page.get_text("text") + "\n"
doc.close()

# Save for processing
with open("/tmp/extracted_text.txt", "w") as f:
    f.write(full_text)
```

## Troubleshooting
- **Error: `ModuleNotFoundError: No module named 'pymupdf'`** → Install in Hermes venv
- **Error: Empty output** → PDF may be image-based; try OCR with `marker-pdf`
- **Error: Garbled text** → PDF uses non-standard encoding; try different extraction modes