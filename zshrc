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
  # docker
   docker-compose
  # macos
  # python
  # node
  # npm
  # vscode
  # tmux
  # extract
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
# Auto-sync disabled (no cloud account)
# export ATUIN_AUTO_SYNC=1
export ATUIN_SEARCH_MODE=fuzzy
export ATUIN_FILTER_MODE=global

# Initialize atuin with up arrow disabled (use standard zsh history for up/down)
eval "$(atuin init zsh --disable-up-arrow)"
alias ahl="atuin history list"
# Ctrl+R uses atuin search with popup (already set by atuin init)
# Up/down arrows use standard zsh history (default behavior restored)

# Python environment
alias vimz="nvim ~/.zshrc"
alias neo="z ~/Projects && nvim"
alias zz="z"
alias vim="nvim"
export EDITOR="nvim"
export VISUAL="nvim"
alias sdf="source ~/.zshrc"
alias cl=clear
alias vi=vim
alias ls=eza
alias lsa="eza --icons=always -s=time -la"
export PYENV_ROOT=
export PATH="$PYENV_ROOT/shims:$PATH"
export PATH="$HOME/.local/bin:$PATH"
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
# DISABLED 
# eval "$(starship init zsh)"

# Add spacing between prompts (adds blank line before each prompt)
precmd() { print "" }

# fzf configuration (for file search only)
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

# Load fzf key bindings and completion
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# ===========================================
# FD Configuration
# ===========================================
# fd flags are inlined in each function to avoid variable expansion issues with sourcing

# ===========================================
# File Type Detection Functions
# ===========================================
detect_file_type() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "binary"
        return
    fi

    # Check if file is text using mime type
    local mime_type=$(file --mime "$file" 2>/dev/null | cut -d: -f2 | tr -d ' ')
    local mime_primary=$(echo "$mime_type" | cut -d/ -f1)

    if [[ "$mime_primary" == "text" ]] || [[ "$mime_type" == *"charset=utf-8"* ]] || [[ "$mime_type" == *"charset=us-ascii"* ]]; then
        echo "text"
    else
        echo "binary"
    fi
}

smart_preview() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "No file provided"
        return 1
    fi

    if [[ ! -e "$file" ]]; then
        echo "File does not exist: $file"
        return 1
    fi

    local file_type=$(detect_file_type "$file")

    case "$file_type" in
        "text")
            bat --color=always --style=header,grid --line-range :300 "$file" 2>/dev/null || cat "$file" 2>/dev/null || echo "Cannot preview file: $file"
            ;;
        "binary")
            echo "Binary file detected:"
            file "$file"
            echo ""
            echo "Size: $(du -h "$file" 2>/dev/null | cut -f1)"
            echo ""
            echo "First 512 bytes as hex:"
            hexdump -C "$file" | head -n 10
            ;;
        *)
            echo "Unknown file type for: $file"
            file "$file"
            ;;
    esac
}

open_file() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "No file provided"
        return 1
    fi

    if [[ ! -e "$file" ]]; then
        echo "File does not exist: $file"
        return 1
    fi

    local file_type=$(detect_file_type "$file")

    case "$file_type" in
        "text")
            # Open text files in the default editor
            ${EDITOR:-nvim} "$file"
            ;;
        "binary")
            # For binary files, try to open with the system's default application
            case "$(uname -s)" in
                Darwin*)
                    open "$file" 2>/dev/null || xdg-open "$file" 2>/dev/null || echo "Could not open binary file: $file"
                    ;;
                *)
                    xdg-open "$file" 2>/dev/null || open "$file" 2>/dev/null || echo "Could not open binary file: $file"
                    ;;
            esac
            ;;
        *)
            # Unknown file type - try to open with default application
            case "$(uname -s)" in
                Darwin*)
                    open "$file" 2>/dev/null || xdg-open "$file" 2>/dev/null || echo "Could not open file: $file"
                    ;;
                *)
                    xdg-open "$file" 2>/dev/null || open "$file" 2>/dev/null || echo "Could not open file: $file"
                    ;;
            esac
            ;;
    esac
}

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

# ===========================================
# Keyboard Shortcuts for fzf Preview Navigation
# ===========================================

# Interactive file finder with keyboard scrolling
# Usage: ff [path] - Search from current directory by default, or specify path
ff() {
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview-window=right:60% \
              --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}' \
              --bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
              --bind 'ctrl-y:preview-up,ctrl-e:preview-down'
}

# Interactive directory finder
# Usage: fdir [path] - Search from current directory by default, or specify path
fdir() {
    fd --type d --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview "eza --tree --level=2 --icons {}"
}

# Find and open file in editor
# Usage: ffe [path] - Search from current directory by default, or specify path
ffe() {
    local file=$(fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}')
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# Find and open file with system default app
# Usage: fo [path] - Search from current directory by default, or specify path
fo() {
    local file=$(fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}')
    [[ -n "$file" ]] && open_file "$file"
}

alias gcof='git checkout $(git branch | fzf | sed "s/^[ *]*//")'
alias gbdf='git branch -d $(git branch | fzf | sed "s/^[ *]*//")'

# Open lazygit with commits panel focused
alias glog='lazygit log'
alias lz='lazygit'

# ===========================================
# Enhanced fd Helper Functions
# ===========================================

# Find files by extension with preview
# Usage: fde <extension> [path]
fde() {
    [[ $# -eq 0 ]] && { echo "Usage: fde <extension> [path]"; return 1; }
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --extension "$1" "${2:-.}" \
        | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}'
}

# Find recently modified files
# Usage: fdm <time> [path] (e.g., 1h, 1d, 1w)
fdm() {
    [[ $# -eq 0 ]] && { echo "Usage: fdm <time> [path] (e.g., 1h, 1d, 1w)"; return 1; }
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --changed-within "$1" "${2:-.}"
}

# Find files by pattern
# Usage: fdf <pattern> [path]
fdf() {
    [[ $# -eq 0 ]] && { echo "Usage: fdf <pattern> [path]"; return 1; }
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "$1" "${2:-.}"
}

# Find empty files
# Usage: fdempty [path]
fdempty() {
    fd --type empty --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}"
}

# Find files at depth 1 only
# Usage: fdc [path]
fdc() {
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --max-depth 1 "${1:-.}"
}

# Ripgrep configuration
alias rg='rg --smart-case --ignore-file ~/dotfiles/rgignore'

# Modern terminal tools
alias cat='bat'
# Pretty man pages with bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# bat will automatically use less as a pager for large files
export BAT_PAGER="less -RF"
export BAT_THEME="Catppuccin Macchiato"
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

# Claude Code config 
alias clont='claude --continue'  # Resume latest chat
export USE_BUILTIN_RIPGREP=0

# OpenCode shortcuts
export OPENCODE_CONFIG="$HOME/opencode.json"  # Point to OpenCode config
alias oc='opencode'  # Quick access to OpenCode

# OpenCode pipe function - analyze command output with AI
ocprompt() {
  # local model="${1:-github-copilot/gpt-4.1}"
  local prompt="${1:-Analyze and summarize this output.}"
  local input=$(cat)
  local model="anthropic/claude-haiku-4-5"
  if [ -z "$PERSONAL" is 0 ]; then
      model="github-copilot/gpt-4.1-personal"
  fi
  # Run opencode and render markdown output with glow (using global config style)
  echo "$input" | opencode run -m "$model" "Be concise. $prompt"
}

olparse() {
  local model="${1:-llama3.2:latest}"
  local prompt="${2:-Analyze and summarize this output.}"
  local input=$(cat)
  
  # Run ollama and render markdown output with glow (using global config style)
  echo "$input" | ollama run $model "Be concise. $prompt" | glow -p
}

alias ocp='ocprompt'
alias ocl='olprompt'

# Usage examples:
# docker ps | ocparse
# npm test | ocparse
# git log | ocparse "github/gpt-4.1" "Summarize these commits"
# cat error.log | ocparse "github/gpt-4.1" "Find the root cause of errors"

# ===========================================
# Machine-Specific Configuration
# ===========================================
# Source local configuration if it exists
# Use this file for machine-specific overrides, work configs, API keys, etc.
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

#fastfetch
alias ffs='fastfetch'
killer() { kill $(lsof -t -i:$1); }

# ===========================================
# Git Worktree Aliases
# ===========================================
alias gwl='git worktree list'
alias gwr='git worktree remove'
alias gwp='git worktree prune'

# Smart aliases that auto-create path from branch name
gwab() { git worktree add -b "$1" "../$1"; }  # new branch
gwa() { git worktree add "../$1" "$1"; }      # existing branch

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

alias vimlocal="nvim ~/.zshrc.local"
alias fabric="fabric-ai"
alias fab="fabric-ai"
alias mvnds="mvn eclipse:clean eclipse:eclipse -DdownloadSources=true"

