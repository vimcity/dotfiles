 # zmodload zsh/zprof
# ===========================================
# Terminal & Color Support
# ===========================================
# Force true color support (24-bit RGB) for tmux and neovim
export COLORTERM=truecolor

# Homebrew - must be before OMZ so fpath is consistent across login and non-login shells
# (tmux panes are non-login; without this, fpath differs and zcompdump rebuilds every pane)
eval "$(/opt/homebrew/bin/brew shellenv)"


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

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-policy _omz_cache_policy

# Shadow compinit so OMZ reuses the cached dump on normal startups.
# `-C` skips the expensive rebuild/security checks and `-D` avoids rewriting
# the dump file every shell. If the dump is missing, fall back to a full build.
autoload -Uz compinit
compinit() {
  unfunction compinit
  autoload -Uz compinit
  if [[ -f "$ZSH_COMPDUMP" ]]; then
    compinit -C -D -d "$ZSH_COMPDUMP"
  else
    compinit -d "$ZSH_COMPDUMP"
  fi
}

# Stub zrecompile - .zwc from last full build is still valid, no need to recompile every start
zrecompile() { : }

# ===========================================
# Shell Behavior Toggles
# ===========================================
export CASE_SENSITIVE="false"
export ENABLE_CORRECTION="true"
export HYPHEN_INSENSITIVE="true"
export DISABLE_MAGIC_FUNCTIONS="true"
# eza handles colors, skip OMZ's ls detection
export DISABLE_LS_COLORS="true"  
export INSIDE_EMACS=""

# Theme
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  # docker
  docker-compose
  # macos
  brew
  # python
  # node
  # npm
  # tmux
  # extract
  # copyfile
  copypath
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ===========================================
# Prompt
# ===========================================
setopt PROMPT_SUBST
zmodload zsh/datetime

ZSH_THEME_GIT_PROMPT_PREFIX=" %F{#7287fd} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED=" %F{#a6d189}●%f"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %F{#e5c890}✚%f"
ZSH_THEME_GIT_PROMPT_DELETED=" %F{#e78284}✖%f"
ZSH_THEME_GIT_PROMPT_RENAMED=" %F{#8caaee}➜%f"
ZSH_THEME_GIT_PROMPT_UNMERGED=" %F{#e78284}═%f"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %F{#ef9f76}◌%f"

ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX=" %F{#8CA0E8}⇡%f"
ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX=""
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX=" %F{#6c76c2}⇣%f"
ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX=""

typeset -gF PROMPT_CMD_START=0
typeset -g PROMPT_LAST_DURATION=''

prompt_segment() {
    local bg="$1"
    local fg="$2"
    local text="$3"
    print -n "%K{$bg}%F{$fg} ${text} %f%k"
}

prompt_context_segment() {
    if [[ -n "$SSH_CONNECTION" || "$EUID" -eq 0 ]]; then
        prompt_segment '#414559' '#c6d0f5' '%n'
    fi
}

prompt_dir_display() {
    local path="$PWD"

    if [[ "$path" == "$HOME" ]]; then
        print -r -- "~"
        return
    fi

    if [[ "$path" != "$HOME"/* ]]; then
        print -r -- "$path"
        return
    fi

    local rel_path="${path#$HOME/}"
    local -a path_parts
    path_parts=("${(@s:/:)rel_path}")

    local part
    for part in "${path_parts[@]}"; do
        if [[ "$part" == .* ]]; then
            print -r -- "~/${rel_path}"
            return
        fi
    done

    print -r -- "${path_parts[-1]}"
}

prompt_venv_segment() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        prompt_segment '#414559' '#babbf1' "venv ${VIRTUAL_ENV:t}"
    elif [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
        prompt_segment '#414559' '#babbf1' "conda ${CONDA_DEFAULT_ENV}"
    fi
}

prompt_git_segment() {
    local git_output
    git_output="$(__git_prompt_git status --porcelain -b 2>/dev/null)" || return

    local -a lines
    lines=("${(@f)git_output}")
    [[ ${#lines[@]} -eq 0 ]] && return

    local branch_line branch segment
    branch_line="${lines[1]#\#\# }"
    branch="${branch_line%%...*}"
    branch="${branch%% *}"

    if [[ "$branch" == "HEAD" || "$branch" == "" ]]; then
        branch="detached"
    fi

    segment="%F{#a6d189} %F{#7287fd}%B${branch}%b%f"

    if [[ "$branch_line" =~ 'ahead ([0-9]+)' ]]; then
        segment+=" %F{#8CA0E8}⇡${match[1]}%f"
    fi

    if [[ "$branch_line" =~ 'behind ([0-9]+)' ]]; then
        segment+=" %F{#6c76c2}⇣${match[1]}%f"
    fi

    local has_staged=0
    local has_unstaged=0
    local has_untracked=0
    local has_conflicts=0
    local line xy

    for line in "${lines[@]:1}"; do
        [[ -z "$line" ]] && continue

        xy="${line[1,2]}"

        if [[ "$xy" == '??' ]]; then
            has_untracked=1
            continue
        fi

        case "$xy" in
            UU|AA|DD|AU|UA|UD|DU)
                has_conflicts=1
                ;;
        esac

        [[ "${xy[1]}" != ' ' ]] && has_staged=1
        [[ "${xy[2]}" != ' ' ]] && has_unstaged=1
    done

    (( has_staged )) && segment+=" %F{#a6d189}%f"
    (( has_unstaged )) && segment+=" %F{#e5c890}%f"
    (( has_untracked )) && segment+=" %F{#ef9f76}%f"
    (( has_conflicts )) && segment+=" %F{#e78284}%f"

    prompt_segment '#2A2C3B' '#7287fd' "$segment"
}

prompt_dir_segment() {
    prompt_segment '#7287fd' '#202131' "%B$(prompt_dir_display)%b"
}

prompt_build_left() {
    prompt_context_segment
    prompt_dir_segment
    prompt_venv_segment
    prompt_git_segment
}

prompt_build_right() {
    local last_status="$1"
    local out=''

    if [[ -n "$PROMPT_LAST_DURATION" ]]; then
        out+="%K{#414559}%F{#e5c890}  ${PROMPT_LAST_DURATION} %f%k "
    fi

    local count
    count=$(jobs -p 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" != "0" ]]; then
        out+="%K{#414559}%F{#e5c890}  ${count} %f%k "
    fi

    if [[ "$last_status" -ne 0 ]]; then
        out+="%K{#414559}%F{#e78284} ✘ ${last_status} %f%k"
    fi

    print -n "$out"
}

prompt_precmd() {
    local last_status="$?"

    if (( PROMPT_CMD_START > 0 )); then
        local elapsed_ms=$(( ( EPOCHREALTIME - PROMPT_CMD_START) * 1000 ))
        if (( elapsed_ms >= 1200 )); then
            PROMPT_LAST_DURATION="$(prompt_format_duration "$elapsed_ms")"
        else
            PROMPT_LAST_DURATION=''
        fi
        PROMPT_CMD_START=0
    else
        PROMPT_LAST_DURATION=''
    fi

    RPROMPT="$(prompt_build_right "$last_status")"
    print ""
}

prompt_preexec() {
    PROMPT_CMD_START=$EPOCHREALTIME
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd
add-zsh-hook preexec prompt_preexec

PROMPT='$(prompt_build_left)'
PROMPT+=$'\n''%F{#ef9f76}$%f '

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
alias vimzz="vimz"
alias cat=bat
alias neo="z ~/Projects && nvim"
alias vim="nvim"
alias post="posting --env ~/.local/share/posting/default/posting.env"
alias zz="z"
export EDITOR="nvim"
export VISUAL="nvim"

# Neovim cache management (for symlink/treesitter issues)
alias nvclear="rm -rf ~/.cache/nvim ~/.local/share/nvim && echo '✓ Neovim caches cleared'"
alias nvrebuild="nvclear && nvim -c 'Lazy! sync' -c 'TSUpdate' -c 'qa' && echo '✓ Neovim rebuilt'"
alias nvclean="nvim --clean"  # Start with factory defaults (no plugins)

alias sdf="source ~/.zshrc"


alias vi=vim
alias lsa="eza --icons=always -s=time -la"
alias yz=yazi
alias lz=lazygit
alias lzz=lazygit
alias lzd=lazydocker

# Ensure lazygit loads dotfiles-managed config on macOS
if [ -f "$HOME/.lazygit-local.yml" ]; then
    export LG_CONFIG_FILE="$HOME/dotfiles/lazygit-config.yml,$HOME/.lazygit-local.yml"
else
    export LG_CONFIG_FILE="$HOME/dotfiles/lazygit-config.yml"
fi

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
# eval "$(starship init zsh)"

# fzf configuration (for file search only)
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border --inline-info'

# Load fzf key bindings and completion
# if [ -f ~/.fzf.zsh ]; then
#     source ~/.fzf.zsh
# fi

# ===========================================
# FD File Finding & Search
# ===========================================
# fd flags are inlined to avoid variable expansion issues with sourcing
#
# Available functions:
#   ff          - Interactive file finder (ff [path])
#   fdir        - Interactive directory finder (fdir [path])
#   ffe         - Find file & open in editor (ffe [path])
#   fo          - Find file & open with default app (fo [path])
#   fde         - Find by extension (fde <ext> [path])
#   fdm         - Find recently modified (fdm <time> [path])
#   fdf         - Find by pattern (fdf <pattern> [path])
#   fdc         - Find at depth 1 only (fdc [path])
#
# Keyboard shortcuts in previews:
#   Ctrl+U/D    - Page up/down
#   Ctrl+Y/E    - Line up/down
# ===========================================

# Helper: Detect if file is text or binary
detect_file_type() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "binary"
        return
    fi
    local mime_type=$(file --mime "$file" 2>/dev/null | cut -d: -f2 | tr -d ' ')
    local mime_primary=$(echo "$mime_type" | cut -d/ -f1)
    if [[ "$mime_primary" == "text" ]] || [[ "$mime_type" == *"charset=utf-8"* ]] || [[ "$mime_type" == *"charset=us-ascii"* ]]; then
        echo "text"
    else
        echo "binary"
    fi
}

# Helper: Smart preview with file type detection
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

# Helper: Open file with appropriate app (text=editor, binary=default app)
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
            ${EDITOR:-nvim} "$file"
            ;;
        "binary")
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

# Interactive file finder with keyboard scrolling
ff() {
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview-window=right:60% \
              --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}' \
              --bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
              --bind 'alt-k:preview-up,alt-j:preview-down'
}

# Interactive directory finder
fdir() {
    fd --type d --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview "eza --tree --level=2 --icons {}"
}

# Find and open file in editor
ffe() {
    local file=$(fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}')
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# Find and open file with system default app
fo() {
    local file=$(fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
        | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}')
    [[ -n "$file" ]] && open_file "$file"
}

# Find files by extension
fde() {
    [[ $# -eq 0 ]] && { echo "Usage: fde <extension> [path]"; return 1; }
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --extension "$1" "${2:-.}" \
        | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}'
}

# Find recently modified files
fdm() {
    [[ $# -eq 0 ]] && { echo "Usage: fdm <time> [path] (e.g., 1h, 1d, 1w)"; return 1; }
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --changed-within "$1" "${2:-.}"
}

# Find files by pattern
fdf() {
    [[ $# -eq 0 ]] && { echo "Usage: fdf <pattern> [path]"; return 1; }
    fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "$1" "${2:-.}"
}



# Ripgrep configuration
alias rg='rg --smart-case --ignore-file ~/dotfiles/rgignore'

# Modern terminal tools
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

alias oc='opencode'  # Quick access to OpenCode

cheat() {
    curl cheat.sh/$1
}

# OpenCode pipe function - analyze command output with AI
ocprompt() {
  local prompt="${1:-Analyze and summarize this output.}"
  local input=$(cat)
  local model="${WORK_SMALL_MODEL:-pss-anthropic/claude-haiku-4-5-20251001}"

  if [[ "${PERSONAL:-0}" == "1" ]]; then
      model="${PERSONAL_SMALL_MODEL:-github-copilot/gpt-4.1-personal}"
  fi
  # Run opencode and render markdown output with glow (using global config style)
  echo "$input" | opencode run -m "$model" "Be concise. $prompt"
}

alias ocp='ocprompt'

# ===========================================
# Machine-Specific Configuration
# ===========================================
# OpenCode Tmux Status Plugin
# ===========================================
# Auto-reset Tmux window color to blue when you switch to a Tmux window
# (allows permission prompts and task completion indicators to auto-clear on focus)
if [[ -n "$TMUX_PANE" ]]; then
    # Run once on shell startup to reset any stale status colors
    tmux set-window-option -t current status-style bg=blue 2>/dev/null
    
    # Hook into Tmux window focus event (fires when pane gains focus)
    # This resets the status color to blue when you switch to the window
    trap "tmux set-window-option -t current status-style bg=blue 2>/dev/null" USR1
fi

# ===========================================
# Source local configuration if it exists
# ========================================== 

# Use this file for machine-specific overrides, work configs, API keys, etc.
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

#fastfetch
alias ffs='fastfetch'
# killer() { kill $(lsof -t -i:$1); }
# ffs -c "$HOME/.config/fastfetch/config.jsonc" 

# ===========================================
# JJ (Jujutsu) - Git-compatible VCS
# ===========================================
alias ljj='lazyjj'

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
export COLORTERM=truecolor
alias jdtls-clean='rm -rf ~/.cache/nvim/jdtls'

alias qt='qutebrowser >/dev/null 2>&1 &'
prompt_format_duration() {
    local elapsed_ms="$1"

    if (( elapsed_ms >= 60000 )); then
        printf '%dm%02ds' $(( elapsed_ms / 60000 )) $(( ( elapsed_ms % 60000 ) / 1000 ))
    else
        printf '%d.%01ds' $(( elapsed_ms / 1000 )) $(( ( elapsed_ms % 1000 ) / 100 ))
    fi
}
# zprof
