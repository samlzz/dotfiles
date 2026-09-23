#!/usr/bin/env bash
# Print the HYPRLAND_INSTANCE_SIGNATURE (and, with --export, WAYLAND_DISPLAY)
# of the currently-live Hyprland instance, detected directly from the filesystem
#
# Usage:
#   hypr-live-signature.sh            # prints just the signature
#   hypr-live-signature.sh --export   # prints `export KEY=VALUE` lines,
#                                      # ready for `eval "$(... --export)"`
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr"

sig=""
for dir in "$runtime_dir"/*/; do
    candidate="$(basename "$dir")"
    if [ -S "${dir}.socket.sock" ]; then
        sig="$candidate"
        break
    fi
done

if [ -z "$sig" ]; then
    echo "No live Hyprland instance found under $runtime_dir" >&2
    exit 1
fi

if [ "${1:-}" = "--export" ]; then
    wayland_display="$(sed -n '2p' "$runtime_dir/$sig/hyprland.lock" 2>/dev/null || true)"
    printf 'export HYPRLAND_INSTANCE_SIGNATURE=%q\n' "$sig"
    if [ -n "$wayland_display" ]; then
        printf 'export WAYLAND_DISPLAY=%q\n' "$wayland_display"
    fi
else
    printf '%s\n' "$sig"
fi
