#!/usr/bin/env bash

systemctl --user import-environment \
	WAYLAND_DISPLAY \
	XDG_CURRENT_DESKTOP \
	HYPRLAND_INSTANCE_SIGNATURE

echo "Load and start hypridle" >~/test_hypridle_service.log

systemctl --user start hypridle.service
