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

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "📦 Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "✓ TPM already installed"
fi

# Install tools via brew
for formula in lazydocker; do
    if brew list "$formula" &> /dev/null; then
        echo "✓ $formula already installed"
    else
        echo "📦 Installing $formula..."
        brew install "$formula"
    fi
done

# Install tools from custom taps
echo "📦 Installing tools from custom taps..."

# taproom from gromgit/brewtils
if brew list "taproom" &> /dev/null; then
    echo "✓ taproom already installed"
else
    echo "  - Installing taproom..."
    brew install gromgit/brewtils/taproom
fi

# llmfit from AlexsJones/llmfit
if brew list "llmfit" &> /dev/null; then
    echo "✓ llmfit already installed"
else
    echo "  - Installing llmfit..."
    brew tap AlexsJones/llmfit
    brew install llmfit
fi

# models from arimxyer/tap
if brew list "models" &> /dev/null; then
    echo "✓ models already installed"
else
    echo "  - Installing models..."
    brew tap arimxyer/tap
    brew install models
fi

# Backup existing files
backup_if_exists "$HOME/.config/ghostty"
backup_if_exists "$HOME/.config/atuin"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.fdignore"
backup_if_exists "$HOME/.config/lazygit/config.yml"

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/lazygit"

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf "$HOME/dotfiles/ghostty" "$HOME/.config/ghostty"
ln -sf "$HOME/dotfiles/atuin" "$HOME/.config/atuin"
ln -sf "$HOME/dotfiles/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$HOME/dotfiles/lazygit-config.yml" "$HOME/.config/lazygit/config.yml"
ln -sf "$HOME/dotfiles/vimrc" "$HOME/.vimrc"
ln -sf "$HOME/dotfiles/zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$HOME/dotfiles/fdignore" "$HOME/.fdignore"
ln -sf "$HOME/dotfiles/bin" "$HOME/.local/scripts"
ln -sf "$HOME/dotfiles/tmux-cht-languages" "$HOME/.tmux-cht-languages"
ln -sf "$HOME/dotfiles/tmux-cht-commands" "$HOME/.tmux-cht-commands"

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
echo "🔌 To install Tmux plugins:"
echo "   1. Start tmux: tmux"
echo "   2. Press: Ctrl+Space then Shift+I (capital i)"
echo "   3. Wait for plugins to install"
echo ""
if [ -d "$backup_dir" ] && [ "$(ls -A $backup_dir)" ]; then
    echo "💾 Original configs backed up to: $backup_dir"
fi
