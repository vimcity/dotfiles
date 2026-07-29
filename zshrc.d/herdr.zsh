# Herdr CLI wrapper + tab auto-rename in Herdr panes

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

typeset -g HERDR_AUTO_RENAME_LAST_CWD=''
herdr_auto_rename_current_tab() {
    [[ "${HERDR_ENV:-}" == "1" && -n "${HERDR_TAB_ID:-}" ]] || return 0
    [[ "$PWD" == "$HERDR_AUTO_RENAME_LAST_CWD" ]] && return 0
    HERDR_AUTO_RENAME_LAST_CWD="$PWD"
    "$HOME/dotfiles/bin/herdr-autorename-tab" "$PWD" >/dev/null 2>&1
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd herdr_auto_rename_current_tab
add-zsh-hook precmd herdr_auto_rename_current_tab
