# Dotfiles

Personal configuration files synced between work and personal machines.

## Contents

- **ghostty/** - Ghostty terminal config
- **atuin/** - Shell history sync config
- **starship.toml** - Starship prompt config
- **zshrc** - Zsh configuration (work-specific items filtered out)
- **neofetch/** - Neofetch system info config
- **hammerspoon/** - Hammerspoon automation config
- **vimrc** - Vim configuration
- **bat/** - Bat (cat replacement) config with Catppuccin theme

Note: Oh My Zsh and its plugins are installed automatically by the install script.

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
