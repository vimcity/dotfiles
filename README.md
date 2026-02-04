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
- **Modular config** split into settings, plugins, keybindings, and theme
- **Vim-style navigation** between panes with seamless Neovim integration
- **Plugins**:
  - tmux-resurrect & continuum (session persistence - survive reboots)
  - tmux-yank (better clipboard integration)
  - tmux-thumbs (hint-based text selection, like vimium)
  - tmux-fzf-url (fuzzy find and open URLs from terminal output)
  - tmux-sessionist (enhanced session management shortcuts)
  - tmux-battery & cpu (system resource monitoring in status bar)
  - tmux-pomodoro-plus (integrated pomodoro timer with display script)
- **Theme**: Catppuccin Frappe with custom zoom level controls
- Mouse support enabled
- History limit: 1 million lines
- Auto-save sessions every 15 minutes
- Path monitoring script for directory tracking

### Text Editor
**Neovim (LazyVim)** - Modern modal text editor
> Highly extensible Vim-based editor with LSP, treesitter, and modern IDE features. LazyVim provides sensible defaults and plugin management

- **Language Support**: TypeScript, Python, Java, JSON with full LSP (autocomplete, go-to-definition, refactoring)
- **AI Integration**: 
  - GitHub Copilot (code suggestions)
  - CodeCompanion with Ollama (local AI using gemma3:1b model - disabled by default)
  - Fabric AI integration for command analysis
- **Testing**: Neotest (modern test runner with UI for Java, TypeScript, and more)
- **Debugging**: DAP (Debug Adapter Protocol) for in-editor debugging
- **Documentation**: DevDocs integration for quick API reference
- **Extras**: 
  - Editor: illuminate (highlight matching words), inc-rename (live preview renames), mini-move (move lines/blocks), mini-diff (inline git changes)
  - Coding: mini-surround (edit surrounding quotes/brackets), yanky (yank history manager), conform (autoformatting)
  - UI: treesitter-context (show current function at top), indent-blankline (visual indent guides), mini-indentscope (highlight current scope)
  - Project management and organization mode (org-agenda support)
- **Cache Management**: Handles symlinked config with proper cache normalization (fixes treesitter crashes)

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
- **OpenCode** - AI-assisted command workflow (CLI agent tool)
- **GitHub Copilot** - Code suggestions in Neovim
- **CodeCompanion** - Local AI chat with Ollama integration (optional)
- **Ollama** - Local LLM backend for CodeCompanion
- Custom shell functions to pipe command output to AI for analysis

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
│   │   ├── config/     # Core settings (keymaps, options, autocmds, lazy.lua)
│   │   └── plugins/    # Custom plugin configs (codecompanion, neotest, devdocs, etc.)
│   └── init.lua        # Entry point
├── tmux/               # Tmux configuration (modular)
│   ├── conf/
│   │   ├── settings.conf     # Core settings
│   │   ├── plugins.conf      # Plugin declarations
│   │   ├── keybindings.conf  # Key mappings
│   │   └── theme.conf        # Theme and appearance
│   ├── scripts/               # Helper scripts (pomodoro, memory monitoring, path tracking)
│   └── tmux.conf       # Main config (sources modules)
├── zshrc               # Zsh configuration with extensive aliases
├── starship.toml       # Prompt configuration
├── lazygit-config.yml  # Git UI configuration
├── karabiner.json      # Keyboard remapping (Corne, traditional layouts)
├── gitconfig.delta     # Delta git diff config
├── fdignore            # fd ignore patterns
├── rgignore            # ripgrep ignore patterns
├── glow-style.json     # Markdown renderer style
├── AGENTS.md           # Guidance for agents + cache management + recent changes
├── CLAUDE.md           # Architecture documentation
├── SECURITY.md         # Security best practices
├── PORTABILITY.md      # Cross-platform compatibility notes
└── install.sh          # Installation script
```

## Notable Features

- **Catppuccin Frappe** theme consistently applied across terminal, tmux, neovim, and bat
- **Vim keybindings** in shell (vi mode), tmux copy mode, neovim, and file managers
- **Fuzzy finding** integrated throughout with fzf (files, directories, git branches)
- **Shell history** synced across machines with Atuin
- **Session persistence** with tmux-resurrect, continuum, and integrated pomodoro timer
- **Testing & debugging** with Neotest (UI test runner) and DAP (step-through debugging)
- **AI assistance** with GitHub Copilot, CodeCompanion (Ollama), Fabric, and OpenCode
- **Performance optimized** with lazy-loading (pyenv, plugins, LazyVim cache handling)
- **Modern tools** replacing traditional Unix utilities (eza, fd, ripgrep, bat, delta)
- **Keyboard customization** with Karabiner for mechanical keyboards (Corne) and traditional layouts
- **Symlink-safe config** with proper cache normalization for Neovim
- **Documentation at hand** with DevDocs integration in Neovim

## Requirements

These tools should be installed via Homebrew or other package managers:
- **Core**: ghostty, neovim, tmux, zsh
- **Utilities**: starship, atuin, zoxide, fzf, fd, ripgrep, bat, eza, delta, glow, lazygit, fastfetch, yazi
- **Optional**: pyenv (Python), ollama (local LLM), Karabiner-Elements (keyboard remapping)
- **Font**: JetBrains Mono Nerd Font or CommitMono (see https://commitmono.com/)

The install script handles:
- Oh My Zsh installation and plugin setup (git, autosuggestions, syntax-highlighting)
- TPM (Tmux Plugin Manager) bootstrap
- Config file symlinks to ~/.config/

Note: The install script assumes the above tools are already installed via Homebrew.
