---
name: krailynd-email
description: "Email operations for Krailynd's connected inboxes: vivaldi.net via Himalaya IMAP and Gmail via Google Workspace OAuth. Covers listing, reading, monitoring, and cross-inbox important-mail triage patterns specific to Krailynd's setup."
version: 1.0.0
author: Hermes
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Email, IMAP, Vivaldi, Krailynd, Monitoring]
    user: krailynd
prerequisites:
  commands: [himalaya]
  env_vars: []
---

# Krailynd Email Operations (Vivaldi + Gmail)

This skill captures the specific patterns, commands, and gotchas for managing Krailynd's connected inboxes:

- **YOUR_VIVALDI_EMAIL** via Himalaya CLI v1.2.0 / IMAP
- **YOUR_GMAIL_EMAIL** via Google Workspace OAuth / Gmail API

It complements the generic `himalaya` and `google-workspace` skills with Krailynd-specific workflows, especially combined inbox review and prioritization of work/opportunity/security emails.

## Environment

- **Vivaldi Email**: YOUR_VIVALDI_EMAIL
  - IMAP Server: imap.vivaldi.net:993
  - Himalaya CLI: v1.2.0 at `/home/YOUR_USER/.local/bin/himalaya`
  - Config: `~/.config/himalaya/config.toml`
  - Monitor Script: `~/.hermes/scripts/email_inbox_monitor.py`
- **Gmail Email**: YOUR_GMAIL_EMAIL
  - Access: Google Workspace OAuth token at `~/.hermes/google_token.json`
  - API wrapper: `~/.hermes/skills/productivity/google-workspace/scripts/google_api.py`
  - Before use: verify with `python ~/.hermes/skills/productivity/google-workspace/scripts/setup.py --check`

## User Preferences

- **Sender Name Format**: Always use full name **'YOUR_NAME'** in the `From` field for professional consistency.
- **Sent Folder Sync**: All sent emails MUST include `Bcc: YOUR_VIVALDI_EMAIL` to ensure they appear in the Vivaldi 'Sent' folder.
- **Confirmation Required**: NEVER send emails without explicit user confirmation in the same conversation turn.

 → **Syntax error** (v1.2.0 doesn't support `--limit` flag)
- `himalaya envelope list --sort newest` → **Syntax error** (v1.2.0 doesn't support `--sort` flag)

### ✅ What DOES Work
- **List all emails (newest first, default)**: `himalaya envelope list`
- **Get N most recent emails**: `himalaya envelope list | tail -N` (skip header row)
- **Get the very last email**: `himalaya envelope list | tail -1`
- **Get first N emails**: `himalaya envelope list | head -N` (includes header)

## Common Operations

### List Recent Emails

**Get the 5 most recent emails:**
```bash
himalaya envelope list | tail -5
```

**Get the single most recent email:**
```bash
himalaya envelope list | tail -1
```

**Get emails from the last 7 days (via monitor script):**
```bash
python3 ~/.hermes/scripts/email_inbox_monitor.py list --days 7 --limit 20
```

### Send Emails via SMTP (Python fallback)

**When Himalaya CLI fails for sending (v1.2.0 limitation):**
```bash
python3 -c "
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

msg = MIMEMultipart()
msg['From'] = 'YOUR_NAME <YOUR_VIVALDI_EMAIL>'
msg['To'] = 'recipient@example.com'
msg['Subject'] = 'Your Subject'
msg.attach(MIMEText('Body text here', 'plain', 'utf-8'))

server = smtplib.SMTP_SSL('smtp.vivaldi.net', 465)
server.login('YOUR_VIVALDI_EMAIL', 'YOUR_VIVALDI_SMTP_PASSWORD')
server.send_message(msg)
server.quit()
print('✅ Email sent')
"
```

**Note:** Password is stored in `~/.hermes/.env` as `EMAIL_PASSWORD=YOUR_VIVALDI_SMTP_PASSWORD`

**Important:** To ensure the sent email appears in the 'Sent' folder, add BCC to your own email:
```python
msg['Bcc'] = 'YOUR_VIVALDI_EMAIL'
```
This triggers Vivaldi's server to save a copy in Sent.

### Read a Specific Email

**Read by ID (from envelope list):**
```bash
himalaya message read <ID>
```

**Example:**
```bash
# From envelope list output: | 1242 | | GLM-5.2 is now faster... | Ollama | 2026-07-07 12:24+00:00 |
himalaya message read 1242
```

### Get Email Summary (Last N Days)

**Via email_inbox_monitor.py (preferred for Krailynd):**
```bash
# New/unread emails only
python3 ~/.hermes/scripts/email_inbox_monitor.py list --limit 20

# All emails from last 7 days
python3 ~/.hermes/scripts/email_inbox_monitor.py list --days 7 --limit 50

# Detailed summary of new emails
python3 ~/.hermes/scripts/email_inbox_monitor.py summary --limit 10
```

### Check for New Emails (WhatsApp Alert Mode)

```bash
python3 ~/.hermes/scripts/email_inbox_monitor.py check --limit 20
```

## Workflow Patterns

### Pattern 0: Cross-Inbox Important Mail Triage

When Krailynd asks to review “los dos correos”, “correos importantes”, “trabajo”, or “oportunidades”, check BOTH connected inboxes and return a prioritized human summary, not a raw dump.

1. **Vivaldi / IMAP** — check new/unread first:
   ```bash
   python3 ~/.hermes/scripts/email_inbox_monitor.py list --limit 20
   ```
   If the user wants more than unread, use `--days 7 --limit 50`.

2. **Gmail / Google Workspace** — verify OAuth then search unread/recent:
   ```bash
   GSETUP="python ${HERMES_HOME:-$HOME/.hermes}/skills/productivity/google-workspace/scripts/setup.py"
   GAPI="python ${HERMES_HOME:-$HOME/.hermes}/skills/productivity/google-workspace/scripts/google_api.py"
   $GSETUP --check
   $GAPI gmail search "is:unread" --max 30
   ```

3. **Prioritize for Krailynd**:
   - Highest: direct recruiter/company replies, interview requests, offers, application follow-ups.
   - High: software/IT roles, Java/backend/fullstack, internships/practicantes at known companies, remote tech roles.
   - Medium: non-tech work from home or broad LinkedIn recommendations.
   - Important but not job: Google security alerts / OAuth access notifications.
   - Low: newsletters, promotions, product updates.

4. **Read details only for promising messages** using Gmail message IDs:
   ```bash
   $GAPI gmail get MESSAGE_ID
   ```
   For LinkedIn alerts, the useful body fields are usually title, company, location, “busca personal activamente”, “solicitar con perfil y CV”, and job link.

5. **Response format**: short Spanish summary grouped by account and priority. State “Vivaldi sin correos nuevos” when applicable. Do not include long tracking URLs unless the user asks to open/apply.

### Pattern 1: Get Last Email Details

```bash
# Step 1: Get the ID of the last email
LAST_EMAIL_ID=$(himalaya envelope list | tail -1 | awk '{print $1}')

# Step 2: Read it
if [ -n "$LAST_EMAIL_ID" ]; then
  himalaya message read "$LAST_EMAIL_ID"
fi
```

### Pattern 2: Monitor for New Emails (Cron)

The existing cron job (`25d412a4f6ea`) runs every 15 minutes:
```bash
python3 ~/.hermes/scripts/email_inbox_monitor.py check --limit 20
```

**To add a custom monitor:**
```bash
# Check every 30 minutes for new emails and send WhatsApp alert
cronjob action=create name="krailynd-email-alerts" \
  schedule="every 30m" \
  prompt="Run: python3 ~/.hermes/scripts/email_inbox_monitor.py check --limit 10" \
  no_agent=true
```

### Pattern 3: Search by Sender

```bash
# List all emails from a specific sender
himalaya envelope list | grep "Ollama"
```

## Gotchas

| Issue | Symptom | Fix |
|-------|---------|-----|
| `--limit` flag fails | `cannot parse search emails query` | Use `tail -N` instead |
| `--sort` flag fails | `cannot parse search emails query` | Default is newest-first; use `tail` |
| Empty envelope list | No output | Check IMAP connection: `himalaya folder list` |
| Message ID not found | `Error: message not found` | IDs are folder-relative; re-list after folder changes |

## Configuration Files

- **Himalaya Config**: `~/.config/himalaya/config.toml`
- **Monitor State**: `~/.hermes/email_monitor_state.json`
- **Monitor Log**: `~/.hermes/logs/email_monitor.log`

## Related Scripts

- `~/.hermes/scripts/email_inbox_monitor.py` — Primary monitoring script
- `~/.hermes/scripts/hermes_send_text.sh` — WhatsApp notification sender
- `~/.hermes/scripts/hermes_send_file.sh` — Email attachment sender

## References

- [Himalaya GitHub](https://github.com/pimalaya/himalaya)
- [Vivaldi Mail Docs](https://help.vivaldi.com/desktop/mail/)
- [SMTP Send with BCC for Sent Folder Sync](references/smtp-send-with-bcc.md) — Python workaround for ensuring sent emails appear in Vivaldi's Sent folder
- [Cross-Inbox Job/Important Mail Triage](references/cross-inbox-job-triage.md) — Gmail + Vivaldi workflow for prioritizing work opportunities and security notices

## See Also

- Skill: `himalaya` — Generic Himalaya CLI usage
- Skill: `email` — General email handling patterns