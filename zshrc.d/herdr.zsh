# Herdr CLI wrapper + tab auto-rename in Herdr panes

_herdr_plugin_installed() {
    local plugin_id="$1"
    local actions
    actions="$(command herdr plugin list 2>/dev/null)" || return 1
    [[ "$actions" == *"$plugin_id"* ]]
}

_herdr_ensure_plugin() {
    local plugin_id="$1"
    local plugin_source="$2"
    local plugin_ref="${3:-}"
    local -a install_args=(plugin install "$plugin_source" --yes)

    _herdr_plugin_installed "$plugin_id" && return 0
    [[ -n "$plugin_ref" ]] && install_args+=(--ref "$plugin_ref")
    command herdr "${install_args[@]}" >/dev/null || return 1
    command herdr server reload-config >/dev/null
}

_herdr_ensure_plugins() {
    _herdr_ensure_plugin "herdr-splits" "lmilojevicc/herdr-splits.nvim" "167641719f364e6bd9866f584df8a210f7d7bfd2" || return
    _herdr_ensure_plugin "hotchpotch.herdr-tiny-fingers" "hotchpotch/herdr-tiny-fingers" "2c817583fa1d5385fe4a95e2fd4cfa30fa4e915e" || return
}

herdr() {
    local is_handoff_update=0
    local arg
    if [[ "$1" == "update" ]]; then
        for arg in "$@"; do
            [[ "$arg" == "--handoff" ]] && is_handoff_update=1
        done
    elif (( $# )); then
        :
    else
        _herdr_ensure_plugins || return
    fi
    command herdr "$@"
    local status=$?
    if (( status == 0 && is_handoff_update )); then
        _herdr_ensure_plugins || return
    fi
    return "$status"
}

# Same binding as prefix+t in herdr/config.toml
fingers() {
    [[ "${HERDR_ENV:-}" == "1" ]] || {
        print "fingers: not inside Herdr (HERDR_ENV=1)" >&2
        return 1
    }
    command herdr plugin action run --plugin hotchpotch.herdr-tiny-fingers --action open
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
