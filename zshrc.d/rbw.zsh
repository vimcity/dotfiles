# rbw (Bitwarden) helpers — manual unlock, ~8h lock timeout

rbwup() {
    rbw unlock
    rbw sync
}

rbwlock() {
    rbw lock
}

rbws() {
    rbw search "$@"
}

rbwp() {
    if (( $# == 0 )); then
        print -u2 "usage: rbwp <needle> [username]"
        return 1
    fi
    rbw get "$@" -c
}

rbwu() {
    if (( $# == 0 )); then
        print -u2 "usage: rbwu <needle> [username]"
        return 1
    fi
    rbw get "$@" --field username -c
}

rbwt() {
    if (( $# == 0 )); then
        print -u2 "usage: rbwt <needle> [username]"
        return 1
    fi
    rbw code "$@" -c
}
