# ===========================================
# Prompt Theme System
# ===========================================
# Easy switching between different prompt themes
# Current themes: rose-pine (default), alt-theme, minimal

# Set current theme (can override in .zshrc.local or shell session)
export PROMPT_THEME="${PROMPT_THEME:-rose-pine}"

# Define theme colors and styles
declare -A THEME_COLORS

# Rose Pine Theme (current - warm, cozy, sophisticated)
# Colors: soft purples, pinks, and earth tones
define_rose_pine_theme() {
    THEME_COLORS=(
        # Main segments - Rose Pine Moon (darker variant)
        [user_bg]="#323238"
        [user_fg]="#ebbcba"
        [dir_bg]="#d08cbe"
        [dir_fg]="#191724"
        [git_bg]="#2a283e"
        [git_fg]="#ebbcba"
        [venv_bg]="#323238"
        [venv_fg]="#c4a7e7"
        
        # Git status colors - Rose Pine Moon palette
        [git_added]="#a6da95"
        [git_modified]="#f5e0ac"
        [git_deleted]="#eb6f92"
        [git_renamed]="#9ccfd8"
        [git_unmerged]="#eb6f92"
        [git_untracked]="#f6a192"
        [git_ahead]="#c4a7e7"
        [git_behind]="#ab9dc9"
        
        # Right prompt
        [right_bg]="#323238"
        [right_fg]="#f5e0ac"
        [error_fg]="#eb6f92"
        [prompt_char]="#ebbcba"
        
        # Metadata
        [name]="rose-pine"
        [description]="Rose Pine Moon - darker with pink/rose accents"
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
        [venv_bg]="#45475a"
        [venv_fg]="#cba6f7"
        
        # Git status colors
        [git_added]="#a6e3a1"
        [git_modified]="#f9e2af"
        [git_deleted]="#f38ba8"
        [git_renamed]="#89b4fa"
        [git_unmerged]="#f38ba8"
        [git_untracked]="#fab387"
        [git_ahead]="#94e2d5"
        [git_behind]="#74c7ec"
        
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
# Colors: arctic blues and greens
define_nord_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#4c566a"
        [user_fg]="#eceff4"
        [dir_bg]="#88c0d0"
        [dir_fg]="#2e3440"
        [git_bg]="#3b4252"
        [git_fg]="#88c0d0"
        [venv_bg]="#4c566a"
        [venv_fg]="#81a1c1"
        
        # Git status colors
        [git_added]="#a3be8c"
        [git_modified]="#ebcb8b"
        [git_deleted]="#bf616a"
        [git_renamed]="#81a1c1"
        [git_unmerged]="#bf616a"
        [git_untracked]="#d08770"
        [git_ahead]="#b48ead"
        [git_behind]="#5e81ac"
        
        # Right prompt
        [right_bg]="#4c566a"
        [right_fg]="#ebcb8b"
        [error_fg]="#bf616a"
        [prompt_char]="#d08770"
        
        # Metadata
        [name]="nord"
        [description]="Cool Arctic Nord theme with professional colors"
    )
}

# Minimal Theme (monochrome, clean)
# Colors: mostly grays and whites
define_minimal_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#333333"
        [user_fg]="#ffffff"
        [dir_bg]="#555555"
        [dir_fg]="#ffffff"
        [git_bg]="#222222"
        [git_fg]="#888888"
        [venv_bg]="#333333"
        [venv_fg]="#cccccc"
        
        # Git status colors
        [git_added]="#77dd77"
        [git_modified]="#ffcc99"
        [git_deleted]="#ff6666"
        [git_renamed]="#6699ff"
        [git_unmerged]="#ff6666"
        [git_untracked]="#ffaa66"
        [git_ahead]="#99ccff"
        [git_behind]="#6699cc"
        
        # Right prompt
        [right_bg]="#333333"
        [right_fg]="#999999"
        [error_fg]="#ff6666"
        [prompt_char]="#cccccc"
        
        # Metadata
        [name]="minimal"
        [description]="Clean monochrome minimal theme"
    )
}

# Dracula Theme (dark and vibrant)
# Colors: bold purples and pinks
define_dracula_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#44475a"
        [user_fg]="#f8f8f2"
        [dir_bg]="#bd93f9"
        [dir_fg]="#282a36"
        [git_bg]="#282a36"
        [git_fg]="#bd93f9"
        [venv_bg]="#44475a"
        [venv_fg]="#8be9fd"
        
        # Git status colors
        [git_added]="#50fa7b"
        [git_modified]="#f1fa8c"
        [git_deleted]="#ff79c6"
        [git_renamed]="#8be9fd"
        [git_unmerged]="#ff79c6"
        [git_untracked]="#ffb86c"
        [git_ahead]="#a1efe4"
        [git_behind]="#6272a4"
        
        # Right prompt
        [right_bg]="#44475a"
        [right_fg]="#f1fa8c"
        [error_fg]="#ff79c6"
        [prompt_char]="#ffb86c"
        
        # Metadata
        [name]="dracula"
        [description]="Dark and vibrant Dracula theme"
    )
}

# Gruvbox Dark Theme (retro groove)
# Colors: warm earth tones
define_gruvbox_theme() {
    THEME_COLORS=(
        # Main segments
        [user_bg]="#504945"
        [user_fg]="#fbf1c7"
        [dir_bg]="#83a598"
        [dir_fg]="#282828"
        [git_bg]="#3c3836"
        [git_fg]="#83a598"
        [venv_bg]="#504945"
        [venv_fg]="#d3869b"
        
        # Git status colors
        [git_added]="#b8bb26"
        [git_modified]="#d79921"
        [git_deleted]="#fb4934"
        [git_renamed]="#83a598"
        [git_unmerged]="#fb4934"
        [git_untracked]="#fe8019"
        [git_ahead]="#8ec07c"
        [git_behind]="#458588"
        
        # Right prompt
        [right_bg]="#504945"
        [right_fg]="#d79921"
        [error_fg]="#fb4934"
        [prompt_char]="#fe8019"
        
        # Metadata
        [name]="gruvbox"
        [description]="Warm retro Gruvbox theme with earth tones"
    )
}

# Load theme based on PROMPT_THEME variable
prompt_load_theme() {
    local theme="${1:-$PROMPT_THEME}"
    
    case "$theme" in
        rose-pine)
            define_rose_pine_theme
            ;;
        catppuccin|mocha)
            define_catppuccin_theme
            ;;
        nord)
            define_nord_theme
            ;;
        minimal)
            define_minimal_theme
            ;;
        dracula)
            define_dracula_theme
            ;;
        gruvbox)
            define_gruvbox_theme
            ;;
        *)
            echo "Unknown theme: $theme. Using rose-pine."
            define_rose_pine_theme
            ;;
    esac
    
    export PROMPT_THEME="$theme"
}

# Function to switch themes at runtime
prompt_switch_theme() {
    local new_theme="$1"
    
    if [[ -z "$new_theme" ]]; then
        echo "Available themes:"
        echo "  rose-pine  - Warm, cozy Rose Pine (default)"
        echo "  catppuccin - Bold Catppuccin Mocha"
        echo "  nord       - Cool Arctic Nord"
        echo "  minimal    - Clean monochrome"
        echo "  dracula    - Dark and vibrant"
        echo "  gruvbox    - Warm retro Gruvbox"
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
