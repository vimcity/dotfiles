#!/usr/bin/env bash
# Launch tuicr for GitHub PR review inside tmux.
#
# Usage:
#   tuicr-pr.sh              fzf-pick an open PR in the current repo
#   tuicr-pr.sh 123          review PR #123 in the current repo
#   tuicr-pr.sh -w           review uncommitted changes (local)
#   tuicr-pr.sh review       PRs requesting your review (current or focus repos)

set -euo pipefail

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
GH_HOST="${GH_HOST:-github.sie.sony.com}"
MODE="${1:-pick}"

die() {
	printf 'tuicr-pr: %s\n' "$*" >&2
	exit 1
}

require() {
	for cmd in "$@"; do
		command -v "$cmd" >/dev/null 2>&1 || die "required command not found: $cmd"
	done
}

repo_root() {
	git rev-parse --show-toplevel 2>/dev/null || true
}

repo_slug() {
	GH_HOST="$GH_HOST" gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true
}

detect_pr_number() {
	local branch pr
	branch=$(git branch --show-current 2>/dev/null || true)
	[[ -n "$branch" ]] || return 1
	pr=$(GH_HOST="$GH_HOST" gh pr view "$branch" --json number --jq '.number' 2>/dev/null || true)
	[[ -n "$pr" && "$pr" != "null" ]] || return 1
	printf '%s' "$pr"
}

pick_pr_number() {
	local slug json count selected number
	slug=$(repo_slug)
	[[ -n "$slug" ]] || die "not in a git repo with gh remote"

	json=$(GH_HOST="$GH_HOST" gh pr list --repo "$slug" --state open \
		--json number,title,author,updatedAt,reviewDecision,isDraft \
		--limit 100) || die "gh pr list failed"

	count=$(jq 'length' <<<"$json")
	[[ "$count" -gt 0 ]] || die "no open PRs in $slug"

	selected=$(
		jq -r '.[] |
			"\(.number)\t#\(.number)\t\(.title)\t@\(.author.login)\t\(.reviewDecision // "open")"' <<<"$json" |
			fzf --delimiter=$'\t' --with-nth=2.. \
				--prompt="tuicr> " \
				--header="Pick a PR to review in tuicr  (enter: open)" \
				--reverse --height=55% --min-height=12
	) || exit 0

	[[ -n "$selected" ]] || exit 0
	printf '%s' "$selected" | cut -f1
}

launch_tuicr() {
	local root="$1"
	shift
	local win_name="tuicr-$(basename "$root")"

	if [[ -n "${TMUX:-}" ]]; then
		tmux new-window -n "$win_name" -c "$root" "tuicr $*; printf '\nPress enter to close…'; read -r"
	else
		( cd "$root" && exec tuicr "$@" )
	fi
}

require tuicr gh git

case "$MODE" in
-h | --help | help)
	cat <<EOF
Usage:
  tuicr-pr.sh              Pick an open PR in the current repo (fzf)
  tuicr-pr.sh <number>     Review PR #N in the current repo
  tuicr-pr.sh -w           Review uncommitted changes in the current repo
  tuicr-pr.sh review       Pick from PRs requesting your review (ghprs-style)

Environment:
  GH_HOST       GitHub host (default: github.sie.sony.com)
  PROJECTS_DIR  Local clone root (default: ~/Projects)
EOF
	exit 0
	;;
-w)
	root=$(repo_root)
	[[ -n "$root" ]] || die "not inside a git repository"
	launch_tuicr "$root" -w
	;;
review)
	# Org/focus-repo queue lives in gh-pr-dash (C-g) or ghprs (P).
	# From a repo checkout, fall back to open PRs here.
	root=$(repo_root)
	[[ -n "$root" ]] || die "not inside a git repository"
	number=$(pick_pr_number)
	launch_tuicr "$root" pr "$number"
	;;
*[!0-9]*)
	die "unknown mode: $MODE (try --help)"
	;;
*)
	root=$(repo_root)
	[[ -n "$root" ]] || die "not inside a git repository"
	launch_tuicr "$root" pr "$MODE"
	;;
pick)
	root=$(repo_root)
	[[ -n "$root" ]] || die "not inside a git repository"

	if number=$(detect_pr_number); then
		launch_tuicr "$root" pr "$number"
	else
		number=$(pick_pr_number)
		launch_tuicr "$root" pr "$number"
	fi
	;;
esac
