# AGENTS.md

Guidance for coding agents working in this dotfiles repository.

## Daily stack

| Layer | Tool | Notes |
| ------- | ------ | ------- |
| Multiplexer | **Herdr** | Primary terminal workflow; `herdr/`, `zshrc.d/herdr.zsh` |
| Coding agent | **Pi** | Primary agent; config in `pi/`, skills, `SYSTEM.md` |
| IDE agent | **Cursor Agent** | When user works in Cursor |
| Optional CLI | **Codex** | `zshrc.d/codex.zsh`; secondary to Pi |

Herdr + Pi workflow is documented in **README.md** (session restore, org-pi, delegation). Do not reintroduce custom orchestrators, session indexes, or compression middleware.

## Local LLM (OMLX)

**Setup:** Apple Silicon OMLX (mlx-community). Model dir: `~/.omlx/models/`.

## Repository Overview

This repo is a personal macOS dotfiles setup, not a compiled application.
Most changes are configuration edits, shell functions, Herdr scripts, or Neovim plugin specs.

Primary areas:

- `zshrc` + `zshrc.d/` - shell environment split into modules (prompt, codex, omlx, herdr, helpers)
- `install.sh` - bootstrap script and symlink setup
- `nvim/` - LazyVim-based Neovim config in Lua
- `pi/` - Pi agent extensions, skills, themes, SYSTEM.md
- `bin/org-pi` - org task → plan → Pi in Herdr
- `bin/note` - durable bullets → `~/Documents/org/notes.md`
- `herdr/` - Herdr config (`resume_agents_on_restore = true`); **primary multiplexer**
- `ghostty/`, `atuin/`, `fastfetch/`, `yazi/`, `qutebrowser/` - tool-specific config
- `opencode/themes/` - OpenCode TUI theme only

## Build, Lint, and Test Commands

There is no repo-wide build pipeline, unit test suite, or CI command.
Validation is file-type specific.

### Core Validation

Run from repo root:

```bash
./install.sh                         # full install/bootstrap on a real machine
bash -n install.sh                  # validate install script syntax
zsh -n zshrc                        # validate zsh config syntax
bash -n bin/note bin/org-pi         # shell script syntax
python3 -m py_compile qutebrowser/config.py
nvim -c "checkhealth"              # manual Neovim health check
```

Notes:

- `./install.sh` changes the local machine; do not run it unless the task explicitly needs installation behavior tested.
- `nvim -c "checkhealth"` is a manual verification step after Neovim or plugin changes.

### Single-File / Targeted Checks

Use the smallest relevant command for the file you changed:

```bash
bash -n install.sh
zsh -n zshrc
python3 -m py_compile qutebrowser/config.py
```

There is no repo-level "single test" command because this repository has no automated test suite.
For this repo, "single test" usually means validating the one file or subsystem you changed.

### Formatter / Linter Tools In Use

These are present in the repo or editor config, but not enforced by a single root command:

- Lua: `stylua` (`nvim/stylua.toml` sets 2 spaces, width 120)
- Shell: `shellcheck`, `shfmt` are installed through Mason for Neovim workflows
- Python: `ruff`/`pyright` hints appear in `qutebrowser/config.py`
- Neovim formatting is primarily editor-driven through Conform and LSPs

Use them only when relevant to the file you touched and when available in the environment.

## Code Style Guidelines

### General

- Prefer small, local edits that preserve the existing file structure
- Match the style already used in the file before introducing a new pattern
- Keep comments sparse; add them only when the intent is not obvious
- Preserve user-specific behavior and cross-machine setup assumptions
- Never hardcode secrets, tokens, hardcoded paths with user or work-only settings into tracked files

### Shell (`zshrc`, `zshrc.d/*.zsh`, `install.sh`, `herdr/scripts/*.sh`)

- Use 4-space indentation in shell functions and conditionals
- Quote variable expansions: `"$var"`
- Prefer `[[ ... ]]` in Bash/Zsh conditionals when practical
- Use lowercase snake_case for function names
- Use uppercase names for true constants or exported config values
- Keep helper functions near the logic that uses them
- Prefer early returns / exits for invalid state
- Use `set -e` or `set -euo pipefail` for standalone scripts
- Print actionable messages for user-facing install or helper scripts

### Lua (`nvim/`)

- Use 2-space indentation
- Keep lines within the existing `stylua` width of 120 where practical
- Plugin files should return a Lua table spec
- Prefer one plugin or one cohesive feature per file under `nvim/lua/plugins/`
- Use descriptive `desc` values for keymaps and user commands
- Prefer local variables over globals
- Use `require(...)` inline when only used once; localize when reused
- Favor `vim.notify(...)` for user-visible failures inside commands/config
- Use `pcall(...)` around optional integrations that may not exist

### Python (`qutebrowser/`)

- Follow existing 4-space indentation
- Keep assignments direct and declarative; this config is mostly top-level settings
- Preserve qutebrowser globals like `config` and `c`
- Respect inline file directives such as `# ruff: noqa` and `# pyright: ...`
- Prefer small grouped sections with short explanatory comments

### TypeScript (`pi/extensions/*.ts`)

- Use ESM syntax and explicit type imports when available
- Keep functions small and side effects obvious
- Annotate exported plugin objects/functions with concrete types
- Prefer async helpers for shell interactions and wrap external calls in `try/catch`
- Fail softly for environment-dependent integrations like Herdr

### TOML / YAML / JSON Config

- Keep keys grouped by feature
- Preserve existing ordering unless reordering materially improves clarity
- Match the file's current quoting and spacing style
- Avoid unnecessary reformatting of large config blocks

## Imports, Dependencies, and Naming

- Do not add new dependencies unless the task clearly requires them
- Prefer built-in tool capabilities and existing plugins over new packages
- Keep file names descriptive and feature-oriented, especially in `nvim/lua/plugins/`
- Neovim plugin modules generally use lowercase filenames like `colorscheme.lua`, `neotest.lua`, `project.lua`
- Shell functions should be verb-oriented and readable at call sites

## Error Handling

- Shell: validate prerequisites before destructive operations; exit early on failure
- Lua: notify clearly when commands cannot proceed; avoid crashing startup on optional tools
- TypeScript: wrap process interactions in `try/catch`
- Python config: keep it declarative; avoid complex control flow unless necessary

## Editing Guidance

- Keep Catppuccin-based theming consistent unless the task explicitly changes theme direction
- Use `.zshrc.local`-style local overrides for machine-specific values, not tracked files
- For Neovim changes, prefer existing LazyVim conventions over custom bootstrap logic

- For shell changes, avoid slowing startup with eager initialization when lazy loading is already used

## Practical Workflow For Agents

1. Identify the subsystem you are touching
2. Read neighboring config before editing
3. Make the smallest coherent change
4. Run the narrowest validation command that matches the change
5. Mention any manual verification the user should do in the target app

## Important Notes

- This repo may contain local-environment assumptions; preserve them unless the task is explicitly portability-focused
- `install.sh` is idempotent in intent, but still changes the host machine
- Repo guidance currently lives in `AGENTS.md`; `CLAUDE.md` just points back here
