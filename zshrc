 # zmodload zsh/zprof
# ===========================================
# Terminal & Color Support
# ===========================================
# Force true color support (24-bit RGB) for tmux and neovim
export COLORTERM=truecolor

# Homebrew - static exports avoid spawning `brew` on every shell startup
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"


# ===========================================
# Oh My Zsh Configuration
# ===========================================
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
export ZSH_CACHE_DIR="$ZSH/cache"
export DISABLE_UPDATE_PROMPT=true
export DISABLE_AUTO_UPDATE=true
export ZSH_DISABLE_COMPFIX=true
# Skip compaudit security checks (saves ~9ms, not needed on single-user system)
export _CACHED_CHECK=true

# Completion caching - AGGRESSIVE FAST PATH
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-policy _omz_cache_policy

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
  brew
  copypath
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ===========================================
# zsh-syntax-highlighting - Outrun/Vice City theme (blue/pink/purple)
# ===========================================
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'                          # dark gray
ZSH_HIGHLIGHT_STYLES[alias]='fg=13'                           # purple
ZSH_HIGHLIGHT_STYLES[builtin]='fg=13'                         # purple
ZSH_HIGHLIGHT_STYLES[function]='fg=12'                        # blue
ZSH_HIGHLIGHT_STYLES[command]='fg=12'                         # blue
ZSH_HIGHLIGHT_STYLES[precommand]='fg=5'                       # magenta/pink
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=13'                   # purple
ZSH_HIGHLIGHT_STYLES[string]='fg=5'                           # magenta/pink
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=5'           # magenta/pink
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=5'           # magenta/pink
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=5'           # magenta/pink
ZSH_HIGHLIGHT_STYLES[variable]='fg=13'                        # purple
ZSH_HIGHLIGHT_STYLES[path]='fg=14'                            # cyan
ZSH_HIGHLIGHT_STYLES[globbing]='fg=5'                         # magenta/pink
ZSH_HIGHLIGHT_STYLES[option-flag]='fg=12'                     # blue
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=9,bold'               # light red, bold
ZSH_HIGHLIGHT_STYLES[redirection]='fg=14'                     # cyan

# ===========================================
# Prompt Theme System
# ===========================================
# Source theme definitions (allows runtime switching)
source ~/dotfiles/prompt-themes.zsh

# ===========================================
# Prompt
# ===========================================
setopt PROMPT_SUBST
zmodload zsh/datetime

# Suppress venv's default prompt prefix injection; our prompt_venv_segment handles display
export VIRTUAL_ENV_DISABLE_PROMPT=1

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
        # prompt_segment "${THEME_COLORS[user_bg]}" "${THEME_COLORS[user_fg]}" '%n'
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

prompt_format_duration() {
    local elapsed_ms="$1"

    if (( elapsed_ms >= 60000 )); then
        printf '%dm%02ds' $(( elapsed_ms / 60000 )) $(( ( elapsed_ms % 60000 ) / 1000 ))
    else
        printf '%d.%01ds' $(( elapsed_ms / 1000 )) $(( ( elapsed_ms % 1000 ) / 100 ))
    fi
}

prompt_venv_segment() {
    # Only show venv if the current directory is at or inside the venv's project root
    if [[ -n "$VIRTUAL_ENV" && "$PWD" == "${VIRTUAL_ENV:h}"* ]]; then
        prompt_segment "${THEME_COLORS[venv_bg]}" "${THEME_COLORS[venv_fg]}" "%B${VIRTUAL_ENV:t}%b"
    fi
}

prompt_git_recent_stash() {
    local stash_output stash_epoch stash_subject
    local week_seconds=604800

    stash_output="$(__git_prompt_git stash list -1 --date=unix --format='%ct%x1f%gs' 2>/dev/null)" || return
    [[ -z "$stash_output" ]] && return

    stash_epoch="${stash_output%%$'\x1f'*}"
    stash_subject="${stash_output#*$'\x1f'}"

    [[ -z "$stash_epoch" || -z "$stash_subject" ]] && return
    (( EPOCHSECONDS - stash_epoch > week_seconds )) && return

    stash_subject="${stash_subject#*: }"
    stash_subject="${stash_subject//\%/%%}"

    print -n -- "%F{${THEME_COLORS[git_stash]}}≡ ${stash_subject}%f"
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

    branch="${branch//\%/%%}"

    segment="%F{${THEME_COLORS[git_icon]}} %f%F{${THEME_COLORS[git_fg]}}%B${branch}%b%f"

    if [[ "$branch_line" =~ 'ahead ([0-9]+)' ]]; then
        segment+=" %F{${THEME_COLORS[git_ahead]}}⇡${match[1]}%f"
    fi

    if [[ "$branch_line" =~ 'behind ([0-9]+)' ]]; then
        segment+=" %F{${THEME_COLORS[git_behind]}}⇣${match[1]}%f"
    fi

    local has_staged=0
    local has_unstaged=0
    local line xy

    for line in "${lines[@]:1}"; do
        [[ -z "$line" ]] && continue

        xy="${line[1,2]}"

        if [[ "$xy" == '??' ]]; then
            has_unstaged=1
            continue
        fi

        [[ "${xy[1]}" != ' ' ]] && has_staged=1
        [[ "${xy[2]}" != ' ' ]] && has_unstaged=1
    done

    (( has_staged )) && segment+=" %F{${THEME_COLORS[git_added]}}●%f"
    (( has_unstaged )) && segment+=" %F{${THEME_COLORS[git_modified]}}%f"

    local stash_segment
    stash_segment="$(prompt_git_recent_stash)"
    [[ -n "$stash_segment" ]] && segment+=" ${stash_segment}"

    prompt_segment "${THEME_COLORS[git_bg]}" "${THEME_COLORS[git_fg]}" "$segment"
}

prompt_dir_segment() {
    prompt_segment "${THEME_COLORS[dir_bg]}" "${THEME_COLORS[dir_fg]}" "%B$(prompt_dir_display)%b"
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
        out+="%K{${THEME_COLORS[right_bg]}}%F{${THEME_COLORS[right_fg]}}  ${PROMPT_LAST_DURATION} %f%k "
    fi

    local count
    count=$(jobs -p 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" != "0" ]]; then
        out+="%K{${THEME_COLORS[right_bg]}}%F{${THEME_COLORS[right_fg]}}  ${count} %f%k "
    fi

    if [[ "$last_status" -ne 0 ]]; then
        out+="%K{${THEME_COLORS[right_bg]}}%F{${THEME_COLORS[error_fg]}} ✘ ${last_status} %f%k"
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
PROMPT+=$'\n''%F{${THEME_COLORS[prompt_char]}}$%f '

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
# Atuin Configuration (Ctrl+R only) - LAZY LOADED
# ===========================================
# Auto-sync disabled (no cloud account)
# export ATUIN_AUTO_SYNC=1
export ATUIN_SEARCH_MODE=fuzzy
export ATUIN_FILTER_MODE=global

# Initialize atuin (loads atuin-search widget for Ctrl+R)
eval "$(atuin init zsh --disable-up-arrow)" 2>/dev/null

alias ahl="atuin history list"
# Ctrl+R uses atuin search with popup (will be set by deferred atuin init)
# Up/down arrows use standard zsh history (default behavior restored)

alias vimz="nvim ~/.zshrc"
alias vimzz="vimz"
alias cat=bat
alias neo="z ~/Projects && nvim"
alias vim="nvim"
alias post="posting --env ~/.local/share/posting/default/posting.env"
alias zz="z"
alias sp='~/dotfiles/tmux/scripts/session-picker.sh'
export EDITOR="nvim"
export VISUAL="nvim"

# Neovim cache management (for symlink/treesitter issues)
alias nvclear="rm -rf ~/.cache/nvim ~/.local/share/nvim && echo '✓ Neovim caches cleared'"
alias nvrebuild="nvclear && nvim -c 'Lazy! sync' -c 'TSUpdate' -c 'qa' && echo '✓ Neovim rebuilt'"
alias nvclean="nvim --clean"  # Start with factory defaults (no plugins)

alias sdf="source ~/.zshrc"
alias asdf="source ~/.zshrc | head -10"

bwrm() {
    if ! command -v bw >/dev/null 2>&1; then
        echo "bw CLI not installed or not on PATH" >&2
        return 1
    fi
    if ! command -v jaq >/dev/null 2>&1; then
        echo "jaq is required for bwrm" >&2
        return 1
    fi
    if [[ -z "$BW_SESSION" ]]; then
        echo "Please unlock Bitwarden first (e.g. 'bw unlock')" >&2
        return 1
    fi

    local search_term="$1"
    local items_json selection name id
    
    # Get raw JSON once
    items_json=$(bw list items)
    
    # Filter by search term if provided, otherwise show all
    if [[ -n "$search_term" ]]; then
        selection=$(echo "$items_json" | jaq -r ".[] | select(.name | contains(\"$search_term\")) | \"\(.name) | \(.id)\"" | sort | fzf --height=50% --layout=reverse --border --prompt='bwrm> ' --header='select an entry' < /dev/tty)
    else
        selection=$(echo "$items_json" | jaq -r '.[] | "\(.name) | \(.id)"' | sort | fzf --height=50% --layout=reverse --border --prompt='bwrm> ' --header='select an entry' < /dev/tty)
    fi

    if [[ -z "$selection" ]]; then
        return 0
    fi

    # Parse the selection: name | id
    name=$(echo "$selection" | cut -d'|' -f1 | xargs)
    id=$(echo "$selection" | cut -d'|' -f2 | xargs)
    
    # Extract details from already-loaded JSON
    local username password url
    username=$(echo "$items_json" | jaq -r ".[] | select(.id == \"$id\") | .login?.username // \"n/a\"" | head -1)
    password=$(echo "$items_json" | jaq -r ".[] | select(.id == \"$id\") | .login?.password // \"n/a\"" | head -1)
    url=$(echo "$items_json" | jaq -r ".[] | select(.id == \"$id\") | .login?.uris[0]?.uri // \"no url\"" | head -1)
    
    # Show details and menu
    while true; do
        echo ""
        echo "═══════════════════════════════════════"
        echo "  $name"
        echo "═══════════════════════════════════════"
        echo "  URL:      $url"
        echo "  Username: $username"
        echo "  Password: $password"
        echo "═══════════════════════════════════════"
        echo ""
        echo "  (d)elete  |  (c)ancel"
        echo -n "Choice: "
        read -r choice < /dev/tty
        
        case "$choice" in
            [Dd])
                echo -n "Really delete '$name'? (y/n) "
                read -r confirm < /dev/tty
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    if bw delete item "$id"; then
                        echo "✓ Deleted '$name' (moved to trash)."
                        return 0
                    else
                        echo "✗ Failed to delete '$name'" >&2
                        return 1
                    fi
                else
                    echo "canceled"
                    return 0
                fi
                ;;
            [Cc])
                echo "canceled"
                return 0
                ;;
            *)
                echo "Invalid choice. Try again."
                ;;
        esac
    done
}

alias vi=vim
alias zo="cd \$(zoxide query -i)"
alias lsa="eza --icons=always -s=time -la"
alias yz=yazi
alias lz=lazygit
alias lzz=lazygit
alias lzd=lazydocker
alias ghb='gh browse'

# Ensure lazygit loads dotfiles-managed config on macOS
if [ -f "$HOME/.lazygit-local.yml" ]; then
    export LG_CONFIG_FILE="$HOME/dotfiles/lazygit-config.yml,$HOME/.lazygit-local.yml"
else
    export LG_CONFIG_FILE="$HOME/dotfiles/lazygit-config.yml"
fi

# Python utilities
alias pipr="pip install -r requirements.txt"
alias vnvinit="python -m venv venv"
alias vnva="source venv/bin/activate"

# Zoxide - smarter cd
eval "$(zoxide init zsh)"

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
    local mime_type
    mime_type="$(file --mime "$file" 2>/dev/null)"
    mime_type="${mime_type#*: }"
    local mime_primary="${mime_type%%/*}"
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
        | fzf --preview "eza --tree --level=2 --icons {}" | xargs -r cd
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

cheat() {
    curl "https://cheat.sh/$1"
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
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

if [[ -f "$HOME/.zshrc.ps.local" ]]; then
    source "$HOME/.zshrc.ps.local"
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
export PATH="$PATH:$HOME/.local/scripts"

alias vimlocal="nvim ~/.zshrc.local"
alias fabric="fabric-ai"
alias fab="fabric-ai"
alias mvnds="mvn eclipse:clean eclipse:eclipse -DdownloadSources=true"
export COLORTERM=truecolor
alias jdtls-clean='rm -rf ~/.cache/nvim/jdtls'

# ===========================================
# YouTube (ytui)
# ===========================================
alias yt='open -na Ghostty.app --args -e ~/.local/scripts/ytui'  # new Ghostty window (real TTY = pixel thumbnails)
alias ytr='ytui refresh'               # refresh feed cache
alias yts='ytui search'                # search youtube
alias ytw='ytui watch-later'           # open watch-later list
alias ytc='ytui channel'               # browse a channel
alias yta='ytui add'                   # add video to watch-later

# ===========================================
# Qutebrowser
# ===========================================
alias qt='qutebrowser >/dev/null 2>&1 &'
alias qtr='~/.local/qute-scripts/qute-remote'           # remote control qutebrowser

# Shell Master - Interactive CLI Learning Tool
alias shellmaster="$HOME/dotfiles/shell-master/shell-master"

# ===========================================
# Prompt Theme Switcher
# ===========================================

# Quick theme switcher alias
alias theme-list='prompt_switch_theme'

# Quick switcher function
theme() {
    prompt_switch_theme "$1"
}
olf() {
    ollama run "$(ollama list | fzf | awk '{print $1}')" "Answer the following quetion as precisely as you can: $@";
}

ols() {
    ollama run 'gemma4:e2b' "Answer the following quetion as precisely as you can: $@";
}

olm() {
    ollama run 'gemma4:e4b' "Answer the following quetion as precisely as you can: $@";
}

olh() {
    ollama run 'gemma4:31b' "Answer the following quetion as precisely as you can: $@";
}
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias aws-check="env | fzf +i --query 'AWS_'"
# zprof

# pi privacy/security profile
export PI_TELEMETRY=0
export PI_OFFLINE=1
export PI_SKIP_VERSION_CHECK=1

# toofan
export PATH="$HOME/.local/bin:$PATH"

envs()='env | fzf +i --query '\'${1}\'
