#!/usr/bin/env bash
# Push the live Hyprland instance's signature + WAYLAND_DISPLAY into tmux's
# global environment table
#
# Called from two places, to cover both timing directions of the same bug:
#   - tmux.conf's `session-created` hook: a tmux server that starts after
#     Hyprland is already running picks up the right values immediately.
#   - hyprland.lua's `hyprland.start` event: an already-running tmux server
#     (whose panes survive a Hyprland restart) gets its cached copy
#     refreshed the moment the new Hyprland instance comes up, instead of
#     staying pinned to the dead one until someone reattaches tmux.

set -euo pipefail

command -v tmux >/dev/null 2>&1 || exit 0
tmux info >/dev/null 2>&1 || exit 0

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exports="$("$script_dir/hypr-live-signature.sh" --export 2>/dev/null)" || exit 0

while IFS= read -r line; do
    # line looks like: export KEY=VALUE (VALUE already shell-quoted)
    kv="${line#export }"
    key="${kv%%=*}"
    val="${kv#*=}"
    # strip the %q quoting so tmux gets the raw value
    eval "val=$val"
    tmux set-environment -g "$key" "$val"
done <<<"$exports"
