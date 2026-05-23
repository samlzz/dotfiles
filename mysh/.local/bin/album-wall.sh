#!/usr/bin/env bash

DEPENDENCIES=(playerctl awww curl file)
SCRIPT_NAME=$(basename "$0")

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/album-wall"
FALLBACK_WALL="${HOME}/Pictures/wallpapers/evening-sky.png"

awww_TRANSITION="fade" # fade | wipe | wave | grow | outer | any | random
awww_DURATION="1"
awww_FPS="60"
awww_TRANSITION_ANGLE="30" # wipe/wave only

#TARGET_PLAYERS="deezer-enhanced,firefox,chromium,brave,mpv"
TARGET_PLAYERS="deezer-enhanced,mpv"

USE_MATUGEN=true
DEBOUNCE_DELAY="1.5"

function usage() {
	cat <<EOM

Dynamic wallpaper daemon from MPRIS album art (playerctl + awww).

usage: ${SCRIPT_NAME}

    Typically launched via hyprland.conf:
      exec-once = ~/.local/bin/album-wall.sh

dependencies: ${DEPENDENCIES[*]}
optional    : matugen

EOM
	exit 1
}

function main() {
	while [ "$#" != "0" ]; do
		case "$1" in
		-h | --help) usage ;;
		*)
			printf "Error: unknown option '%s'\n" "$1" >&2
			usage
			;;
		esac
		shift
	done

	exit_on_missing_tools "${DEPENDENCIES[@]}"

	mkdir -p "$CACHE_DIR"

	# awww-daemon silently crashes if started twice
	if ! awww query &>/dev/null; then
		log "Starting awww daemon..."
		awww-daemon --format xrgb &
		sleep 1
	fi

	log "Starting (players: $TARGET_PLAYERS)"

	local last_url=""

	# playerctl --follow emits a line on every metadata change;
	# we only act on art URL changes
	playerctl \
		--player="$TARGET_PLAYERS" \
		--follow \
		metadata \
		--format "{{mpris:artUrl}}" 2>/dev/null |
		while IFS= read -r art_url; do

			[[ "$art_url" == "$last_url" ]] && continue
			last_url="$art_url"

			sleep "$DEBOUNCE_DELAY"

			local current_url
			current_url=$(
				playerctl --player="$TARGET_PLAYERS" metadata mpris:artUrl 2>/dev/null || echo ""
			)

			if [[ "$current_url" != "$art_url" ]]; then
				log "URL changed during debounce, skipping"
				continue
			fi

			process_art_url "$art_url"
		done

	log "Daemon stopped (playerctl exited)"
}

function process_art_url() {
	local url="$1"

	if [[ -z "$url" ]]; then
		log "No album art, falling back to wallpaper"
		[[ -f "$FALLBACK_WALL" ]] && set_wallpaper "$FALLBACK_WALL"
		return
	fi

	if [[ "$url" == file://* ]]; then
		local local_path="${url#file://}"
		if [[ -f "$local_path" ]]; then
			log "Local art: $local_path"
			set_wallpaper "$local_path" && apply_matugen "$local_path"
		else
			log "Local file not found: $local_path"
		fi
		return
	fi

	local hash
	hash=$(echo -n "$url" | md5sum | cut -d' ' -f1)
	local cached="${CACHE_DIR}/${hash}.img"

	if [[ ! -f "$cached" ]]; then
		log "Downloading art: $url"
		if ! curl --silent --fail --max-time 10 --location \
			--output "$cached" "$url" 2>/dev/null; then
			log "Download failed"
			rm -f "$cached"
			[[ -f "$FALLBACK_WALL" ]] && set_wallpaper "$FALLBACK_WALL"
			return
		fi
	fi

	set_wallpaper "$cached" && apply_matugen "$cached"
	cleanup_cache
}

function set_wallpaper() {
	local img="$1"

	local mime
	mime=$(file --brief --mime-type "$img" 2>/dev/null || echo "")
	if [[ "$mime" != image/* ]]; then
		log "Not recognized as image ($mime): $img"
		return 1
	fi

	log "Wallpaper → $img"

	awww img "$img" \
		--transition-type "$awww_TRANSITION" \
		--transition-duration "$awww_DURATION" \
		--transition-fps "$awww_FPS" \
		--transition-angle "$awww_TRANSITION_ANGLE" \
		--transition-bezier ".25,.1,.25,1" \
		2>/dev/null || {
		log "awww img failed for $img"
		return 1
	}
}

function apply_matugen() {
	local img="$1"
	if [[ "$USE_MATUGEN" == true ]] && command -v matugen &>/dev/null; then
		matugen image "$img" --mode dark 2>/dev/null &&
			log "matugen palette applied from $img" ||
			log "matugen failed (non-blocking)"
	fi
}

function cleanup_cache() {
	local count
	count=$(find "$CACHE_DIR" -name "*.img" | wc -l)
	if [[ $count -gt 20 ]]; then
		find "$CACHE_DIR" -name "*.img" -printf '%T+ %p\n' |
			sort | head -n $((count - 20)) |
			awk '{print $2}' |
			xargs -r rm --
	fi
}

function log() {
	echo "[album-wall] $(date '+%H:%M:%S') $*" >>"${XDG_STATE_HOME:-$HOME/.local/state}/album-wall.log"
}

function exit_on_missing_tools() {
	for cmd in "$@"; do
		if ! command -v "$cmd" &>/dev/null; then
			printf "Error: required tool '%s' not found in PATH\n" "$cmd" >&2
			exit 1
		fi
	done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
	exit 0
fi
