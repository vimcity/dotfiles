---
name: org-pi
description: Plan and launch Org TODO/PROGRESS tasks with Pi inside Herdr. Use when the user wants org-driven personal work in Pi, not enterprise Codex or cross-session search.
---

# Org + Pi

Bridge org tasks to Pi sessions in Herdr.

## Commands

```bash
org-pi list
org-pi plan
org-pi launch
```

Neovim (in org buffers): `:OrgAiPlan`, `:OrgAiLaunch`  
Herdr: `prefix+alt+r` runs `org-pi launch`

## Flow

1. Pick a TODO/PROGRESS heading (fzf if interactive)
2. `org-pi plan` creates/links `~/Documents/org/plans/<slug>.md`
3. `org-pi launch` opens a Herdr tab in the task workdir and starts Pi with org context + plan path

## Rules

- Requires Herdr context (`HERDR_WORKSPACE_ID` or launch from inside Herdr)
- Keep durable decisions in the linked plan file
- Use `agent-context add` for cross-agent preferences, not the plan file
- For resuming old Pi/Codex chats, use the `sessions` skill instead
