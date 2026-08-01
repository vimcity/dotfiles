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
# Completion & Plugins (no OMZ framework)
# ===========================================

# Completion cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' special-dirs true

# Direct compinit (use cached dump)
autoload -Uz compinit
compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"

# Plugins (sourced directly, no framework)
source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

# Git prompt helper (replaces OMZ lib/git.zsh)
function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

# Completion menu & matching
zmodload -i zsh/complist
unsetopt menu_complete flowcontrol
setopt auto_menu complete_in_word always_to_end
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Directory navigation
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus
alias -g ...='../..'
alias -g ....='../../..'
alias -- -='cd -'

source ~/dotfiles/prompt-themes.zsh
source "$HOME/dotfiles/zshrc.d/vi-ghostty.zsh"

source "$HOME/dotfiles/zshrc.d/highlight.zsh"
source "$HOME/dotfiles/zshrc.d/git-aliases.zsh"
source "$HOME/dotfiles/zshrc.d/session.zsh"
source "$HOME/dotfiles/zshrc.d/codex.zsh"
source "$HOME/dotfiles/zshrc.d/omlx.zsh"
source "$HOME/dotfiles/zshrc.d/helpers.zsh"
source "$HOME/dotfiles/zshrc.d/rbw.zsh"
source "$HOME/dotfiles/zshrc.d/org.zsh"
source "$HOME/dotfiles/zshrc.d/fence.zsh"
source "$HOME/dotfiles/zshrc.d/herdr.zsh"
source "$HOME/dotfiles/zshrc.d/history.zsh"
