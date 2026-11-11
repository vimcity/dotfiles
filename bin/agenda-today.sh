#!/usr/bin/env bash

set -euo pipefail

org_path="${ORG_PATH:-$HOME/Documents/org}"
cd "$org_path"

exec env NVIM_ORG_POPUP=1 NVIM_NO_DASHBOARD=1 nvim '+lua require("orgmode").agenda:open_by_key("a")'
