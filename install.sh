#!/bin/bash
# Dotfiles installation script

set -e

echo "🔧 Installing dotfiles..."

# Backup existing configs
backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        echo "📦 Backing up $1 to $backup_dir"
        mv "$1" "$backup_dir/"
    elif [ -L "$1" ]; then
        echo "🔗 Removing existing symlink $1"
        rm "$1"
    fi
}

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/install.sh)" "" --unattended
else
    echo "✓ Oh My Zsh already installed"
fi

# Install Oh My Zsh plugins
echo "📦 Installing Oh My Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "  - Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "  ✓ zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "  - Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "  ✓ zsh-syntax-highlighting already installed"
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    echo "  - Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo "  ✓ zsh-completions already installed"
fi

# Backup existing files
backup_if_exists "$HOME/.config/ghostty"
backup_if_exists "$HOME/.config/atuin"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/neofetch"
backup_if_exists "$HOME/.hammerspoon"
backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.fdignore"

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf "$HOME/dotfiles/ghostty" "$HOME/.config/ghostty"
ln -sf "$HOME/dotfiles/atuin" "$HOME/.config/atuin"
ln -sf "$HOME/dotfiles/bat" "$HOME/.config/bat"
ln -sf "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$HOME/dotfiles/neofetch" "$HOME/.config/neofetch"
ln -sf "$HOME/dotfiles/hammerspoon" "$HOME/.hammerspoon"
ln -sf "$HOME/dotfiles/vimrc" "$HOME/.vimrc"
ln -sf "$HOME/dotfiles/zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$HOME/dotfiles/fdignore" "$HOME/.fdignore"

echo "✅ Dotfiles installed successfully!"
echo ""
echo "📝 Optional: Create ~/.zshrc.local for machine-specific configs:"
echo "   - Work-specific environment variables and paths"
echo "   - API keys and authentication tokens"
echo "   - Company-specific tooling and aliases"
echo "   - Machine-specific performance tweaks"
echo ""
echo "   This file will be automatically sourced by .zshrc if it exists."
echo ""
if [ -d "$backup_dir" ] && [ "$(ls -A $backup_dir)" ]; then
    echo "💾 Original configs backed up to: $backup_dir"
fi
