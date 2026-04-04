# Quick theme switcher alias
# Add to zshrc or source independently

# Shortcuts for common themes
alias theme-rp='prompt_switch_theme rose-pine'
alias theme-rf='prompt_switch_theme rose-frappe'
alias theme-cat='prompt_switch_theme catppuccin'
alias theme-nord='prompt_switch_theme nord'
alias theme-dracula='prompt_switch_theme dracula'
alias theme-minimal='prompt_switch_theme minimal'
alias theme-gruvbox='prompt_switch_theme gruvbox'

# Show available themes
alias theme-list='prompt_switch_theme'

# Quick switcher function
theme() {
    prompt_switch_theme "$1"
}
