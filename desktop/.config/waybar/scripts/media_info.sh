#!/usr/bin/env bash

# ─── Arguments ───────────────────────────────────────────
# --artist      : affiche aussi l'artiste (désactivé par défaut)
# --priority    : nom du lecteur prioritaire (deezer par défaut)

SHOW_ARTIST=false
PRIORITY_PLAYER="deezer"
PRIORITY_SHOULD_PLAYING=true

parse_arg() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--artist)
			SHOW_ARTIST=true
			shift
			;;
		--priority)
			PRIORITY_PLAYER="$2"
			shift 2
			;;
		*)
			shift
			;;
		esac
	done
}

get_prio_player() {
	local player
	while IFS= read -r player; do
		if [[ "$player" == *"$PRIORITY_PLAYER"* ]]; then
			if [[ "$PRIORITY_SHOULD_PLAYING" == true ]]; then
				local state
				state="$(playerctl -p "$player" status 2>/dev/null)"
				if [[ "$state" == "Playing" ]]; then
					echo "$player"
					break
				fi
			else
				echo "$player"
				break
			fi
		fi
	done <<<"$@"
}

get_playing_player() {
	local player
	while IFS= read -r player; do
		local state
		state=$(playerctl -p "$player" status 2>/dev/null)
		if [[ "$state" == "Playing" ]]; then
			echo "$player"
			break
		fi
	done <<<"$@"
}

main() {
	local players
	players=$(playerctl -l 2>/dev/null)
	if [[ -z "$players" ]]; then
		exit 0
	fi

	selected="$(get_prio_player "$players")"
	if [[ -z "$selected" ]]; then
		selected="$(get_playing_player "$players")"
	fi
	# Fallback to first one
	[[ -z "$selected" ]] && selected=$(echo "$players" | head -1)

	artist=$(playerctl -p "$selected" metadata artist 2>/dev/null)
	title=$(playerctl -p "$selected" metadata title 2>/dev/null)
	[[ -z "$title" ]] && exit 0

	if [[ -n "$artist" ]] && [[ "$SHOW_ARTIST" == true ]]; then
		echo "${artist} — ${title}"
	else
		echo "${title}"
	fi
}

parse_arg "$@"
main
