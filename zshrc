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

# Vi mode in the shell; cursor color follows keymap (Ghostty OSC 12 + tmux passthrough)
bindkey -v
# Default 400ms feels laggy on Esc; 1 (10ms) is snappy in Ghostty+tmux (source ~/.zshrc to apply)
KEYTIMEOUT=1

typeset -g _GHOSTTY_CURSOR_MODE=''

ghostty_cursor() {
  local seq="$1"
  if [[ -n "$TMUX" ]]; then
    print -rn -- $'\033Ptmux;\033'"${seq}"$'\033\\'
  else
    print -rn -- "$seq"
  fi
}

ghostty_cursor_apply() {
  local mode="$1"
  [[ "$mode" == "$_GHOSTTY_CURSOR_MODE" ]] && return
  _GHOSTTY_CURSOR_MODE="$mode"

  if [[ "$mode" == insert ]]; then
    ghostty_cursor $'\033]12;#a6d189\007'
  else
    ghostty_cursor $'\033]12;#c6d0f5\007'
  fi
}

ghostty_cursor_keymap() {
  if [[ "$KEYMAP" == vicmd ]]; then
    ghostty_cursor_apply normal
  else
    ghostty_cursor_apply insert
  fi
}

# Explicit Esc widget: mode switch + cursor (don't rely on timeout alone)
vi-cmd-mode-cursor() {
  zle vi-cmd-mode
  ghostty_cursor_apply normal
}
zle -N vi-cmd-mode-cursor
bindkey -M viins '^[' vi-cmd-mode-cursor

zle-keymap-select() {
  ghostty_cursor_keymap
}
zle -N zle-keymap-select

cursor_precmd() {
  ghostty_cursor_keymap
}
add-zsh-hook precmd cursor_precmd

# Readline-based CLIs (python input(), etc.)
export INPUTRC="$HOME/dotfiles/inputrc"

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

alias cat=bat
alias post="posting --env ~/.local/share/posting/default/posting.env"
alias zz="z"
alias sp='$HOME/dotfiles/tmux/scripts/tmux-sessionizer.sh'
alias vimz="nvim ~/.zshrc"
alias vimzz="nvim ~/.zshrc"
alias cur='cursor-agent'
alias co='codex'
alias cow='codex --profile work'
alias cor='codex --profile research'
alias coa='codex --profile agent'
alias cob='codex --profile browser'
alias cos='codex --profile slack'
alias col='codex --profile local'
cocmt() { cd /Users/rgaur/Projects/CMT-Reboot && codex --profile work "$@"; }
coagent() { cd /Users/rgaur/Projects && codex --profile agent "$@"; }
coms() { cd /Users/rgaur/Projects && codex --profile research "$@"; }
alias vim=nvim
export EDITOR="nvim"
export VISUAL="nvim"
alias view='nvim -R'
# Neovim cache management (for symlink/treesitter issues)
alias nvclear="rm -rf ~/.cache/nvim ~/.local/share/nvim && echo '✓ Neovim caches cleared'"
alias nvrebuild="nvclear && nvim -c 'Lazy! sync' -c 'TSUpdate' -c 'qa' && echo '✓ Neovim rebuilt'"
alias nvclean="nvim --clean"  # Start with factory defaults (no plugins)

alias sdf="source ~/.zshrc"
alias asdf="source ~/.zshrc | head -10"

alias zo="cd \$(zoxide query -i)"
alias ls="eza --icons=always -s=time -la"
alias yz=yazi
alias lz=lazygit
alias lzz=lazygit
alias lzd=lazydocker
alias ghb='gh browse'

export TLDR_AUTO_UPDATE_DISABLED=1
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
alias python=python3

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
        | fzf --preview "eza --tree --level=2 --icons {}" | echo 
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

export PATH="$HOME/Projects/jenk-cli:$PATH"
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

# ===========================================
# oMLX Model Helpers
# ===========================================
export OMLX_BASE_DIR="${OMLX_BASE_DIR:-$HOME/.omlx}"
export OMLX_MODEL_DIR="${OMLX_MODEL_DIR:-$OMLX_BASE_DIR/models}"

_omlx_model_list() {
    [[ -d "$OMLX_MODEL_DIR" ]] || return 1
    command ls -1 "$OMLX_MODEL_DIR" 2>/dev/null | sort
}

_omlx_current_model() {
    if [[ -n "$OMLX_DEFAULT_MODEL" && -d "$OMLX_MODEL_DIR/$OMLX_DEFAULT_MODEL" ]]; then
        print -r -- "$OMLX_DEFAULT_MODEL"
        return 0
    fi

    _omlx_model_list | head -n 1
}

omlx-models() {
    _omlx_model_list
}

omlx-model() {
    local selected="$1"

    if [[ -z "$selected" ]]; then
        if command -v fzf >/dev/null 2>&1; then
            selected="$(_omlx_model_list | fzf --prompt='oMLX model> ' --height=40%)"
        else
            _omlx_model_list
            return 0
        fi
    fi

    [[ -n "$selected" ]] || return 1

    if [[ ! -d "$OMLX_MODEL_DIR/$selected" ]]; then
        print "Model not installed: $selected"
        return 1
    fi

    export OMLX_DEFAULT_MODEL="$selected"
    print "Current oMLX model: $OMLX_DEFAULT_MODEL"
}

omlx-hot() {
    hf models ls --author mlx-community --sort trending_score --limit "${1:-20}" --expand downloads,likes,lastModified
}

omlx-search() {
    local query="$*"

    if [[ -z "$query" ]]; then
        print "Usage: omlx-search <query>"
        return 1
    fi

    hf models ls --author mlx-community --search "$query" --sort trending_score --limit 30 --expand downloads,likes,lastModified
}

omlx-install() {
    local repo="$1"
    local local_name="$2"

    if [[ -z "$repo" ]]; then
        print "Usage: omlx-install <hf-repo> [local-name]"
        return 1
    fi

    if [[ "$repo" != */* ]]; then
        repo="mlx-community/$repo"
    fi

    if [[ -z "$local_name" ]]; then
        local_name="${repo##*/}"
    fi

    mkdir -p "$OMLX_MODEL_DIR" || return 1
    hf download "$repo" --local-dir "$OMLX_MODEL_DIR/$local_name"
}

omlx-pick-install() {
    local query="${*:-Instruct 4bit}"
    local repo

    if ! command -v fzf >/dev/null 2>&1; then
        print "fzf required for omlx-pick-install"
        return 1
    fi

    repo="$(hf models ls --author mlx-community --search "$query" --sort trending_score --limit 50 -q | fzf --prompt='HF mlx model> ' --height=50%)"
    [[ -n "$repo" ]] || return 1

    omlx-install "$repo"
}

omlx-codex() {
    omlx launch codex --model "${1:-$(_omlx_current_model)}"
}

omlx-opencode() {
    omlx launch opencode --model "${1:-$(_omlx_current_model)}"
}

omlx-claude() {
    omlx launch claude --model "${1:-$(_omlx_current_model)}"
}

omlx-app() {
    local model
    model="$(_omlx_current_model)"
    [[ -n "$model" ]] || {
        print "No local oMLX models found in $OMLX_MODEL_DIR"
        return 1
    }

    omlx launch codex_app --model "$model"
}

alias omodel='omlx-model'
alias omodels='omlx-models'
alias osearch='omlx-search'
alias ohot='omlx-hot'
alias oinstall='omlx-install'
alias opick='omlx-pick-install'
alias ocodex='omlx-codex'
alias oopencode='omlx-opencode'
alias oclaude='omlx-claude'
alias oapp='omlx-app'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias aws-check="env | fzf +i --query 'AWS_'"

# pi privacy/security profile
export PI_TELEMETRY=0
export PI_OFFLINE=1
export PI_SKIP_VERSION_CHECK=1

export ANONYMIZE_OLLAMA_MODEL='gemma4:e2b'
alias org='nvim $HOME/Documents/org/todos.org'
export ORG_PATH="$HOME/Documents/org"
alias vimlocal='vim $HOME/.zshrc.local'

# toofan
export PATH="$HOME/.local/bin:$PATH"

# LLM usage terminal dashboard
alias lstat="$HOME/.local/bin/lstat"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# opencode completions
if command -v opencode >/dev/null 2>&1; then
    eval "$(opencode completion 2>/dev/null)"
fi
# zprof
