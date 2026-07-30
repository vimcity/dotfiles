# ── fence sandbox ──────────────────────────────────
# Wraps Pi (and other agents) in OS-level sandboxing.
# Blocks destructive commands, credential reads, and config writes.
# See ~/.config/fence/fence.jsonc for the full policy.

alias pi='fence -- pi'                       # Default: fence-wrapped Pi
alias pi-read='fence --block-net -- pi'      # No network (untrusted projects)
alias pi-yolo='pi'                           # pi is fenced by default; for true yolo: command -v pi

# Work agent aliases (uncomment on work machine)
# alias codex='fence -- codex'
# alias claude='fence -- claude'