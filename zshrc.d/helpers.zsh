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
alias sp='$HOME/dotfiles/tmux/scripts/tmux-sessionizer.sh'
alias vimz="vim ~/.zshrc"
alias vimzz="vim ~/.zshrc"
alias vimal="vim ~/zshrc.d/helpers.zsh"
alias cur='cursor-agent'
_herdr_ensure_navigation_plugin() {
 local plugin_source='lmilojevicc/herdr-splits.nvim'
 local plugin_ref='167641719f364e6bd9866f584df8a210f7d7bfd2'
 local actions
 actions="$(command herdr plugin action list --plugin herdr-splits 2>/dev/null)" || return 0
 [[ "$actions" == *'"action_id":"nav-left"'* ]] && return 0
 command herdr plugin install "$plugin_source" --ref "$plugin_ref" --yes >/dev/null || return 1
 command herdr server reload-config >/dev/null
}
herdr() {
 local is_handoff_update=0
 local arg
 if [[ "$1" == "update" ]]; then
  for arg in "$@"; do
   [[ "$arg" == "--handoff" ]] && is_handoff_update=1
  done
 elif (( $# == 0 )); then
  _herdr_ensure_navigation_plugin || return
 fi
 command herdr "$@"
 local status=$?
 if (( status == 0 && is_handoff_update )); then
  _herdr_ensure_navigation_plugin || return
 fi
 return "$status"
}
alias vim=nvim
export EDITOR="nvim"
export VISUAL="nvim"
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
    | fzf --preview "eza --tree --level=2 --icons {}" | echo 
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
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'
alias clont='claude --continue'  # Resume latest chat
export USE_BUILTIN_RIPGREP=0
cheat() {
  curl "https://cheat.sh/$1"
}
if [[ -n "$TMUX_PANE" ]]; then
  tmux set-window-option -t current status-style bg=blue 2>/dev/null
  trap "tmux set-window-option -t current status-style bg=blue 2>/dev/null" USR1
fi
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
export COLORTERM=truecolor
alias jdtls-clean='rm -rf ~/.cache/nvim/jdtls'
alias qt='qutebrowser >/dev/null 2>&1 &'
alias qtr='~/.local/qute-scripts/qute-remote'           # remote control qutebrowser
alias shellmaster="$HOME/dotfiles/shell-master/shell-master"
alias theme-list='prompt_switch_theme'
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
export PATH="$BUN_INSTALL/bin:$PATH"
alias aws-check="env | fzf +i --query 'AWS_'"
export PI_TELEMETRY=0
export PI_OFFLINE=1
export PI_SKIP_VERSION_CHECK=1
export ANONYMIZE_OLLAMA_MODEL='gemma4:e2b'
alias org='nvim $HOME/Documents/org/todos.org'
export ORG_PATH="$HOME/Documents/org"
alias vimlocal='vim $HOME/.zshrc.local'
export PATH="$HOME/.local/bin:$PATH"
alias lstat="$HOME/.local/bin/lstat"












