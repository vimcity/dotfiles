#!/usr/bin/env bash

set -euo pipefail

cpu_usage() {
    top -l 1 -n 0 2>/dev/null |
        awk '/CPU usage:/ {gsub(/%/, "", $3); gsub(/%/, "", $5); printf "%.0f", $3 + $5; exit}'
}

memory_usage() {
    local total_bytes page_size
    total_bytes="$(sysctl -n hw.memsize 2>/dev/null || true)"
    page_size="$(vm_stat 2>/dev/null | awk '/page size of/ {print $8; exit}')"

    [[ -n "$total_bytes" && -n "$page_size" ]] || return 0

    # Match btop's useful-memory view on macOS: wired + active pages.
    # Inactive/file-backed pages are reclaimable cache, so counting them makes
    # memory look almost full even when the system has plenty of headroom.
    vm_stat 2>/dev/null | awk -v total="$total_bytes" -v page_size="$page_size" '
        /Pages active:/ {active = $3}
        /Pages wired down:/ {wired = $4}
        END {
            gsub(/\./, "", active)
            gsub(/\./, "", wired)
            printf "%.0f", ((active + wired) * page_size * 100) / total
        }
    '
}

cpu="$(cpu_usage)"
mem="$(memory_usage)"
cwd="${HERDR_ACTIVE_PANE_CWD:-}"

if [[ -n "$cwd" ]]; then
    if [[ "$cwd" == "$HOME"/* ]]; then
        cwd="~/${cwd#"$HOME"/}"
    fi
    if (( ${#cwd} > 36 )); then
        cwd="…${cwd: -35}"
    fi
fi

status=""
append_status() {
    [[ -n "$status" ]] && status+="  "
    status+="$1"
}

[[ -n "$cwd" ]] && append_status " ${cwd}"
[[ -n "$cpu" ]] && append_status "󰓅 ${cpu}%"
[[ -n "$mem" ]] && append_status "󰍛 ${mem}%"

printf '%s\n' "$status"
