#? Finds the currently live Hyprland instance directly from its runtime
#? dir, rather than trusting any cached copy 
hyprsign() {
	local base="/run/user/$(id -u)/hypr"
	local dir sig
	[[ -d "$base" ]] || return 1
	for dir in "$base"/*/; do
		dir="${dir%/}"
		if [[ -S "$dir/.socket.sock" ]]; then
			sig="${dir##*/}"
			print -r -- "$sig"
			return 0
		fi
	done
	return 1
}

#? Re-exports HYPRLAND_INSTANCE_SIGNATURE / WAYLAND_DISPLAY for the live
#? Hyprland instance in the current shell, and pushes them into tmux's
#? global environment too.
hyprsync() {
	local sig
	sig=$(hyprsign) || {
		echo "hyprsync: no live Hyprland instance found under /run/user/$(id -u)/hypr" >&2
		return 1
	}

	local lock="/run/user/$(id -u)/hypr/$sig/hyprland.lock"
	local wayland_display=""
	[[ -r "$lock" ]] && wayland_display=$(sed -n '2p' "$lock")

	export HYPRLAND_INSTANCE_SIGNATURE="$sig"
	[[ -n "$wayland_display" ]] && export WAYLAND_DISPLAY="$wayland_display"

	if command -v tmux &>/dev/null && tmux info &>/dev/null; then
		tmux set-environment -g HYPRLAND_INSTANCE_SIGNATURE "$sig"
		[[ -n "$wayland_display" ]] && tmux set-environment -g WAYLAND_DISPLAY "$wayland_display"
	fi

	echo "HYPRLAND_INSTANCE_SIGNATURE=$HYPRLAND_INSTANCE_SIGNATURE"
	echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
}

# Self-heal a stale HYPRLAND_INSTANCE_SIGNATURE (e.g. after a Hyprland
# restart while this shell survived inside tmux). Checked before every
# prompt; the check itself is a single stat, so the common case (socket
# still alive) costs nothing.
_hypr_env_selfheal() {
	[[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]] || return 0
	local sock="/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"
	[[ -S "$sock" ]] && return 0
	hyprsync >/dev/null 2>&1
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _hypr_env_selfheal
