# Herdr app configuration

Portable Herdr app customizations for the minimal Frappé layout.

## Install

From this directory:

```sh
./install.sh
```

The installer uses:

- `XDG_CONFIG_HOME`, defaulting to `~/.config`
- `HERDR_APP_HOME`, defaulting to `${XDG_CONFIG_HOME:-~/.config}/herdr-app`
- `HERDR_BACKUP_HOME`, defaulting to `${HERDR_APP_HOME}-backups`

JavaScript and mod metadata are copied into the live mod directory: GPUI rejects imported modules that resolve outside it, and the live watcher does not follow changes to symlink targets. Re-run the installer to deploy dotfiles edits. Other configuration files remain linked.

Existing live files are moved under `HERDR_BACKUP_HOME` before links are created. The installer refuses to overwrite an existing backup.

## Managed files

- `keys.json`: app shortcuts, including Alt+J/K vertical tab navigation.
- `settings.json`: portable appearance and keyboard settings.
- `layouts/minimal-frappe.json`: the custom layout structure.
- `themes/catppuccin-frappe.json`: the custom Catppuccin Frappé theme used by the layout and settings.
- `mods/minimal-sidebar`: space and tab navigation/sidebar presentation.
- `mods/minimal-metrics`: compact resource metrics shown in the layout header.
- `mods/minimal-agents`: agent list presentation.
- `mods/minimal-picker`: the Cmd-P / Ctrl-F navigation popup.
- `mods/minimal-pane`: pane header controls.
- `mods/changes-close`: the layout's Changes panel.
- `mods/minimal-palette`, `mods/minimal-rename`, `mods/review-toggle`, and `mods/legacy-prefix`: custom commands referenced by `keys.json`.
- `mods/recap`: custom key handlers for the recap mod.

Generated Herdr files such as `gpui-kit.d.ts` and `jsconfig.json` are intentionally not stored here; Herdr regenerates them locally.

## Desktop workflow

Prefix is **Ctrl-Space**, followed by the second key:

| Key | Action |
| --- | --- |
| `b` | Frozen scrollback in a clean Neovim viewer; `v`/`V`, `y`, `/`, `gg`/`G`; `q` closes |
| `t` | Regex copy hints for the visible screen; type a hint or click a match; Escape cancels |
| `Shift-R` | Agent recaps |
| `Ctrl-B` | btop; quitting closes its tab |
| `Ctrl-A` | Org capture |
| `Ctrl-O` | Today's agenda |
| `Shift-O` | Org plans picker |

Ctrl-F opens the expanded navigation picker. The command palette also exposes copy mode, hints and Recap.

- Customize hint regexes in `mods/terminal-hints/rules.js`, then deploy them into the live mod folder.
- Hints are a contextual match list, not labels painted over the source terminal. JavaScript regex syntax applies.
- Soft-wrapped matches are not reconstructed; the core's available text snapshot is the boundary. Alternate-screen applications may expose only their current screen.
- Copy mode is a local read-only Neovim snapshot, not a pause of the source program. Temporary snapshots are removed on normal exit.
- Launchers start interactive login shells directly through hc, without the desktop's extra persistent shell wrapper. The prefix stays alive until the new terminal is visible in the app's live model, preventing adoption races.
- Traffic-light clearance and the top sidebar headings compensate for app zoom; fonts and the remaining UI still scale normally.
- Recap is already installed and may provision a checksum-verified helper on machines with agents when opened. No new community integrations are installed by this configuration change.

## Verification

```sh
node tests.mjs
bash -n install.sh
bash -n mods/terminal-copy/copy-mode.sh
herdr-app check ~/.config/herdr-app/mods/terminal-copy
herdr-app check ~/.config/herdr-app/mods/terminal-hints
```

Community candidates, reviewed 2026-11-07:
- Desktop gallery: https://herdr.dev/gallery/?type=mods — Recap, GitHub, Teleport; verify each recipe and permissions before adding.
- Recap: https://github.com/mrolafsson/herdr-recap — already present here.
- Reviewr: https://github.com/persiyanov/herdr-reviewr — legacy TUI diff review; the desktop Changes panel is not its full equivalent.
- Tiny Fingers: https://github.com/hotchpotch/herdr-tiny-fingers — legacy TUI hinted copying; includes richer patterns, multi-select and wrap handling than this initial desktop implementation.
- Linear is referenced by the installed Recap mod as an optional integration; availability was not independently verified.

## Session-first navigation

- Ctrl-F: type a session title, repo/path, tool name or machine; Up/Down selects, PageUp/PageDown jumps, Enter opens it, Escape dismisses.
- The picker uses a native virtual list with an always-visible scrollbar when content overflows; its thumb can be dragged.
- Coding-agent rows use the reported session title, falling back to a named tab, then the folder. Their icon identifies the harness; no repeated Pi/Codex label or directory subtitle.
- Regular applications retain their app/tab name and directory. Hidden context remains searchable; sidebar rows retain full-context tooltips.
- Pane headers, the sidebar and the picker share the label policy from `lib/session-label.js`. The installer copies it into each mod's local import sandbox.

Picker scrolling keeps space order stable as agents change status. Live updates do not recenter the list; keyboard navigation scrolls only at viewport edges, and arrows stop at the ends. Run `node picker-scroll.test.mjs` for the scrolling regression tests.

## Visual hierarchy

- The sidebar keeps its roomier 28px tab rows; compact rows are confined to Ctrl-F.
- Machine sections use a blue monitor for This Mac and a teal server for remote hosts. No readiness labels, repeated machine suffixes or machine dividers.
- Space names are plain muted headings, not pills. Only the selected session gets a filled row; mouse hover does not add a second competing selection in Ctrl-F.
- Main text remains `#C6D0F5`; secondary text uses `#A5ADCE` and tertiary metadata uses `#838BA7`.
