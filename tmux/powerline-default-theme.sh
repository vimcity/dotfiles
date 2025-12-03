# shellcheck shell=bash
# Default Theme
# If changes made here does not take effect, then try to re-create the tmux session to force reload.

# background for macchiato catppuccin terminal theme
thm_bg="#24273A"

thm_fg="#c6d0f5"
thm_cyan="#99d1db"
thm_black="#292c3c"
thm_gray="#414559"
thm_magenta="#ca9ee6"
thm_pink="#f4b8e4"
thm_blue="#8caaee"
thm_black4="#626880"
rosewater="#f2d5cf"
flamingo="#eebebe"
pink="#f4b8e4"
mauve="#ca9ee6"
red="#e78284"
maroon="#ea999c"
peach="#ef9f76"
yellow="#e5c890"
green="#a6d189"
teal="#81c8be"
sky="#99d1db"
sapphire="#85c1dc"
blue="#8caaee"
lavender="#babbf1"
text="#c6d0f5"
subtext1="#b5bfe2"
subtext0="#a5adce"
overlay2="#949cbb"
overlay1="#838ba7"
overlay0="#737994"
surface2="#626880"
surface1="#51576d"
surface0="#414559"
base="#303446"
mantle="#292c3c"
crust="#232634"
eggplant="#e889d2"
sky_blue="#a7c7e7"
spotify_green="#1db954"
spotify_black="#191414"

if tp_patched_font_in_use; then
    # TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
    # TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
    # TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
    # TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""

    TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
    TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
    TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
    TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
    TMUX_POWERLINE_SEPARATOR_THIN="|"
else
    TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
    TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
    TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
    TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

# See Color formatting section below for details on what colors can be used here.
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-$thm_bg}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-$thm_fg}
# shellcheck disable=SC2034
TMUX_POWERLINE_SEG_AIR_COLOR=$(tp_air_color)

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

# See `man tmux` for additional formatting options for the status line.
# The `format regular` and `format inverse` functions are provided as conveniences

if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
    TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
        "#[fg=$thm_fg,bg=$thm_bg]"
        "$TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR"
        "#[fg=$thm_bg,bg=$thm_fg]"
        # " #I#F "
        "#I#F"
        # "$TMUX_POWERLINE_SEPARATOR_THIN"
        # " #W#{?window_zoomed_flag, 󰁌,} "
        " #W "
        "#[fg=$thm_fg,bg=$thm_bg]"
        "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
    )
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_STYLE" ]; then
    TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
        "$(tp_format regular)"
    )
fi

# shellcheck disable=SC2128
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
    TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
        "#[$(tp_format regular)]"
        # "  #I#{?window_flags,#F, } "
        " "
        "#I#F"
        # " #{?window_flags,,} "
        # "$TMUX_POWERLINE_SEPARATOR_THIN"
        # " #W#{?window_zoomed_flag, 󰁌,} "
        " #W "
        " "
    )
fi

# Format: segment_name [background_color|default_bg_color] [foreground_color|default_fg_color] [non_default_separator|default_separator] [separator_background_color|no_sep_bg_color]
#                      [separator_foreground_color|no_sep_fg_color] [spacing_disable|no_spacing_disable] [separator_disable|no_separator_disable]
#
# * background_color and foreground_color. Color formatting (see `man tmux` for complete list) or run the color_palette.sh in the tmux-powerline root directory:
#   * Named colors, e.g. black, red, green, yellow, blue, magenta, cyan, white
#   * Hexadecimal RGB string e.g. #ffffff
#   * 'default_fg_color|default_bg_color' for the default theme bg and fg color
#   * 'default' for the default tmux color.
#   * 'terminal' for the terminal's default background/foreground color
#   * The numbers 0-255 for the 256-color palette. Run `tmux-powerline/color-palette.sh` to see the colors.
# * non_default_separator - specify an alternative character for this segment's separator
#   * 'default_separator' for the theme default separator
# * separator_background_color - specify a unique background color for the separator
#   * 'no_sep_bg_color' for using the default coloring for the separator
# * separator_foreground_color - specify a unique foreground color for the separator
#   * 'no_sep_fg_color' for using the default coloring for the separator
# * spacing_disable - remove space on left, right or both sides of the segment:
#   * "no_spacing_disable" - don't disable spacing (default)
#   * "left_disable" - disable space on the left
#   * "right_disable" - disable space on the right
#   * "both_disable" - disable spaces on both sides
#   * - any other character/string produces no change to default behavior (eg "none", "X", etc.)
#
# * separator_disable - disables drawing a separator on this segment, very useful for segments
#   with dynamic background colours (eg tmux_mem_cpu_load):
#   * "no_separator_disable" - don't disable the separator (default)
#   * "separator_disable" - disables the separator
#   * - any other character/string produces no change to default behavior
#
# Example segment with separator disabled and right space character disabled:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} 0 0 right_disable separator_disable"
#
# Example segment with spacing characters disabled on both sides but not touching the default coloring:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} no_sep_bg_color no_sep_fg_color both_disable"
#
# Example segment with changing the foreground color of the default separator:
# "hostname 33 0 default_separator no_sep_bg_color 120"
#
## Note that although redundant the non_default_separator, separator_background_color and
# separator_foreground_color options must still be specified so that appropriate index
# of options to support the spacing_disable and separator_disable features can be used
# The default_* and no_* can be used to keep the default behaviour.

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
    TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
        "tmux_session_info #{?client_prefix,$red,$blue} $thm_bg"
        # "hostname $eggplant $thm_bg"
        #"ifstat 30 255"
        #"ifstat_sys 30 255"
        # "lan_ip $sky_blue $thm_bg ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}"
        # "wan_ip $sky_blue $thm_bg"
        # "vcs_branch $thm_gray"
        #"air ${TMUX_POWERLINE_SEG_AIR_COLOR} $thm_bg"
        #"vcs_compare 60 255"
        #"vcs_staged 64 255"
        #"vcs_modified 9 255"
        #"vcs_others 245 0"
    )
fi

# shellcheck disable=SC1143,SC2128
if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
    TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
        "earthquake 3 0"
        # "pwd $mauve $surface0"
        "macos_notification_count 29 255"
        #"mailcount 9 255"
        # "now_playing $spotify_green $spotify_black"
        "mem_used $maroon $thm_bg"
        # "cpu $lavender $thm_bg"
        #"tmux_mem_cpu_load 234 136"
        "battery $teal $thm_bg"
        #"weather 37 255"
        #"rainbarf 0 ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}"
        #"xkb_layout 125 117"
        "date_day $blue $thm_bg"
        "date $mauve $thm_bg"
        "time $green $thm_bg"
        #"utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"
    )
fi
