#!/usr/bin/env bash
# Shared helpers for rbw qutebrowser userscripts.

rbw_qute_msg() {
    local kind="$1"
    local text="$2"
    printf "%s '%s'\n" "$kind" "$text" >> "$QUTE_FIFO"
}

rbw_qute_cmd() {
    printf '%s\n' "$1" >> "$QUTE_FIFO"
}

rbw_host_from_url() {
    python3 - <<'PY'
from urllib.parse import urlparse
import os

url = os.environ.get("QUTE_URL", "")
host = urlparse(url).hostname or ""
if host:
    print(host)
PY
}

rbw_search_terms() {
    python3 - <<'PY'
from urllib.parse import urlparse
import os

url = os.environ.get("QUTE_URL", "")
host = urlparse(url).hostname or ""
if not host:
    raise SystemExit(1)

parts = host.split(".")
terms = [host]
if len(parts) >= 2:
    terms.append(".".join(parts[-2:]))
if len(parts) >= 3 and parts[0] not in {"www", "login", "auth", "account"}:
    terms.append(".".join(parts[1:]))

seen = set()
for term in terms:
    if term and term not in seen:
        seen.add(term)
        print(term)
PY
}

rbw_first_entry() {
    local term line
    while IFS= read -r term; do
        [[ -z "$term" ]] && continue
        line="$(rbw search "$term" --fields user,name 2>/dev/null | sed '/^$/d' | head -1)"
        if [[ -n "$line" ]]; then
            printf '%s\n' "$line"
            return 0
        fi
    done < <(rbw_search_terms)
    return 1
}

rbw_fake_key() {
    local text="$1"
    local i char

    for (( i=0; i<${#text}; i++ )); do
        char="${text:$i:1}"
        if [[ "$char" == " " ]]; then
            rbw_qute_cmd 'fake-key " "'
        else
            rbw_qute_cmd "fake-key \\${char}"
        fi
    done
}
