#!/usr/bin/env bash
set -euo pipefail

snapshot="$(mktemp "${TMPDIR:-/tmp}/herdr-copy.XXXXXX")"
trap 'rm -f "$snapshot"' EXIT
hc read "$1" --json --lines 10000 |
    python3 -c 'import json,sys; sys.stdout.write(json.load(sys.stdin)["text"])' >"$snapshot"

nvim -u NONE -i NONE -n -R "$snapshot" \
    '+setlocal buftype=nofile bufhidden=wipe noswapfile nomodifiable nowrap' \
    '+set clipboard=unnamedplus number laststatus=2' \
    '+set statusline=\ frozen\ copy\ mode\ —\ v/V:select\ y:copy\ /:search\ q:close' \
    '+nnoremap <buffer> q :qa!<CR>' \
    '+normal! G'
