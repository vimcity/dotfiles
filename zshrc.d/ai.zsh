# Session finder shell helpers

export AI_ORCH_CACHE="${AI_ORCH_CACHE:-$HOME/.cache/ai-orchestrator}"

ais() { ai session pick "$@"; }
aisr() { ai session pick --resume "$@"; }
ail() { ai session list "$@"; }
aid() { ai doctor "$@"; }

# Org → plan → Pi in Herdr (native glue, not part of `ai`)
orgp() { "$HOME/dotfiles/bin/org-pi" "$@"; }

# Optional tmux-heavy workbench (voice, runs, dashboard)
if [[ -d "$HOME/Projects/ai-workbench/bin" ]]; then
    export PATH="$HOME/Projects/ai-workbench/bin:$PATH"
fi
