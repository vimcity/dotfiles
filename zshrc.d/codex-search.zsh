# sid KEYWORD  -> thread_id + rollout_path from memory (primary use case)
#
# Plain ripgrep when you want more:
#   rg -l KEYWORD ~/.codex/memories/rollout_summaries
#   rg KEYWORD ~/.codex/memories/MEMORY.md

codex-search() {
  local kw="$1"
  local -a summaries summary

  [[ -n "$kw" ]] || {
    print -u2 'usage: codex-search KEYWORD'
    return 1
  }

  summaries=("${(@f)$(rg -l "$kw" "$HOME/.codex/memories/rollout_summaries" 2>/dev/null)}")
  if (( ${#summaries[@]} )); then
    for summary in "${summaries[@]}"; do
      rg '^thread_id:|^rollout_path:|^cwd:' "$summary"
      print -r -- ''
    done
    return 0
  fi

  print -u2 'no memory match; try: rg -l '"$kw"' ~/.codex/memories'
  return 1
}
