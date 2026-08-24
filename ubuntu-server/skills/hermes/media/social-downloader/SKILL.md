---
name: social-downloader
description: "Download videos, photos, and GIFs from YouTube, X/Twitter, Instagram, Facebook, TikTok via yt-dlp."
version: 1.0.0
author: Krailynd
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [YouTube, X, Twitter, Instagram, Facebook, TikTok, download, video, image, gif, yt-dlp]
---

# Social Downloader

Downloads public video/photo/GIF content from YouTube, X (Twitter), Instagram, Facebook,
and TikTok using `yt-dlp` (already installed at `~/.local/bin/yt-dlp`, on PATH for every
Hermes session/channel). `ffmpeg` is available system-wide for format merging/conversion.

Use this when the user pastes a link from one of these platforms and asks to download,
save, or send them the video/image/gif — not for transcript/summary requests (that's the
`youtube-content` skill).

## Scope and limits — read before using

- **Public content only.** Do not pass cookies, session tokens, or login credentials to
  bypass private accounts, age gates, or paywalls. If a download fails because content is
  private/restricted, tell the user — do not attempt to circumvent it.
- **No mass scraping.** One user-requested URL at a time, not channel/profile crawls,
  unless the user explicitly asks for a small bounded batch (e.g. "the last 3 videos").
- **Respect WhatsApp/Telegram size limits.** WhatsApp document/video delivery via the bridge
  is unreliable above ~64MB. Cap format selection accordingly (see below) and warn the user
  if a video is too large to deliver inline — offer a lower-quality version instead.
- Always download to `/tmp/` and clean up after delivery (or leave it — `/tmp` is ephemeral).

## Basic usage

```bash
# Video, capped at a WhatsApp-friendly size, best available under the cap
yt-dlp -f "best[filesize<50M]/bestvideo[filesize<50M]+bestaudio/best" \
  -o "/tmp/%(title).60s.%(ext)s" "URL"

# Audio only (music, voice notes)
yt-dlp -x --audio-format mp3 -o "/tmp/%(title).60s.%(ext)s" "URL"

# Single image / photo post (Instagram, X photo tweets)
yt-dlp -o "/tmp/%(title).60s.%(ext)s" "URL"

# Metadata only, no download (title, duration, uploader — useful to confirm before downloading)
yt-dlp --dump-json --no-download "URL" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('title'), '|', d.get('duration'), 's |', d.get('uploader'))"
```

## Per-platform notes

- **YouTube**: full support (video, audio, shorts, playlists — ask before downloading a whole playlist). Age-restricted/members-only content will fail; tell the user rather than retrying with workarounds.
- **X / Twitter**: extractor is internally named `twitter` but handles both `twitter.com` and `x.com` URLs. GIFs on X are actually served as looping MP4 — yt-dlp downloads them as video; convert to a real `.gif` with `ffmpeg -i in.mp4 -vf "fps=15,scale=480:-1" out.gif` only if the user specifically needs a `.gif` file.
- **Instagram**: works for public posts/reels. Stories and private accounts are not accessible without login — do not attempt.
- **Facebook**: works for public videos/posts. Private/friends-only content will fail — expected, not a bug.
- **TikTok**: full support, usually without watermark by default extractor behavior.

## Delivery via WhatsApp

After downloading, send with the existing delivery script (do not reinvent this):

```bash
~/.hermes/scripts/hermes_send_file.sh /tmp/downloaded_file.mp4 video "" "caption here"
~/.hermes/scripts/hermes_send_file.sh /tmp/downloaded_photo.jpg image "" "caption here"
```

Omit the phone argument to default to `WHATSAPP_HOME_NUMBER` from `~/.hermes/.env`. For
Telegram/CLI/dashboard, just reference the `/tmp/` path directly — those channels handle
their own file delivery.

## Error handling

- **"Unsupported URL"**: confirm the URL is from a supported platform and not a shortened
  link `yt-dlp` can't resolve — try expanding it first (`curl -sIL URL | grep -i location`).
- **Private/login-required**: tell the user directly; do not attempt to bypass.
- **File too large for the size cap**: retry with a lower format (e.g. `-f "worst"` or a
  specific height like `-f "best[height<=480]"`) and tell the user you downgraded quality.
- **`yt-dlp` reports an extractor error for a platform that changed its API**: this happens
  periodically for Instagram/X/TikTok since they change internals. Run
  `uv tool upgrade yt-dlp` once, then retry. If it still fails, tell the user the platform's
  extractor is temporarily broken upstream — don't loop retrying.
