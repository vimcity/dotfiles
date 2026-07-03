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
# Codex — enterprise default (cloud) + opt-in MCPs/plugins per session
_codex_launch() {
  local mode="$1"
  shift
  local -a args=()
  local parsing_mcps=1
  local token

  case "$mode" in
    cloud) ;;
    local)
      args+=(
        --profile local
        # -c 'mcp_servers.headroom.enabled=false'
        # -c 'mcp_servers.serena.enabled=false'
      )
      ;;
    *)
      print "unknown codex launcher mode: $mode" >&2
      return 2
      ;;
  esac

  while (( $# )); do
    token=$1
    shift
    case $token in
      -h|--help)
        if [[ "$mode" == local ]]; then
          command cat <<'EOF'
usage: col [mcp|keyword...] [codex flags/options] [-- prompt...]

  col                              local Codex, no MCPs by default
  col headroom                     enable Headroom MCP retrieve/compress tools
  col serena                       enable Serena for this session
  col github jira                  enable named MCPs for this session
  col github resume --last         resume last chat with github MCP
  col playwright                   enable Playwright MCP for this session
  col browser devtools             enable browser plugins/devtools MCP
  col -- -m model "prompt"         pass normal Codex flags/prompt

Keywords: browser, devtools, outlook
MCP names: playwright, github, jira, confluence, slack, context7, datadog,
           serena, service-now, chrome-devtools, headroom
EOF
        else
          command cat <<'EOF'
usage: co [mcp|keyword...] [codex flags/options] [-- prompt...]

  co                               plain Codex cloud session
  co noserena                      skip Serena for this session
  co github jira confluence        enable work MCPs for this session
  co slack                         slack MCP
  co slack resume --last           resume last chat with slack MCP
  co outlook                       outlook-email plugin
  co playwright resume --last      resume last chat with Playwright MCP loaded
  co browser devtools github       combine keywords and MCPs
  co -- -m gpt-5.5 "prompt"        pass normal Codex flags/prompt

Keywords: browser, devtools, outlook, noserena
MCP names: playwright, github, jira, confluence, slack, context7, datadog,
           serena, service-now, chrome-devtools, headroom
EOF
        fi
        return 0
        ;;
      --)
        parsing_mcps=0
        args+=("$token" "$@")
        break
        ;;
      -*)
        parsing_mcps=0
        args+=("$token")
        ;;
      browser)
        if (( parsing_mcps )); then
          args+=(
            -c 'plugins."browser@openai-bundled".enabled=true'
            -c 'plugins."chrome@openai-bundled".enabled=true'
            -c 'plugins."computer-use@openai-bundled".enabled=true'
            -c 'mcp_servers.node_repl.enabled=true'
          )
        else
          args+=("$token")
        fi
        ;;
      devtools)
        if (( parsing_mcps )); then
          args+=(-c 'mcp_servers."chrome-devtools".enabled=true')
        else
          args+=("$token")
        fi
        ;;
      outlook)
        if (( parsing_mcps )); then
          args+=(-c 'plugins."outlook-email@openai-curated".enabled=true')
        else
          args+=("$token")
        fi
        ;;
      slack)
        if (( parsing_mcps )); then
          args+=(-c 'mcp_servers.slack.enabled=true')
        else
          args+=("$token")
        fi
        ;;
      slack-mcp)
        print "MCP is named 'slack' now; use: co slack" >&2
        return 2
        ;;
      resume|fork|exec|review|mcp|plugin|login|logout|doctor|app|cloud|archive|delete|unarchive|completion|update|debug|features|sandbox|apply|remote-control|app-server|mcp-server|exec-server|help)
        parsing_mcps=0
        args+=("$token" "$@")
        break
        ;;
      headroom)
        if (( parsing_mcps )); then
          args+=(
            -c 'model_provider="headroom-local"'
            -c 'mcp_servers.headroom.enabled=true'
          )
        else
          args+=("$token")
        fi
        ;;
      noserena)
        if (( parsing_mcps )); then
          args+=(-c 'mcp_servers.serena.enabled=false')
        else
          args+=("$token")
        fi
        ;;
      *)
        if (( parsing_mcps )); then
          args+=(-c "mcp_servers.${token}.enabled=true")
        else
          args+=("$token")
        fi
        ;;
    esac
  done

  codex "${args[@]}"
}

co() { _codex_launch cloud "$@"; }
col() { _codex_launch local "$@"; }
cor() { _codex_launch cloud "$@" resume --last; }
colr() { codex resume --last --profile local -c 'mcp_servers.headroom.enabled=false' -c 'mcp_servers.serena.enabled=false' "$@"; }
cores() { codex resume --last "$@"; }

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

# Cold-start profile (sdf re-sources in the current shell and zprof is cumulative — misleading)
zshprof() {
    ZSHRC_PROFILE=1 command time zsh -ic 'exit' 2>&1 | head -25
}

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

# Codex memory + session search (memrg, sesrg, sesshow, sessid, codexrg)
[[ -f "$HOME/dotfiles/codex-search.zsh" ]] && source "$HOME/dotfiles/codex-search.zsh"

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

if [[ -f "$HOME/.zshrc.local.env" ]]; then
    source "$HOME/.zshrc.local.env"
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

_omlx_ram_gb() {
    local mem_bytes
    mem_bytes="$(sysctl -n hw.memsize 2>/dev/null)" || return 1
    print -r -- $(( mem_bytes / 1024 / 1024 / 1024 ))
}

_omlx_max_params_b() {
    local ram_gb
    ram_gb="${OMLX_MAX_PARAMS_RAM_GB_OVERRIDE:-$(_omlx_ram_gb)}"

    if (( ram_gb >= 64 )); then
        print -r -- 72
    elif (( ram_gb >= 48 )); then
        print -r -- 32
    elif (( ram_gb >= 32 )); then
        print -r -- 24
    elif (( ram_gb >= 24 )); then
        print -r -- 14
    elif (( ram_gb >= 16 )); then
        print -r -- 8
    else
        print -r -- 3
    fi
}

_omlx_model_params_b() {
    local model_name="$1"

    if [[ "$model_name" =~ 'A([0-9]+)B' ]]; then
        print -r -- "$match[1]"
        return 0
    fi

    if [[ "$model_name" =~ '([0-9]+)B' ]]; then
        print -r -- "$match[1]"
        return 0
    fi

    return 1
}

_omlx_model_fits_machine() {
    local model_name="$1"
    local params_b max_params_b

    params_b="$(_omlx_model_params_b "$model_name")" || return 1
    max_params_b="${OMLX_MAX_PARAMS_B:-$(_omlx_max_params_b)}"

    (( params_b <= max_params_b )) || return 1

    if (( params_b > 14 )) && [[ "$model_name:l" != *4bit* ]] && [[ "$model_name:l" != *q4* ]]; then
        return 1
    fi

    return 0
}

_omlx_filter_fit_models() {
    local model_name

    while IFS= read -r model_name; do
        [[ -n "$model_name" ]] || continue
        _omlx_model_fits_machine "$model_name" && print -r -- "$model_name"
    done
}

_omlx_model_has_permissive_license() {
    local model_name="$1"
    local info

    info="$(hf models info "$model_name" 2>/dev/null)" || return 1
    [[ "$info" == *'license:apache-2.0'* || "$info" == *'license:mit'* ]]
}

_omlx_filter_permissive_models() {
    local model_name

    while IFS= read -r model_name; do
        [[ -n "$model_name" ]] || continue
        _omlx_model_has_permissive_license "$model_name" && print -r -- "$model_name"
    done
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

omlx-hot-fit() {
    hf models ls --author mlx-community --sort trending_score --limit "${1:-50}" -q | _omlx_filter_fit_models
}

omlx-hot-fit-oss() {
    hf models ls --author mlx-community --sort trending_score --limit "${1:-30}" -q | _omlx_filter_fit_models | _omlx_filter_permissive_models
}

ohot() {
    omlx-hot-fit-oss "$@"
}

omlx-search() {
    local query="$*"

    if [[ -z "$query" ]]; then
        print "Usage: omlx-search <query>"
        return 1
    fi

    hf models ls --author mlx-community --search "$query" --sort trending_score --limit 30 --expand downloads,likes,lastModified
}

omlx-search-fit() {
    local query="$*"

    if [[ -z "$query" ]]; then
        print "Usage: omlx-search-fit <query>"
        return 1
    fi

    hf models ls --author mlx-community --search "$query" --sort trending_score --limit 50 -q | _omlx_filter_fit_models
}

omlx-search-fit-oss() {
    local query="$*"

    if [[ -z "$query" ]]; then
        print "Usage: omlx-search-fit-oss <query>"
        return 1
    fi

    hf models ls --author mlx-community --search "$query" --sort trending_score --limit 50 -q | _omlx_filter_fit_models | _omlx_filter_permissive_models
}

osearch() {
    omlx-search-fit-oss "$@"
}

omlx-machine() {
    local ram_gb max_params_b
    ram_gb="$(_omlx_ram_gb)" || return 1
    max_params_b="${OMLX_MAX_PARAMS_B:-$(_omlx_max_params_b)}"

    print "Machine RAM: ${ram_gb}GB"
    print "Recommended max model size: ${max_params_b}B"
    print "Rule: models over 14B should be 4-bit/Q4"
}

omachine() {
    omlx-machine
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

oinstall() {
    omlx-install "$@"
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

omlx-pick-install-fit() {
    local query="${*:-Instruct 4bit}"
    local repo

    if ! command -v fzf >/dev/null 2>&1; then
        print "fzf required for omlx-pick-install-fit"
        return 1
    fi

    repo="$(hf models ls --author mlx-community --search "$query" --sort trending_score --limit 80 -q | _omlx_filter_fit_models | fzf --prompt='HF mlx fit> ' --height=50%)"
    [[ -n "$repo" ]] || return 1

    omlx-install "$repo"
}

omlx-pick-install-fit-oss() {
    local query="${*:-Instruct 4bit}"
    local repo

    if ! command -v fzf >/dev/null 2>&1; then
        print "fzf required for omlx-pick-install-fit-oss"
        return 1
    fi

    repo="$(hf models ls --author mlx-community --search "$query" --sort trending_score --limit 60 -q | _omlx_filter_fit_models | _omlx_filter_permissive_models | fzf --prompt='HF mlx oss fit> ' --height=50%)"
    [[ -n "$repo" ]] || return 1

    omlx-install "$repo"
}

omodel() {
    omlx-model "$@"
}

omodels() {
    omlx-models
}

opick() {
    omlx-pick-install-fit-oss "$@"
}

# Quick LLM asks (llm CLI + oMLX/Ollama/OpenAI)
alias ask='$HOME/dotfiles/bin/ask'
alias askr='$HOME/dotfiles/bin/ask -r'
alias asko='$HOME/dotfiles/bin/ask -o'
alias askc='$HOME/dotfiles/bin/ask -c'
alias askp='$HOME/dotfiles/bin/ask -p'
alias asks='$HOME/dotfiles/bin/ask -t shell-help'
alias askv='$HOME/dotfiles/bin/ask -t vim-help'
alias askl='$HOME/dotfiles/bin/ask -l'

export LLM_LOCAL_MODEL="${LLM_LOCAL_MODEL:-omlx-gemma}"
export LLM_REMOTE_MODEL="${LLM_REMOTE_MODEL:-gpt-4o-mini}"
export LLM_OLLAMA_MODEL="${LLM_OLLAMA_MODEL:-gemma4:e2b}"

hr-cloud() {
    nohup headroom proxy --port 8787 --no-telemetry >/tmp/headroom-cloud.log 2>&1 &!
}

hr-local() {
    nohup headroom proxy --port 8788 --no-telemetry --openai-api-url http://127.0.0.1:8000/v1 >/tmp/headroom-local.log 2>&1 &!
}

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias aws-check="env | fzf +i --query 'AWS_'"

# pi privacy/security profile
export PI_TELEMETRY=0
export PI_OFFLINE=1
export PI_SKIP_VERSION_CHECK=1
export RTK_TELEMETRY_DISABLED=1

export ANONYMIZE_OLLAMA_MODEL='gemma4:e2b'
alias org='nvim $HOME/Documents/org/todos.org'
export ORG_PATH="$HOME/Documents/org"
alias vimlocal='vim $HOME/.zshrc.local'

# toofan
export PATH="$HOME/.local/bin:$PATH"

# LLM usage terminal dashboard
alias lstat="$HOME/.local/bin/lstat"

# bun completions
# [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# # opencode completions
# if command -v opencode >/dev/null 2>&1; then
#     eval "$(opencode completion 2>/dev/null)"
# fi

# [[ -n "$ZSHRC_PROFILE" ]] && zprof
