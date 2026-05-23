#!/usr/bin/env bash
set -uo pipefail

# Terminal dimensions per day mode (chars — used for wttr.in fetch width)
readonly -a COLS=(90 175 175)
readonly -a ROWS=(12 26 37)

# Window pixel sizes per day mode — tune WIN_W/WIN_H to your font/padding
# WIN_W[0] doit correspondre au `windowrule = size` width
readonly -a WIN_W=(720 1800 1800)
readonly -a WIN_H=(240 680 785)

resize_terminal() {
	hyprctl dispatch resizewindowpixel \
		"exact ${WIN_W[$1]} ${WIN_H[$1]},title:WayWea" 2>/dev/null
	hyprctl dispatch movewindowpixel \
		"exact ${WIN_ORIGIN},title:WayWea" 2>/dev/null
	stty cols "${COLS[$1]}" rows "${ROWS[$1]}" 2>/dev/null || true
	sleep 0.05
}

fetch_weather() {
	COLUMNS="${COLS[$1]}" curl -s "wttr.in/?${1}d" 2>/dev/null
}

render_hint() {
	case $1 in
	0) printf '\n  \033[2m[→] Tomorrow   [q] Close\033[0m\n' ;;
	1) printf '\n  \033[2m[←] Back   [→] +1 day   [q] Close\033[0m\n' ;;
	2) printf '\n  \033[2m[←] Back   [q] Close\033[0m\n' ;;
	esac
}

read_key() {
	local key seq
	IFS= read -rsn1 key
	if [[ "$key" == $'\x1b' ]]; then
		IFS= read -rsn2 -t 0.1 seq || true
		key+="${seq-}"
	fi
	printf '%s' "$key"
}

# ── Init ──────────────────────────────────────────────────
days=0
cache_0="" cache_1="" cache_2=""

# Capture la position appliquée par le windowrule move (attendre Hyprland)
sleep 0.15
WIN_ORIGIN=$(hyprctl clients -j 2>/dev/null |
	jq -r '.[] | select(.title == "WayWea") | "\(.at[0]) \(.at[1])"' |
	head -1)
WIN_ORIGIN="${WIN_ORIGIN:-10 50}"

resize_terminal 0
cache_0=$(fetch_weather 0)

# ── Render loop ───────────────────────────────────────────
while true; do
	clear

	case $days in
	0) printf '%s' "$cache_0" ;;
	1) printf '%s' "$cache_1" ;;
	2) printf '%s' "$cache_2" ;;
	esac
	render_hint "$days"

	key=$(read_key)

	case "$key" in
	# Expand: → or space
	$'\x1b[C' | ' ')
		if [[ $days -lt 2 ]]; then
			((days++))
			resize_terminal "$days"
			# Lazy fetch
			case $days in
			1) [[ -z "$cache_1" ]] && cache_1=$(fetch_weather 1) ;;
			2) [[ -z "$cache_2" ]] && cache_2=$(fetch_weather 2) ;;
			esac
		fi
		;;
	# Collapse: ←
	$'\x1b[D')
		if [[ $days -gt 0 ]]; then
			((days--))
			resize_terminal "$days"
		fi
		;;
	# Quit: q, Q, or plain Escape
	'q' | 'Q' | $'\x1b') break ;;
	esac
done
