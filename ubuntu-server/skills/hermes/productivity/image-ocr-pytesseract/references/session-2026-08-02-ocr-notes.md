# OCR Session Notes — 2026-08-02

## Task
User uploaded a PNG screenshot of a Python tutorial page explaining the modulo operator (`%`). Needed to extract text and explain the concept.

## What worked

### pytesseract (primary)
```python
import pytesseract
from PIL import Image
img = Image.open("/home/sahacloud/.hermes/images/upload_20260802_221736_1.png")
text = pytesseract.image_to_string(img, lang='spa+eng')
```
- Extracted Spanish text cleanly
- Detected code snippets with `my_int_1 = 56`, `my_int_2 = 12`, `56 % 12 = 8`
- Float result: `1.1999999999999993` (floating point precision)

### pymupdf (fallback, no tesseract binary needed)
```python
import pymupdf
doc = pymupdf.open("image.png")
text = doc[0].get_text("text")
```
- Returns empty for this image (pymupdf OCR is basic, language-limited)
- Good zero-dep fallback when tesseract not available

## Image details
- Size: 853×617
- Mode: RGBA
- Content: Spanish Python tutorial text + code examples

## Key learning for future sessions

**When user uploads an image and asks "read this" or "explain this":**
1. First try `pytesseract` with appropriate `lang=` (spa+eng for Spanish/English mix)
2. If tesseract not installed → `pip install pytesseract pillow` + system `tesseract-ocr`
3. If still fails → pymupdf basic OCR (zero extra deps)
4. If scanned PDF → use `marker-pdf` via `ocr-and-documents` skill instead

## Prompt improvement
User initially asked for "metodo ocr o algun modo de analizar la imagen" — the skill should trigger on:
- "read this image"
- "what does this say"
- "OCR this"
- "extract text from image"
- "analiza esta imagen"
- "qué dice esta imagen"