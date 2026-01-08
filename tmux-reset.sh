#!/bin/bash
# Complete tmux reset script

echo "=== COMPLETE TMUX RESET ==="
echo ""

# 1. Kill all tmux sessions
echo "[1/4] Killing all tmux sessions..."
tmux kill-server 2>/dev/null || echo "No tmux server running"

# 2. Remove powerline plugins
echo "[2/4] Removing old plugins..."
rm -rf ~/.tmux/plugins/tmux-powerline
rm -rf ~/.tmux/plugins/tmux-battery
rm -rf ~/.tmux/plugins/tmux-cpu

# 3. Reload tmux config
echo "[3/4] Reloading tmux configuration..."
tmux start-server
tmux source-file ~/.tmux.conf 2>/dev/null || echo "Config loaded"

# 4. Install Catppuccin plugin
echo "[4/4] Installing Catppuccin plugin..."
if [ -d ~/.tmux/plugins/tpm ]; then
  ~/.tmux/plugins/tpm/bin/install_plugins
else
  echo "TPM not found, please install it first:"
  echo "  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
fi

echo ""
echo "=== DONE ==="
echo "Now start a new tmux session:"
echo "  tmux"
echo ""
echo "The status bar should show:"
echo "  - Left: Session name (blue, red when prefix pressed)"
echo "  - Middle: Window names"
echo "  - Right: Nothing (clean!)"
