#!/usr/bin/env bash
set -euo pipefail

rex_bin="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
if [[ ! -x "$rex_bin" ]]; then
    rex_bin="$(command -v rex)" || {
        printf 'scrollback-nvim: Rex CLI not found\n' >&2
        exit 1
    }
fi
snapshot="$(mktemp "${TMPDIR:-/tmp}/rex-scrollback.XXXXXX")"
trap 'rm -f "$snapshot"' EXIT
"$rex_bin" capture -s "$1" -b "$2" --trim --unwrap >"$snapshot"
if command -v tspin >/dev/null 2>&1; then
    tspin --theme "$HOME/dotfiles/tailspin/theme.toml" -p "$snapshot" | "${NVIM_BIN:-nvim}" -R - \
        -c 'setlocal filetype=ansi' \
        -c 'silent! AnsiEnable' \
        -c 'setlocal buftype=nofile nomodifiable nomodified bufhidden=wipe nowrap signcolumn=no'
else
    "${NVIM_BIN:-nvim}" -R "$snapshot"
fi
