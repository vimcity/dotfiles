#!/usr/bin/env bash
# rbw defaults: manual master password, 8-hour unlock window.
set -euo pipefail

if ! command -v rbw >/dev/null 2>&1; then
    echo "rbw is not installed. Run: brew install rbw" >&2
    exit 1
fi

LOCK_TIMEOUT="${RBW_LOCK_TIMEOUT:-28800}"

rbw config set lock_timeout "$LOCK_TIMEOUT"

current_pinentry="$(rbw config show 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("pinentry") or "")' 2>/dev/null || true)"
if [[ "$current_pinentry" == *pinentry-rbw-macos* ]]; then
    rbw config unset pinentry
    echo "rbw pinentry -> default (manual master password)"
fi

echo "rbw lock_timeout -> ${LOCK_TIMEOUT}s (~$(( LOCK_TIMEOUT / 3600 )) hours)"
