# AI session finder

Cross-provider search/resume for native Codex and Pi sessions. Org work and
Herdr orchestration use other tools — see below.

## Quick start

```bash
ai doctor
ai session rebuild
ai session pick --resume
```

Shell aliases: `ais`, `aisr`, `ail`, `aid`.

## Layout

```text
dotfiles/
  bin/ai                 # session finder entrypoint
  bin/org-pi             # org task → plan → Pi in Herdr
  orchestrator/          # stdlib Python (Codex sqlite + Pi jsonl index)
  zshrc.d/ai.zsh
  pi/skills/sessions/    # when to use session pick/resume
  pi/skills/herdr/       # pane/agent orchestration
~/.cache/ai-orchestrator/session-index.json
```

## End-state routing

| Job | Tool |
|-----|------|
| Find/resume any Codex or Pi session | `ai session pick --resume` / `aisr` |
| Org task → plan | `org-pi plan` / `:OrgAiPlan` in Neovim |
| Org task → Pi in Herdr | `org-pi launch` / `prefix+alt+r` |
| Delegate to another agent in Herdr | `herdr` skill |
| Enterprise vs local Codex | `co` / `col` |
| Durable notes | `agent-context add` |
| Plan progress | Edit plan markdown; Pi updates the file in-session |

## Design

- Provider stores stay authoritative; `ai` only caches searchable metadata.
- No second transcript database. No plan launcher inside `ai`.
- Optional `~/Projects/ai-workbench` for tmux voice/runs when needed.
