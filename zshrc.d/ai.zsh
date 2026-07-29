# AI orchestrator shell helpers

export AI_ORCH_CACHE="${AI_ORCH_CACHE:-$HOME/.cache/ai-orchestrator}"
export ORG_PATH="${ORG_PATH:-$HOME/Documents/org}"
export ORG_FILE="${ORG_FILE:-$ORG_PATH/todos.org}"

# Optional full workbench (org voice/tmux flows) — Herdr-first orchestrator lives in `ai`.
if [[ -d "$HOME/Projects/ai-workbench/bin" ]]; then
    export PATH="$HOME/Projects/ai-workbench/bin:$PATH"
fi

ais() { ai session pick "$@"; }
aisr() { ai session pick --resume "$@"; }
ail() { ai session list "$@"; }
aip() { ai plan create "$@"; }
aipl() { ai plan launch "$@"; }
aips() { ai plan snapshot "$@"; }
aid() { ai doctor "$@"; }
