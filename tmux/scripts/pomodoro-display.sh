#!/bin/bash
# ============================================================================
# TMUX Pomodoro Display - Simplified
# ============================================================================

POMODORO_DIR="/tmp/pomodoro"
STATUS_FILE="$POMODORO_DIR/current_status.txt"
START_FILE="$POMODORO_DIR/start_time.txt"
TIME_PAUSED_FOR_FILE="$POMODORO_DIR/time_paused_for.txt"

pink="#f2a4d5"
gray="#6c7086"

[ -f "$STATUS_FILE" ] && status=$(cat "$STATUS_FILE") || status="stopped"

if [ "$status" = "in_progress" ]; then
    start_time=$(cat "$START_FILE" 2>/dev/null)
    if [ -n "$start_time" ]; then
        elapsed=$(( $(date +%s) - start_time - $(cat "$TIME_PAUSED_FOR_FILE" 2>/dev/null || echo 0) ))
        remaining=$(( 1500 - elapsed ))
        [ $remaining -lt 0 ] && remaining=0
        time_display=$(printf "%d:%02d" $(( remaining / 60 )) $(( remaining % 60 )))
    else
        time_display="25:00"
    fi
    printf "#[bg=%s,fg=%s,bold] 󱎫 %s #[default]" "$pink" "#000000" "$time_display"
elif [ "$status" = "paused" ]; then
    printf "#[bg=%s,fg=%s,bold] 󰏤 paused #[default]" "$gray" "#ffffff"
elif [ "$status" = "break" ] || [ "$status" = "long_break" ]; then
    printf "#[bg=%s,fg=%s,bold]  break #[default]" "$pink" "#000000"
fi
