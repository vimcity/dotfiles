#!/bin/bash
target=$(tmux list-windows -a -F '#{session_name}:#{window_index} #{window_name}' | fzf-tmux -p --prompt="Move pane to: " | awk '{print $1}')
[ -n "$target" ] && tmux join-pane -t "$target"
