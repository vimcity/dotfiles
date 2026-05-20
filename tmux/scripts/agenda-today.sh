#!/usr/bin/env bash

set -euo pipefail

exec env NVIM_ORG_POPUP=1 nvim '+lua require("orgmode").agenda:open_by_key("a")'
