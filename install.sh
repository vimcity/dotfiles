#!/bin/bash
# Dotfiles installation script

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname -s)" = "Darwin" ]; then
    QUTE_CONFIG_DIR="$HOME/.qutebrowser"
    QUTE_DATA_DIR="$HOME/Library/Application Support/qutebrowser"
else
    QUTE_CONFIG_DIR="$HOME/.config/qutebrowser"
    QUTE_DATA_DIR="$HOME/.local/share/qutebrowser"
fi

echo "🔧 Installing dotfiles..."

# Remove existing configs before relinking
remove_if_exists() {
    if [ -L "$1" ]; then
        echo "🔗 Removing existing symlink $1"
        rm "$1"
    elif [ -e "$1" ]; then
        echo "🗑️ Removing existing $1"
        rm -rf "$1"
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
for formula in lazygit lazydocker git-delta; do
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

# Remove existing files
remove_if_exists "$HOME/.config/ghostty"
remove_if_exists "$HOME/.config/atuin"
remove_if_exists "$HOME/.config/btop/themes/catppuccin-frappe.theme"
remove_if_exists "$HOME/.config/starship.toml"
remove_if_exists "$HOME/.vimrc"
remove_if_exists "$HOME/.zshrc"
remove_if_exists "$HOME/.tmux.conf"
remove_if_exists "$HOME/.fdignore"
remove_if_exists "$HOME/.config/lazygit/config.yml"
remove_if_exists "$HOME/Library/Application Support/lazygit/config.yml"
remove_if_exists "$QUTE_CONFIG_DIR/config.py"
remove_if_exists "$QUTE_CONFIG_DIR/greasemonkey"
remove_if_exists "$QUTE_CONFIG_DIR/quickmarks"
remove_if_exists "$QUTE_DATA_DIR/userscripts/bw-copy"

if [ -d "$DOTFILES_DIR/yazi" ]; then
    remove_if_exists "$HOME/.config/yazi"
fi

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/lazygit"
mkdir -p "$HOME/Library/Application Support/lazygit"
mkdir -p "$HOME/.config/btop/themes"
mkdir -p "$HOME/.config/opencode"
mkdir -p "$QUTE_CONFIG_DIR"
mkdir -p "$QUTE_DATA_DIR/userscripts"

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/atuin" "$HOME/.config/atuin"
ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES_DIR/lazygit-config.yml" "$HOME/.config/lazygit/config.yml"
ln -sf "$DOTFILES_DIR/lazygit-config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
ln -sf "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/fdignore" "$HOME/.fdignore"
ln -sf "$DOTFILES_DIR/bin" "$HOME/.local/scripts"
ln -sf "$DOTFILES_DIR/tmux-cht-languages" "$HOME/.tmux-cht-languages"
ln -sf "$DOTFILES_DIR/tmux-cht-commands" "$HOME/.tmux-cht-commands"
ln -sf "$DOTFILES_DIR/btop/themes/catppuccin-frappe.theme" "$HOME/.config/btop/themes/catppuccin-frappe.theme"
ln -sf "$DOTFILES_DIR/opencode/plugins" "$HOME/.config/opencode/plugins"

if [ -d "$DOTFILES_DIR/yazi" ]; then
    echo "📁 Found yazi config in dotfiles, linking..."
    ln -sf "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"
fi

# qutebrowser (config + userscripts + greasemonkey + quickmarks)
ln -sf "$DOTFILES_DIR/qutebrowser/config.py" "$QUTE_CONFIG_DIR/config.py"
ln -sf "$DOTFILES_DIR/qutebrowser/greasemonkey" "$QUTE_CONFIG_DIR/greasemonkey"
ln -sf "$DOTFILES_DIR/qutebrowser/quickmarks" "$QUTE_CONFIG_DIR/quickmarks"
ln -sf "$DOTFILES_DIR/qutebrowser/userscripts/bw-copy" "$QUTE_DATA_DIR/userscripts/bw-copy"

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
