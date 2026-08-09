# ===========================================
# Prompt Theme System
# ===========================================
# Easy switching between different prompt themes

# Set current theme (can override in .zshrc.local or shell session)
THEME_STATE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/theme"
if [[ -z "$PROMPT_THEME" && -f "$THEME_STATE_FILE" ]]; then
    PROMPT_THEME="$(<"$THEME_STATE_FILE")"
fi
export PROMPT_THEME="${PROMPT_THEME:-catppuccin-rose}"

# Define theme colors and styles
# Neovim (lualine) mirrors these in nvim/lua/config/dotfiles_prompt_colors.lua — keep in sync.
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
        [venv_bg]="#74c678"
        [venv_fg]="#1e1e2e"
        
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
        [prompt_char]="#ec8aba"
        
        # Metadata
        [name]="catppuccin-rose"
        [description]="Catppuccin Frappe with Rose rose colors"
    )
}

# Catppuccin Frappe Theme (lower contrast alternative)
define_catppuccin_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#414559"
        [user_fg]="#c6d0f5"
        [dir_bg]="#8caaee"
        [dir_fg]="#303446"
        [git_bg]="#292c3c"
        [git_fg]="#8caaee"
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
