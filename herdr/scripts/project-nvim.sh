#!/usr/bin/env bash
set -euo pipefail

projects_dir="${PROJECTS_DIR:-$HOME/Projects}"

payload="$(herdr tab create --workspace "$(herdr workspace list | jq -r '.result.workspaces[] | select(.focused == true) | .workspace_id // empty')" --label nvim --cwd "$projects_dir" --focus)"

pane_id="$(printf '%s' "$payload" | jq -r '.result.root_pane.pane_id // empty')"

if [[ -z "$pane_id" ]]; then
    printf 'Herdr did not return a new tab pane\n' >&2
    exit 1
fi

cmd="cd \"$projects_dir\" && exec nvim"
exec herdr pane run "$pane_id" "$cmd"
