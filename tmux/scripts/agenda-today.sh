#!/usr/bin/env bash

set -euo pipefail

exec nvim '+lua require("orgmode").action("agenda.prompt")'
