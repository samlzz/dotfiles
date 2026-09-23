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

	# active is "<color1> <color2> <angle>deg" -- hl.config() rejects that
	# raw gradient string, it needs the { colors = {...}, angle = N } form.
	local -a parts
	read -ra parts <<<"$active"
	local color1="${parts[0]}" color2="${parts[1]}" angle="${parts[2]%deg}"

	hyprctl eval "hl.config({ general = { col = { active_border = { colors = { \"$color1\", \"$color2\" }, angle = $angle }, inactive_border = \"$inactive\" } } })"
}

if systemctl --user is-active --quiet "$IDLE_SERVICE"; then
	systemctl --user stop "$IDLE_SERVICE"
	set_border_colors "$BORDER_ACTIVE_NOIDDLE" "$BORDER_INACTIVE_NOIDLE"
	hyprctl eval 'hl.config({ general = { border_size = 5 } })'
	logger -i $$ "waybar:toggle-idle: Hypridle disable"
else
	systemctl --user start "$IDLE_SERVICE"
	set_border_colors "$BORDER_ACTIVE" "$BORDER_INACTIVE"
	hyprctl eval 'hl.config({ general = { border_size = 2 } })' # Default value
	logger -i $$ "waybar:toggle-idle: Hypridle enable"
fi

pgrep -u "$USER" -x waybar | xargs -r kill -SIGRTMIN+10
