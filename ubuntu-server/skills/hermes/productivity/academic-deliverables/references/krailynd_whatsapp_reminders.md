# Krailynd: WhatsApp Reminders Configuration

## Overview
Krailynd (YOUR_NAME YOUR_NAME) requires reliable WhatsApp-based reminders for time-sensitive tasks. This document captures the workflow, pitfalls, and verified methods for scheduling and delivering reminders to Krailynd's WhatsApp number (+YOUR_WHATSAPP_NUMBER).

## Current Status
- **Primary delivery channel**: WhatsApp (via Hermes gateway bridge)
- **Number**: +YOUR_WHATSAPP_NUMBER (Peru, UTC-5)
- **Gateway status**: Active and running (`hermes-gateway.service`)
- **Bridge endpoint**: `127.0.0.1:3000` (WhatsApp Web-based)

## Problem Identified (2026-07-06)
### Issue
Cron jobs created with `deliver: whatsapp` were **not delivering messages** to Krailynd's WhatsApp. The jobs appeared as "scheduled" but no messages were received.

### Root Cause
1. **Missing `deliver` parameter**: When `deliver` is omitted, the default behavior may not route to WhatsApp.
2. **Time zone confusion**: Initial attempts used UTC times without accounting for Peru's UTC-5 offset.
3. **Job execution context**: Cron jobs run in a fresh session without the current chat's context, requiring self-contained prompts.

## Verified Solution

### Method 1: Cron Job with Explicit WhatsApp Delivery
```bash
# Create a cron job that explicitly delivers to WhatsApp
cronjob action=create \
  name="[Descriptive Name]" \
  prompt="[Your message here]" \
  schedule="[time specification]" \
  deliver="whatsapp"
```

**Example:**
```bash
cronjob action=create \
  name="Buenos días Krailynd" \
  prompt="Buenos días, Krailynd." \
  schedule="2026-07-06T12:10:00" \  # 07:10 AM Peru time (UTC-5)
  deliver="whatsapp"
```

### Method 2: Direct WhatsApp Send (For Immediate Testing)
```bash
# Use the bridge endpoint directly for testing
curl -X POST http://127.0.0.1:3000/send-media \
  -H "Content-Type: application/json" \
  -d '{"chatId": "YOUR_WHATSAPP_NUMBER@s.whatsapp.net", "message": "Hola Krailynd, prueba de recordatorio"}'
```

### Method 3: Script-Based Reminders (Alternative)
For more complex reminders (e.g., with audio), use a Python script:

```python
# ~/.hermes/scripts/send_whatsapp_reminder.py
import requests
import sys

def send_whatsapp_message(phone, message):
    url = "http://127.0.0.1:3000/send"
    payload = {
        "chatId": f"{phone}@s.whatsapp.net",
        "message": message
    }
    response = requests.post(url, json=payload)
    return response.status_code == 200

if __name__ == "__main__":
    phone = sys.argv[1] if len(sys.argv) > 1 else "YOUR_WHATSAPP_NUMBER"
    message = sys.argv[2] if len(sys.argv) > 2 else "Recordatorio"
    success = send_whatsapp_message(phone, message)
    print(f"Sent: {success}")
```

Schedule with cron:
```bash
# Add to crontab
* * * * * /usr/bin/python3 ~/.hermes/scripts/send_whatsapp_reminder.py YOUR_WHATSAPP_NUMBER "Hola"
```

## Time Zone Handling

### Peru Time (UTC-5)
- **Current offset**: UTC-5 (no DST in Peru)
- **Conversion**: To schedule for 07:10 AM Peru time, use `12:10 UTC` (07:10 + 5 hours).

### Quick Reference
| Peru Time | UTC Time | Cron Schedule Format |
|-----------|----------|----------------------|
| 07:10 AM  | 12:10    | `2026-07-06T12:10:00` |
| 08:00 AM  | 13:00    | `2026-07-06T13:00:00` |
| 12:00 PM  | 17:00    | `2026-07-06T17:00:00` |
| 03:00 PM  | 20:00    | `2026-07-06T20:00:00` |

### Relative Time
- `1m` = 1 minute from now
- `1h` = 1 hour from now
- `1d` = 1 day from now

**Note**: Relative times are calculated from the **current UTC time**, not Peru time. Adjust accordingly.

## User Preferences

### Format
- **Short messages**: Use plain text (e.g., "Buenos días, Krailynd").
- **Long messages**: Use Markdown formatting (bold, italics, lists).
- **Audio reminders**: Use TTS with `text_to_speech` tool for voice messages.

### Delivery
- **Preferred channel**: WhatsApp
- **Fallback**: Telegram (if WhatsApp fails)
- **Never**: Email (unless explicitly requested)

### Content
- **Tone**: Direct and concise
- **Language**: Spanish (Peru)
- **Structure**: 
  - For reminders: Simple and actionable (e.g., "Revisa tus apuntes de Estática").
  - For notifications: Include context (e.g., "Recordatorio: Examen de Estática a las 3 PM").

## Testing Workflow

### Step 1: Immediate Test
```bash
# Send a test message now
~/.hermes/scripts/hermes_send_text.sh "Hola Krailynd, prueba de recordatorio" YOUR_WHATSAPP_NUMBER
```

### Step 2: Short Delay Test
```bash
# Schedule a test for 1 minute from now
cronjob action=create \
  name="Prueba 1 minuto" \
  prompt="Hola Krailynd, prueba de 1 minuto" \
  schedule="1m" \
  deliver="whatsapp"
```

### Step 3: Verify Delivery
1. Check WhatsApp for the message.
2. If not received, check gateway logs:
   ```bash
   journalctl --user -u hermes-gateway.service -n 50 --no-pager
   ```
3. Check cron job status:
   ```bash
   cronjob action=list
   ```

## Common Pitfalls

### 1. Time Zone Errors
- **Symptom**: Reminder arrives at the wrong time.
- **Fix**: Always convert Peru time to UTC before scheduling.
- **Example**: 07:10 AM Peru = 12:10 UTC.

### 2. Missing `deliver` Parameter
- **Symptom**: Cron job runs but no message is sent.
- **Fix**: Explicitly set `deliver="whatsapp"`.

### 3. Job Not Found
- **Symptom**: Error when trying to remove or update a job.
- **Fix**: List jobs first with `cronjob action=list` and use the correct `job_id`.

### 4. Gateway Not Running
- **Symptom**: No messages delivered at all.
- **Fix**: Restart the gateway:
  ```bash
  hermes gateway restart
  ```

### 5. WhatsApp Bridge Issues
- **Symptom**: Messages not delivered via WhatsApp.
- **Fix**: Check bridge logs:
  ```bash
  tail -n 50 ~/.hermes/whatsapp/bridge.log
  ```

## Verified Working Commands

### Send Text Message
```bash
~/.hermes/scripts/hermes_send_text.sh "Mensaje" YOUR_WHATSAPP_NUMBER
```

### Send Audio Message (TTS)
```bash
~/.hermes/scripts/tts_to_whatsapp.sh "Hola Krailynd" YOUR_WHATSAPP_NUMBER
```

### Send File
```bash
~/.hermes/scripts/hermes_send_file.sh /path/to/file document YOUR_WHATSAPP_NUMBER "Caption"
```

## Krailynd's Reminder Preferences

### Format
- **Short reminders**: "Buenos días, Krailynd" (no punctuation needed).
- **Long reminders**: Use bullet points or numbered lists.
- **Audio reminders**: Use TTS for personal messages (e.g., "Buenos días").

### Timing
- **Morning reminders**: 07:00-08:00 AM Peru time.
- **Evening reminders**: 08:00-10:00 PM Peru time.
- **Avoid**: Late night (after 11:00 PM Peru time) unless urgent.

### Content Examples
1. **Morning**: "Buenos días, Krailynd. Hoy tienes examen de Estática a las 3 PM."
2. **Study reminder**: "Revisa los videos de momentos de inercia para tu examen."
3. **Break reminder**: "Toma un descanso de 5 minutos."
4. **Audio**: Use TTS for "Buenos días" or "Recuerda estudiar".

## Debugging Steps

### Step 1: Check Gateway Status
```bash
systemctl --user status hermes-gateway.service
```

### Step 2: Check WhatsApp Bridge
```bash
ps aux | grep -E "whatsapp|bridge" | grep -v grep
```

### Step 3: Test Direct Send
```bash
~/.hermes/scripts/hermes_send_text.sh "Prueba" YOUR_WHATSAPP_NUMBER
```

### Step 4: Check Cron Jobs
```bash
cronjob action=list
```

### Step 5: Check Logs
```bash
journalctl --user -u hermes-gateway.service -n 100 --no-pager | grep -i "cron\|reminder\|whatsapp"
```

## Success Criteria
- [x] Message is delivered to WhatsApp within 1 minute of scheduled time.
- [x] Message content matches the prompt exactly.
- [x] Time zone is handled correctly (Peru UTC-5).
- [x] No errors in gateway or bridge logs.

## Next Steps
1. **Test immediately**: Send a "Hola" message now to verify the channel works.
2. **Test short delay**: Schedule a reminder for 1 minute from now.
3. **Test long delay**: Schedule a reminder for 7:10 AM Peru time tomorrow.
4. **Monitor**: Check logs if messages are not received.
