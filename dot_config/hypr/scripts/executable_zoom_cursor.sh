#!/usr/bin/env bash
set -eu -o pipefail

current=$(hyprctl getoption cursor:zoom_factor | grep float | cut -d' ' -f2)

shopt -s extglob

case "${1:-}" in
    reset)
        current=1
        ;;
    ++([0-9])?(.) | ++([0-9]).+([0-9]) | +.+([0-9]))
        current=$(echo "$current $1" | bc -l)
        ;;
    -+([0-9])?(.) | -+([0-9]).+([0-9]) | -.+([0-9]))
        current=$(echo "$current $1" | bc -l)
        ;;
    +([0-9])?(.) | +([0-9]).+([0-9]) | .+([0-9]))
        current=$1
        ;;
    *)
        echo "Error: enter a valid input!" >&2
        exit 1
        ;;
esac

shopt -u extglob

if (( $(echo "$current < 1" | bc -l) )); then
    current=1
fi

hyprctl keyword cursor:zoom_factor "$current"
