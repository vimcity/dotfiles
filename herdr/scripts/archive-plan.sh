#!/usr/bin/env bash

set -euo pipefail

plans_dir="${ORG_PLANS_PATH:-$HOME/Documents/org/plans}"

mv -- "$plans_dir/$1" "$plans_dir/archive/"
