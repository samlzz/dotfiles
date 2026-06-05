#!/usr/bin/env bash
set -uo pipefail

readonly LOCK="/tmp/waypanel-${USER}.pid"
readonly WAYCAL_CSS="/home/sliziard/.config/waybar/waycal_mocha.css"
readonly WAYWEA_SCRIPT="/home/sliziard/.config/hypr/scripts/waywea.sh"

# ── Toggle invocation (waybar on-click / hyprland keybind) ───────────────────
# Returns immediately; delegates lifecycle management to the daemon mode.
if [[ "${1-}" != "--daemon" ]]; then
	if [[ -f "$LOCK" ]]; then
		watcher_pid=$(cat "$LOCK" 2>/dev/null)
		if kill -0 "$watcher_pid" 2>/dev/null; then
			kill "$watcher_pid"
		else
			rm -f "$LOCK"
		fi
		exit 0
	fi
	nohup "$0" --daemon &>/dev/null &
	exit 0
fi

# ── Daemon: open all components and watch for any close event ─────────────────
readonly SELF=$$
echo "$SELF" >"$LOCK"

# Kill any stale instances before opening fresh ones
pkill -x waycal 2>/dev/null || true
pkill -f "term-float.overlay.waywea" 2>/dev/null || true
pkill -f "term-float.overlay.clock" 2>/dev/null || true
swaync-client --open-panel 2>/dev/null || true

waycal \
	--css-path="$WAYCAL_CSS" \
	--anchor=bottom-right \
	--margin-bottom=20 \
	--margin-right=30 \
	--zoom=1.3 &
readonly WAYCAL_PID=$!

alacritty \
	--class "term-float.overlay.waywea" \
	--title "WayWea" \
	-e "$WAYWEA_SCRIPT" &
readonly ALACRITTY_WEA_PID=$!

alacritty \
	--class "term-float.overlay.clock" \
	--title "Clock" \
	-e "tty-clock" &
readonly ALACRITTY_CLOCK_PID=$!

cleanup() {
	trap - EXIT INT TERM
	swaync-client --close-panel 2>/dev/null || true
	kill "${WAYCAL_PID}" "${ALACRITTY_WEA_PID}" "${ALACRITTY_CLOCK_PID}" 2>/dev/null || true
	wait "${WAYCAL_PID}" "${ALACRITTY_WEA_PID}" "${ALACRITTY_CLOCK_PID}" 2>/dev/null || true
	rm -f "$LOCK"
}
trap 'cleanup' EXIT
trap 'exit 0' INT TERM

wait -n "$WAYCAL_PID" "$ALACRITTY_WEA_PID" "$ALACRITTY_CLOCK_PID" || true
