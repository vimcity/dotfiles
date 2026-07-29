#!/bin/bash
# Dotfiles installation script
# Supports macOS and Debian/Ubuntu server installs

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
IS_MAC=0
IS_LINUX=0

if [ "$OS" = "Darwin" ]; then
	IS_MAC=1
elif [ "$OS" = "Linux" ]; then
	IS_LINUX=1
	if [ ! -f /etc/os-release ]; then
		echo "Cannot detect Linux distribution. Exiting."
		exit 1
	fi
	source /etc/os-release
	if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
		echo "Unsupported Linux: $PRETTY_NAME. Use Debian or Ubuntu."
		exit 1
	fi
else
	echo "Unsupported OS: $OS"
	exit 1
fi

if [ "$IS_LINUX" -eq 1 ] && [ "$EUID" -ne 0 ] && [ -z "${SUDO_USER:-}" ]; then
	echo "On Linux, run this script with sudo."
	exit 1
fi

USER_NAME="${SUDO_USER:-$USER}"
HOME_DIR="$(eval echo "~$USER_NAME")"

if [ "$IS_MAC" -eq 1 ]; then
	QUTE_CONFIG_DIR="$HOME/.qutebrowser"
	QUTE_DATA_DIR="$HOME/Library/Application Support/qutebrowser"
else
	QUTE_CONFIG_DIR="$HOME_DIR/.config/qutebrowser"
	QUTE_DATA_DIR="$HOME_DIR/.local/share/qutebrowser"
fi

echo "🔧 Installing dotfiles on $OS..."

remove_if_exists() {
	if [ -L "$1" ]; then
		echo "󰔌 Removing existing symlink $1"
		rm "$1"
	elif [ -e "$1" ]; then
		echo "󰆴 Removing existing $1"
		rm -rf "$1"
	fi
}

run_as_user() {
	if [ "$IS_MAC" -eq 1 ]; then
		"$@"
	else
		su - "$USER_NAME" -c "$*"
	fi
}

# ============================================================================
# Oh My Zsh + plugins
# ============================================================================
install_ohmyzsh() {
	local target_home="${1:-$HOME}"
	if [ ! -d "$target_home/.oh-my-zsh" ]; then
		echo "󰇚 Installing Oh My Zsh..."
		if [ "$IS_LINUX" -eq 1 ]; then
			su - "$USER_NAME" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/install.sh)" "" --unattended'
		else
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		fi
	else
		echo "󰄵 Oh My Zsh already installed"
	fi
}

install_ohmyzsh "$HOME_DIR"

ZSH_CUSTOM="$HOME_DIR/.oh-my-zsh/custom"

install_omz_plugin() {
	local repo="$1"
	local dest="$2"
	if [ ! -d "$dest" ]; then
		echo "  󰌶 Installing $(basename "$dest")..."
		run_as_user git clone --depth=1 "https://github.com/$repo" "$dest"
	else
		echo "  󰄵 $(basename "$dest") already installed"
	fi
}

install_omz_plugin "zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
install_omz_plugin "zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions"
install_omz_plugin "zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ============================================================================
# TPM
# ============================================================================
if [ ! -d "$HOME_DIR/.tmux/plugins/tpm" ]; then
	echo "󰌶 Installing TPM (Tmux Plugin Manager)..."
	run_as_user git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME_DIR/.tmux/plugins/tpm"
else
	echo "󰄵 TPM already installed"
fi

# ============================================================================
# OS-specific package installation
# ============================================================================
if [ "$IS_MAC" -eq 1 ]; then
	echo "󰌶 Installing macOS tools via Homebrew..."
	for formula in lazygit lazydocker git-delta yt-dlp fzf jq chafa rbw; do
		if brew list "$formula" &>/dev/null; then
			echo "󰄵 $formula already installed"
		else
			echo "󰌶 Installing $formula..."
			brew install "$formula"
		fi
	done

else
	echo "󰌶 Updating system..."
	apt-get update
	apt-get upgrade -y

	echo "󰌶 Installing base server packages..."
	BASE_PACKAGES=(
		openssh-server
		curl
		wget
		git
		zsh
		tmux
		neovim
		htop
		btop
		ncdu
		rsync
		syncthing
		build-essential
		python3
		python3-pip
		python3-venv
		nodejs
		npm
		unzip
		jq
		ca-certificates
		gnupg
		lsb-release
		software-properties-common
		apt-transport-https
		file
		xclip
		ntfs-3g
	)

	if [ "$ID" = "ubuntu" ]; then
		add-apt-repository -y universe
	fi

	apt-get update
	apt-get install -y "${BASE_PACKAGES[@]}"

	echo "󰌶 Installing modern CLI tools..."
	MODERN_TOOLS=(
		aria2
		atuin
		bat
		btop
		eza
		fastfetch
		fd-find
		fzf
		git-delta
		htop
		jq
		lazygit
		lazydocker
		ripgrep
		shellcheck
		syncthing
		yazi
		zoxide
	)

	missing_tools=()
	for pkg in "${MODERN_TOOLS[@]}"; do
		if apt-cache show "$pkg" >/dev/null 2>&1; then
			apt-get install -y "$pkg"
		else
			missing_tools+=("$pkg")
			echo "  $pkg not available in apt, skipping"
		fi
	done

	if [ ${#missing_tools[@]} -gt 0 ]; then
		echo ""
		echo "Missing tools: ${missing_tools[*]}"
	fi

	echo "󰌶 Installing Docker..."
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL "https://download.docker.com/linux/$ID/gpg" |
		gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	chmod a+r /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/$ID $VERSION_CODENAME stable" \
		>/etc/apt/sources.list.d/docker.list
	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	usermod -aG docker "$USER_NAME"

	echo "󰌶 Setting up Linux clipboard wrappers..."
	mkdir -p "$HOME_DIR/.local/bin"
	if ! command -v pbcopy >/dev/null 2>&1; then
		cat >"$HOME_DIR/.local/bin/pbcopy" <<'EOF'
#!/bin/sh
xclip -selection clipboard
EOF
		chmod +x "$HOME_DIR/.local/bin/pbcopy"
	fi
	if ! command -v pbpaste >/dev/null 2>&1; then
		cat >"$HOME_DIR/.local/bin/pbpaste" <<'EOF'
#!/bin/sh
xclip -selection clipboard -o
EOF
		chmod +x "$HOME_DIR/.local/bin/pbpaste"
	fi
	chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.local"
fi

# ============================================================================
# Common dotfile symlinks
# ============================================================================
echo "󰔌 Creating symlinks..."

mkdir -p "$HOME_DIR/.config"
mkdir -p "$HOME_DIR/.config/lazygit"
mkdir -p "$HOME_DIR/.config/btop/themes"
mkdir -p "$HOME_DIR/.config/herdr"
mkdir -p "$HOME_DIR/.config/herdr/plugins/config/persiyanov.reviewr"
mkdir -p "$HOME_DIR/.config/tailspin"
mkdir -p "$HOME_DIR/.pi/agent"

if [ "$IS_MAC" -eq 1 ]; then
	mkdir -p "$HOME/Library/Application Support/lazygit"
	mkdir -p "$HOME/.config/opencode"
	mkdir -p "$QUTE_CONFIG_DIR"
	mkdir -p "$QUTE_DATA_DIR/userscripts"
	mkdir -p "$HOME/.pi/agent"
fi

if [ "$IS_LINUX" -eq 1 ]; then
	chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.config" "$HOME_DIR/.local" 2>/dev/null || true
fi

link_dotfile() {
	local src="$1"
	local dest="$2"
	if [ ! -e "$src" ]; then
		echo "  Source missing, skipping: $src"
		return
	fi
	remove_if_exists "$dest"
	run_as_user ln -sf "$src" "$dest"
}

link_dotfile "$DOTFILES_DIR/zshrc" "$HOME_DIR/.zshrc"
link_dotfile "$DOTFILES_DIR/vimrc" "$HOME_DIR/.vimrc"
link_dotfile "$DOTFILES_DIR/tmux/tmux.conf" "$HOME_DIR/.tmux.conf"
link_dotfile "$DOTFILES_DIR/tmux-cht-languages" "$HOME_DIR/.tmux-cht-languages"
link_dotfile "$DOTFILES_DIR/tmux-cht-commands" "$HOME_DIR/.tmux-cht-commands"
link_dotfile "$DOTFILES_DIR/lazygit-config.yml" "$HOME_DIR/.config/lazygit/config.yml"
link_dotfile "$DOTFILES_DIR/fdignore" "$HOME_DIR/.fdignore"
link_dotfile "$DOTFILES_DIR/bin" "$HOME_DIR/.local/scripts"
link_dotfile "$DOTFILES_DIR/btop/themes/catppuccin-rose" "$HOME_DIR/.config/btop/themes/catppuccin-rose"

# Pi coding-agent configuration. Keep credentials, sessions, and runtime state local.
if [ -d "$DOTFILES_DIR/pi" ]; then
	mkdir -p "$HOME_DIR/.pi/agent"
	link_dotfile "$DOTFILES_DIR/pi/extensions" "$HOME_DIR/.pi/agent/extensions"
	link_dotfile "$DOTFILES_DIR/pi/themes" "$HOME_DIR/.pi/agent/themes"
	link_dotfile "$DOTFILES_DIR/pi/keybindings.json" "$HOME_DIR/.pi/agent/keybindings.json"
	# Don't overwrite existing settings — keeps machine-specific provider/model config
	if [ ! -f "$HOME_DIR/.pi/agent/settings.json" ]; then
		cp "$DOTFILES_DIR/pi/settings.json" "$HOME_DIR/.pi/agent/settings.json"
	fi
	link_dotfile "$DOTFILES_DIR/pi/SYSTEM.md" "$HOME_DIR/.pi/agent/SYSTEM.md"
fi

if [ -d "$DOTFILES_DIR/nvim" ]; then
	remove_if_exists "$HOME_DIR/.config/nvim"
	link_dotfile "$DOTFILES_DIR/nvim" "$HOME_DIR/.config/nvim"
fi

if [ -d "$DOTFILES_DIR/atuin" ]; then
	remove_if_exists "$HOME_DIR/.config/atuin"
	link_dotfile "$DOTFILES_DIR/atuin" "$HOME_DIR/.config/atuin"
fi

if [ -d "$DOTFILES_DIR/fastfetch" ]; then
	remove_if_exists "$HOME_DIR/.config/fastfetch"
	link_dotfile "$DOTFILES_DIR/fastfetch" "$HOME_DIR/.config/fastfetch"
fi

if [ -f "$DOTFILES_DIR/herdr/config.toml" ]; then
	link_dotfile "$DOTFILES_DIR/herdr/config.toml" "$HOME_DIR/.config/herdr/config.toml"
fi

if [ -f "$DOTFILES_DIR/herdr/reviewr.toml" ]; then
	link_dotfile "$DOTFILES_DIR/herdr/reviewr.toml" "$HOME_DIR/.config/herdr/plugins/config/persiyanov.reviewr/config.toml"
fi

if [ -f "$DOTFILES_DIR/tailspin/theme.toml" ]; then
	link_dotfile "$DOTFILES_DIR/tailspin/theme.toml" "$HOME_DIR/.config/tailspin/theme.toml"
fi

# ============================================================================
if [ -d "$DOTFILES_DIR/yazi" ]; then
	remove_if_exists "$HOME_DIR/.config/yazi"
	link_dotfile "$DOTFILES_DIR/yazi" "$HOME_DIR/.config/yazi"
fi

# macOS-only symlinks
# ============================================================================
if [ "$IS_MAC" -eq 1 ]; then
	link_dotfile "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
	link_dotfile "$DOTFILES_DIR/mpv" "$HOME/.config/mpv"
	link_dotfile "$DOTFILES_DIR/lazygit-config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
	link_dotfile "$DOTFILES_DIR/ytui-config" "$HOME/.config/ytui"
	link_dotfile "$DOTFILES_DIR/opencode/plugins" "$HOME/.config/opencode/plugins"
	link_dotfile "$DOTFILES_DIR/opencode/themes" "$HOME/.config/opencode/themes"
	link_dotfile "$DOTFILES_DIR/opencode/tui.json" "$HOME/.config/opencode/tui.json"
	link_dotfile "$DOTFILES_DIR/ghostty/themes" "$HOME/.config/ghostty/themes"
	link_dotfile "$DOTFILES_DIR/qutebrowser/scripts" "$HOME/.local/qute-scripts"
	link_dotfile "$DOTFILES_DIR/qutebrowser/config.py" "$QUTE_CONFIG_DIR/config.py"
	link_dotfile "$DOTFILES_DIR/qutebrowser/greasemonkey" "$QUTE_CONFIG_DIR/greasemonkey"
	link_dotfile "$DOTFILES_DIR/qutebrowser/quickmarks" "$QUTE_CONFIG_DIR/quickmarks"
	for userscript in bw-copy rbw-autofill _rbw-common.sh; do
		link_dotfile "$DOTFILES_DIR/qutebrowser/userscripts/$userscript" "$QUTE_DATA_DIR/userscripts/$userscript"
		chmod +x "$DOTFILES_DIR/qutebrowser/userscripts/$userscript" 2>/dev/null || true
	done

	if [ -d "$DOTFILES_DIR/yazi" ]; then
		remove_if_exists "$HOME/.config/yazi"
		link_dotfile "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"
	fi

	if command -v llm >/dev/null 2>&1; then
		bash "$DOTFILES_DIR/llm/setup.sh"
	fi

	if command -v rbw >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/rbw/configure.sh" ]; then
		bash "$DOTFILES_DIR/rbw/configure.sh"
	fi

	# Pi MCP config (macOS-specific — .pi agent dir handled in common section)
	link_dotfile "$DOTFILES_DIR/pi/mcp.json" "$HOME/.pi/agent/mcp.json"

	# Install context-mode and lean-ctx tooling
	if ! command -v context-mode >/dev/null 2>&1; then
		echo "  󰌶 Installing context-mode..."
		npm install -g context-mode 2>/dev/null || echo "  󰅖 Failed to install context-mode"
	else
		echo "  󰄵 context-mode already installed"
	fi

	if ! command -v lean-ctx >/dev/null 2>&1; then
		echo "  󰌶 Installing lean-ctx..."
		curl -fsSL https://leanctx.com/install.sh | sh 2>/dev/null || echo "  󰅖 Failed to install lean-ctx"
	else
		echo "  󰄵 lean-ctx already installed"
	fi

	# Install npm dependencies for any extension that needs them
	for pi_ext_dir in "$HOME/.pi/agent/extensions/"*/; do
		if [ -f "$pi_ext_dir/package.json" ]; then
			deps=$(python3 -c "import json; d=json.load(open('${pi_ext_dir}package.json')); print(len(d.get('dependencies',{})))" 2>/dev/null || echo "0")
			if [ "$deps" -gt 0 ] && [ ! -d "$pi_ext_dir/node_modules" ]; then
				echo "  󰌶 Installing dependencies for $(basename "$pi_ext_dir")..."
				(cd "$pi_ext_dir" && npm install --silent) 2>/dev/null || echo "  󰅖 Failed to install for $(basename "$pi_ext_dir")"
			fi
		fi
	done

	# Apply catppuccin-rose theme in settings if currently set to dark
	if [ -f "$HOME/.pi/agent/settings.json" ]; then
		current_theme=$(python3 -c "import json; s=json.load(open('$HOME/.pi/agent/settings.json')); print(s.get('theme',''))" 2>/dev/null || echo "")
		if [ "$current_theme" = "dark" ] || [ -z "$current_theme" ]; then
			python3 -c "
import json
path = '$HOME/.pi/agent/settings.json'
s = json.load(open(path))
s['theme'] = 'catppuccin-rose'
s['defaultThinkingLevel'] = 'low'
s['showHardwareCursor'] = True
json.dump(s, open(path, 'w'), indent=2)
" 2>/dev/null && echo "  󰆊 Set Pi theme to catppuccin-rose"
		fi
	fi
fi

# ============================================================================
# Linux server-only setup
# ============================================================================
if [ "$IS_LINUX" -eq 1 ]; then
	LOCAL_ZSHRC="$HOME_DIR/.zshrc.local"
	if [ ! -f "$LOCAL_ZSHRC" ]; then
		echo "󰌶 Creating $LOCAL_ZSHRC with Linux overrides..."
		cat >"$LOCAL_ZSHRC" <<'EOF'
# Server / Linux overrides for macOS dotfiles

export PATH="$HOME/.local/bin:$HOME/.local/scripts:$PATH"

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat=batcat
fi
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd=fdfind
fi

unalias qt 2>/dev/null || true
unalias qtr 2>/dev/null || true
unalias shellmaster 2>/dev/null || true

unset OMLX_BASE_DIR OMLX_MODEL_DIR OMLX_DEFAULT_MODEL

alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
EOF
		chown "$USER_NAME:$USER_NAME" "$LOCAL_ZSHRC"
	fi

	SSHD_CONFIG="/etc/ssh/sshd_config.d/99-hardening.conf"
	if [ ! -f "$SSHD_CONFIG" ]; then
		echo "󰌶 Writing SSH hardening stub to $SSHD_CONFIG..."
		cat >"$SSHD_CONFIG" <<'EOF'
# Hardening applied by install.sh
# PasswordAuthentication no
# PermitRootLogin no
# PubkeyAuthentication yes
EOF
		echo "Uncomment the lines in $SSHD_CONFIG and run: systemctl restart ssh"
	fi

	if [[ "$SHELL" != *"zsh" ]]; then
		echo "󰌶 Changing default shell to zsh for $USER_NAME..."
		chsh -s "$(command -v zsh)" "$USER_NAME"
	fi
fi

echo "󰸞 Dotfiles installed successfully!"
echo ""
if [ "$IS_MAC" -eq 1 ]; then
	echo "󱀭 Optional: Create ~/.zshrc.local for machine-specific configs."
	echo "󰔌 To install Tmux plugins: start tmux, press Ctrl+Space then Shift+I"
else
	echo "Next steps:"
	echo "  1. Log out and back in to pick up the docker group."
	echo "  2. Start tmux and install plugins: Ctrl+Space then Shift+I"
	echo "  3. Open nvim and run :Lazy! sync"
	echo "  4. Review $HOME_DIR/.zshrc.local for Linux-specific overrides."
	echo "  5. Edit /etc/ssh/sshd_config.d/99-hardening.conf, enable key-only auth, restart ssh."
fi
echo ""
