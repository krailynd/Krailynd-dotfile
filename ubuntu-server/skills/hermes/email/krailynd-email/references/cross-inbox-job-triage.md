# Cross-Inbox Job/Important Mail Triage

Session-derived pattern for Krailynd when asked to review both connected emails for important work/opportunity messages.

## Connected inboxes

- `YOUR_VIVALDI_EMAIL` — use `~/.hermes/scripts/email_inbox_monitor.py` / Himalaya IMAP.
- `YOUR_GMAIL_EMAIL` — use Google Workspace OAuth and `google_api.py` Gmail commands.

## Useful Gmail searches

```bash
GAPI="python ${HERMES_HOME:-$HOME/.hermes}/skills/productivity/google-workspace/scripts/google_api.py"
$GAPI gmail search "is:unread" --max 30
$GAPI gmail search '(LinkedIn OR empleo OR trabajo OR practicante OR recruiter OR entrevista OR "security alert" OR "Alerta de seguridad") newer_than:14d' --max 50
```

Read selected messages:

```bash
$GAPI gmail get MESSAGE_ID
```

## Ranking heuristic

1. Direct replies from recruiters/employers; interview scheduling; offers.
2. Tech/software roles matching Krailynd's direction: Java, backend, fullstack, IT, systems, programming, automation.
3. Internships/practicante roles from strong-brand companies.
4. Remote roles if relevant, especially tech; non-tech remote roles below tech.
5. Account/security alerts from Google or critical services.
6. Newsletters, promotions, tool updates, product marketing.

## Example summaries from the 2026-07-11 review

High-value Gmail opportunities found:

- **Backend Java Software Engineer — BCP** (Lima): strong Java/backend match; LinkedIn alert said active hiring and CV/profile application.
- **Java Fullstack Developer Junior — EPAM Systems** (Perú/remoto): good tech/company match.
- **Recién Egresado Sistemas / Programación — Indra Group** (San Isidro): aligned with systems/programming.
- **Practicante Automatización de Procesos — Newport Capital** (San Miguel): relevant automation/practice role.
- **Practicante Pre Profesional — Scotiabank** (Lima): strong company brand.
- **IT Intern — Procter & Gamble** (San Isidro): strong company brand.
- **Analista TI — Gilat Perú** (San Isidro): IT role; CV/profile application.

Security notices seen:

- Google OAuth/access notices for kimi.com, blackbox.ai, Claude for Gmail/Calendar, and a Linux login. Treat as important informational: if user does not recognize one, advise revoking access/checking account security.

## Response style

- Use Spanish when Krailynd asks in Spanish.
- Summarize by inbox first, then priority.
- Say explicitly if one inbox has no new mail.
- Avoid dumping raw JSON or tracking URLs. Offer to open links, inspect requirements, or help apply.
