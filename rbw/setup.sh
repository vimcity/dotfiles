#!/usr/bin/env bash
# One-time rbw bootstrap: register device, set email, login, unlock.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if ! command -v rbw >/dev/null 2>&1; then
    echo "rbw is not installed. Run: brew install rbw" >&2
    exit 1
fi

bash "$DOTFILES_DIR/rbw/configure.sh"

email="${RBW_EMAIL:-}"
if [[ -z "$email" ]]; then
    if rbw config show email >/dev/null 2>&1; then
        email="$(rbw config show email)"
    fi
fi

if [[ -z "$email" ]]; then
    read -r -p "Bitwarden email: " email
fi

if [[ -n "$email" ]]; then
    rbw config set email "$email"
fi

if ! rbw config show >/dev/null 2>&1; then
    echo "Failed to write rbw config" >&2
    exit 1
fi

echo "If this is your first rbw device on bitwarden.com, register it now."
echo "Get your personal API key from: https://vault.bitwarden.com/#/settings/security/security-keys"
read -r -p "Register this device now? [y/N] " register_now
if [[ "$register_now" =~ ^[Yy]$ ]]; then
    rbw register
fi

echo "Logging in and syncing vault..."
rbw login
rbw sync

echo "Unlocking vault (enter master password)..."
rbw unlock

echo "rbw is ready. Use rbwup once or twice a day to unlock/sync."
