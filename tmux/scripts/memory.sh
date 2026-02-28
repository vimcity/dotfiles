#!/bin/bash
# ============================================================================
# TMUX Memory Display Script - Btop-style Memory Calculation with Color Coding
# ============================================================================
# Displays memory usage with nerd icon, percentage, and color based on usage
# Used: (active + wired) pages * page size
# Colors: Green (0-50%), Yellow (50-80%), Red (80%+)
# Output includes TMUX color codes for pill box styling
# ============================================================================

# Get page size in bytes (typically 4096)
pagesize=$(vm_stat | head -1 | grep -oE '[0-9]+')

# Get active pages count
active=$(vm_stat | grep "Pages active:" | grep -oE '[0-9]+' | tail -1)

# Get wired pages count
wired=$(vm_stat | grep "Pages wired down:" | grep -oE '[0-9]+')

# Get total memory in bytes
total_bytes=$(sysctl -n hw.memsize)

# Calculate used memory in bytes: (active + wired) * pagesize
used_bytes=$((($active + $wired) * pagesize))

# Convert to GB
used_gb=$(printf "%.1f" $((used_bytes / 1073741824)))

# Calculate percentage
percentage=$((used_bytes * 100 / total_bytes))

# RAM nerd icon (󰍛)
icon="󰍛"

# Color scheme
green="#a6e3a1"     # Green (healthy)
yellow="#ef9f76"    # More orangy yellow (warning)
red="#e25a8a"       # Red (matches prefix color, critical)
text_dark="#000000" # Dark text for contrast

# Determine color based on percentage (thirds: 0-33% green, 33-67% yellow, 67%+ red)
if [ "$percentage" -lt 33 ]; then
    bg_color="$green"
elif [ "$percentage" -lt 67 ]; then
    bg_color="$yellow"
else
    bg_color="$red"
fi

# Output colored text without pill box
# Format: [color code] icon used_gb (percentage%) [reset]
printf "#[fg=%s,bold]%s %sGB (%s%%)#[default]" "$bg_color" "$icon" "$used_gb" "$percentage"
