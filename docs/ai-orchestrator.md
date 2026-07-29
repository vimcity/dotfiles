# AI Orchestrator (dotfiles)

Terminal-native control plane for session discovery, org-backed plans, and Herdr launches.

## Quick start

```bash
ai doctor
ai session rebuild
ai session pick --resume
ai plan create
ai plan launch
```

Shell aliases: `ais`, `aisr`, `aip`, `aipl`, `aids`, `aid`.

## Layout

```text
dotfiles/
  bin/ai                 # CLI entrypoint
  orchestrator/          # Python implementation (stdlib only)
  zshrc.d/ai.zsh         # shell aliases + optional ai-workbench PATH
  pi/skills/orchestrator/
  nvim/lua/plugins/ai-orchestrator.lua
~/.cache/ai-orchestrator/session-index.json
~/Documents/org/plans/
~/Documents/org/ai-tasks/
```

## Design

- Provider-native stores stay authoritative.
- The orchestrator caches searchable metadata only.
- Org headings with `:ai:` / `:agent:` tags bridge capture → plan → launch.
- Herdr is the default launch backend; tmux workbench remains optional via `~/Projects/ai-workbench`.

See also: `~/Documents/org/plans/ai-orchestrator-plan.md`.
