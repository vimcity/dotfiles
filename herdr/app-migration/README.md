# Herdr app migration

## Applied desktop configuration

- `minimal-frappe`: personal clone of the shipped `main` layout with Catppuccin
  Frappé colors.
- Sidebar: one compact row per tab. Split panes appear as a small superscript count beside one program icon; the
  front icon and label follow the focused pane, including its program/agent and
  working directory. Herdr's program icons are used. The Agents section remains.
- Pane layout: square borderless edges, 6 px split gap, no outer gutter or header
  divider. Compact headers show the reported agent session title (program fallback),
  blue path, adjacent mauve branch, and a right-aligned icon-only unzoom button when zoomed. Header rows compensate for UI zoom to align with native traffic lights. Only the first pane reserves traffic-light
  space when the sidebar is hidden. The gap canvas is slightly lighter than terminals.
- Sidebar top: local CPU and RAM percentages with accented icons, inline after the
  macOS traffic lights. Samples every 3 seconds: CPU from the second one-second `/usr/bin/top` sample;
  RAM from active + wired `vm_stat` pages / `hw.memsize`, matching btop on macOS.
  RAM is not memory pressure. Sampling stops on failure rather than repeatedly launching a failed command.
- Hidden tab toolbar, sidebar brand controls, footer, and bottom status strip.
  macOS traffic lights remain native. Keyboard bindings remain the way to create
  tabs and spaces.
- Square-edged Go to switcher (`minimal-picker`): one row per pane, with program/session titles, paths, branches, tab/pane positions, zoom markers, and each agent’s own status (not the tab aggregate). Selection focuses the exact pane, including across workspaces. Ctrl+D closes only the selected pane. Paths, titles, branches and programs are searchable; quiet tabs remain visible. Ctrl+F / Cmd+P and prefix+q use it; Ctrl+Shift+P / Cmd+Shift+P use the matching square-edged `minimal-palette`, preserving fuzzy command search, shortcuts and recent commands.
- `prefix+r` and F2 open `minimal-rename`, a compact theme-aware tab-name dialog; `prefix+shift+r` opens Recap in the app and TUI.
- Invisible Ctrl+Space prefix (no hint popup); prefix+? opens help. Migrated tab, space, split, navigation, and tool shortcuts.
  Popup tools launch in centered dialogs; closing a dialog leaves its terminal
  running. Exit the tool to end it.

The old TUI configuration is unchanged. Stock app layouts and mods are unchanged.
Live settings and keys were backed up as `*.backup-20261106-112352`.
Switch back with `herdr-app do layout.switch '{"name":"main"}'`.
Restoring keys/settings requires copying their backups over the live files.

## Repository files

- `prepare.py`: generates migrated keys/settings and prefix bindings from
  `~/.config/herdr/config.toml`; `--install` backs up live keys/settings, checks
  the prefix mod, then installs. This is the original shortcut installer, not a
  complete visual-pass installer; do not rerun it over the applied configuration.
- `mods/legacy-prefix`: prefix handler, including terminal dialogs.
- `mods/minimal-sidebar`: tab rows with a single program icon, pane-count superscript, and focused-pane labels.
- `mods/minimal-pane`: compact accented headers with reported agent titles and zoom state.
- `mods/minimal-picker`: personal switcher, cloned from the shipped picker; stock picker is unchanged.
- `mods/minimal-palette`: personal command palette, cloned from the app frame; stock frame is unchanged.
- `mods/minimal-rename`: compact, theme-aware replacement for the app's native tab rename prompt.
- `mods/minimal-metrics`: local CPU and RAM counters below the traffic lights.
- `mods/minimal-agents` and `mods/minimal-spaces`: earlier personal sidebar
  experiments, not used by the current layout.
- `generated/minimal-frappe.json`: applied personal layout.
- `generated/catppuccin-frappe.json`: applied theme.
- Generated keys/settings are migration intermediates, not current app backups.

## Verification and limits

The prefix, spaces, agents, and minimal-sidebar mods pass `herdr-app check`.
Live `herdr-app status` reports no errors. The configured pane icon/label follows
live `panes()` focus; the current tab has two panes, explaining why it appears as
one tab row with a two-pane icon stack.

Per-pane content dimming and a cursor-flash animation are not exposed by the
current layout settings. Herdr uses Ghostty VT for terminal state, but Ghostty
shader configuration does not automatically apply to Herdr's renderer. Those
effects require renderer support, not a theme/config change. A dedicated Herdr
shell environment marker is also not documented, so the zsh prompt was not
conditionally changed; keep it until a reliable marker is available.

Still needs interactive verification: pane navigation and focus switching,
popup tool execution, and dialog resizing/keep-as-tab. The migration does not
install missing external programs or repair old scripts.

## Remaining differences

- No automatic pane arrangement; the installed command API exposes directional
  splits, navigation, and swapping, but no balance/retile operation.
- Legacy popup percentage dimensions are not translated; dialogs use 1000×650.
- Reviewr, Tiny Fingers, Neovim-aware pane navigation, old scrollback APIs,
  detach, resize mode, copy mode, status script, and tab reordering are not ported.
- The app's native persistent-terminal recovery does not rerun lost agents.

## Chrome regression checks

`node --test tests/test_herdr_chrome.mjs` covers switcher filtering, quiet/empty/long lists, keyboard wrapping, native-light zoom alignment, zoom markers and invisible-prefix dispatch using UI fixtures. Run `herdr-app check` on minimal-picker, minimal-palette, minimal-pane and legacy-prefix for native API validation. Final spacing and focus behavior still need visual review in the app.
