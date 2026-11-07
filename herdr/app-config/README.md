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
