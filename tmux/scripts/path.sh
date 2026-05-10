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

# Green color for directory (fresh, vibrant look)
# bg_color='#8CA0E8'
fg_color='#7287fd'
text_dark="#000000" # Dark text for contrast

# Output with colored text without pill box
# Format: [color code] icon path [reset]
printf "#[fg=%s,bg=%s,bold]%s %s#[default]" "$text_dark" "$fg_color" " $icon" "$display_path "
