# Keep HYPRLAND_INSTANCE_SIGNATURE (and WAYLAND_DISPLAY) correct in
# long-lived shells by exports the live values straight from the socket
# before every prompt

_hypr_env_sync() {
	local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr"
	[[ -d "$runtime_dir" ]] || return 0

	if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" && -S "$runtime_dir/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" ]]; then
		return 0
	fi

	local script="$HOME/.config/hypr/scripts/hypr-live-signature.sh"
	[[ -x "$script" ]] || return 0

	local exports
	exports="$("$script" --export 2>/dev/null)" || return 0
	eval "$exports"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _hypr_env_sync
