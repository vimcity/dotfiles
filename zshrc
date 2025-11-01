# ===========================================
# Oh My Zsh Configuration
# ===========================================
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
export ZSH_CACHE_DIR="$ZSH/cache"
export ZSH_COMPDUMP="$ZSH/cache/.zcompdump-$HOST"
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
export ZSH_DISABLE_COMPFIX=true

# ===========================================
# Shell Behavior Toggles
# ===========================================
export CASE_SENSITIVE="false"
export ENABLE_CORRECTION="true"
export HYPHEN_INSENSITIVE="true"
export DISABLE_MAGIC_FUNCTIONS="true"
export DISABLE_LS_COLORS="false"
export INSIDE_EMACS=""

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  # zsh-completions
   docker
   docker-compose
  # brew
  # macos
  # python
  # node
  # npm
  # yarn
  # vscode
  # sublime
  # tmux
  # colored-man-pages
  # command-not-found
  # extract
  # web-search
  # copyfile
  # copypath
  # dirhistory
  # z
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Oh My Zsh completions
autoload -U compinit && compinit

# ===========================================
# Zsh History Configuration
# ===========================================
# Standard zsh history for current session
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# ===========================================
# Atuin Configuration (Ctrl+R only)
# ===========================================
# Enable auto-sync for cross-shell history
export ATUIN_AUTO_SYNC=1
export ATUIN_SEARCH_MODE=fuzzy
export ATUIN_FILTER_MODE=global

# Initialize atuin with up arrow disabled (use standard zsh history for up/down)
eval "$(atuin init zsh --disable-up-arrow)"
alias ahl="atuin history list"
# Ctrl+R uses atuin search with popup (already set by atuin init)
# Up/down arrows use standard zsh history (default behavior restored)
export BAT_THEME="Catppuccin-mocha"

# Python environment
alias vimz="nvim ~/.zshrc"
alias vim="nvim"
alias sourz="source ~/.zshrc"
alias sz="source ~/.zshrc"
alias vi=vim
alias ls=eza
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
# Lazy load pyenv to avoid slow shell startup
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init - --no-rehash)"
fi

# Python utilities
alias pipr="pip install -r requirements.txt"
alias vnvinit="python -m venv venv"
alias vnva="source venv/bin/activate"

# Zoxide - smarter cd
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# fzf configuration (for file search only)
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

# ===========================================
# Search & Navigation Shortcuts
# ===========================================
search-in-files() {
    if [ $# -eq 0 ]; then
        echo "Usage: search-in-files <pattern> [directory]"
        return 1
    fi
    local pattern="$1"
    local dir="${2:-.}"
    rg --smart-case --line-number --with-filename "$pattern" "$dir" | fzf --preview 'bat --color=always --style=header,grid --line-range {2}:{3} {1}'
}

alias sif='search-in-files'
alias ff='fd --type f --hidden --exclude .git | fzf --preview "bat --color=always --style=header,grid --line-range :300 {}"'
alias fdir='fd --type d --hidden --exclude .git | fzf --preview "eza --tree --level=2 --icons {}"'
alias ffe='fd --type f --hidden --exclude .git | fzf --preview "bat --color=always --style=header,grid --line-range :300 {}" | xargs ${EDITOR:-vim}'
alias gcof='git checkout $(git branch | fzf | sed "s/^[ *]*//")'
alias gbdf='git branch -d $(git branch | fzf | sed "s/^[ *]*//")'

# Interactive git log browser with fzf
fzf-git-log() {
    git log --oneline --graph --decorate --all | fzf --preview 'git show --stat {1}' | cut -d' ' -f1 | xargs git show
}
alias glog='fzf-git-log'

# fd helpers with ignore rules
alias fdf='fd --ignore-file ~/.fdignore --search-path ~'
alias fde='fd --ignore-file ~/.fdignore --search-path ~ --extension'
alias fdn='fd --ignore-file ~/.fdignore --search-path ~ --name'
alias fdt='fd --ignore-file ~/.fdignore --search-path ~ --type'
alias fdi='fd --ignore-file ~/.fdignore --search-path ~ --ignore-case'
alias fdl='fd --ignore-file ~/.fdignore --search-path ~ --list-details'
alias fdex='fd --ignore-file ~/.fdignore --search-path ~ --exec'
alias fdc='fd --ignore-file ~/.fdignore --max-depth 1'
alias fdp='fd --ignore-file ~/.fdignore --search-path ~ --perm'
alias fdm='fd --ignore-file ~/.fdignore --search-path ~ --changed-within'
alias fds='fd --ignore-file ~/.fdignore --search-path ~ --size'
alias fdempty='fd --ignore-file ~/.fdignore --search-path ~ --type empty'

# Ripgrep configuration
alias rg='rg --ignore-file ~/dotfiles/rgignore'

# Modern terminal tools
alias cat='bat'
alias less='bat'
alias more='bat'
alias ll='eza -la --git --icons'
alias la='eza -a --icons'
alias lt='eza --tree --level=2 --icons'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias psg='ps aux | grep'
alias c='clear'
alias find='fd'

# Quick directory navigation
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'

# GitHub Copilot CLI shortcuts
alias gcs='gh copilot suggest'
alias gce='gh copilot explain'

# Claude Code shortcuts
alias clont='claude --continue'  # Resume latest chat

# OpenCode shortcuts
alias oc='opencode'  # Quick access to OpenCode
export OPENCODE_CONFIG="$HOME/dotfiles/opencode.json"

# ===========================================
# Machine-Specific Configuration
# ===========================================
# Source local configuration if it exists
# Use this file for machine-specific overrides, work configs, API keys, etc.
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

#fastfetch

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section
alias brain='killall NordVPN 2>/dev/null; tailscale up; echo "🧠 Brain mode active"'
alias browse='tailscale down; open -a NordVPN; echo "🌐 Browse mode - click Connect in NordVPN"'

