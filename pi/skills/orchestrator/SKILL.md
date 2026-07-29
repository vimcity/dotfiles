---
name: orchestrator
description: Use the local `ai` CLI for session discovery, org-backed plans, compact task state, and Herdr launches. Prefer this over ad-hoc tmux glue when the user wants to find/resume agent sessions or turn an org :ai: task into a running plan.
---

# Orchestrator

The dotfiles orchestrator is a file-backed control plane around native agent stores.

## Commands

```bash
ai doctor
ai session rebuild
ai session pick
ai session pick --resume
ai session search "refund bug"
ai session resume <session-id>
ai plan list
ai plan create
ai plan snapshot --state "Implemented session index" --next "Dogfood picker"
ai plan launch
ai task create "title"
```

## Rules

- Index and summarize native sessions; never mirror full transcripts.
- Provider stores remain authoritative: Codex `~/.codex/state_5.sqlite`, Pi `~/.pi/agent/sessions`.
- Org `:ai:` / `:agent:` headings are the bridge from capture to execution.
- Plans live under `~/Documents/org/plans/` with a managed snapshot section between `<!-- ai-managed:start/end -->`.
- Launch plans through Herdr when `HERDR_ENV=1`; verify with `test "${HERDR_ENV:-}" = 1`.
- For Herdr-specific pane/agent control, also read the `herdr` skill.

## Typical flows

**Resume anything**

```bash
ai session pick --resume
```

**Org task → plan → Herdr agent**

```bash
ai plan create
ai plan launch
```

**Record durable progress**

```bash
ai plan snapshot --decision "Use Herdr backend" --state "V1 shipped" --next "Dogfood for a week"
agent-context add "Prefer ai session pick over manual codex resume"
```
