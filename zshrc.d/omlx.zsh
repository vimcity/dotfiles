export OMLX_BASE_DIR="${OMLX_BASE_DIR:-$HOME/.omlx}"
export OMLX_MODEL_DIR="${OMLX_MODEL_DIR:-$OMLX_BASE_DIR/models}"
_omlx_model_list() {
  [[ -d "$OMLX_MODEL_DIR" ]] || return 1
  command ls -1 "$OMLX_MODEL_DIR" 2>/dev/null | sort
}
_omlx_current_model() {
  if [[ -n "$OMLX_DEFAULT_MODEL" && -d "$OMLX_MODEL_DIR/$OMLX_DEFAULT_MODEL" ]]; then
    print -r -- "$OMLX_DEFAULT_MODEL"
    return 0
  fi
  _omlx_model_list | head -n 1
}
_omlx_ram_gb() {
  local mem_bytes
  mem_bytes="$(sysctl -n hw.memsize 2>/dev/null)" || return 1
  print -r -- $(( mem_bytes / 1024 / 1024 / 1024 ))
}
_omlx_max_params_b() {
  local ram_gb
  ram_gb="${OMLX_MAX_PARAMS_RAM_GB_OVERRIDE:-$(_omlx_ram_gb)}"
  if (( ram_gb >= 64 )); then
    print -r -- 72
  elif (( ram_gb >= 48 )); then
    print -r -- 32
  elif (( ram_gb >= 32 )); then
    print -r -- 24
  elif (( ram_gb >= 24 )); then
    print -r -- 14
  elif (( ram_gb >= 16 )); then
    print -r -- 8
  else
    print -r -- 3
  fi
}
_omlx_model_params_b() {
  local model_name="$1"
  if [[ "$model_name" =~ 'A([0-9]+)B' ]]; then
    print -r -- "$match[1]"
    return 0
  fi
  if [[ "$model_name" =~ '([0-9]+)B' ]]; then
    print -r -- "$match[1]"
    return 0
  fi
  return 1
}
_omlx_model_fits_machine() {
  local model_name="$1"
  local params_b max_params_b
  params_b="$(_omlx_model_params_b "$model_name")" || return 1
  max_params_b="${OMLX_MAX_PARAMS_B:-$(_omlx_max_params_b)}"
  (( params_b <= max_params_b )) || return 1
  if (( params_b > 14 )) && [[ "$model_name:l" != *4bit* ]] && [[ "$model_name:l" != *q4* ]]; then
    return 1
  fi
  return 0
}
_omlx_filter_fit_models() {
  local model_name
  while IFS= read -r model_name; do
    [[ -n "$model_name" ]] || continue
    _omlx_model_fits_machine "$model_name" && print -r -- "$model_name"
  done
}
_omlx_model_has_permissive_license() {
  local model_name="$1"
  local info
  info="$(hf models info "$model_name" 2>/dev/null)" || return 1
  [[ "$info" == *'license:apache-2.0'* || "$info" == *'license:mit'* ]]
}
_omlx_filter_permissive_models() {
  local model_name
  while IFS= read -r model_name; do
    [[ -n "$model_name" ]] || continue
    _omlx_model_has_permissive_license "$model_name" && print -r -- "$model_name"
  done
}
omlx-models() {
  _omlx_model_list
}
omlx-model() {
  local selected="$1"
  if [[ -z "$selected" ]]; then
    if command -v fzf >/dev/null 2>&1; then
      selected="$(_omlx_model_list | fzf --prompt='oMLX model> ' --height=40%)"
    else
      _omlx_model_list
      return 0
    fi
  fi
  [[ -n "$selected" ]] || return 1
  if [[ ! -d "$OMLX_MODEL_DIR/$selected" ]]; then
    print "Model not installed: $selected"
    return 1
  fi
  export OMLX_DEFAULT_MODEL="$selected"
  print "Current oMLX model: $OMLX_DEFAULT_MODEL"
}
omlx-hot() {
  hf models ls --author mlx-community --sort trending_score --limit "${1:-20}" --expand downloads,likes,lastModified
}
omlx-hot-fit() {
  hf models ls --author mlx-community --sort trending_score --limit "${1:-50}" -q | _omlx_filter_fit_models
}
omlx-hot-fit-oss() {
  hf models ls --author mlx-community --sort trending_score --limit "${1:-30}" -q | _omlx_filter_fit_models | _omlx_filter_permissive_models
}
omlx-search() {
  local query="$*"
  if [[ -z "$query" ]]; then
    print "Usage: omlx-search <query>"
    return 1
  fi
  hf models ls --author mlx-community --search "$query" --sort trending_score --limit 30 --expand downloads,likes,lastModified
}
omlx-search-fit() {
  local query="$*"
  if [[ -z "$query" ]]; then
    print "Usage: omlx-search-fit <query>"
    return 1
  fi
  hf models ls --author mlx-community --search "$query" --sort trending_score --limit 50 -q | _omlx_filter_fit_models
}
omlx-search-fit-oss() {
  local query="$*"
  if [[ -z "$query" ]]; then
    print "Usage: omlx-search-fit-oss <query>"
    return 1
  fi
  hf models ls --author mlx-community --search "$query" --sort trending_score --limit 50 -q | _omlx_filter_fit_models | _omlx_filter_permissive_models
}
omlx-machine() {
  local ram_gb max_params_b
  ram_gb="$(_omlx_ram_gb)" || return 1
  max_params_b="${OMLX_MAX_PARAMS_B:-$(_omlx_max_params_b)}"
  print "Machine RAM: ${ram_gb}GB"
  print "Recommended max model size: ${max_params_b}B"
  print "Rule: models over 14B should be 4-bit/Q4"
}
omlx-install() {
  local repo="$1"
  local local_name="$2"
  if [[ -z "$repo" ]]; then
    print "Usage: omlx-install <hf-repo> [local-name]"
    return 1
  fi
  if [[ "$repo" != */* ]]; then
    repo="mlx-community/$repo"
  fi
  if [[ -z "$local_name" ]]; then
    local_name="${repo##*/}"
  fi
  mkdir -p "$OMLX_MODEL_DIR" || return 1
  hf download "$repo" --local-dir "$OMLX_MODEL_DIR/$local_name"
}
omlx-pick-install() {
  local query="${*:-Instruct 4bit}"
  local repo
  if ! command -v fzf >/dev/null 2>&1; then
    print "fzf required for omlx-pick-install"
    return 1
  fi
  repo="$(hf models ls --author mlx-community --search "$query" --sort trending_score --limit 50 -q | fzf --prompt='HF mlx model> ' --height=50%)"
  [[ -n "$repo" ]] || return 1
  omlx-install "$repo"
}
omlx-pick-install-fit() {
  local query="${*:-Instruct 4bit}"
  local repo
  if ! command -v fzf >/dev/null 2>&1; then
    print "fzf required for omlx-pick-install-fit"
    return 1
  fi
  repo="$(hf models ls --author mlx-community --search "$query" --sort trending_score --limit 80 -q | _omlx_filter_fit_models | fzf --prompt='HF mlx fit> ' --height=50%)"
  [[ -n "$repo" ]] || return 1
  omlx-install "$repo"
}
omlx-pick-install-fit-oss() {
  local query="${*:-Instruct 4bit}"
  local repo
  if ! command -v fzf >/dev/null 2>&1; then
    print "fzf required for omlx-pick-install-fit-oss"
    return 1
  fi
  repo="$(hf models ls --author mlx-community --search "$query" --sort trending_score --limit 60 -q | _omlx_filter_fit_models | _omlx_filter_permissive_models | fzf --prompt='HF mlx oss fit> ' --height=50%)"
  [[ -n "$repo" ]] || return 1
  omlx-install "$repo"
}
