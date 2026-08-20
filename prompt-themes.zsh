# ===========================================
# Prompt Theme System
# ===========================================
# Keep the prompt aligned with the official Catppuccin Frappé palette.
export PROMPT_THEME="catppuccin"

# Define theme colors and styles
declare -A THEME_COLORS

# Catppuccin Frappe Theme (lower contrast alternative)
define_catppuccin_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#414559"
        [user_fg]="#c6d0f5"
        [dir_bg]="#7287fd"
        [dir_fg]="#303446"
        [git_bg]="#292c3c"
        [git_fg]="#bd93f9"
        [git_icon]="#a6d189"
        [venv_bg]="#414559"
        [venv_fg]="#a6d189"
        
        # Git status colors
        [git_added]="#a6d189"
        [git_modified]="#e5c890"
        [git_deleted]="#e78284"
        [git_renamed]="#8caaee"
        [git_unmerged]="#e78284"
        [git_untracked]="#ef9f76"
        [git_ahead]="#81c8be"
        [git_behind]="#99d1db"
        [git_stash]="#85c1dc"
        
        # Right prompt
        [right_bg]="#414559"
        [right_fg]="#e5c890"
        [error_fg]="#e78284"
        [prompt_char]="#ef9f76"
        
        # Metadata
        [name]="catppuccin"
        [description]="Bold Catppuccin Mocha theme with high contrast"
    )
}

# Initialize the single official theme on startup.
prompt_load_theme() {
    define_catppuccin_theme
}

prompt_load_theme

# Also add color getter for convenience
get_theme_color() {
    local color_name="$1"
    echo "${THEME_COLORS[$color_name]}"
}
