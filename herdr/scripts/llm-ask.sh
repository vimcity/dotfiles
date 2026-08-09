#!/usr/bin/env bash
# Quick LLM question in current pane directory.
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

ASK_BIN="${ASK_BIN:-$HOME/dotfiles/bin/ask}"
MODE="local"
TEMPLATE=""
QUESTION=""
MENU=0

usage() {
	cat <<'EOF'
Usage: llm-ask.sh [--menu]

Without --menu, asks one local question immediately.
Modes: local (default), remote, omlx, clipboard, pane, command-help, man, nvim-help, fabric
Templates: shell-help, vim-help, error-diagnose, prompt-clean
EOF
}

choose_mode() {
	local value default="$1"
	printf 'mode [local|remote|omlx|clipboard|pane|command-help|man|nvim-help|fabric] [%s]: ' "$default" >&2
	read -r value
	printf '%s\n' "${value:-$default}"
}

choose_template() {
	local value
	printf 'template (blank for none) [shell-help|vim-help|error-diagnose|prompt-clean]: ' >&2
	read -r value
	printf '%s\n' "$value"
}

main() {
	if [[ "${1:-}" == "--menu" ]]; then
		MENU=1
		shift
	elif [[ $# -gt 0 ]]; then
		usage >&2
		exit 1
	fi

	if [[ ! -x "$ASK_BIN" ]]; then
		printf 'llm-ask: ask script not found\n' >&2
		exit 1
	fi

	if ! command -v llm >/dev/null 2>&1; then
		printf 'llm-ask: llm not installed\n' >&2
		exit 1
	fi

	if [[ "$MENU" -eq 0 ]]; then
		read -r -p 'ask: ' QUESTION
		[[ -n "$QUESTION" ]] || exit 0
		"$ASK_BIN" "$QUESTION"
		exit 0
	fi

	MODE="$(choose_mode local)"
	TEMPLATE="$(choose_template)"

	case "$MODE" in
	clipboard)
		if [[ -n "$TEMPLATE" ]]; then
			"$ASK_BIN" -t "$TEMPLATE" -c
		else
			"$ASK_BIN" -c
		fi
		exit 0
		;;
	pane)
		read -r -p 'question: ' QUESTION
		[[ -n "$QUESTION" ]] || {
			printf 'llm-ask: empty question\n' >&2
			exit 1
		}
		if [[ -n "$TEMPLATE" ]]; then
			"$ASK_BIN" -t "$TEMPLATE" -p "$QUESTION"
		else
			"$ASK_BIN" -p "$QUESTION"
		fi
		exit 0
		;;
	command-help)
		local command_name
		read -r -p 'command: ' command_name
		read -r -p 'question: ' QUESTION
		[[ -n "$command_name" && -n "$QUESTION" ]] || exit 0
		"$ASK_BIN" --help-for "$command_name" "$QUESTION"
		exit 0
		;;
	man)
		local man_topic
		read -r -p 'man topic: ' man_topic
		read -r -p 'question: ' QUESTION
		[[ -n "$man_topic" && -n "$QUESTION" ]] || exit 0
		"$ASK_BIN" --man "$man_topic" "$QUESTION"
		exit 0
		;;
	nvim-help)
		local help_topic
		read -r -p 'Neovim help topic: ' help_topic
		read -r -p 'question: ' QUESTION
		[[ -n "$help_topic" && -n "$QUESTION" ]] || exit 0
		"$ASK_BIN" --nvim-help "$help_topic" "$QUESTION"
		exit 0
		;;
	fabric)
		local fabric_pattern
		read -r -p 'Fabric pattern: ' fabric_pattern
		read -r -p 'input: ' QUESTION
		[[ -n "$fabric_pattern" && -n "$QUESTION" ]] || exit 0
		"$ASK_BIN" --pattern "$fabric_pattern" "$QUESTION"
		exit 0
		;;
	esac

	read -r -p 'question: ' QUESTION
	if [[ -z "$QUESTION" ]]; then
		printf 'llm-ask: empty question\n' >&2
		exit 1
	fi

	local ask_args=()
	case "$MODE" in
	remote) ask_args=(-r) ;;
	omlx) ask_args=(--omlx) ;;
	local | *) ask_args=() ;;
	esac

	if [[ -n "$TEMPLATE" ]]; then
		ask_args+=(-t "$TEMPLATE")
	fi

	"$ASK_BIN" "${ask_args[@]}" "$QUESTION"
}

main "$@"
