# Himalaya CLI v1.2.0: Envelope List Syntax

## Problem
The following commands **FAIL** with error:
```
Error: cannot parse search emails query `--limit 1`
 ╭─[query:1:1]
 │
 1 │ --limit 1
 │ ┬ 
 │ ╰── found '-' expected `not`, `date`, `before`, `after`, `from`, `to`, `subject`, `body`, `flag`, or (nested filter)
───╯
```

**Failing patterns:**
- `himalaya envelope list --limit 1`
- `himalaya envelope list --limit 1 --sort newest`
- `himalaya envelope list --sort newest`

## Root Cause
Himalaya CLI v1.2.0 does NOT support `--limit` or `--sort` flags for the `envelope list` command. These flags are not part of the query syntax.

## Solution

### Get N most recent emails:
```bash
# Get 5 most recent (skip header row)
himalaya envelope list | tail -5

# Get the single most recent email
himalaya envelope list | tail -1
```

### Get first N emails:
```bash
# Get first 5 emails (includes header row)
himalaya envelope list | head -6
```

### Pagination (alternative):
```bash
# Use built-in pagination instead
himalaya envelope list --page 1 --page-size 10
```

## Verification

**Tested on:**
- Himalaya CLI v1.2.0
- Ubuntu 26.04
- Vivaldi IMAP (imap.vivaldi.net)

**Date:** 2026-07-07

## Workaround for Scripts

If you need to get the last N emails programmatically:

```bash
#!/bin/bash
# Get last 5 emails (skip header)
LAST_5=$(himalaya envelope list | tail -5)

# Extract just the IDs
IDs=$(echo "$LAST_5" | awk '{print $1}')

# Process each email
for ID in $IDs; do
  echo "Processing email $ID"
  himalaya message read "$ID"
done
```

## Related
- See: `himalaya envelope list --help` for full syntax
- See: SKILL.md for more Krailynd-specific patterns