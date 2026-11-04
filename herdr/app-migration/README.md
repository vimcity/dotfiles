# Herdr app migration

Prepared from `~/.config/herdr/config.toml`. The old config is unchanged.

Apply from this folder:

```sh
python3 prepare.py --install
herdr-app status
```

The installer preserves existing app shortcuts, overlays the migrated bindings,
backs up settings and keys with a timestamp, installs the prefix mod, and checks
it before replacing settings and keys. It refuses to overwrite an existing
`legacy-prefix` mod. If the check fails, settings and keys stay unchanged; remove
the newly copied mod before retrying.

## Included

- Ctrl+Space prefix through a small native popup; Escape cancels.
- Tab, space, agent, split, zoom, sidebar, picker, rename and close shortcuts.
- Prefix+1–9 and Alt+1–9 select tabs; prefix+Shift+1–9 select spaces.
- Custom pane and popup launch commands open as new tabs in this draft.
- New/open worktree shortcuts use the app's worktree dialog.
- Custom panel colors and disabled sounds. Dark appearance stays fixed.
- Existing app shortcuts remain available. Ctrl+F now opens the picker,
  taking that chord from the terminal program, as in the old config.

## Remaining differences

This is a partial migration, pending app verification.

- Legacy popup dimensions and floating behavior are not carried over.
- Reviewr and Tiny Fingers are old plugins; their shortcuts are omitted.
- Ctrl+H/J/K/L Neovim-aware navigation and scrollback use the old `herdr` API;
  they are omitted pending a separate port.
- Detach, config reload, resize mode, copy mode, previous pane and tab reordering
  have no direct mapping in the installed command list; shortcuts are omitted.
- Copy-on-select, old sidebar row templates and widths, status command,
  terminal toast delivery and new-space name prompts are not settings in the new
  app. The shipped layout is unchanged.
- Kitty graphics and persistent terminals are native app/core features.
  The old agent-resume setting has no direct equivalent; lost terminals recover
  as shells rather than rerunning their original agent commands.
- The old `terminal` theme inherited terminal colors. Only explicit custom colors
  are mapped; the app's existing ANSI palette remains.

The sandbox blocks writes to the live config folder. Mod checks also encountered
macOS application-service errors here; a passing check and interactive shortcut
verification are still required. Try Ctrl+Space then C, V, S and Escape, plus
Alt+H/L, Alt+J/K and Cmd+J/K after installation. Do not claim this draft is fully
verified until those checks pass.
