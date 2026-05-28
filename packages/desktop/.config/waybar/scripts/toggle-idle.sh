#!/usr/bin/env bash

if systemctl --user is-active --quiet hypridle.service; then
	systemctl --user stop --now hypridle.service
	logger -i $$ "waybar:toggle-idle: Hypridle disable"
else
	systemctl --user start --now hypridle.service
	logger -i $$ "waybar:toggle-idle: Hypridle enable"
fi

pgrep -u "$USER" -x waybar | xargs -r kill -SIGRTMIN+10
