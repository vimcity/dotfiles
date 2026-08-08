# Vi mode + Ghostty cursor sync (optional zsh-vi-mode via OMZ plugin)

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

    ghostty_cursor $'\033]12;#c6d0f5\007'

    if [[ "$mode" == insert ]]; then
        ghostty_cursor $'\033[6 q'
    else
        ghostty_cursor $'\033[2 q'
    fi
}

ghostty_cursor_keymap() {
    if [[ "$KEYMAP" == vicmd ]]; then
        ghostty_cursor_apply normal
    else
        ghostty_cursor_apply insert
    fi
}

# Vi mode + Ghostty cursor sync
bindkey -v
KEYTIMEOUT=1

zle-line-init() {
    ghostty_cursor_apply insert
}
zle-line-finish() {
    ghostty_cursor_apply normal
}
zle -N zle-line-init
zle -N zle-line-finish

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

bindkey -M viins '^R' atuin-search
bindkey -M vicmd 'A' undefined-key
