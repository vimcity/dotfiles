# rex-resume — auto-resume agent sessions on Rex shell startup.
# For an interactive top-level shell (SHLVL 1) inside Rex:
#   - If a record under 14 days old exists and the agent PID is dead,
#     auto-resume by executing `rex-resume resume` once (via exec).
#   - On every prompt after that, clean up the pane's record if its PID is dead
#     (= user quit on purpose).
#
# Disable auto-resume: export REX_RESUME_DISABLE=1

# ---------------------------------------------------------------------------
# Init
# ---------------------------------------------------------------------------

if [ -n "${REX_RESUME_DISABLE:-}" ]; then
  return 0 2>/dev/null || true
fi

# Only activate for interactive shells inside Rex.
if [ -z "${REX_SESSION:-}" ]; then
  return 0 2>/dev/null || true
fi

if [ "${SHLVL:-1}" -gt 1 ]; then
  return 0 2>/dev/null || true
fi

REX_RESUME_DATA_FILE="${REX_RESUME_DIR:-$HOME/.local/state/rex-resume}/.json"
REX_RESUME_SHELL_PID=$$
REX_RESUME_SHOWN=0

# ---------------------------------------------------------------------------
# One-shot precmd: auto-resume if a fresh record exists with dead PID.
# Uses exec so the agent replaces this shell — no more precmd calls after.
# ---------------------------------------------------------------------------

_rex_resume_precmd() {
  [ -f "$REX_RESUME_DATA_FILE" ] || return 0

  local record
  record=$(jq -es ".[] | select(.block == \"$REX_BLOCK\")" "$REX_RESUME_DATA_FILE" 2>/dev/null) || return 0

  local updated_at agent pid
  updated_at=$(echo "$record" | jq -r '.updated_at')
  agent=$(echo "$record" | jq -r '.agent')
  pid=$(echo "$record" | jq -r '.pid')

  # Skip if stale (>14 days).
  local updated_epoch now_epoch cutoff_epoch
  now_epoch=$(date +%s)
  updated_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated_at" +%s 2>/dev/null || echo "0")
  cutoff_epoch=$((now_epoch - 14 * 86400))

  if [ "$updated_epoch" -lt "$cutoff_epoch" ]; then
    return 0
  fi

  # Only resume once per shell session.
  if [ "$REX_RESUME_SHOWN" -eq 1 ]; then
    return 0
  fi

  # Only resume if the recorded agent process is dead (user quit or Rex restarted).
  if kill -0 "$pid" 2>/dev/null; then
    return 0
  fi

  REX_RESUME_SHOWN=1

  # Get the resume command and execute it via exec (replaces this shell).
  local cmd_line
  cmd_line=$(rex-resume resume "$REX_BLOCK" 2>/dev/null) || {
    echo -e "\n\033[33mrex-resume:\033[0m No resume command available for this pane."
    return 0
  }

  if [ -z "$cmd_line" ]; then
    echo -e "\n\033[33mrex-resume:\033[0m No resume command available for this pane."
    return 0
  fi

  # Execute the resume command — agent replaces this shell.
  eval "$cmd_line"
}

precmd_functions=(_rex_resume_precmd $precmd_functions)

# ---------------------------------------------------------------------------
# Cleanup: on every prompt, remove stale records for dead PIDs.
# Only cleans up our own block's record.
# ---------------------------------------------------------------------------

_rex_resume_cleanup() {
  [ -f "$REX_RESUME_DATA_FILE" ] || return 0

  local tmp
  tmp=$(mktemp "${REX_RESUME_DIR:-$HOME/.local/state/rex-resume}/.rex-resume.XXXXXX")

  while IFS= read -r record; do
    local pid block
    pid=$(echo "$record" | jq -r '.pid')
    block=$(echo "$record" | jq -r '.block')

    # Only clean up our own block.
    if [ "$block" != "$REX_BLOCK" ]; then
      echo "$record" >> "$tmp"
      continue
    fi

    # If PID is still alive, keep the record.
    if kill -0 "$pid" 2>/dev/null; then
      echo "$record" >> "$tmp"
    fi
  done < "$REX_RESUME_DATA_FILE"

  mv "$tmp" "$REX_RESUME_DATA_FILE"
}

precmd_functions=(_rex_resume_cleanup $precmd_functions)
