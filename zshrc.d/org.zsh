# Org + optional ai-workbench PATH

orgp() { "$HOME/dotfiles/bin/org-pi" "$@"; }

if [[ -d "$HOME/Projects/ai-workbench/bin" ]]; then
    export PATH="$HOME/Projects/ai-workbench/bin:$PATH"
fi
