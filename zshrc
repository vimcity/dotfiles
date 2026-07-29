# zmodload zsh/zprof
# ===========================================
# Terminal & Color Support
# ===========================================
# Force true color support (24-bit RGB) for tmux and neovim
export COLORTERM=truecolor

# ===========================================
# OS / Machine Detection
# ===========================================
IS_MAC=0
IS_LINUX=0
if [[ "$(uname -s)" == "Darwin" ]]; then
    IS_MAC=1
elif [[ "$(uname -s)" == "Linux" ]]; then
    IS_LINUX=1
fi

# Homebrew - static exports avoid spawning `brew` on every shell startup
if (( IS_MAC )); then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
    export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi


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
# Sourced Shell Modules
# ===========================================
source "$HOME/dotfiles/zshrc.d/session.zsh"
source "$HOME/dotfiles/zshrc.d/helpers.zsh"

source "$HOME/dotfiles/zshrc.d/rbw.zsh"

# lean-ctx shell hook — begin
if [ -f "$HOME/.config/lean-ctx/shell-hook.zsh" ]; then
    . "$HOME/.config/lean-ctx/shell-hook.zsh"
fi
# lean-ctx shell hook — end


