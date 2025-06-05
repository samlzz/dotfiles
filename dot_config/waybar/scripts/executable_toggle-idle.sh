#!/usr/bin/env bash

if systemctl --user is-active --quiet hypridle.service; then
  systemctl --user stop hypridle.service
  logger "waybar:toggle-idle: Hypridle disable"
else
  systemctl --user start hypridle.service
  logger "waybar:toggle-idle: Hypridle enable" 
fi

pgrep -u "$USER" -x waybar | xargs -r kill -SIGRTMIN+10

