#!/bin/bash

BATTERY_PATH=$(upower -e | grep 'BAT')
[ -z "$BATTERY_PATH" ] && exit 1

# Récupère état et pourcentage
STATE=$(upower -i "$BATTERY_PATH" | awk '/state/ {print $2}')
PERCENT=$(upower -i "$BATTERY_PATH" | awk '/percentage/ {print $2}' | tr -d '%')

# Ne pas notifier si branché ou batterie absente
if [[ "$STATE" == "charging" || "$STATE" == "fully-charged" || -z "$PERCENT" ]]; then
	exit 0
fi

# Notification selon seuils
if ((PERCENT <= 5)); then
	notify-send -u critical -h string:x-canonical-private-synchronous:low-battery \
		"󰂃 Critical battery" "Only ${PERCENT}% left. Device is about to shutdown"
elif ((PERCENT <= 10)); then
	notify-send -u critical -h string:x-canonical-private-synchronous:low-battery \
		"󰁺 Critical battery" "Only ${PERCENT}% left."
elif ((PERCENT <= 20)); then
	notify-send -u normal -h string:x-canonical-private-synchronous:low-battery \
		"󰁼 Low battery" "${PERCENT}% remaining."
fi
