#!/usr/bin/env bash
set -euo pipefail
SOURCE_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SOURCE_ROOT/deploy.py" "$@"
