# Custom prompt segments (colors from prompt-themes.zsh)
#
# Optimizations:
#   - No PROMPT_SUBST: prompt segments computed in precmd, stored in globals
#   - Single subshell for both git calls (status + stash): 2→1 fork
#   - No subshell forks on every prompt render

zmodload zsh/datetime

export VIRTUAL_ENV_DISABLE_PROMPT=1

typeset -gF PROMPT_CMD_START=0
typeset -g PROMPT_LAST_DURATION=''

# Accumulated prompt segments (set by precmd, read by PROMPT/RPROMPT)
typeset -g _PROMPT_LEFT=''     # left prompt, single line
typeset -g _PROMPT_RIGHT=''    # right prompt
typeset -g _PROMPT_DIR_DISPLAY=''  # dir display result (avoids subshell)
typeset -g _PROMPT_GIT_COMBINED=''  # combined git status+stash output
typeset -g PROMPT_HAS_SHOWN=0

# ── Segment helpers (append to _PROMPT_LEFT directly, no subshells) ──

prompt_segment() {
    local bg="$1" fg="$2" text="$3"
    _PROMPT_LEFT+="%K{$bg}%F{$fg} ${text} %f%k"
}

prompt_context_segment() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        prompt_segment "#313244" "#fab387" "ssh:%m"
    elif [[ "$EUID" -eq 0 ]]; then
        prompt_segment "#bf616a" "#f5f5f5" "root"
    fi
}

prompt_dir_display() {
    local path="$PWD"

    if [[ "$path" == "$HOME" ]]; then
        _PROMPT_DIR_DISPLAY="~"
        return
    fi

    if [[ "$path" != "$HOME"/* ]]; then
        _PROMPT_DIR_DISPLAY="$path"
        return
    fi

    local rel_path="${path#$HOME/}"
    local -a path_parts
    path_parts=("${(@s:/:)rel_path}")

    local part
    for part in "${path_parts[@]}"; do
        if [[ "$part" == .* ]]; then
            _PROMPT_DIR_DISPLAY="~/${rel_path}"
            return
        fi
    done

    _PROMPT_DIR_DISPLAY="${path_parts[-1]}"
}

prompt_format_duration() {
    local elapsed_ms="$1"

    if (( elapsed_ms >= 60000 )); then
        printf '%dm%02ds' $(( elapsed_ms / 60000 )) $(( (elapsed_ms % 60000) / 1000 ))
    else
        printf '%d.%01ds' $(( elapsed_ms / 1000 )) $(( (elapsed_ms % 1000) / 100 ))
    fi
}

prompt_venv_segment() {
    if [[ -n "$VIRTUAL_ENV" && "$PWD" == "${VIRTUAL_ENV:h}"* ]]; then
        prompt_segment "${THEME_COLORS[venv_bg]}" "${THEME_COLORS[venv_fg]}" "%B${VIRTUAL_ENV:t}%b"
    fi
}

prompt_dir_segment() {
    prompt_dir_display
    prompt_segment "${THEME_COLORS[dir_bg]}" "${THEME_COLORS[dir_fg]}" "%B${_PROMPT_DIR_DISPLAY}%b"
}

# ── Single subshell: both git calls in one fork ──
# Output format: STATUS_LINES<\x00>STASH_LINE

_prompt_git_combined() {
    local combined_output
    combined_output="$({
        __git_prompt_git status --porcelain -b 2>/dev/null
        print -r $'\x00'
        __git_prompt_git stash list -1 --date=unix --format='%ct%x1f%gs' 2>/dev/null
    })" || return 1
    _PROMPT_GIT_COMBINED="${combined_output}"
}

# ── Parse combined output ──

_prompt_git_status_lines() {
    print -r -- "${_PROMPT_GIT_COMBINED%%$'\x00'*}"
}

_prompt_git_stash_line() {
    print -r -- "${_PROMPT_GIT_COMBINED##*$'\x00'}"
}

prompt_git_segment() {
    local -a lines branch_line branch segment
    local has_staged=0 has_unstaged=0 line xy week_seconds=604800

    # No git data = not in a repo, skip silently
    [[ -n "$_PROMPT_GIT_COMBINED" ]] || return 0

    lines=("${(@f)$(_prompt_git_status_lines)}")
    [[ ${#lines[@]} -eq 0 ]] && return

    branch_line="${lines[1]#\#\# }"
    branch="${branch_line%%...*}"
    branch="${branch%% *}"

    if [[ "$branch" == "HEAD" || "$branch" == "" ]]; then
        branch="detached"
    fi
    branch="${branch//\%/%%}"

    segment="%F{${THEME_COLORS[git_icon]}} %f%F{${THEME_COLORS[git_fg]}}%B${branch}%b%f"

    if [[ "$branch_line" =~ 'ahead ([0-9]+)' ]]; then
        segment+=" %F{${THEME_COLORS[git_ahead]}}⇡${match[1]}%f"
    fi

    if [[ "$branch_line" =~ 'behind ([0-9]+)' ]]; then
        segment+=" %F{${THEME_COLORS[git_behind]}}⇣${match[1]}%f"
    fi

    for line in "${lines[@]:1}"; do
        [[ -z "$line" ]] && continue
        xy="${line[1,2]}"
        if [[ "$xy" == '??' ]]; then
            has_unstaged=1; continue
        fi
        [[ "${xy[1]}" != ' ' ]] && has_staged=1
        [[ "${xy[2]}" != ' ' ]] && has_unstaged=1
    done

    (( has_staged )) && segment+=" %F{${THEME_COLORS[git_added]}}●%f"
    (( has_unstaged )) && segment+=" %F{${THEME_COLORS[git_modified]}}%f"

    # Parse stash from combined output
    local stash_output stash_epoch stash_subject
    stash_output="$(_prompt_git_stash_line)"
    if [[ -n "$stash_output" ]]; then
        stash_epoch="${stash_output%%$'\x1f'*}"
        stash_subject="${stash_output#*$'\x1f'}"
        if [[ -n "$stash_epoch" && -n "$stash_subject" ]] &&
           (( EPOCHSECONDS - stash_epoch <= week_seconds )); then
            stash_subject="${stash_subject#*: }"
            stash_subject="${stash_subject//\%/%%}"
            segment+=" %F{${THEME_COLORS[git_stash]}}≡ ${stash_subject}%f"
        fi
    fi

    prompt_segment "${THEME_COLORS[git_bg]}" "${THEME_COLORS[git_fg]}" "$segment"
}

# ── Build prompt segments into globals (no subshells) ──

prompt_build_left() {
    _PROMPT_LEFT=''
    prompt_context_segment
    prompt_dir_segment
    prompt_venv_segment
    prompt_git_segment
}

prompt_build_right() {
    local last_status="$1" out=''

    if [[ -n "$PROMPT_LAST_DURATION" ]]; then
        out+="%K{${THEME_COLORS[right_bg]}}%F{${THEME_COLORS[right_fg]}}  ${PROMPT_LAST_DURATION} %f%k "
    fi

    local count
    count=$(jobs -p 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" != "0" ]]; then
        out+="%K{${THEME_COLORS[right_bg]}}%F{${THEME_COLORS[right_fg]}}  ${count} %f%k "
    fi

    if [[ "$last_status" -ne 0 ]]; then
        out+="%K{${THEME_COLORS[right_bg]}}%F{${THEME_COLORS[error_fg]}} ✘ ${last_status} %f%k"
    fi

    _PROMPT_RIGHT="$out"
}

# ── Precmd: compute everything once per render ──

prompt_precmd() {
    local last_status="$?"

    if (( PROMPT_CMD_START > 0 )); then
        local elapsed_ms=$(( ( EPOCHREALTIME - PROMPT_CMD_START) * 1000 ))
        if (( elapsed_ms >= 1200 )); then
            PROMPT_LAST_DURATION="$(prompt_format_duration "$elapsed_ms")"
        else
            PROMPT_LAST_DURATION=''
        fi
        PROMPT_CMD_START=0
    else
        PROMPT_LAST_DURATION=''
    fi

    # Add a spacer before subsequent prompts, not before the initial prompt.
    if (( PROMPT_HAS_SHOWN )); then
        print
    else
        PROMPT_HAS_SHOWN=1
    fi

    # Single subshell for both git calls, then build all segments (no more $())
    _PROMPT_GIT_COMBINED=''
    _prompt_git_combined 2>/dev/null || _PROMPT_GIT_COMBINED=''
    prompt_build_left
    prompt_build_right "$last_status"

    # Build final PROMPT — no $() expansion on render, just variable reference
    local prompt_char_color="${THEME_COLORS[prompt_char]}"
    PROMPT="${_PROMPT_LEFT}"$'\n'"%F{${prompt_char_color}}"'$'"%f "
    RPROMPT="${_PROMPT_RIGHT}"
}

prompt_preexec() {
    PROMPT_CMD_START=$EPOCHREALTIME
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd
add-zsh-hook preexec prompt_preexec
