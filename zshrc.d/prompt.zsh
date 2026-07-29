# Custom prompt segments (colors from prompt-themes.zsh)

setopt PROMPT_SUBST
zmodload zsh/datetime

export VIRTUAL_ENV_DISABLE_PROMPT=1

typeset -gF PROMPT_CMD_START=0
typeset -g PROMPT_LAST_DURATION=''

prompt_segment() {
    local bg="$1"
    local fg="$2"
    local text="$3"
    print -n "%K{$bg}%F{$fg} ${text} %f%k"
}

prompt_context_segment() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        prompt_segment "#313244" "#fab387" "󰢹 %m"
    elif [[ "$EUID" -eq 0 ]]; then
        prompt_segment "#bf616a" "#f5f5f5" "󰚌 root"
    fi
}

prompt_dir_display() {
    local path="$PWD"

    if [[ "$path" == "$HOME" ]]; then
        print -r -- "~"
        return
    fi

    if [[ "$path" != "$HOME"/* ]]; then
        print -r -- "$path"
        return
    fi

    local rel_path="${path#$HOME/}"
    local -a path_parts
    path_parts=("${(@s:/:)rel_path}")

    local part
    for part in "${path_parts[@]}"; do
        if [[ "$part" == .* ]]; then
            print -r -- "~/${rel_path}"
            return
        fi
    done

    print -r -- "${path_parts[-1]}"
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

prompt_git_recent_stash() {
    local stash_output stash_epoch stash_subject
    local week_seconds=604800

    stash_output="$(__git_prompt_git stash list -1 --date=unix --format='%ct%x1f%gs' 2>/dev/null)" || return
    [[ -z "$stash_output" ]] && return

    stash_epoch="${stash_output%%$'\x1f'*}"
    stash_subject="${stash_output#*$'\x1f'}"

    [[ -z "$stash_epoch" || -z "$stash_subject" ]] && return
    (( EPOCHSECONDS - stash_epoch > week_seconds )) && return

    stash_subject="${stash_subject#*: }"
    stash_subject="${stash_subject//\%/%%}"

    print -n -- "%F{${THEME_COLORS[git_stash]}}≡ ${stash_subject}%f"
}

prompt_git_segment() {
    local git_output
    git_output="$(__git_prompt_git status --porcelain -b 2>/dev/null)" || return

    local -a lines
    lines=("${(@f)git_output}")
    [[ ${#lines[@]} -eq 0 ]] && return

    local branch_line branch segment
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

    local has_staged=0
    local has_unstaged=0
    local line xy

    for line in "${lines[@]:1}"; do
        [[ -z "$line" ]] && continue

        xy="${line[1,2]}"

        if [[ "$xy" == '??' ]]; then
            has_unstaged=1
            continue
        fi

        [[ "${xy[1]}" != ' ' ]] && has_staged=1
        [[ "${xy[2]}" != ' ' ]] && has_unstaged=1
    done

    (( has_staged )) && segment+=" %F{${THEME_COLORS[git_added]}}●%f"
    (( has_unstaged )) && segment+=" %F{${THEME_COLORS[git_modified]}}%f"

    local stash_segment
    stash_segment="$(prompt_git_recent_stash)"
    [[ -n "$stash_segment" ]] && segment+=" ${stash_segment}"

    prompt_segment "${THEME_COLORS[git_bg]}" "${THEME_COLORS[git_fg]}" "$segment"
}

prompt_dir_segment() {
    prompt_segment "${THEME_COLORS[dir_bg]}" "${THEME_COLORS[dir_fg]}" "%B$(prompt_dir_display)%b"
}

prompt_build_left() {
    prompt_context_segment
    prompt_dir_segment
    prompt_venv_segment
    prompt_git_segment
}

prompt_build_right() {
    local last_status="$1"
    local out=''

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

    print -n "$out"
}

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

    RPROMPT="$(prompt_build_right "$last_status")"
    print ""
}

prompt_preexec() {
    PROMPT_CMD_START=$EPOCHREALTIME
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd
add-zsh-hook preexec prompt_preexec

PROMPT='$(prompt_build_left)'
PROMPT+=$'\n''%F{${THEME_COLORS[prompt_char]}}$%f '
