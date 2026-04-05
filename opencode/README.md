# OpenCode Configuration

This directory contains OpenCode configuration, themes, and plugins that are symlinked to `~/.config/opencode/`.

## Plugins

### tmux-status.ts

A plugin that provides visual feedback in Tmux by changing your window's background color based on OpenCode status.

**Status Colors:**
- **Yellow** → Permission requested (when OpenCode asks for approval)
- **Green** → Task completed (when a session becomes idle)
- **Blue** → Default state (when permission is granted or window gains focus)

**How it works:**
1. When OpenCode fires a `permission.asked` event, the plugin changes the Tmux window background to yellow
2. When you grant permission (`permission.replied`), it resets to blue
3. When a session completes (`session.idle`), it turns green
4. When you switch focus to that Tmux window, the shell automatically resets it to blue

**Setup:**
The plugin is automatically loaded by OpenCode when placed in `~/.config/opencode/plugins/`. The symlink is created by `install.sh`.

The Tmux focus reset logic is in `zshrc` - it runs when you have a shell in a Tmux pane and hooks into the window focus event.

**Requirements:**
- Running inside Tmux (`$TMUX_PANE` must be set)
- Tmux available in PATH
- Zsh shell (for the focus reset hook)

## Themes

### catppuccin-rose.json

A custom OpenCode theme built on Catppuccin Frappe with rose-toned overrides to match the rest of this dotfiles setup.

The theme is tracked in `opencode/themes/catppuccin-rose.json` and symlinked into `~/.config/opencode/themes/` by `install.sh`.

## Structure

```
opencode/
├── README.md           # This file
├── plugins/
│   └── tmux-status.ts  # Tmux window color status plugin
└── themes/
    └── catppuccin-rose.json
```

## Installation

Run the `install.sh` script in the dotfiles root to automatically:
1. Create the `~/.config/opencode` directory
2. Symlink `~/dotfiles/opencode/plugins` to `~/.config/opencode/plugins`
3. Symlink `~/dotfiles/opencode/themes` to `~/.config/opencode/themes`
4. Update `zshrc` with the Tmux focus reset hook

```bash
cd ~/dotfiles
./install.sh
```

## Development

To modify the plugin:
1. Edit `/Users/rgaur/dotfiles/opencode/plugins/tmux-status.ts`
2. Changes are immediately reflected in `~/.config/opencode/plugins/` (via symlink)
3. Restart OpenCode or reload the session to pick up changes
