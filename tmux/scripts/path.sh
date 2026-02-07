#!/bin/bash
# ============================================================================
# TMUX Current Working Directory Display Script
# ============================================================================
# Displays the current pane's working directory in a stylish pill box
# Colors: Catppuccin Frappe palette
# ============================================================================

# Get current pane path from tmux
current_path="$(tmux display-message -p '#{pane_current_path}')"

# Abbreviate home directory to ~
if [[ "$current_path" == "$HOME"* ]]; then
  display_path="~${current_path#$HOME}"
else
  display_path="$current_path"
fi

# Limit length for display (truncate if too long)
if [ ${#display_path} -gt 40 ]; then
  display_path="...${display_path: -37}"
fi

# Folder nerd icon
icon=""

# Catppuccin colors - using purple/pink for directory
bg_color="#c6a0f6"  # Catppuccin Frappe Lavender (purple/pink)
text_dark="#000000" # Dark text for contrast

# Output with TMUX color codes for pill box styling
# Format: [color code] space icon path space [reset]
printf "#[bg=%s,fg=%s,bold] %s %s #[default]" "$bg_color" "$text_dark" "$icon" "$display_path"
