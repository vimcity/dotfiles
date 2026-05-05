#!/bin/bash
# Session launcher - creates predefined sessions with custom window layouts
# Use this for complex multi-window setups

# Define your session templates here
declare -A sessions
declare -A session_paths
declare -A session_commands

# dotfiles session
sessions["dotfiles"]="editor"
session_paths["dotfiles"]="~/dotfiles"
session_commands["dotfiles"]="nvim"

# sesh dev session  
sessions["sesh-dev"]="editor"
session_paths["sesh-dev"]="~/Projects/sesh"
session_commands["sesh-dev"]="nvim"

# api-work example (multi-window)
sessions["api-work"]="editor,server,logs"
session_paths["api-work"]="~/Projects/api"
session_commands["api-work"]="nvim,npm run dev,tail -f logs/app.log"

# Show picker
choice=$(printf "%s\n" "${!sessions[@]}" | sort | fzf-tmux -p --prompt="launch: ")

[ -z "$choice" ] && exit 0

# Check if already exists
if tmux has-session -t "$choice" 2>/dev/null; then
  tmux switch-client -t "$choice"
  exit 0
fi

# Create session with windows
windows="${sessions[$choice]}"
path="${session_paths[$choice]}"
commands="${session_commands[$choice]}"

IFS=',' read -ra window_array <<< "$windows"
IFS=',' read -ra cmd_array <<< "$commands"

# Create first window
tmux new-session -d -s "$choice" -c "$path"
tmux send-keys -t "$choice:1" "${cmd_array[0]}" Enter
[ -n "${window_array[0]}" ] && tmux rename-window -t "$choice:1" "${window_array[0]}"

# Create additional windows
for i in "${!window_array[@]}"; do
  [ "$i" -eq 0 ] && continue
  tmux new-window -t "$choice" -n "${window_array[$i]}" -c "$path"
  tmux send-keys -t "$choice:${window_array[$i]}" "${cmd_array[$i]}" Enter
done

# Switch to it
tmux switch-client -t "$choice"
