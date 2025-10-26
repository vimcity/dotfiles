# Dotfiles

Personal configuration files synced between work and personal machines.

## Contents

- **ghostty/** - Ghostty terminal config
- **atuin/** - Shell history sync config
- **starship.toml** - Starship prompt config
- **zshrc** - Zsh configuration (work-specific items filtered out)
- **tmux.conf** - Tmux configuration with Catppuccin theme and plugins
- **neofetch/** - Neofetch system info config
- **hammerspoon/** - Hammerspoon automation config
- **vimrc** - Vim configuration
- **bat/** - Bat (cat replacement) config with Catppuccin theme

Note: Oh My Zsh plugins and TPM (Tmux Plugin Manager) are installed automatically by the install script.

## Setup on new machine

```bash
cd ~/dotfiles
./install.sh
```

## Manual setup

If you prefer not to use the install script, create symlinks manually:

```bash
# Install Oh My Zsh first
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/install.sh)"

# Install Oh My Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions

# Create symlinks
ln -sf ~/dotfiles/ghostty ~/.config/ghostty
ln -sf ~/dotfiles/atuin ~/.config/atuin
ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/neofetch ~/.config/neofetch
ln -sf ~/dotfiles/hammerspoon ~/.hammerspoon
ln -sf ~/dotfiles/vimrc ~/.vimrc
```

## Machine-Specific Configuration

The `zshrc` file contains universal configuration that works on all machines. For machine-specific overrides (work configs, API keys, company-specific paths, etc.), create a `~/.zshrc.local` file which will be automatically sourced at the end of `.zshrc`.

### Use Cases for `~/.zshrc.local`:
- Work-specific environment variables and paths
- Company-specific tooling and aliases
- API keys and authentication tokens
- Machine-specific performance tweaks

### Example Setup:

**Work Machine:**
```bash
# Create ~/.zshrc.local with work-specific config
export JAVA_HOME=/path/to/work/java
export AWS_PROFILE=work-profile
alias deploy='./work-deploy-script.sh'
```

**Personal Machine:**
```bash
# Create ~/.zshrc.local with personal overrides
export ANTHROPIC_API_KEY="your-personal-key"
alias projects='cd ~/personal-projects'
```

This file is **not tracked** in the repository - keep it local to each machine.

## Tmux Usage

Tmux is configured with Catppuccin Mocha theme and useful plugins. The prefix key is `Ctrl+a`.

### Essential Key Bindings:

**Window & Pane Management:**
- `Ctrl+a v` - Split pane vertically
- `Ctrl+a s` - Split pane horizontally
- `Ctrl+a h/j/k/l` - Navigate panes (Vim-style)
- `Ctrl+a c` - Create new window
- `Ctrl+a 1-9` - Switch to window by number
- `Ctrl+a x` - Kill current pane
- `Ctrl+a w` - Kill current window
- `Ctrl+a z` - Zoom/unzoom current pane

**Session Management:**
- `Ctrl+a d` - Detach from session
- `Ctrl+a Ctrl+s` - Choose session
- `tmux new -s name` - Create named session
- `tmux attach -t name` - Attach to session
- `tmux ls` - List sessions

**Copy Mode (Vim-style):**
- `Ctrl+a [` - Enter copy mode
- `v` - Begin selection
- `y` - Copy selection
- `Ctrl+a p` - Paste

**Utilities:**
- `Ctrl+a r` - Reload config
- `Ctrl+a I` - Install plugins (after first setup)
- `Ctrl+a U` - Update plugins

### Installed Plugins:
- **tmux-resurrect** - Save/restore sessions
- **tmux-continuum** - Auto-save sessions every 15 minutes
- **tmux-yank** - Better copy/paste integration
- **catppuccin/tmux** - Beautiful Catppuccin theme

### Recommended Workflow:

Use one terminal tab with tmux for your entire workspace:
```bash
# Start tmux
tmux new -s work

# Create panes:
# - Pane 1: Neovim for editing
# - Pane 2: Running dev server
# - Pane 3: Git commands
# - Pane 4: Monitoring/logs

# Split panes as needed with Ctrl+a v or Ctrl+a s
# Navigate with Ctrl+a h/j/k/l
```

**Benefits:**
- .zshrc loads only once (faster than multiple tabs)
- Session persistence (survives terminal crashes)
- Better workspace organization
