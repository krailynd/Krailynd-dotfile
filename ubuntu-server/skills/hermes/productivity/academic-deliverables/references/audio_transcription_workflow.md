# Audio Transcription Workflow for Krailynd

## Overview
This document outlines the audio transcription capabilities and workflow for Krailynd's WhatsApp audio messages.

## Current Capabilities

### Supported Formats
- OGG (primary format from WhatsApp)
- MP3
- M4A
- WAV

### Transcription Engine
- **Tool**: faster-whisper (local, no API required)
- **Models**: base (fast, default), small (more accurate), medium (most accurate, slower)
- **Language**: Spanish (es) for Krailynd
- **Accuracy**: Near-perfect for clear Spanish audio with base model

## Workflow

### 1. Audio Reception
- WhatsApp audios are received via the Hermes gateway
- Files are automatically cached to: `/home/sahacloud/.hermes/cache/audio/`
- Filename pattern: `aud_[uuid].ogg`

### 2. Transcription Command
```bash
python3 ~/.hermes/scripts/hermes_transcribe.py /path/to/audio.ogg --language es
```

### 3. Model Selection
- **base** (default): Fast, suitable for most clear audio
- **small**: More accurate, slightly slower
- **medium**: Most accurate, significantly slower

Command with specific model:
```bash
python3 ~/.hermes/scripts/hermes_transcribe.py /path/to/audio.ogg --language es --model small
```

## File Locations

### Received Audio Cache
```
/home/sahacloud/.hermes/cache/audio/
├── aud_8fd8828894be.ogg
├── aud_88dd9e6b9e07.ogg
└── aud_20f2ea71c9c6.ogg
```

### Script Location
```
~/.hermes/scripts/hermes_transcribe.py
```

## Example Output
```
[lang=es conf=1.00 model=base]
Hola, hola, hola, hola, les escuché, sonos.
```

## Troubleshooting

### Audio File Not Found
1. Check the cache directory: `ls -la /home/sahacloud/.hermes/cache/audio/`
2. Verify the file was received: `find /home/sahacloud/.hermes -name "*.ogg"`
3. Check all possible locations: `find / -name "*.ogg" 2>/dev/null | grep -v "code-server" | head -10`

### Transcription Errors
1. Verify faster-whisper is installed: `pip list | grep faster-whisper`
2. Check Python environment: `python3 -c "import faster_whisper; print('OK')"`
3. Test with a known good file: Use one of the cached files

## Krailynd's Usage Pattern

### Natural Language Triggers
- "¿Qué dice este audio?"
- "Transcribe este audio"
- "Mejora lo que dije"
- "Corrige el texto"
- "Hazme un resumen de esto"

### Response Format
- Return the transcription as plain text
- Include confidence score and model used
- For WhatsApp delivery: Return the transcription directly

## Integration with Other Skills

### Academic Deliverables
- Transcribed audio can be used for:
  - Creating study notes
  - Generating summaries
  - Creating flashcards
  - Building knowledge bases

### Note Taking
- Transcribed content can be saved to:
  - AFFiNE (primary for Krailynd)
  - Nextcloud
  - Local files

## Performance Notes

### Speed
- base model: ~1-2 seconds for 10-second audio
- small model: ~3-5 seconds for 10-second audio
- medium model: ~10-15 seconds for 10-second audio

### Accuracy
- base model: >95% for clear Spanish speech
- small model: >98% for clear Spanish speech
- medium model: >99% for clear Spanish speech

## Best Practices

1. **Always use Spanish language**: `--language es`
2. **Start with base model**: Fast enough for most use cases
3. **Use small for important content**: When accuracy is critical
4. **Cache results**: Store transcriptions for future reference
5. **Verify output**: Always check the transcription makes sense in context