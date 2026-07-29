---
name: session-finder
description: Find and resume native Codex or Pi sessions with `ai session` commands. Use when continuing prior agent work, not for new org tasks or Herdr delegation.
---

# Sessions

```bash
ai session pick --resume
ai session search "keyword"
ai session resume <session-id>
```

Aliases: `aisr`, `ais`, `ail`.

## Rules

- Metadata index only; provider stores stay authoritative.
- Not for org launch (`org-pi`) or Herdr delegation (`herdr` skill).
