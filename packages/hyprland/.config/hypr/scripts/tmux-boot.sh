#!/usr/bin/env bash

tmux new-session -d -s autostart

"$(dirname "${BASH_SOURCE[0]}")/hypr-tmux-sync.sh"

sleep 3

if tmux has-session -t autostart 2>/dev/null; then
    tmux kill-session -t autostart
fi

