#!/bin/bash

# Script : timer_notify.sh
# Usage : timer_notify.sh <seconds>

DELAY="${1:-0}"

if [[ "$DELAY" -gt 0 ]]; then
    sleep "$DELAY"
    "$HOME"/.local/bin/fs_popup \
        --title "  Time to stop ! " \
        --message "Timer has run out, take a break." \
        --opacity 0.2 \
        --accent "mauve" \
        --monitor "primary"
fi

