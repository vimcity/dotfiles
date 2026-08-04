# ── fence sandbox ──────────────────────────────────
# Wraps Pi (and other agents) in OS-level sandboxing.
# Blocks destructive commands, credential reads, and config writes.
# See ~/.config/fence/fence.jsonc for the full policy.

# alias pi='fence -- pi'                       # Default: Fence-wrapped Pi
# alias pi-read='fence --block-net -- pi'      # No network (untrusted projects)
# alias pi-yolo='command pi'                    # Explicitly bypass Fence

# Work agent aliases (uncomment on work machine)
# alias codex='fence -- codex'
# alias claude='fence -- claude'
