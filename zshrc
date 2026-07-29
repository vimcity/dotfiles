# zmodload zsh/zprof
# ===========================================
# Terminal & Color Support
# ===========================================
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
export _CACHED_CHECK=true

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-policy _omz_cache_policy

export CASE_SENSITIVE="false"
export ENABLE_CORRECTION="true"
export HYPHEN_INSENSITIVE="true"
export DISABLE_MAGIC_FUNCTIONS="true"
export DISABLE_LS_COLORS="true"
export INSIDE_EMACS=""

ZSH_THEME=""

plugins=(
  git
  copypath
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
)

source ~/dotfiles/prompt-themes.zsh
source "$HOME/dotfiles/zshrc.d/vi-ghostty.zsh"

source $ZSH/oh-my-zsh.sh

source "$HOME/dotfiles/zshrc.d/highlight.zsh"
source "$HOME/dotfiles/zshrc.d/session.zsh"
source "$HOME/dotfiles/zshrc.d/codex.zsh"
source "$HOME/dotfiles/zshrc.d/omlx.zsh"
source "$HOME/dotfiles/zshrc.d/helpers.zsh"
source "$HOME/dotfiles/zshrc.d/rbw.zsh"
source "$HOME/dotfiles/zshrc.d/ai.zsh"

