# 🎨 Themeable Prompt System - Complete Summary

Your shell prompt is now fully themeable with 6 beautiful themes and instant switching!

## What Changed

### New Files Added
1. **prompt-themes.zsh** - Theme definitions with 6 themes
2. **theme-switcher.zsh** - Convenient aliases and commands
3. **PROMPT_THEMES.md** - Complete documentation
4. **PROMPT_THEMES_DEMO.md** - Visual demonstrations

### Files Modified
- **zshrc** - Updated to use themeable colors
  - Now sources `prompt-themes.zsh`
  - All hardcoded colors replaced with `${THEME_COLORS[key]}`
  - Instant theme switching without shell restart

## Quick Start

```bash
# Switch themes instantly
theme-rp          # Rose Pine (default, warm and cozy)
theme-cat         # Catppuccin (bold and modern)
theme-nord        # Nord (cool and professional)
theme-dracula     # Dracula (dark and vibrant)
theme-minimal     # Minimal (clean and simple)
theme-gruvbox     # Gruvbox (warm and retro)

# Or use function for flexibility
theme catppuccin
theme rose-pine

# See all available themes
theme-list
```

## The 6 Themes

| Theme | Vibe | Best For |
|-------|------|----------|
| **Rose Pine** | Warm, sophisticated | Default, beautiful everywhere |
| **Catppuccin** | Bold, modern, high-contrast | Clarity and energy |
| **Nord** | Cool, professional, arctic | Work environments |
| **Dracula** | Dark, vibrant, trendy | Dark theme enthusiasts |
| **Minimal** | Clean, simple, monochrome | Focus and distraction-free |
| **Gruvbox** | Warm, retro, comfortable | Cozy, earth-tone lovers |

## How It Works

### Theme Loading Flow

```
startup
  ↓
zshrc sources prompt-themes.zsh
  ↓
prompt_load_theme("rose-pine") [or PROMPT_THEME env var]
  ↓
define_rose_pine_theme()
  ↓
THEME_COLORS array populated (22 colors)
  ↓
Prompt functions use ${THEME_COLORS[key]} instead of hardcoded values
  ↓
Beautiful themed prompt ready!
```

### Instant Switching

```bash
# Type any of these
theme-cat          # Updates THEME_COLORS
                   # Next prompt render uses new colors
                   # ✨ Theme changed instantly!
```

No shell restart needed! The prompt re-renders when you press Enter.

## Customization

### Persist Your Theme Choice

Add to `~/.zshrc.local`:

```bash
export PROMPT_THEME="catppuccin"  # Your preferred theme
```

### Create Custom Themes

1. Edit `prompt-themes.zsh`
2. Add a new `define_my_theme()` function with 22 color definitions
3. Add it to the `prompt_load_theme()` case statement
4. Use: `theme my-theme`

### Modify Existing Themes

Simply edit the color values in `prompt-themes.zsh`:

```bash
define_rose_pine_theme() {
    THEME_COLORS=(
        [dir_bg]="#NEW_COLOR"  # Change any color
        # ... etc ...
    )
}
```

## Files Reference

### prompt-themes.zsh (295 lines)
- `define_rose_pine_theme()`
- `define_catppuccin_theme()`
- `define_nord_theme()`
- `define_dracula_theme()`
- `define_minimal_theme()`
- `define_gruvbox_theme()`
- `prompt_load_theme()` - Load theme by name
- `prompt_switch_theme()` - Switch at runtime with feedback
- `get_theme_color()` - Utility to get color values

### theme-switcher.zsh
- Aliases: `theme-rp`, `theme-cat`, `theme-nord`, `theme-dracula`, `theme-minimal`, `theme-gruvbox`
- Function: `theme <name>` - Flexible switcher
- Help: `theme-list` - Show all themes

### zshrc (Updated)
- Sourced `prompt-themes.zsh` after color setup
- Updated all prompt functions to use `${THEME_COLORS[...]}`:
  - `prompt_context_segment()`
  - `prompt_dir_segment()`
  - `prompt_venv_segment()`
  - `prompt_git_segment()`
  - `prompt_build_right()`
  - Prompt character color

## Color Categories

### Segment Colors (8)
- user_bg, user_fg - SSH/root indicator
- dir_bg, dir_fg - Directory path
- git_bg, git_fg - Git branch/status
- venv_bg, venv_fg - Virtual environment

### Git Status Colors (8)
- git_added - Staged files (●)
- git_modified - Unstaged changes (✚)
- git_deleted - Deleted files (✖)
- git_renamed - Renamed files (➜)
- git_unmerged - Merge conflicts (═)
- git_untracked - Untracked files (◌)
- git_ahead - Commits ahead (⇡)
- git_behind - Commits behind (⇣)

### Status Colors (6)
- right_bg, right_fg - Right prompt (duration, jobs)
- error_fg - Error code color
- prompt_char - The $ character

## Features

✅ **6 Beautiful Themes** - Each with distinct personality  
✅ **Instant Switching** - No shell restart needed  
✅ **Easy Aliases** - `theme-cat`, `theme-nord`, etc.  
✅ **Flexible Function** - `theme catppuccin`  
✅ **Persistent Config** - Set in `.zshrc.local`  
✅ **Customizable** - Add your own themes  
✅ **Documented** - Full guides and examples  
✅ **Zero Dependencies** - Pure Zsh arrays  

## Commands

```bash
# Switch using aliases (fastest)
theme-rp          # Rose Pine
theme-cat         # Catppuccin
theme-nord        # Nord
theme-dracula     # Dracula
theme-minimal     # Minimal
theme-gruvbox     # Gruvbox

# Switch using function (flexible)
theme rose-pine
theme catppuccin
theme "custom-theme"

# Show available themes and current
theme-list        # or: prompt_switch_theme

# Check current theme
echo $PROMPT_THEME

# Reload to apply theme from environment
source ~/.zshrc
```

## Examples

### Machine-Specific Themes

```bash
# In ~/.zshrc.local
if [[ $(hostname) == "work-laptop" ]]; then
    export PROMPT_THEME="nord"      # Professional for work
else
    export PROMPT_THEME="rose-pine"  # Cozy at home
fi
```

### Time-Based Themes

```bash
# In ~/.zshrc.local
HOUR=$(date +%H)
if [[ $HOUR -ge 18 || $HOUR -lt 6 ]]; then
    export PROMPT_THEME="dracula"  # Dark at night
else
    export PROMPT_THEME="rose-pine"  # Warm during day
fi
```

## Troubleshooting

### Theme not switching
Ensure prompt-themes.zsh is sourced:
```bash
grep "source.*prompt-themes" ~/.zshrc
```

### Colors look wrong
Check 24-bit color support:
```bash
echo $COLORTERM  # Should be: truecolor
```

### Can't use aliases
Make sure theme-switcher.zsh is sourced at end of zshrc:
```bash
source ~/dotfiles/theme-switcher.zsh
```

## Next Steps

1. **Try all themes**: Use each one for a bit
2. **Pick your favorite**: Set in `~/.zshrc.local`
3. **Customize colors**: Edit `prompt-themes.zsh`
4. **Create custom themes**: Add your own
5. **Share themes**: Contribute back!

---

**Your prompt is now fully customizable!** 🎨✨

Switch themes, create custom ones, and make your shell uniquely yours.

