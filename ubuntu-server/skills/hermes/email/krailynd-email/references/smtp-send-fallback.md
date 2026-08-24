# SMTP Send Fallback for Vivaldi (YOUR_VIVALDI_EMAIL)

## Issue
Himalaya CLI v1.2.0 does **NOT** support the `send` command properly on this system. Attempts to use:
```bash
himalaya message send --to recipient@example.com --subject "..." --body "..."
```
result in:
```
error: unexpected argument '--to' found
```

## Solution: Python SMTP Fallback

Use Python's built-in `smtplib` with the credentials from `~/.hermes/.env`:

### Working Command Template
```bash
python3 -c "
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

msg = MIMEMultipart()
msg['From'] = 'YOUR_VIVALDI_EMAIL'
msg['To'] = 'RECIPIENT_EMAIL'
msg['Subject'] = 'SUBJECT_HERE'
msg.attach(MIMEText('''BODY_TEXT_HERE''', 'plain', 'utf-8'))

server = smtplib.SMTP_SSL('smtp.vivaldi.net', 465)
server.login('YOUR_VIVALDI_EMAIL', 'YOUR_VIVALDI_SMTP_PASSWORD')
server.send_message(msg)
server.quit()
print('✅ Email sent')
"
```

### Credentials
- **SMTP Server:** `smtp.vivaldi.net:465` (SSL)
- **Username:** `YOUR_VIVALDI_EMAIL`
- **Password:** `YOUR_VIVALDI_SMTP_PASSWORD` (stored in `~/.hermes/.env` as `EMAIL_PASSWORD`)

### Verification
- Tested successfully on 2026-07-07
- Message queued with ID: `A6CBDFC595`
- Recipient: `YOUR_EMAIL_ADDRESS`

### Debugging
If authentication fails (535 error):
1. Verify password in `~/.hermes/.env`
2. Check if Vivaldi requires an app-specific password
3. Test IMAP connectivity first: `himalaya folder list`

### Note
Himalaya's `message.send` configuration in `~/.config/himalaya/config.toml` references the password via:
```toml
message.send.backend.auth.cmd = "python3 -c \"import re; f=open('/home/YOUR_USER/.hermes/.env'); v=[l.split('=',1)[1].strip().strip('\\\"') for l in f if l.startswith('EMAIL_PASSWORD=')]; print(v[0] if v else '')\""
```
This works for receiving but **not for sending** in v1.2.0 on this system.