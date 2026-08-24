---
name: youtube-download
description: "Download YouTube videos using yt-dlp with Deno runtime for JavaScript extraction. Optimized for Krailynd's workflow (Vector, tutorials, offline viewing)."
version: 1.0.0
author: Hermes (Krailynd)
license: MIT
platforms: [linux, macos, windows]
prerequisites: [pip, curl]
metadata:
  hermes:
    tags: [YouTube, yt-dlp, Video, Download, Deno, MP4]
    homepage: https://github.com/yt-dlp/yt-dlp
---

# YouTube Video Download

**Purpose:** Download YouTube videos for offline viewing, analysis, or delivery via WhatsApp. Uses `yt-dlp` with **Deno** as the JavaScript runtime for YouTube extraction.

## Setup

### 1. Install yt-dlp
```bash
pip install yt-dlp
```

### 2. Install Deno (Required for YouTube Extraction)
YouTube requires a JavaScript runtime for extraction. `yt-dlp` supports Deno, Node.js, or Bun. **Deno is recommended** for its simplicity and lightweight installation.

```bash
# Install Deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# Add Deno to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$HOME/.deno/bin:$PATH"
```

**⚠️ Critical:** Without a JavaScript runtime, `yt-dlp` will fail with:
```
WARNING: [youtube] No supported JavaScript runtime could be found.
```

## Usage

### List Available Formats
Always check available formats before downloading to avoid errors:
```bash
yt-dlp -F "https://www.youtube.com/watch?v=VIDEO_ID"
```

### Download in 360p MP4 (Recommended)
Format `18` is a **MP4 container with H.264 video and AAC audio** at 360p. Ideal for compatibility and file size (~90 MB for a 40-minute video).

```bash
yt-dlp -f "18" -o "/tmp/hermes_youtube_%(title)s.%(ext)s" "YOUTUBE_URL"
```

### Download Best MP4 Format
For higher quality (720p/1080p), use:
```bash
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" \
  --merge-output-format mp4 \
  -o "/path/to/output.mp4" \
  "YOUTUBE_URL"
```

### Download to /tmp for WhatsApp Delivery
```bash
yt-dlp -f "18" -o "/tmp/hermes_download.mp4" "YOUTUBE_URL"
```
Then send via:
```bash
~/.hermes/scripts/hermes_send_file.sh /tmp/hermes_download.mp4 video YOUR_WHATSAPP_NUMBER "Vector Latest Video"
```

## Format Selection Guide

| **Format ID** | **Resolution** | **Codec**       | **Size (Approx.)** | **Notes**                     |
|---------------|----------------|------------------|--------------------|-------------------------------|
| 18            | 360p           | MP4 (H.264)     | ~90 MB             | Best for WhatsApp delivery    |
| 22            | 720p           | MP4 (H.264)     | ~200-400 MB        | Higher quality                |
| 137+140       | 1080p          | MP4 + M4A        | ~400-800 MB        | Requires merging              |
| 299           | 1080p60        | MP4 (H.264)     | ~800 MB+           | High bitrate, large files     |
| 401           | 4K             | MP4 (AV1)       | ~2-4 GB            | Requires AV1 support          |

**🎯 Recommendation:** Use **Format 18** for WhatsApp (16 MB limit). For larger videos, use Format 22 (720p) and compress if needed.

## Example: Vector's Latest Video
- **Video**: ["Most Viral VECTOR Compilation Ever (10 BILLION VIEWS!)"](https://www.youtube.com/watch?v=kM9UrJBkZjk)
- **Command**:
  ```bash
  yt-dlp -f "18" -o "/tmp/hermes_vector_final.mp4" "https://www.youtube.com/watch?v=kM9UrJBkZjk"
  ```
- **Result**: 360p MP4, **90.10 MB**, with audio.

## Troubleshooting

### 1. Disk Quota Exceeded
**Error:**
```
ERROR: unable to write data: [Errno 122] Disk quota exceeded
```
**Fix:**
```bash
# Free up space in /tmp
rm -f /tmp/hermes_*.mp4 /tmp/hermes_*.m4a /tmp/hermes_*.webm

# Check available space
df -h /tmp
```

### 2. Format Not Available
**Error:**
```
ERROR: [youtube] VIDEO_ID: Requested format is not available.
```
**Fix:**
```bash
# List available formats
yt-dlp -F "YOUTUBE_URL"

# Choose a valid format ID from the list
```

### 3. JavaScript Runtime Missing
**Error:**
```
WARNING: [youtube] No supported JavaScript runtime could be found.
```
**Fix:**
```bash
# Install Deno (recommended)
curl -fsSL https://deno.land/x/install/install.sh | sh
export PATH="$HOME/.deno/bin:$PATH"

# Or install Node.js
sudo apt install nodejs
```

### 4. Video Too Large for WhatsApp
**Issue:** WhatsApp has a **16 MB limit** for video files.

**Fix:**
- Use **Format 18 (360p)** for smaller files.
- Compress the video with `ffmpeg`:
  ```bash
  ffmpeg -i input.mp4 -vcodec libx264 -crf 28 -preset fast -acodec aac -b:v 1M output.mp4
  ```

### 5. Private/Unavailable Video
**Error:**
```
ERROR: [youtube] VIDEO_ID: This video is private or unavailable.
```
**Fix:** Verify the URL and ensure the video is public.

## Commands Summary
```bash
# Install dependencies
pip install yt-dlp
curl -fsSL https://deno.land/x/install/install.sh | sh

# List formats for a video
yt-dlp -F "YOUTUBE_URL"

# Download in 360p MP4 (recommended)
yt-dlp -f "18" -o "/tmp/output.mp4" "YOUTUBE_URL"

# Download best MP4
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]" --merge-output-format mp4 -o "/tmp/output.mp4" "YOUTUBE_URL"

# Clean up /tmp
rm -f /tmp/hermes_*.mp4
```

## References
- [yt-dlp GitHub](https://github.com/yt-dlp/yt-dlp)
- [Deno Installation](https://deno.land/manual/getting_started/installation)
- [YouTube Format Codes](https://github.com/yt-dlp/yt-dlp/blob/master/README.md#format-selection)
