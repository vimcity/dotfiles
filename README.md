# Dotfiles

Personal macOS development environment configuration with a focus on modern CLI tools and productivity.

## Daily stack

| Layer | Tool | Role |
| ------- | ------ | ------ |
| Terminal | **Ghostty** | GPU terminal emulator |
| Multiplexer | **Herdr** | Primary workspaces, tabs, panes, agent sidebar |
| Coding agent | **Pi** | Primary agent for repo work and org tasks |
| IDE agent | **Cursor Agent** | In-editor coding when needed |
| Optional | **Codex** (`co` / `col`) | Secondary CLI agent |

Session and agent state live in **Herdr** — not a separate dotfiles index. Do not reintroduce custom orchestrators or session indexes.

## Herdr + Pi workflow

Herdr is the primary terminal multiplexer. Pi is the primary coding agent.

### Session restore

`herdr/config.toml` sets:

```toml
[session]
resume_agents_on_restore = true
```

Herdr persists workspace layout, pane scrollback, and **agent session refs** (`PersistedAgentSession`) for recognized agents (Pi, Codex, Cursor, etc.). On server restart it can rebuild panes and resume agents from stored session IDs/paths.

Use Herdr sidebar / `cmd+j` `cmd+k` to jump agents. Use native resume inside each tool when needed:

- **Pi:** `pi --resume` or `--session-id` (primary)
- **Codex:** `co resume <id>` / `col resume <id>` (optional)
- **Cursor:** Cursor Agent resume in IDE

### Org → Pi

```bash
org-pi plan
org-pi launch
```

Herdr: `prefix+shift+i` (org task → Pi tab)

Neovim org buffer: `:OrgAiPlan`, `:OrgAiLaunch`

### Durable notes

```bash
note add "preference here"
```

Or Pi: `/note ...` → `~/Documents/org/notes.md`

### Delegation

Read Pi `herdr` skill when splitting panes or prompting another agent.

## Quick Start

```bash
cd ~/dotfiles
./install.sh
```

The install script will:

- Install Oh My Zsh and plugins (autosuggestions, syntax highlighting)

- Link Herdr, Pi, and Neovim configs
- Backup existing configs
- Create symlinks for all dotfiles

## Overview

This configuration emphasizes:

- **Herdr + Pi** as the primary terminal and agent workflow
- **Modern CLI replacements** (bat, eza, fd, ripgrep, zoxide)
- **Catppuccin-based theming** across all tools, with a custom `catppuccin-rose` variant in Neovim/OpenCode
- **Vim-style keybindings** everywhere
- **Cross-machine sync** with machine-specific overrides
- **Performance** with lazy-loading and optimized startup

## Tools & Configuration

### Terminal

**Ghostty** - Modern GPU-accelerated terminal emulator
> Fast, native macOS terminal with GPU rendering for smooth scrolling and animations

- **Theme**: Custom `catppuccin-rose` (tracked in `ghostty/themes/`, derived from Catppuccin Frappe with rose accents)
- Font: CommitMono at 16pt with 40% cell height adjustment
- Quick terminal toggle (`Cmd+Shift+\``)
- Shell integration enabled for Zsh
- Launches into **Herdr** for day-to-day work

### Terminal Multiplexer (primary)

**Herdr** - Agent-aware terminal multiplexer
> Primary daily driver: workspaces, tabs, panes, agent sidebar, and session restore for Pi/Codex/Cursor agents

- **Config**: `herdr/config.toml` (+ plugins under `herdr/plugins/`)
- **Prefix**: `Ctrl+Space`
- **Agents**: Pi is the default coding agent; Herdr tracks pane-bound sessions
- **Session restore**: `resume_agents_on_restore = true` rebuilds layout and resumes agents after restart
- **Navigation**: `Cmd+j` / `Cmd+k` between agents; `Ctrl+h/j/k/l` across Neovim splits and panes
- **Org → Pi**: `prefix+shift+i` runs `org-pi launch`

### Shell Environment

**Zsh** - Unix shell with powerful customization
> Primary command-line interface with enhanced features via Oh My Zsh framework

- **Modules**: `zshrc.d/` splits prompt, Herdr glue, oMLX, Codex, org helpers
- **Prompt**: Custom prompt theme system with `catppuccin-rose` as the default, plus Starship modules for context
- **Plugins**: git, zsh-autosuggestions, zsh-syntax-highlighting, docker-compose
- **History**: Standard zsh history for up/down arrow, Atuin for fuzzy search (`Ctrl+R`)
- **Navigation**: Zoxide for smart directory jumping
- **Python**: pyenv for version management (lazy-loaded)

### Shell History

**Atuin** - Shell history database with sync capabilities
> Replaces default shell history with searchable, encrypted, cross-machine synced command database

- Fuzzy search mode
- Cross-machine sync enabled
- History preview
- Global filter mode (search across all sessions)
- Customized format showing relative time and directory

### Modern CLI Tools

- **bat** - Syntax-highlighted file viewer
  > Drop-in cat replacement with syntax highlighting, line numbers, and git integration. Used as default pager for man pages
  - Catppuccin Frappe theme, used as man pager
  
- **eza** - Modern file lister
  > Replacement for ls with colors, icons, git status, and tree views
  - Icons and git integration enabled
  
- **fd** - Fast file finder
  > Simpler, faster alternative to find with sensible defaults and ignore patterns
  - Custom ignore file support
  
- **ripgrep (rg)** - Fast text search tool
  > Blazingly fast grep alternative that respects gitignore and uses smart defaults
  - Custom ignore rules for better search results
  
- **fzf** - Fuzzy finder
  > Interactive filter for command-line that enables fuzzy searching for files, history, and more
  - Integrated for file search, command history, git branch selection
  
- **delta** - Enhanced git diff viewer
   > Syntax-highlighting pager for git diffs with side-by-side view support
  - Used in lazygit for better diff visualization

### Text Editor

**Neovim (LazyVim)** - Modern modal text editor
> Highly extensible Vim-based editor with LSP, treesitter, and modern IDE features

- **Language Support**: TypeScript, Python, Java, Go, Kotlin, JSON with full LSP
- **AI in-editor**: GitHub Copilot (`Alt-y` / `<leader>cp`), CodeCompanion → oMLX (`<leader>aa/ac/ap`)
- **Org glue**: `:OrgAiPlan`, `:OrgAiLaunch` → `org-pi` in Herdr
- **Herdr-aware splits**: `Ctrl+h/j/k/l` uses Herdr navigation
- **Testing / debugging**: Neotest, DAP
- **Theme**: Custom `catppuccin-rose` colorscheme
- **Surround**: LazyVim default `gsa` / `gsd` / `gsr` (mini-surround extra)

### Git Tools

**Lazygit** - Terminal UI for git operations
> Interactive terminal interface for git that simplifies staging, committing, branching, merging, and rebasing

- GitHub-style diff colors
- Delta integration for better diffs
- File tree view enabled
- Custom theme matching overall color scheme

### System Info

**Fastfetch** - System information tool
> Fast neofetch alternative that displays system specs (OS, CPU, memory, etc.) with styling

- Shows OS, kernel, uptime, packages, terminal, CPU, GPU, memory, battery, etc.

### Additional Tools

**Starship** - Cross-shell prompt
> Fast, customizable prompt that shows relevant context (git branch, language versions, execution time)

**Zoxide** - Smart directory jumper
> Replaces cd with an intelligent version that remembers your most-used directories

**Yazi** - Terminal file manager
> Fast TUI file explorer with preview support, similar to ranger

**Karabiner-Elements** - Keyboard remapping
> macOS keyboard customization for Corne mechanical keyboard and traditional layout support

**pyenv** - Python version manager
> Manage multiple Python versions and easily switch between them per-project

### Search & Navigation Aliases

Custom functions for fuzzy finding:

- `ff` - Fuzzy find files with bat preview
- `fdir` - Fuzzy find directories with eza preview
- `ffe` - Fuzzy find and edit files
- `sif` - Search in files with ripgrep and fzf
- `glog` - Interactive git log browser
- `gcof` / `gbdf` - Fuzzy git branch checkout/delete

### AI Integration

- **Pi** — primary coding agent (terminal + org tasks)
- **Herdr** — layout, agent sidebar, session restore (see **Herdr + Pi workflow** above)
- **Org + Pi (`org-pi`)** — org task → plan → Pi; Herdr `prefix+shift+i`
- **Cursor Agent** — in-editor when needed
- **Codex** (`co` / `col`) — optional secondary CLI agent
- **Neovim**: Copilot inline, CodeCompanion chat/actions
- **`note`** — durable bullets; **oMLX / `ask`** — local glue and RAG

### Git Workflow

- Extensive git aliases in zsh
- Git worktree shortcuts for multi-branch development
- Delta for enhanced git diffs
- Lazygit for terminal UI

## Directory Structure

```
dotfiles/
├── bin/                # org-pi, note, herdr helpers
├── herdr/              # Herdr config + plugins (primary multiplexer)
├── pi/                 # Pi agent config, skills, extensions, SYSTEM.md
├── atuin/              # Shell history configuration
├── fastfetch/          # System info display config
├── ghostty/            # Terminal emulator config
│   ├── shaders/        # Custom cursor shaders
│   └── config          # Main Ghostty config
├── nvim/               # Neovim LazyVim configuration
│   ├── lua/
│   │   ├── config/     # Core settings (keymaps, options, autocmds, lazy.lua)
│   │   └── plugins/    # Custom plugin configs (copilot, codecompanion, etc.)
│   └── init.lua        # Entry point

├── zshrc               # Zsh entrypoint (sources zshrc.d/)
├── zshrc.d/            # Modular shell config (herdr, omlx, codex, prompt, …)
├── lazygit-config.yml  # Git UI configuration
├── karabiner.json      # Keyboard remapping
├── AGENTS.md           # Guidance for coding agents
├── CLAUDE.md           # Points to AGENTS.md
└── install.sh          # Installation script
```

## Notable Features

- **Herdr-first workflow** with Pi as the primary agent and agent session restore
- **Catppuccin + rose overrides** across Ghostty, Herdr, prompt, Neovim, and bat
- **Vim keybindings** in shell (vi mode), Herdr copy mode, Neovim, and file managers
- **Fuzzy finding** integrated throughout with fzf (files, directories, git branches)
- **Shell history** synced across machines with Atuin
- **Testing & debugging** with Neotest and DAP
- **AI assistance** — Pi/Herdr for coding; Copilot + CodeCompanion in Neovim; oMLX for local glue
- **Performance optimized** with lazy-loading (pyenv, plugins, LazyVim cache handling)
- **Modern tools** replacing traditional Unix utilities (eza, fd, ripgrep, bat, delta)
- **Symlink-safe Neovim config** with proper cache normalization

## Requirements

These tools should be installed via Homebrew or other package managers:

- **Core**: ghostty, herdr, pi, neovim, zsh

- **Utilities**: atuin, zoxide, fzf, fd, ripgrep, bat, eza, delta, lazygit, fastfetch, yazi
- **Optional**: pyenv (Python), oMLX (local LLM), Codex, Karabiner-Elements
- **Font**: JetBrains Mono Nerd Font or CommitMono (see <https://commitmono.com/>)

The install script handles:

- Oh My Zsh installation and plugin setup

- Symlinks for Herdr, Pi, Neovim, shell, and tool configs

Note: The install script assumes the above tools are already installed via Homebrew on macOS, or via apt on Debian/Ubuntu Linux dev machines.
