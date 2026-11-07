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

printf 'Herdr app configuration installed at %s\n' "$HERDR_APP_HOME"
