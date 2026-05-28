#!/usr/bin/env bash

kbd_pct=$(brightnessctl -d chromeos::kbd_backlight 2>/dev/null | awk '/Current brightness/ {print $4}' | tr -d '()%')

# Affiche en JSON pour Waybar
echo "{\"percentage\": $kbd_pct, \"icon\": \"\"}"


