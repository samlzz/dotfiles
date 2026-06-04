#!/usr/bin/env bash

IDLE_SERVICE="${1:-hypridle.service}"

# Main colors
BORDER_ACTIVE="0xff89b4fa 0xffcba6f7 35deg" # $blue $mauve
BORDER_INACTIVE="0xff313244"                # $surface0

# Disabled idle colors
BORDER_ACTIVE_NOIDDLE="0xfff38ba8 0xfffab387 35deg" # $red $peach
BORDER_INACTIVE_NOIDLE="0xffeba0ac"                 # $maroon

set_border_colors() {
	local active="$1"
	local inactive="$2"

	hyprctl keyword general:col.active_border "$active"
	hyprctl keyword general:col.inactive_border "$inactive"
}

if systemctl --user is-active --quiet "$IDLE_SERVICE"; then
	systemctl --user stop "$IDLE_SERVICE"
	set_border_colors "$BORDER_ACTIVE_NOIDDLE" "$BORDER_INACTIVE_NOIDLE"
	hyprctl keyword general:border_size 5
	logger -i $$ "waybar:toggle-idle: Hypridle disable"
else
	systemctl --user start "$IDLE_SERVICE"
	set_border_colors "$BORDER_ACTIVE" "$BORDER_INACTIVE"
	hyprctl keyword general:border_size 2 # Default value
	logger -i $$ "waybar:toggle-idle: Hypridle enable"
fi

pgrep -u "$USER" -x waybar | xargs -r kill -SIGRTMIN+10
