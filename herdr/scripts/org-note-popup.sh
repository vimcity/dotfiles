#!/usr/bin/env bash

set -euo pipefail

plans_dir="${ORG_PLANS_PATH:-$HOME/Documents/org/plans}"
inbox_dir="${ORG_INBOX_PATH:-$plans_dir/inbox}"
archive_dir="$plans_dir/archive"
editor="${EDITOR:-nvim}"

mkdir -p "$inbox_dir" "$archive_dir"
cd "$plans_dir"

new_note='[ new note ]'
file="$({
	printf '%s\n' "$new_note"
	fd --type f --hidden --exclude .git --exclude archive \
		--extension md --extension org \
		--ignore-file "$HOME/.fdignore" --strip-cwd-prefix .
} | fzf --height 100% \
	--layout reverse \
	--border=none \
	--prompt 'notes ❯ ' \
	--header '⌃n new  ·  ⌃a archive' \
	--preview-window 'right:70%:wrap:border-left' \
	--preview 'if [[ {} == "[ new note ]" ]]; then printf "Create a fresh Markdown note in %s\n" "$inbox_dir"; else bat --color=always --style=plain --paging=never --line-range :300 {} 2>/dev/null || file {}; fi' \
	--bind "ctrl-n:become(printf '%s\\n' '$new_note')" \
	--bind 'ctrl-a:execute-silent(bash "$HOME/dotfiles/herdr/scripts/archive-plan.sh" {})+reload(fd --type f --hidden --exclude .git --exclude archive --extension md --extension org --ignore-file "$HOME/.fdignore" --strip-cwd-prefix .)' \
	--bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
	--bind 'alt-k:preview-up,alt-j:preview-down')" || exit 0

if [[ -z "$file" ]]; then
	exit 0
fi

if [[ "$file" == "$new_note" ]]; then
	file="$inbox_dir/$(date +%Y-%m-%d-%H%M).md"
	if [[ ! -e "$file" ]]; then
		printf '# Quick note\n\n' >"$file"
	fi
else
	file="$plans_dir/$file"
fi

exec "$editor" "$file"
