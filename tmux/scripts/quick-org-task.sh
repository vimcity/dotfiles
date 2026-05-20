#!/usr/bin/env bash

set -euo pipefail

exec env NVIM_ORG_POPUP=1 nvim '+lua require("orgmode").action("capture.open_template_by_shortcut", "t")'
