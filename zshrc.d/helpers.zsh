export ATUIN_SEARCH_MODE=fuzzy
export ATUIN_FILTER_MODE=global
eval "$(atuin init zsh --disable-up-arrow)" 2>/dev/null
alias ahl="atuin history list"
alias cat=bat
alias post="posting --env ~/.local/share/posting/default/posting.env"
alias zz="z"
alias d="z"
alias zo="cd \$(zoxide query -i)"
alias ls="eza --icons=always -s=time -la"
alias yz=yazi
alias lz=lazygit
alias lzz=lazygit
alias lzd=lazydocker
alias ghb='gh browse'
# tmux-sessionizer removed (Herdr-only workflow)
alias vimz="nvim ~/.zshrc"
alias vimal="nvim $HOME/dotfiles/zshrc.d/helpers.zsh"
alias cur='cursor-agent'
# herdr() {
#  local is_handoff_update=0
#  local arg
#  if [[ "$1" == "update" ]]; then
#   for arg in "$@"; do
#    [[ "$arg" == "--handoff" ]] && is_handoff_update=1
#   done
#  elif (( $# == 0 )); then
#   _herdr_ensure_navigation_plugin || return
#  fi
#  command herdr "$@"
#  local status=$?
#  if (( status == 0 && is_handoff_update )); then
#   _herdr_ensure_navigation_plugin || return
#  fi
#  return "$status"
# }
alias vim=nvim
export EDITOR="/opt/homebrew/bin/nvim"
export VISUAL="/opt/homebrew/bin/nvim"
alias view='nvim -R'
alias nvclear="rm -rf ~/.cache/nvim ~/.local/share/nvim && echo '✓ Neovim caches cleared'"
alias nvrebuild="nvclear && nvim -c 'Lazy! sync' -c 'TSUpdate' -c 'qa' && echo '✓ Neovim rebuilt'"
alias nvclean="nvim --clean"  # Start with factory defaults (no plugins)
alias sdf="source ~/.zshrc"
alias asdf="source ~/.zshrc | head -10"
zshprof() {
  ZSHRC_PROFILE=1 command time zsh -ic 'exit' 2>&1 | head -25
}
export TLDR_AUTO_UPDATE_DISABLED=1
if [ -f "$HOME/.lazygit-local.yml" ]; then
  export LG_CONFIG_FILE="$HOME/dotfiles/lazygit-config.yml,$HOME/.lazygit-local.yml"
else
  export LG_CONFIG_FILE="$HOME/dotfiles/lazygit-config.yml"
fi
alias pipr="pip install -r requirements.txt"
alias vnvinit="python -m venv venv"
alias vnva="source venv/bin/activate"
alias python=python3
eval "$(zoxide init zsh)"
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border --inline-info'
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
ff() {
  fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
    | fzf --preview-window=right:60% \
       --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}' \
       --bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
       --bind 'alt-k:preview-up,alt-j:preview-down'
}
fdir() {
  fd --type d --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
    | fzf --preview "eza --tree --level=2 --icons {}"
}
ffe() {
  local file=$(fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
    | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}')
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}
fo() {
  local file=$(fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "${1:-.}" \
    | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}')
  [[ -n "$file" ]] && open_file "$file"
}
fde() {
  [[ $# -eq 0 ]] && { echo "Usage: fde <extension> [path]"; return 1; }
  fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --extension "$1" "${2:-.}" \
    | fzf --preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}'
}
fdm() {
  [[ $# -eq 0 ]] && { echo "Usage: fdm <time> [path] (e.g., 1h, 1d, 1w)"; return 1; }
  fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" --changed-within "$1" "${2:-.}"
}
fdf() {
  [[ $# -eq 0 ]] && { echo "Usage: fdf <pattern> [path]"; return 1; }
  fd --type f --hidden --exclude .git --ignore-file "$HOME/.fdignore" "$1" "${2:-.}"
}
alias rg='rg --smart-case --ignore-file ~/dotfiles/rgignore'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_PAGER="less -RF"
export TAILSPIN_EXTRAS="${TAILSPIN_EXTRAS:-jvm-stack-trace}"
if [[ "${PROMPT_THEME:-catppuccin-rose}" == "catppuccin" ]]; then
  export BAT_THEME="Catppuccin Frappe"
else
  export BAT_THEME="Catppuccin Macchiato"
fi

theme-switch() {
  command theme-switch "$@"
  source "$HOME/.zshrc"
}
alias ll='eza -la --git --icons'
alias la='eza -a --icons'
alias lt='eza --tree --level=2 --icons'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias psg='ps aux | grep'
alias c='clear'
alias find='fd'
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'
export USE_BUILTIN_RIPGREP=0
cheat() {
  curl "https://cheat.sh/$1"
}
# tmux status/trap removed (Herdr-only workflow)
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
if [[ -f "$HOME/.zshrc.local.env" ]]; then
  source "$HOME/.zshrc.local.env"
fi
alias ffs='fastfetch'
alias ljj='lazyjj'
alias gwl='git worktree list'
alias gwr='git worktree remove'
alias gwp='git worktree prune'
gwab() { git worktree add -b "$1" "../$1"; }  # new branch
gwa() { git worktree add "../$1" "$1"; }      # existing branch
export PATH="$HOME/Projects/jenk-cli:$PATH"
export PATH="$PATH:$HOME/.local/scripts"
alias vimlocal="nvim ~/.zshrc.local"
fabric() {
  fabric-ai --raw --disable-responses-api "$@"
}
alias fab="fabric"
alias mvnds="mvn eclipse:clean eclipse:eclipse -DdownloadSources=true"
alias jdtls-clean='rm -rf ~/.cache/nvim/jdtls'
alias qt='qutebrowser >/dev/null 2>&1 &'
alias qtr='~/.local/qute-scripts/qute-remote'           # remote control qutebrowser
alias shellmaster="$HOME/dotfiles/shell-master/shell-master"
alias theme-list='prompt_switch_theme'
theme() {
  prompt_switch_theme "$1"
}
alias ask='$HOME/dotfiles/bin/ask'
export LLM_LOCAL_MODEL="${LLM_LOCAL_MODEL:-omlx-gemma}"
export LLM_REMOTE_MODEL="${LLM_REMOTE_MODEL:-gpt-4o-mini}"
export LLM_DEFAULT_MODEL="${LLM_DEFAULT_MODEL:-openrouter/qwen/qwen3.5-35b-a3b}"
export PATH="$BUN_INSTALL/bin:$PATH"
alias aws-check="env | fzf +i --query 'AWS_'"
export PI_TELEMETRY=0
export PI_OFFLINE=1
export PI_SKIP_VERSION_CHECK=1
alias org='nvim $HOME/Documents/org/todos.org'
export ORG_PATH="$HOME/Documents/org"
alias vimlocal='vim $HOME/.zshrc.local'
alias vimenv='vim $HOME/.zshrc.local.env'
export PATH="$HOME/.local/bin:$PATH"
alias lstat="$HOME/.local/bin/lstat"

