#!/bin/bash
# Session picker with preview
# Shows active sessions + predefined templates
# Preview pane on right (customizable size)

# Get active sessions with current path
active_sessions=$(tmux list-sessions -F '#{session_name} | #{pane_current_path}' 2>/dev/null)

# Predefined templates (these will create new sessions if selected)
templates=$(cat <<'EOF'
dotfiles | ~/dotfiles
sesh-dev | ~/Projects/sesh
EOF
)

# Combine and dedupe (active sessions take precedence)
all_sessions=$(echo -e "$active_sessions\n$templates" | awk -F' | ' '!seen[$1]++')

# Show picker with preview
selected=$(echo "$all_sessions" | fzf-tmux -p 80%,70% \
  --prompt="session: " \
  --delimiter=' | ' \
  --with-nth=1 \
  --preview '
    session=$(echo {1} | xargs)
    if tmux has-session -t "$session" 2>/dev/null; then
      tmux capture-pane -t "$session:" -p -S -20 2>/dev/null || echo "Session exists but no preview available"
    else
      echo "New session: $session"
      echo "Path: {2}"
    fi
  ' \
  --preview-window=right:60%:wrap)

[ -z "$selected" ] && exit 0

session_name=$(echo "$selected" | awk -F' | ' '{print $1}' | xargs)
path=$(echo "$selected" | awk -F' | ' '{print $3}' | xargs)

# Switch to existing or create new
if tmux has-session -t "$session_name" 2>/dev/null; then
  tmux switch-client -t "$session_name"
else
  tmux new-session -d -s "$session_name" -c "$path"
  tmux switch-client -t "$session_name"
fi
