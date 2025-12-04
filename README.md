# Dotfiles

Personal macOS development environment configuration with a focus on modern CLI tools and productivity.

## Quick Start

```bash
cd ~/dotfiles
./install.sh
```

The install script will:
- Install Oh My Zsh and plugins (autosuggestions, syntax highlighting)
- Install TPM (Tmux Plugin Manager)
- Backup existing configs
- Create symlinks for all dotfiles

## Overview

This configuration emphasizes:
- **Modern CLI replacements** (bat, eza, fd, ripgrep, zoxide)
- **Catppuccin Frappe theme** across all tools
- **Vim-style keybindings** everywhere
- **Cross-machine sync** with machine-specific overrides
- **Performance** with lazy-loading and optimized startup

## Tools & Configuration

### Terminal
**Ghostty** - Modern GPU-accelerated terminal
- Catppuccin Frappe theme with custom darker background
- JetBrains Mono Nerd Font at 16pt
- Custom cursor shader (blaze effect)
- Quick terminal toggle (`Cmd+Shift+\``)
- Ligatures disabled

### Shell Environment
**Zsh** with Oh My Zsh
- **Prompt**: Starship (customized with Catppuccin Mocha colors, shows OS, directory, git status, language versions)
- **Plugins**: git, zsh-autosuggestions, zsh-syntax-highlighting, docker-compose
- **History**: Standard zsh history for up/down arrow, Atuin for fuzzy search (`Ctrl+R`)
- **Navigation**: Zoxide for smart directory jumping
- **Python**: pyenv for version management (lazy-loaded)

### Shell History
**Atuin** - Encrypted, synced shell history
- Fuzzy search mode
- Cross-machine sync enabled
- History preview
- Global filter mode (search across all sessions)
- Customized format showing relative time and directory

### Modern CLI Tools
- **bat** - Syntax-highlighted cat replacement (Catppuccin Frappe theme, used as man pager)
- **eza** - Modern ls replacement with icons and git integration
- **fd** - Fast find alternative with ignore file support
- **ripgrep (rg)** - Fast grep with custom ignore rules
- **fzf** - Fuzzy finder for files and commands
- **delta** - Better git diffs (used in lazygit)
- **glow** - Markdown renderer in terminal

### Terminal Multiplexer
**Tmux** - Session and window management
- **Prefix**: `Ctrl+Space`
- **Theme**: tmux-powerline
- **Modular config** split into settings, plugins, and keybindings
- **Vim-style navigation** between panes
- **Plugins**:
  - tmux-resurrect & continuum (session persistence)
  - tmux-yank (better clipboard)
  - tmux-thumbs (hint-based selection)
  - tmux-fzf-url (open URLs from terminal)
  - tmux-sessionist (session management)
  - tmux-battery & cpu (status indicators)
- Mouse support enabled
- History limit: 1 million lines
- Auto-save sessions every 15 minutes

### Text Editor
**Neovim (LazyVim)** - Modern Neovim distribution
- **Language Support**: TypeScript, Python, Java, JSON with full LSP
- **AI Integration**: GitHub Copilot and Claude Code
- **Debugging**: DAP core enabled
- **Extras**: 
  - Editor: illuminate (highlight matching), inc-rename, mini-move, mini-diff
  - Coding: mini-surround, yanky (yank history)
  - UI: treesitter-context, indent-blankline, mini-indentscope
  - Project management

### Git Tools
**Lazygit** - Terminal UI for git
- GitHub-style diff colors
- Delta integration for better diffs
- File tree view enabled
- Custom theme matching overall color scheme

### System Info
**Fastfetch** - Fast system info display
- Shows OS, kernel, uptime, packages, terminal, CPU, GPU, memory, battery, etc.

### Search & Navigation Aliases
Custom functions for fuzzy finding:
- `ff` - Fuzzy find files with bat preview
- `fdir` - Fuzzy find directories with eza preview
- `ffe` - Fuzzy find and edit files
- `sif` - Search in files with ripgrep and fzf
- `glog` - Interactive git log browser
- `gcof` / `gbdf` - Fuzzy git branch checkout/delete

### AI Integration
- **OpenCode** shortcuts for AI-assisted workflow
- **Ollama** integration for local LLM usage
- Custom functions to pipe command output to AI for analysis

### Git Workflow
- Extensive git aliases in zsh
- Git worktree shortcuts for multi-branch development
- Delta for enhanced git diffs
- Lazygit for terminal UI

## Directory Structure

```
dotfiles/
├── atuin/              # Shell history configuration
├── fastfetch/          # System info display config
├── ghostty/            # Terminal emulator config
│   ├── shaders/        # Custom cursor shaders
│   └── config          # Main Ghostty config
├── nvim/               # Neovim LazyVim configuration
│   ├── lua/
│   │   ├── config/     # Core settings (keymaps, options, autocmds)
│   │   └── plugins/    # Custom plugin configs
│   └── init.lua        # Entry point
├── tmux/               # Tmux configuration (modular)
│   ├── conf/
│   │   ├── settings.conf     # Core settings
│   │   ├── plugins.conf      # Plugin declarations
│   │   └── keybindings.conf  # Key mappings
│   └── tmux.conf       # Main config (sources modules)
├── zshrc               # Zsh configuration
├── starship.toml       # Prompt configuration
├── lazygit-config.yml  # Git UI configuration
├── gitconfig.delta     # Delta git diff config
├── fdignore            # fd ignore patterns
├── rgignore            # ripgrep ignore patterns
├── glow-style.json     # Markdown renderer style
└── install.sh          # Installation script
```

## Machine-Specific Configuration

For machine-specific overrides (work configs, API keys, etc.), create `~/.zshrc.local`:

```bash
# Work machine example
export JAVA_HOME=/path/to/work/java
export AWS_PROFILE=work-profile
alias deploy='./work-deploy-script.sh'

# Personal machine example
export ANTHROPIC_API_KEY="your-key"
alias projects='cd ~/personal-projects'
```

This file is automatically sourced but not tracked in git.

## Tmux Quick Reference

**Prefix**: `Ctrl+Space`

**Panes & Windows**:
- `prefix v` - Split vertical
- `prefix s` - Split horizontal  
- `prefix h/j/k/l` - Navigate panes (Vim-style)
- `prefix c` - New window
- `prefix 1-9` - Switch window
- `prefix z` - Zoom/unzoom pane

**Sessions**:
- `prefix d` - Detach
- `prefix Ctrl+s` - Choose session
- `tmux new -s name` - Create session
- `tmux attach -t name` - Attach to session

**Copy Mode** (Vim-style):
- `prefix [` - Enter copy mode
- `v` - Begin selection
- `y` - Copy
- `prefix p` - Paste

**Plugins**:
- `prefix I` - Install plugins
- `prefix U` - Update plugins
- `prefix S` - Save session (resurrect)
- `prefix R` - Restore session (resurrect)

## Notable Features

- **Catppuccin Frappe** theme consistently applied across terminal, tmux, neovim, and bat
- **Vim keybindings** in shell (vi mode), tmux copy mode, and neovim
- **Fuzzy finding** integrated throughout with fzf
- **Shell history** synced across machines with Atuin
- **Session persistence** with tmux-resurrect and continuum
- **Performance optimized** with lazy-loading (pyenv, plugins)
- **Modern tools** replacing traditional Unix utilities
- **AI integration** for command analysis and assistance

## Requirements

These tools should be installed via Homebrew or other package managers:
- ghostty
- neovim
- tmux
- starship
- atuin
- zoxide
- fzf
- fd
- ripgrep
- bat
- eza
- delta
- glow
- lazygit
- fastfetch
- pyenv (optional, for Python)

The install script handles Oh My Zsh and plugin installation but assumes these tools are already present.
