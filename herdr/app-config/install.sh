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
link_config "$SOURCE_ROOT/themes/catppuccin-frappe.json" "$HERDR_APP_HOME/themes/catppuccin-frappe.json"
link_config "$SOURCE_ROOT/mods/minimal-sidebar/main.js" "$HERDR_APP_HOME/mods/minimal-sidebar/main.js"
link_config "$SOURCE_ROOT/mods/minimal-sidebar/mod.json" "$HERDR_APP_HOME/mods/minimal-sidebar/mod.json"
link_config "$SOURCE_ROOT/mods/minimal-agents/main.js" "$HERDR_APP_HOME/mods/minimal-agents/main.js"
link_config "$SOURCE_ROOT/mods/minimal-agents/mod.json" "$HERDR_APP_HOME/mods/minimal-agents/mod.json"

printf 'Herdr app configuration installed at %s\n' "$HERDR_APP_HOME"
