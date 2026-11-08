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

Mod files (including helpers and assets) are copied into the live mod directory: GPUI rejects imported modules that resolve outside it, and the live watcher does not follow changes to symlink targets. Re-run the installer to deploy dotfiles edits. Other configuration files and the test suite remain linked.

Deployment is described by `deploy.json`: linked configuration files and owned mod directories, not a hand-maintained list of every asset. Each mod directory is deployed flat; generated type/config files are excluded. Shared source helpers remain symlinked to `lib/` in dotfiles, then materialized inside each live sandbox.

The installer records managed hashes in `data/dotfiles-deploy.json`. Unchanged files are left alone; updates preserve previous files in unique backup batches under `HERDR_BACKUP_HOME`. Unexpected edits to previously managed live copies abort the entire preflight before any file is replaced. On first adoption, existing files are backed up. Removed managed files and the retired `legacy-prefix` directory are backed up rather than deleted.

Run `./install.sh --check` to detect source/live drift without writing. Reconcile live edits into dotfiles before deploying; never edit copied live modules as the source of truth.

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
- `mods/minimal-palette`, `mods/minimal-rename`, `mods/review-toggle`, and `mods/command-prefix`: custom commands referenced by `keys.json`.
- `mods/recap`: custom key handlers for the recap mod.

Generated Herdr files such as `gpui-kit.d.ts` and `jsconfig.json` are intentionally not stored here; Herdr regenerates them locally.

## Desktop workflow

Prefix is **Ctrl-Space**, followed by the second key:

| Key | Action |
| --- | --- |
| `t` | Regex copy hints for the visible screen; type a hint or click a match; Escape cancels |
| `Shift-R` | Agent recaps |
| `Ctrl-B` | btop; quitting closes its tab |
| `Ctrl-A` | Org capture |
| `Ctrl-O` | Today's agenda |
| `Shift-O` | Org plans picker |

Ctrl-F opens the expanded navigation picker. The command palette also exposes hints and Recap.

- Customize hint regexes in `mods/terminal-hints/rules.js`, then deploy them into the live mod folder.
- Hints are a contextual match list, not labels painted over the source terminal. JavaScript regex syntax applies.
- Soft-wrapped matches are not reconstructed; the core's available text snapshot is the boundary. Alternate-screen applications may expose only their current screen.
- Launchers use a non-login `zsh -c` with an explicit tool environment through hc, without the desktop's extra persistent shell wrapper; individual bindings can request a login shell when required. The prefix stays alive until the new terminal is visible in the app's live model, preventing adoption races.
- Traffic-light clearance and the top sidebar headings compensate for app zoom; fonts and the remaining UI still scale normally.
- Recap is already installed and may provision a checksum-verified helper on machines with agents when opened. No new community integrations are installed by this configuration change.

## Verification

```sh
node tests.mjs          # all JS and Python regression tests
node tests.mjs --live   # also check deployment drift and every managed live mod
bash -n install.sh
```

Community candidates, reviewed 2026-11-07:
- Desktop gallery: https://herdr.dev/gallery/?type=mods — Recap, GitHub, Teleport; verify each recipe and permissions before adding.
- Recap: https://github.com/mrolafsson/herdr-recap — already present here.
- Reviewr: https://github.com/persiyanov/herdr-reviewr — legacy TUI diff review; the desktop Changes panel is not its full equivalent.
- Tiny Fingers: https://github.com/hotchpotch/herdr-tiny-fingers — legacy TUI hinted copying; includes richer patterns, multi-select and wrap handling than this initial desktop implementation.
- Linear is referenced by the installed Recap mod as an optional integration; availability was not independently verified.

## Session-first navigation

- Alt-J/K traverses tabs across spaces in sidebar order, even while the sidebar is hidden. Commands are handled once by the focused pane header, not by the sidebar UI.
- Ctrl-F: type a session title, repo/path, tool name or machine; Up/Down selects, PageUp/PageDown jumps, Enter opens it, Escape dismisses.
- The picker uses one controlled viewport for keyboard selection, wheel scrolling and a draggable scrollbar. The bar remains visible when content overflows.
- Coding-agent rows use the reported session title, falling back to a named tab, then the folder. The sidebar uses a program icon without a directory subtitle. Ctrl-F uses the program icon too, without a duplicate agent-name badge; tool names remain searchable and appear in tooltips.
- Regular applications retain their app/tab name and directory. Hidden context remains searchable; sidebar rows retain full-context tooltips.
- The sidebar and picker share the session-label policy from `lib/session-label.js`. Pane headers show their own terminal's directory, using `~` for the home directory and the absolute path in a tooltip.

Picker scrolling keeps space order stable as agents change status. Live updates do not recenter the list; keyboard navigation scrolls only at viewport edges, and arrows stop at the ends. Run `node tests/picker-scroll.test.mjs` for the scrolling regression tests.

## Terminal-only text zoom

- In minimal-frappe, Cmd-Plus/Equals and Cmd-Minus change terminal font size by 1px; Cmd-0 resets to the font size recorded before the first adjustment. The header, sidebar and overall app zoom stay unchanged.
- All terminals that inherit settings.json use the new font size. Other layouts keep their existing app-zoom shortcuts; this does not change pane maximization (Cmd-Shift-Enter).
- The focused pane header handles the keys even when the sidebar is hidden. A local Python 3 helper updates only font_size, preserving settings symlinks and unrelated fields. Changes are serialized with a local file lock and clamped to 8–40px.
- Reset state is stored in data/terminal-zoom.json. Test with python3 tests/terminal-zoom.test.py and node tests/terminal-zoom.test.mjs.

## Visual hierarchy

- Pane frames use 10px corners, 8px gaps and 0.5px hairlines: white at 4% opacity normally, 16% when focused. Headers keep the terminal background in both states. Focused paths use theme-foreground semibold 13.5px text inside a content-sized 26px pill using the sidebar selection background (`theme().selected`), text (`theme().foreground`) and faint border. The pill includes the 15px program icon, separated from the path by 5px. Inactive paths stay dim with no visible pill; neither state fills the whole header. Terminal content is unchanged because this Herdr version does not expose focus-dependent terminal dimming. Header rounding is derived from the pane radius minus its border width, keeping the curves aligned; true rounded terminal clipping still requires renderer support.
- Headers use 32px height and one 12px left inset, without the old nested title padding or gold flash. Split/zoom controls appear on hover; the restore control also appears when the pane reports itself zoomed.
- Sidebar sessions use 36px rounded rows, program icons and a soft neutral selection, with 7px row insets. The outer gutters are 12px left and 4px right, balancing the additional 8px workspace inset so the visible spacing is equal. Selection has one faint 0.5px border, without an extra top highlight. One status mark shows working/blocked/done; idle agents do not produce dot clusters.
- Machine headings use quiet monitor/server icons and normal-case labels, without colored banners or LOCAL/SSH badges. Unavailable/loading machines retain a warning indicator and tooltip.
- Space headings disclose their sessions and show session counts. Below 110px, the sidebar becomes a selectable initials rail; metrics hide when they no longer fit.
- Sidebar labels use a native 22px edge fade instead of an ellipsis; full labels remain in tooltips. Sessions use 14px medium text (semibold when selected), with 13px bold gray space headings. CPU/memory percentages use 12px semibold text and hide when they no longer fit.
- Pane headers show the cwd with `~` replacing the home directory, with no session title or branch competing for space. The tooltip retains the full absolute cwd. Very long paths can scroll horizontally and retain their full tooltip. Shared fading/icon helpers live in `lib/ui.js`, copied into each mod's import sandbox.
- Main text remains `#C6D0F5`; secondary text uses `#A5ADCE` and tertiary metadata uses `#838BA7`.
- Ctrl-F uses the same soft 18px-radius selection and fading labels as the sidebar, with no tree connectors or idle-agent clusters. Machine labels use blue/purple, tinted tool icons mint, and status filters red/amber/green; session titles stay neutral. Normal-case machine labels replace the old banners and LOCAL/SSH badges.
- Verify the redesign with `node tests/ui-revamp.test.mjs` and `herdr-app check` for minimal-sidebar, minimal-pane and minimal-metrics. Review normal/narrow/rail widths, focus switching, zoom and hidden-sidebar clearance in the app.

### Ctrl-F input and scroll fixes

- Up/Down, PageUp/PageDown, Home/End and Escape have explicit `mod:minimal-picker` bindings, so the search input cannot swallow list navigation.
- Page movement uses actual row heights, including machine and space headings, rather than an estimated number of sessions.
- Selection and rendered row positions share the same scroll offset. Live updates preserve it; selecting an off-screen result brings the full row into view.
- Coding-agent rows are 38px, ordinary app rows 50px, and the search field 36px. Session names use 14px medium text, semibold when selected; space headings are 13px bold gray.
- Live app-command tests exercised Home/End, 18 consecutive Down/Up commands and PageUp/PageDown; screenshots confirmed selection stayed visible. Wheel scaling, thumb dragging and filtered Enter behavior have controller regression tests.

## Menu style and motion

- Ctrl-F and Ctrl-Shift-P share the same 600px card, full-window transparent host, popup placement, 12px frame, 18px selected-row radius, 36px search field and 14px command/session text. Group headings stay bold gray; icons and status filters carry color.
- Both use the same native slide/fade controller: 160ms ease-out entrance and 110ms ease-in exit. Entry is staged once after mount or the first host layout; native GPUI runs the transition, with no frame-by-frame script timers. A single completion deadline closes the popup and then runs its chosen action.
- Escape and the menu's own toggle shortcuts animate dismissal. Backdrop clicks inside the app animate dismissal; native outside-window dismissal remains app-controlled.
- Sidebar layout resizing and live terminal tab creation/removal have no animation hooks in this Herdr version. Smooth transitions for those surfaces require native app support; they are not implemented by the menu motion controller.
- Shared frame/search/motion/scrollbar code lives in lib/menu-ui.js and is copied into each popup's import sandbox. Check both mods and run node tests/menu-motion.test.mjs plus node tests/picker-scroll.test.mjs.

## Fixed window controls and popup expansion

- There is no full-width top strip or extra control panel. The sidebar toggle lives inline in the sidebar or first pane header. Local CPU/memory appears beside This Mac; the background collector occupies zero layout space.
- Pane headers normally use a 12px inset. When the sidebar is hidden, the first header reserves space for window controls and the inline sidebar button. Pane frames have a 6px vertical inset without a separate toolbar row.
- Ctrl-F and Ctrl-Shift-P: Cmd-Shift-Enter or Alt-Z toggles between the 600px card and near-window-sized expansion, with native 220ms ease-out width/height transitions. Search, selection and keyboard focus stay in the same view. Full-window hosts provide room for the shadow and resize without reopening the popup.
- Menu cards use a soft native shadow; the sidebar and workspace gutter share the same `chrome` surface without a shadow seam and terminal-tool popup layouts use a large shadow.
- In-place terminal-tool popup resize animation is not exposed by the current Herdr API. Their running processes are not restarted or replaced to imitate resizing.

## Sidebar row motion

- Tab rows and space sections use native 160ms ease-out height transitions and 110ms fades. The settled row heights, colors, margins and selection styles are unchanged.
- A small presence model keeps closing row/space snapshots for 180ms, then removes them. New entries start their native transition after one staging callback. Rapid close/reopen events invalidate stale cleanup callbacks; live status updates do not restart motion.
- Machine headings remain stable while their spaces animate. Closing the last tab also animates removal of its sidebar space entry.
- This animates the sidebar representation, not the terminal compositor or whole-sidebar layout resizing. Those still require native Herdr support.
- Run node tests/sidebar-motion.test.mjs and node tests/ui-revamp.test.mjs; the helper is shared from lib/sidebar-motion.js.

## Maintenance and native boundaries

- `command-prefix` is the Ctrl-Space launcher; the old `legacy-prefix` name is retired. Renaming changes no key behavior.
- System metrics sample every 10 seconds while the sidebar is visible, cache total RAM and publish only changed percentages. Failures stop collection for that mod instance instead of repeatedly spawning broken commands.
- Sidebar and picker index panes by tab once per render; the picker also indexes agents by pane/address.
- Changes parsing/tree/diff-row logic lives in `mods/changes-close/diff-model.js`; syntax tokenization lives in `syntax.js`. The view owns UI interactions and Git operations.
- Recap helper execution/provisioning lives in `mods/recap/tools.js`; session naming/ticket policy lives in `session-policy.js`. One poll stays in flight through all machine helper results; GitHub/Linear lookups also have independent overlap guards.
- Actual sidebar show/hide uses native `layout.toggle`/`layout.resize`. This version exposes no layout-node size-transition API. The existing native sidebar-row animations remain; they do not animate the whole sidebar.
- Actual terminal-pane creation/removal is owned by Herdr's split compositor. `pane.close` ends the terminal and removes its pane; exiting a terminal program also closes the pane. `terminal.park` removes a pane but keeps its terminal running. A mod pane closes its view instead. There is no exposed pre-close animation callback or compositor transition setting. JS element transitions only affect mod-drawn content. Do not emulate pane closure with timers, repeated layout writes or process restarts.
- Sidebar gutters intentionally retain spacing around rounded terminal cards, but both sides now paint `chrome`; the sidebar shadow is removed. Pane-to-pane spacing is unchanged.

Workspace headings use `#7F86A1` text and Helvetica Neue Bold (700), including the text inside the fade wrapper, in the sidebar and Ctrl-F picker. On this Mac, changing the weight of the previous UI font alone did not visibly render bold; the system font face was verified in a live screenshot. Compact sidebar initials use the same family.
