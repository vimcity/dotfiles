export default {
  "ctrl-,": "app.settings",
  "g": { "panel": "changes" },
  "t": "mod.open:terminal-hints",
  "?": "app.help",
  "q": "mod.open:minimal-picker",
  "c": "tab.new",
  "r": "mod.open:minimal-rename",
  "shift-r": "mod.open:recap",
  "w": "tab.close",
  "v": "pane.split:right",
  "s": "pane.split:down",
  "-": "pane.split:down",
  "x": "pane.close",
  "n": "space.new",
  ".": "space.rename",
  "1": "tab.select:1",
  "shift-1": "space.select:1",
  "2": "tab.select:2",
  "shift-2": "space.select:2",
  "3": "tab.select:3",
  "shift-3": "space.select:3",
  "4": "tab.select:4",
  "shift-4": "space.select:4",
  "5": "tab.select:5",
  "shift-5": "space.select:5",
  "6": "tab.select:6",
  "shift-6": "space.select:6",
  "7": "tab.select:7",
  "shift-7": "space.select:7",
  "8": "tab.select:8",
  "shift-8": "space.select:8",
  "9": "tab.select:9",
  "shift-9": "space.select:9",
  "ctrl-p": {
    "shell": "exec \"${SHELL:-/bin/zsh}\" -l",
    "name": "open floating shell",
    "popup": true
  },
  "ctrl-c": {
    "shell": "exec \"${SHELL:-/bin/zsh}\" -l",
    "name": "open floating shell",
    "popup": false
  },
  "ctrl-n": {
    "shell": "cd \"${PROJECTS_DIR:-$HOME/Projects}\" && exec nvim",
    "name": "open Neovim in a Projects tab",
    "popup": false
  },
  "alt-j": {
    "shell": "exec \"$HOME/dotfiles/herdr/scripts/jarvis-action.sh\"",
    "name": "preview a Jarvis terminal action",
    "popup": true
  },
  "alt-v": {
    "shell": "exec \"$HOME/dotfiles/bin/jv\"",
    "name": "start local Jarvis voice (Ctrl-C to stop)",
    "popup": false
  },
  "shift-s": {
    "shell": "exec ~/.local/bin/lzk",
    "name": "start lazy splunk tui",
    "popup": false
  },
  "shift-g": {
    "shell": "exec $HOME/.local/bin/gh-pr-dash",
    "name": "review PRs",
    "popup": false
  },
  "shift-m": {
    "shell": "cd \"${PROJECTS_DIR:-$HOME/Projects}\" && exec \"$HOME/dotfiles/bin/ghprs\" mine",
    "name": "review PRs in a floating popup",
    "popup": true
  },
  "ctrl-g": {
    "shell": "exec lazygit",
    "name": "open lazyzgit",
    "popup": false
  },
  "ctrl-a": {
    "shell": "exec $HOME/dotfiles/herdr/scripts/quick-org-task.sh",
    "name": "open or create an org todo",
    "popup": true
  },
  "shift-c": {
    "shell": "exec fluence pick",
    "name": "open confluence docs",
    "popup": false
  },
  "ctrl-f": {
    "shell": "cd \"${PROJECTS_DIR:-$HOME/Projects}\" && \"${SHELL:-/bin/zsh}\" -lic 'g; exec \"${SHELL:-/bin/zsh}\" -l'",
    "name": "pick a directory with g",
    "popup": false
  },
  "ctrl-s": {
    "shell": "/opt/homebrew/bin/nvim ~/Documents/org/stash.md",
    "name": "checkout stash",
    "popup": true
  },
  "ctrl-o": {
    "shell": "exec $HOME/dotfiles/herdr/scripts/agenda-today.sh",
    "name": "open today's org agenda",
    "popup": true
  },
  "shift-o": {
    "shell": "exec $HOME/dotfiles/herdr/scripts/org-plans.sh",
    "name": "create new org plans",
    "popup": true
  },
  "p": {
    "shell": "exec posting --env \"$HOME/.local/share/posting/default/posting.env\"",
    "name": "open Posting",
    "popup": false
  },
  "ctrl-j": {
    "shell": "cd \"${JIRA_TUI_ROOT:-$HOME/Projects/jira-tui/bin}\" && exec \"${JIRA_TUI_BIN:-$HOME/.local/bin/jira-tui}\"",
    "name": "open Jira TUI",
    "popup": false
  },
  "ctrl-b": {
    "shell": "exec \"${BTOP_BIN:-/opt/homebrew/bin/btop}\"",
    "name": "open btop",
    "popup": false
  },
  "ctrl-y": {
    "shell": "exec \"${YAZI_BIN:-yazi}\"",
    "name": "open yazi",
    "popup": false
  },
  "ctrl-d": {
    "shell": "exec /opt/homebrew/bin/lazydocker",
    "name": "open lazydocker",
    "popup": false
  },
  "ctrl-l": {
    "shell": "exec $HOME/.local/bin/lmstat",
    "name": "open lmstat",
    "popup": false
  },
  "shift-w": {
    "worktree": "new"
  },
  "ctrl-w": {
    "worktree": "open"
  }
};
