#!/usr/bin/env bash

set -euo pipefail

plans_dir="${ORG_PLANS_PATH:-$HOME/Documents/org/plans}"

if [[ ! -d "$plans_dir" ]]; then
	printf 'Plans directory not found: %s\n' "$plans_dir" >&2
	exit 1
fi

cd "$plans_dir"

file="$(
	fd --type f --hidden --exclude .git --exclude archive \
		--ignore-file "$HOME/.fdignore" --strip-cwd-prefix . |
		fzf --height 100% \
			--layout reverse \
			--border \
			--delimiter=/ \
			--with-nth=-1 \
			--prompt 'plan> ' \
			--preview-window 'right:70%:wrap' \
			--preview 'bat --color=always --style=header,grid --line-range :300 {} 2>/dev/null || file {}' \
			--bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
			--bind 'alt-k:preview-up,alt-j:preview-down'
)" || exit 0

[[ -n "$file" ]] || exit 0

if [[ "$file" != /* ]]; then
	file="$plans_dir/$file"
fi

exec "${EDITOR:-nvim}" "$file"
