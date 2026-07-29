# Herdr-first workflow

Session and agent state live in Herdr — not a separate dotfiles index.

## Session restore

Your `herdr/config.toml` sets:

```toml
[session]
resume_agents_on_restore = true
```

Herdr persists workspace layout, pane scrollback, and **agent session refs** (`PersistedAgentSession`) for recognized agents (Pi, Codex, Cursor, etc.). On server restart it can rebuild panes and resume agents from stored session IDs/paths.

Use Herdr sidebar / `cmd+j` `cmd+k` to jump agents. Use native resume inside each tool when needed:

- **Pi:** `pi --resume` or `--session-id`
- **Codex:** `co resume <id>` / `col resume <id>` (optional; Pi preferred)
- **Cursor:** Cursor Agent resume in IDE

## Org → Pi

```bash
org-pi plan
org-pi launch
```

Herdr: `prefix+shift+i` (org task → Pi tab)

Neovim org buffer: `:OrgAiPlan`, `:OrgAiLaunch`

## Durable notes

```bash
note add "preference here"
```

Or Pi: `/note ...` → `~/Documents/org/notes.md`

## Delegation

Read Pi `herdr` skill when splitting panes or prompting another agent.
