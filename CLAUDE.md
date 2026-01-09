# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal macOS development environment dotfiles repository focused on modern CLI tools and productivity. It manages configurations for terminal emulator (Ghostty), shell (Zsh), editor (Neovim with LazyVim), terminal multiplexer (Tmux), and various CLI tools.

## Common Commands

### Installation
```bash
cd ~/dotfiles
./install.sh
```
The install script backs up existing configs, installs Oh My Zsh, Zsh plugins, TPM (Tmux Plugin Manager), and creates symlinks for all dotfile configurations.

### Tmux Plugin Installation
After running install.sh:
1. Start tmux: `tmux`
2. Press: `Ctrl+Space` then `Shift+I` (capital i)
3. Wait for plugins to install

### Machine-Specific Configuration
Create `~/.zshrc.local` for machine-specific settings (environment variables, API keys, company tooling, performance tweaks). This file is automatically sourced by `.zshrc` if it exists.

### Configuration Editing
- `nvim ~/.zshrc` - Edit Zsh configuration
- `nvim ~/.config/starship.toml` - Edit prompt configuration
- `nvim ~/.tmux.conf` - Edit Tmux configuration (sources modular configs in tmux/conf/)
- `nvim ~/.config/ghostty` - Edit terminal emulator configuration
- `nvim ~/.config/neovim/init.lua` - Edit editor configuration

## Architecture & Structure

### Top-Level Configuration Files
- **zshrc** - Main shell configuration with aliases, functions, environment variables, and plugin setup
- **starship.toml** - Cross-shell prompt showing OS, directory, git status, language versions
- **tmux/tmux.conf** - Modular Tmux configuration entry point (sources plugins, settings, keybindings)
- **ghostty/config** - Terminal emulator settings (theme, fonts, cursors, keybindings)

### Configuration Organization

#### Neovim (LazyVim)
- **nvim/init.lua** - Entry point
- **nvim/lua/config/** - Core settings (keymaps, options, autocmds)
- **nvim/lua/plugins/** - Custom plugin configurations

Key features: LSP support for TypeScript/Python/Java/JSON, GitHub Copilot, Debug Adapter Protocol, Tree-sitter integration with plugins for code highlighting/navigation.

#### Tmux
Configuration is modularly split:
- **tmux/conf/settings.conf** - Core settings (prefix is Ctrl+Space, history limit 1M)
- **tmux/conf/plugins.conf** - Plugin declarations (tmux-resurrect, continuum for session persistence; tmux-yank, tmux-fzf-url, tmux-sessionist for enhanced navigation)
- **tmux/conf/keybindings.conf** - Key mappings with Vim-style pane navigation

Features: Session persistence across reboots, mouse support, status bar with system resource monitoring.

#### Zsh Shell
Configuration layers:
1. Oh My Zsh framework setup with minimal plugins (git, zsh-autosuggestions, zsh-syntax-highlighting, docker-compose)
2. Standard zsh history (10k entries) for up/down arrows
3. Atuin fuzzy history search (Ctrl+R) with local-only history (cloud sync disabled)
4. Environment setup: Zoxide for smart directory jumping, Starship for prompt
5. Aliases and custom functions for git workflows, fuzzy finding, and AI integration
6. Machine-specific overrides via ~/.zshrc.local

### Theme & Styling
All tools use **Catppuccin Frappe** color scheme consistently:
- Terminal: Ghostty with custom darker background and blaze cursor effect
- Prompt: Starship with Catppuccin Mocha colors
- Editor: Neovim
- Git UI: Lazygit with GitHub-style diff colors
- Pager: bat (used as default man pager)

### Tool Integrations

**Modern CLI Replacements** (configured for consistency):
- **bat** - cat replacement with syntax highlighting (Catppuccin theme)
- **eza** - ls replacement with icons and git integration
- **fd** - find replacement with fdignore patterns
- **ripgrep (rg)** - grep replacement with rgignore patterns
- **fzf** - Fuzzy finder used throughout shell and keybindings
- **delta** - Git diff viewer integrated with lazygit
- **zoxide** - Smart directory jumper (z command)

**Shell Functions for Productivity**:
```
ff          # Fuzzy find files with bat preview
fdir        # Fuzzy find directories with eza preview
ffe         # Fuzzy find and edit files
sif         # Search in files with ripgrep and fzf
glog        # Interactive git log browser
gcof/gbdf   # Fuzzy git branch checkout/delete
```

**Git Workflow**:
- Extensive git aliases for common operations
- Git worktree shortcuts for multi-branch development
- Delta integration for enhanced diffs
- Lazygit for terminal UI

**AI Integration**:
- GitHub Copilot in Neovim
- Ollama integration for local LLM usage

## Key Configuration Points

### Important Paths
- Configurations are symlinked from ~/dotfiles/ to ~/.config/ (per XDG Base Directory spec)
- Neovim LazyVim is a starter template (refer to https://lazyvim.github.io/installation for updates)
- Oh My Zsh plugins installed to ~/.oh-my-zsh/custom/plugins/
- Tmux plugins managed by TPM in ~/.tmux/plugins/

### Performance Considerations
- Pyenv is lazy-loaded in zshrc
- Zsh history optimization with deduplication enabled
- Atuin provides fast fuzzy history search
- Starship prompt is optimized for speed

### Session Management
- **Tmux-resurrect & continuum**: Automatically saves sessions every 15 minutes and restores on terminal startup
- **Atuin**: Syncs shell history across machines
- Session key: `Ctrl+Space` (all Tmux commands prefixed with this)

## Dependencies

All required tools should be installed before running install.sh (via Homebrew or other package managers):
- ghostty, neovim, tmux, starship, atuin, zoxide, fzf, fd, ripgrep, bat, eza, delta, glow, lazygit, fastfetch, pyenv (optional)

The install script handles Oh My Zsh and plugin setup but assumes these are already present.
