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
**Ghostty** - Modern GPU-accelerated terminal emulator
> Fast, native macOS terminal with GPU rendering for smooth scrolling and animations

- Catppuccin Frappe theme with custom darker background
- JetBrains Mono Nerd Font at 16pt
- Custom cursor shader (blaze effect)
- Quick terminal toggle (`Cmd+Shift+\``)
- Ligatures disabled

### Shell Environment
**Zsh** - Unix shell with powerful customization
> Primary command-line interface with enhanced features via Oh My Zsh framework

- **Prompt**: Starship (customized with Catppuccin Mocha colors, shows OS, directory, git status, language versions)
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
  
- **glow** - Markdown renderer
  > Command-line markdown reader with styled formatting
  - For viewing documentation in terminal

### Terminal Multiplexer
**Tmux** - Terminal session and window manager
> Allows multiple terminal sessions in one window, with session persistence and detach/reattach capabilities

- **Prefix**: `Ctrl+Space`
- **Theme**: tmux-powerline
- **Modular config** split into settings, plugins, and keybindings
- **Vim-style navigation** between panes
- **Plugins**:
  - tmux-resurrect & continuum (session persistence - survive reboots)
  - tmux-yank (better clipboard integration)
  - tmux-thumbs (hint-based text selection, like vimium)
  - tmux-fzf-url (fuzzy find and open URLs from terminal output)
  - tmux-sessionist (enhanced session management shortcuts)
  - tmux-battery & cpu (system resource monitoring in status bar)
- Mouse support enabled
- History limit: 1 million lines
- Auto-save sessions every 15 minutes

### Text Editor
**Neovim (LazyVim)** - Modern modal text editor
> Highly extensible Vim-based editor with LSP, treesitter, and modern IDE features. LazyVim provides sensible defaults and plugin management

- **Language Support**: TypeScript, Python, Java, JSON with full LSP (autocomplete, go-to-definition, refactoring)
- **AI Integration**: GitHub Copilot (code suggestions) and Claude Code (chat-based assistance)
- **Debugging**: DAP (Debug Adapter Protocol) for in-editor debugging
- **Extras**: 
  - Editor: illuminate (highlight matching words), inc-rename (live preview renames), mini-move (move lines/blocks), mini-diff (inline git changes)
  - Coding: mini-surround (edit surrounding quotes/brackets), yanky (yank history manager)
  - UI: treesitter-context (show current function at top), indent-blankline (visual indent guides), mini-indentscope (highlight current scope)
  - Project management (find/search across project)

### Git Tools
**Lazygit** - Terminal UI for git operations
> Interactive terminal interface for git that simplifies staging, committing, branching, merging, and rebasing

- GitHub-style diff colors
- Delta integration for better diffs
- File tree view enabled
- Custom theme matching overall color scheme

### Keyboard Customization
**Karabiner-Elements** - Keyboard modifier for macOS
> Enables advanced keyboard customization, used here for home row mods to reduce hand movement

- Left hand: a=Shift, s=Alt, d=Cmd, f=Ctrl (when held)
- Right hand: j=Ctrl, k=Cmd, l=Alt, ;=Shift (when held)
- 100ms hold threshold
- Tap for normal key, hold for modifier

### System Info
**Fastfetch** - System information tool
> Fast neofetch alternative that displays system specs (OS, CPU, memory, etc.) with styling

- Shows OS, kernel, uptime, packages, terminal, CPU, GPU, memory, battery, etc.

### Additional Tools
**Starship** - Cross-shell prompt
> Fast, customizable prompt that shows relevant context (git branch, language versions, execution time)

**Zoxide** - Smart directory jumper
> Replaces cd with an intelligent version that remembers your most-used directories

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
