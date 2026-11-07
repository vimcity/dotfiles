#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
HERDR_APP_HOME="${HERDR_APP_HOME:-$CONFIG_ROOT/herdr-app}"
HERDR_BACKUP_HOME="${HERDR_BACKUP_HOME:-${HERDR_APP_HOME}-backups}"

link_config() {
  local source="$1"
  local target="$2"
  local relative="${target#"$HERDR_APP_HOME/"}"
  local backup="$HERDR_BACKUP_HOME/$relative.before-dotfiles"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      printf 'Refusing to overwrite existing backup: %s\n' "$backup" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    printf 'Backed up %s -> %s\n' "$target" "$backup"
  fi

  ln -s "$source" "$target"
  printf 'Linked %s -> %s\n' "$target" "$source"
}

link_config "$SOURCE_ROOT/keys.json" "$HERDR_APP_HOME/keys.json"
link_config "$SOURCE_ROOT/settings.json" "$HERDR_APP_HOME/settings.json"
link_config "$SOURCE_ROOT/layouts/minimal-frappe.json" "$HERDR_APP_HOME/layouts/minimal-frappe.json"
link_config "$SOURCE_ROOT/mods/minimal-metrics/main.js" "$HERDR_APP_HOME/mods/minimal-metrics/main.js"
link_config "$SOURCE_ROOT/mods/minimal-metrics/usage.js" "$HERDR_APP_HOME/mods/minimal-metrics/usage.js"
link_config "$SOURCE_ROOT/mods/minimal-metrics/mod.json" "$HERDR_APP_HOME/mods/minimal-metrics/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-metrics/cpu.svg" "$HERDR_APP_HOME/mods/minimal-metrics/cpu.svg"
link_config "$SOURCE_ROOT/mods/minimal-metrics/memory.svg" "$HERDR_APP_HOME/mods/minimal-metrics/memory.svg"
link_config "$SOURCE_ROOT/themes/catppuccin-frappe.json" "$HERDR_APP_HOME/themes/catppuccin-frappe.json"
link_config "$SOURCE_ROOT/mods/minimal-sidebar/main.js" "$HERDR_APP_HOME/mods/minimal-sidebar/main.js"
link_config "$SOURCE_ROOT/mods/minimal-sidebar/mod.json" "$HERDR_APP_HOME/mods/minimal-sidebar/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-agents/main.js" "$HERDR_APP_HOME/mods/minimal-agents/main.js"
link_config "$SOURCE_ROOT/mods/minimal-agents/mod.json" "$HERDR_APP_HOME/mods/minimal-agents/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-picker/main.js" "$HERDR_APP_HOME/mods/minimal-picker/main.js"
link_config "$SOURCE_ROOT/mods/minimal-picker/mod.json" "$HERDR_APP_HOME/mods/minimal-picker/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-pane/main.js" "$HERDR_APP_HOME/mods/minimal-pane/main.js"
link_config "$SOURCE_ROOT/mods/minimal-pane/mod.json" "$HERDR_APP_HOME/mods/minimal-pane/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-pane/close.svg" "$HERDR_APP_HOME/mods/minimal-pane/close.svg"
link_config "$SOURCE_ROOT/mods/minimal-pane/split-down.svg" "$HERDR_APP_HOME/mods/minimal-pane/split-down.svg"
link_config "$SOURCE_ROOT/mods/minimal-pane/split-right.svg" "$HERDR_APP_HOME/mods/minimal-pane/split-right.svg"
link_config "$SOURCE_ROOT/mods/minimal-pane/unzoom.svg" "$HERDR_APP_HOME/mods/minimal-pane/unzoom.svg"
link_config "$SOURCE_ROOT/mods/minimal-pane/zoom.svg" "$HERDR_APP_HOME/mods/minimal-pane/zoom.svg"
link_config "$SOURCE_ROOT/mods/changes-close/main.js" "$HERDR_APP_HOME/mods/changes-close/main.js"
link_config "$SOURCE_ROOT/mods/changes-close/mod.json" "$HERDR_APP_HOME/mods/changes-close/mod.json"
link_config "$SOURCE_ROOT/mods/review-toggle/main.js" "$HERDR_APP_HOME/mods/review-toggle/main.js"
link_config "$SOURCE_ROOT/mods/review-toggle/mod.json" "$HERDR_APP_HOME/mods/review-toggle/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-palette/main.js" "$HERDR_APP_HOME/mods/minimal-palette/main.js"
link_config "$SOURCE_ROOT/mods/minimal-palette/mod.json" "$HERDR_APP_HOME/mods/minimal-palette/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-palette/command.svg" "$HERDR_APP_HOME/mods/minimal-palette/command.svg"
link_config "$SOURCE_ROOT/mods/minimal-rename/main.js" "$HERDR_APP_HOME/mods/minimal-rename/main.js"
link_config "$SOURCE_ROOT/mods/minimal-rename/mod.json" "$HERDR_APP_HOME/mods/minimal-rename/mod.json"
link_config "$SOURCE_ROOT/mods/legacy-prefix/main.js" "$HERDR_APP_HOME/mods/legacy-prefix/main.js"
link_config "$SOURCE_ROOT/mods/legacy-prefix/bindings.js" "$HERDR_APP_HOME/mods/legacy-prefix/bindings.js"
link_config "$SOURCE_ROOT/mods/legacy-prefix/mod.json" "$HERDR_APP_HOME/mods/legacy-prefix/mod.json"
link_config "$SOURCE_ROOT/mods/recap/main.js" "$HERDR_APP_HOME/mods/recap/main.js"
link_config "$SOURCE_ROOT/mods/recap/look.js" "$HERDR_APP_HOME/mods/recap/look.js"
link_config "$SOURCE_ROOT/mods/recap/demo.js" "$HERDR_APP_HOME/mods/recap/demo.js"
link_config "$SOURCE_ROOT/mods/recap/mod.json" "$HERDR_APP_HOME/mods/recap/mod.json"

printf 'Herdr app configuration installed at %s\n' "$HERDR_APP_HOME"
