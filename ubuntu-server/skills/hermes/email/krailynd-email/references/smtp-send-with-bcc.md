# SMTP Send with BCC for Sent Folder Sync

## Problem
When sending emails via SMTP (Python `smtplib`) for `YOUR_VIVALDI_EMAIL`, sent emails do not automatically appear in the Vivaldi "Sent" folder.

## Solution
Add `Bcc: YOUR_VIVALDI_EMAIL` to the message headers. This triggers Vivaldi's server to save a copy in the Sent folder.

## Working Python Template

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Configuration
SENDER_NAME = "YOUR_NAME"
SENDER_EMAIL = "YOUR_VIVALDI_EMAIL"
SMTP_SERVER = "smtp.vivaldi.net"
SMTP_PORT = 465
SMTP_PASSWORD = "YOUR_VIVALDI_SMTP_PASSWORD"  # From ~/.hermes/.env

# Create message
msg = MIMEMultipart()
msg['From'] = f"{SENDER_NAME} <{SENDER_EMAIL}>"
msg['To'] = "recipient@example.com"
msg['Subject'] = "Your Subject Here"
msg['Bcc'] = SENDER_EMAIL  # Critical: ensures copy in Sent folder

# Body
body = """Your email body here.

Signed,
YOUR_NAME"""
msg.attach(MIMEText(body, 'plain', 'utf-8'))

# Send
server = smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT)
server.login(SENDER_EMAIL, SMTP_PASSWORD)
server.send_message(msg)
server.quit()

print("✅ Email sent and copy saved to Sent folder")
```

## Verification

After sending, check the Sent folder:
```bash
himalaya envelope list --folder Sent | grep -i "subject\|recipient"
```

## Notes

- Without `Bcc: YOUR_VIVALDI_EMAIL`, the email is sent but won't appear in Vivaldi's Sent folder
- This is a Vivaldi-specific behavior - other providers may handle this differently
- The BCC header is automatically removed from the recipient's copy
