# 🎨 Themeable Prompt System

Your shell prompt can now be easily customized with multiple beautiful themes. Switch between themes instantly without restarting your shell!

## Quick Start

### Available Themes

| Theme | Alias | Style | Best For |
|-------|-------|-------|----------|
| **Rose Pine** (default) | `theme-rp` | Warm, cozy | Default - sophisticated and warm |
| **Catppuccin** | `theme-cat` | Bold, modern | High contrast, productivity |
| **Nord** | `theme-nord` | Cool, professional | Professional environments |
| **Dracula** | `theme-dracula` | Dark, vibrant | Bold developers |
| **Minimal** | `theme-minimal` | Clean monochrome | Distraction-free |
| **Gruvbox** | `theme-gruvbox` | Retro, warm | Warm earth tones |

### Switch Themes

```bash
# Using aliases (fastest)
theme-rp          # Rose Pine
theme-cat         # Catppuccin
theme-nord        # Nord
theme-dracula     # Dracula
theme-minimal     # Minimal
theme-gruvbox     # Gruvbox

# Using function (flexible)
theme catppuccin  # Switch to any theme by name
theme nord

# View all themes
theme-list        # Or: prompt_switch_theme
```

### Persist Theme Choice

Set your preferred theme in `~/.zshrc.local`:

```bash
# Add to ~/.zshrc.local
export PROMPT_THEME="catppuccin"
# or
export PROMPT_THEME="nord"
```

Or set at shell startup:

```bash
# In your shell session
export PROMPT_THEME="dracula"
source ~/.zshrc  # Reload config to apply
```

## Theme Details

### 🌹 Rose Pine (Default)
**Colors**: Soft purples, pinks, earth tones  
**Vibe**: Warm, cozy, sophisticated  
**Use case**: Beautiful default for any environment

```
Directory: 7287fd
Branch: 7287fd  
Git: Added/Modified/Deleted indicators in rose pine colors
```

### 🎨 Catppuccin Mocha
**Colors**: Bold blues, cyans, vibrant accents  
**Vibe**: Modern, high contrast, energetic  
**Use case**: When you want clarity and boldness

```
Directory: 89b4fa (bright blue)
Branch: 89b4fa
Very distinct from background
```

### ❄️ Nord
**Colors**: Arctic blues and greens, professional  
**Vibe**: Cool, professional, minimalist  
**Use case**: Professional coding environments

```
Directory: 88c0d0 (arctic cyan)
Branch: 88c0d0
Clean, professional look
```

### 🧛 Dracula
**Colors**: Dark purples, pinks, vibrant accents  
**Vibe**: Dark and trendy, popular in dev community  
**Use case**: Dracula theme enthusiasts

```
Directory: bd93f9 (bright purple)
Branch: bd93f9
Bold, energetic feel
```

### 📱 Minimal
**Colors**: Grays, whites, selective colors  
**Vibe**: Clean, distraction-free, monochrome  
**Use case**: When you want absolute simplicity

```
Directory: 555555 (dark gray)
Branch: 888888 (medium gray)
Color only for status
```

### 🍂 Gruvbox
**Colors**: Warm earth tones, retro vibes  
**Vibe**: Comfortable, warm, vintage  
**Use case**: Warm color preference enthusiasts

```
Directory: 83a598 (warm sage)
Branch: 83a598
Retro comfortable feel
```

## How It Works

### Architecture

```
prompt-themes.zsh         # Theme definitions (6 themes)
  ├── define_rose_pine_theme()
  ├── define_catppuccin_theme()
  ├── define_nord_theme()
  ├── define_dracula_theme()
  ├── define_minimal_theme()
  └── define_gruvbox_theme()

zshrc                     # Main config (updated)
  ├── Sources prompt-themes.zsh
  ├── Uses THEME_COLORS array
  └── Updated prompt_* functions

theme-switcher.zsh       # Convenience shortcuts
  ├── theme-rp, theme-cat, etc. (aliases)
  ├── theme-list (show all)
  └── theme() (flexible function)
```

### How Switching Works

1. **Load theme definition**: `prompt_load_theme "catppuccin"`
2. **Populate THEME_COLORS array**: 22 color definitions loaded
3. **Prompt functions use THEME_COLORS**: Instead of hardcoded colors
4. **Environment variable set**: `PROMPT_THEME="catppuccin"`
5. **Prompt re-renders**: Next time you press Enter

## Customizing Themes

### Add Your Own Theme

Edit `prompt-themes.zsh` and add a new theme function:

```bash
define_my_theme() {
    THEME_COLORS=(
        # Required colors
        [user_bg]="#XXXXXX"
        [user_fg]="#XXXXXX"
        [dir_bg]="#XXXXXX"
        [dir_fg]="#XXXXXX"
        [git_bg]="#XXXXXX"
        [git_fg]="#XXXXXX"
        [venv_bg]="#XXXXXX"
        [venv_fg]="#XXXXXX"
        
        # Git status colors
        [git_added]="#XXXXXX"
        [git_modified]="#XXXXXX"
        [git_deleted]="#XXXXXX"
        [git_renamed]="#XXXXXX"
        [git_unmerged]="#XXXXXX"
        [git_untracked]="#XXXXXX"
        [git_ahead]="#XXXXXX"
        [git_behind]="#XXXXXX"
        
        # Right prompt
        [right_bg]="#XXXXXX"
        [right_fg]="#XXXXXX"
        [error_fg]="#XXXXXX"
        [prompt_char]="#XXXXXX"
        
        # Metadata
        [name]="my-theme"
        [description]="My custom theme description"
    )
}
```

Then add it to the case statement in `prompt_load_theme()`:

```bash
case "$theme" in
    # ... existing themes ...
    my-theme)
        define_my_theme
        ;;
esac
```

### Modify an Existing Theme

Edit the color definitions in `prompt-themes.zsh`:

```bash
define_rose_pine_theme() {
    THEME_COLORS=(
        # Change these hex colors to what you want
        [dir_bg]="#XXXXXX"  # Modify directory background
        [prompt_char]="#XXXXXX"  # Modify $ character color
        # ... etc ...
    )
}
```

## Theme Colors Explained

### Segment Colors

- **user_bg/fg**: SSH/root indicator background and foreground
- **dir_bg/fg**: Directory path segment
- **git_bg/fg**: Git branch and status segment
- **venv_bg/fg**: Virtual environment indicator
- **right_bg/fg**: Right prompt (duration, jobs, errors)
- **prompt_char**: The `$` character color
- **error_fg**: Error status code color

### Git Status Colors

- **git_added** (●): Files staged for commit
- **git_modified** (✚): Files with unstaged changes
- **git_deleted** (✖): Deleted files
- **git_renamed** (➜): Renamed files
- **git_unmerged** (═): Merge conflicts
- **git_untracked** (◌): Untracked files
- **git_ahead** (⇡): Commits ahead of remote
- **git_behind** (⇣): Commits behind remote

## Commands Reference

### Theme Switching

```bash
# Switch using aliases
theme-rp              # Rose Pine (default)
theme-cat             # Catppuccin Mocha
theme-nord            # Nord (cool & professional)
theme-dracula         # Dracula (dark & vibrant)
theme-minimal         # Minimal (monochrome)
theme-gruvbox         # Gruvbox (warm retro)

# Switch using function
theme rose-pine
theme catppuccin
theme "my-custom-theme"

# View available themes
theme-list
prompt_switch_theme   # (shows all themes)
```

### Check Current Theme

```bash
echo $PROMPT_THEME
# Output: rose-pine (or whatever is set)
```

### Get Theme Color Programmatically

```bash
# In zsh functions
get_theme_color "dir_bg"      # Returns: #7287fd (for rose-pine)
${THEME_COLORS[dir_bg]}       # Alternative way
```

## Performance

- **Instant**: Theme switching is instant (no shell restart needed)
- **Lightweight**: Array-based, no external dependencies
- **Efficient**: Colors loaded once at startup, reused throughout session

## Troubleshooting

### Theme Not Switching

Check that `prompt-themes.zsh` is sourced:

```bash
grep "source.*prompt-themes" ~/.zshrc
# Should show: source ~/dotfiles/prompt-themes.zsh
```

### Colors Look Wrong

Your terminal color palette might not support 24-bit true color. Check:

```bash
echo $COLORTERM
# Should show: truecolor
```

If not, add to `~/.zshrc.local`:

```bash
export COLORTERM=truecolor
```

### Can't Switch Themes at Runtime

Make sure you've sourced the theme system:

```bash
source ~/dotfiles/prompt-themes.zsh
prompt_switch_theme catppuccin
```

## Files

- **prompt-themes.zsh** - Theme definitions (6 themes, 295 lines)
- **theme-switcher.zsh** - Convenience shortcuts and aliases
- **zshrc** - Updated to use THEME_COLORS array

## Tips

1. **Try each theme** - They each have different vibes
2. **Use aliases** - `theme-cat` is faster than `theme catppuccin`
3. **Set in .zshrc.local** - For persistent per-machine themes
4. **Create custom themes** - Base on existing themes for consistency
5. **Share themes** - Add your custom themes to contribute

## Examples

### Set theme based on time of day

In `~/.zshrc.local`:

```bash
HOUR=$(date +%H)
if [[ $HOUR -ge 18 || $HOUR -lt 6 ]]; then
    export PROMPT_THEME="dracula"  # Dark theme at night
else
    export PROMPT_THEME="rose-pine"  # Light/warm during day
fi
```

### Set theme based on machine

```bash
if [[ $(hostname) == "work-laptop" ]]; then
    export PROMPT_THEME="nord"      # Professional for work
else
    export PROMPT_THEME="rose-pine"  # Cozy for personal
fi
```

---

Enjoy customizing your prompt! 🎨✨

