# ===========================================
# Prompt Theme System
# ===========================================
# Easy switching between different prompt themes

# Set current theme (can override in .zshrc.local or shell session)
export PROMPT_THEME="${PROMPT_THEME:-catppuccin-rose}"

# Define theme colors and styles
declare -A THEME_COLORS

define_catppuccin_rose_theme() {
    THEME_COLORS=(
        # Main segments - Catppuccin Frappe base
        [user_bg]="#45475a"
        [user_fg]="#f5f5f5"
        [dir_bg]="#7287fd"
        [dir_fg]="#1e1e2e"
        # [git_fg]="#d679a2"
        [git_fg]="#bd93f9"
        [git_bg]="#302e4b"
        [git_icon]="#a6da95"
        [venv_bg]="#45475a"
        [venv_fg]="#cba6f7"
        
        [git_added]="#f6a192"
        [git_modified]="#f9e2af"
        [git_deleted]="#eb6f92"
        [git_renamed]="#9ccfd8"
        [git_unmerged]="#eb6f92"
        [git_untracked]="#f6a192"
        [git_ahead]="#c4a7e7"
        [git_behind]="#a6da95"
        [git_stash]="#99d1db"
        
        # Right prompt
        [right_bg]="#45475a"
        [right_fg]="#f9e2af"
        [error_fg]="#eb6f92"
        [prompt_char]="#ebbcba"
        
        # Metadata
        [name]="catppuccin-rose"
        [description]="Catppuccin Frappe with Rose rose colors"
    )
}

# Catppuccin Mocha Theme (dark alternative)
# Colors: bold, modern, high contrast
define_catppuccin_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#45475a"
        [user_fg]="#f5f5f5"
        [dir_bg]="#89b4fa"
        [dir_fg]="#1e1e2e"
        [git_bg]="#313244"
        [git_fg]="#89b4fa"
        [git_icon]="#a6e3a1"
        [venv_bg]="#45475a"
        [venv_fg]="#a6e3a1"
        
        # Git status colors
        [git_added]="#a6e3a1"
        [git_modified]="#f9e2af"
        [git_deleted]="#f38ba8"
        [git_renamed]="#89b4fa"
        [git_unmerged]="#f38ba8"
        [git_untracked]="#fab387"
        [git_ahead]="#94e2d5"
        [git_behind]="#74c7ec"
        [git_stash]="#89dceb"
        
        # Right prompt
        [right_bg]="#45475a"
        [right_fg]="#f9e2af"
        [error_fg]="#f38ba8"
        [prompt_char]="#fab387"
        
        # Metadata
        [name]="catppuccin"
        [description]="Bold Catppuccin Mocha theme with high contrast"
    )
}

# Nord Theme (cool, professional)
# [dir_bg]="#88c0d0"
# [dir_bg]="#f38ba8"
# [git_icon]="#a3be8c"
# [git_modified]="#ebcb8b"
# [git_deleted]="#bf616a"
# [error_fg]="#bf616a"
# [git_behind]="#5e81ac"
# [git_unmerged]="#ff79c6"
# [dir_bg]="#bd93f9"
# [venv_fg]="#d3869b"
# [git_deleted]="#fb4934"
# [git_ahead]="#8ec07c"
# [git_behind]="#458588"
# [git_stash]="#83a598"
        

# Load theme based on PROMPT_THEME variable
prompt_load_theme() {
    local theme="${1:-$PROMPT_THEME}"
    
    case "$theme" in
        catppuccin-rose)
            define_catppuccin_rose_theme
            ;;
        catppuccin)
            define_catppuccin_theme
            ;;
        *)
            define_catppuccin_rose_theme
            ;;
    esac
    
    export PROMPT_THEME="$theme"
}

# Function to switch themes at runtime
prompt_switch_theme() {
    local new_theme="$1"
    
    if [[ -z "$new_theme" ]]; then
        echo "Available themes:"
        echo "  catppuccin - Bold Catppuccin"
        echo "  catppuccin-rose - Catppuccin Rose"
        echo ""
        echo "Current theme: $PROMPT_THEME"
        echo ""
        echo "Usage: prompt_switch_theme <theme_name>"
        return 1
    fi
    
    prompt_load_theme "$new_theme"
    echo "Switched to theme: ${THEME_COLORS[name]}"
    echo "${THEME_COLORS[description]}"
}

# Initialize with default theme on startup
prompt_load_theme "$PROMPT_THEME"

# Also add color getter for convenience
get_theme_color() {
    local color_name="$1"
    echo "${THEME_COLORS[$color_name]}"
}
