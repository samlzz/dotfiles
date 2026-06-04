#!/usr/bin/env bash

if systemctl --user is-active --quiet hypridle.service; then

	echo '{"text": "󰾪", "class": "idle-on",  "tooltip": "Idle enable"}'
else
	echo '{"text": "󰅶", "class": "idle-off", "tooltip": "Idle disable"}'
fi
