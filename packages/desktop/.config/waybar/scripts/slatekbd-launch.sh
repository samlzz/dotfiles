#!/usr/bin/env bash
# Launch slatekbd on the right output:
#   - no external monitor : main screen
#   - one external monitor : that monitor
#   - several externals    : pick one through fzf

DEPENDENCIES=(slatekbd hyprctl jq fzf alacritty)
SCRIPT_NAME=$(basename "$0")

usage() {
    cat <<EOM

Launch slatekbd on an external monitor if one is plugged, else on the main screen.
With several external monitors, an fzf menu (in a floating terminal) asks which one.

usage: ${SCRIPT_NAME} [options]

options:
    -h|--help                    Show this help message

dependencies: ${DEPENDENCIES[@]}

EOM
    exit 1
}

exit_on_missing_tools() {
    for cmd in "$@"; do
        if command -v "$cmd" &>/dev/null; then
            continue
        fi
        printf "Error: Required tool '%s' is not installed or not in PATH\n" "$cmd" >&2
        notify-send "slatekbd" "Missing tool: $cmd" 2>/dev/null
        exit 1
    done
}

list_external_monitors() {
    hyprctl monitors -j | jq -r '.[].name | select(startswith("eDP") | not)'
}

pick_monitor() {
    local in out
    in=$(mktemp) || return 1
    out=$(mktemp) || return 1
    printf '%s\n' "$@" >"$in"
    # The terminal has its own stdin, so hand fzf the list and result via files
    alacritty --class=term-float -e bash -c \
        'fzf --prompt="slatekbd output > " --height=100% --reverse <"$1" >"$2"' _ "$in" "$out" 2>/dev/null
    cat "$out"
    rm -f "$in" "$out"
}

main() {
    while [ "$1" != "" ]; do
        case $1 in
        -h | --help)
            usage
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            usage
            ;;
        esac
        shift
    done

    exit_on_missing_tools "${DEPENDENCIES[@]}"

    local -a externals
    mapfile -t externals < <(list_external_monitors)

    case ${#externals[@]} in
    0)
        slatekbd
        ;;
    1)
        slatekbd -o "${externals[0]}"
        ;;
    *)
        local chosen
        chosen=$(pick_monitor "${externals[@]}")
        [ -n "$chosen" ] || exit 0
        slatekbd -o "$chosen"
        ;;
    esac
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit 0
fi
