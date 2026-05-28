#!/usr/bin/env bash

command -v "hyprpicker" &>/dev/null || {
	echo "hyprpicker not found, please install it."
	exit 1
}

color=$(hyprpicker -a)

svg_file="/tmp/colorpicker.svg"
cat <<EOF >"$svg_file"
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">
  <rect width="64" height="64" fill="$color"/>
</svg>
EOF

notify-send -h string:x-canonical-private-synchronous:colorpicker \
	-h int:transient:1 \
	-i "$svg_file" \
	"🎨 Couleur copiée" "$color"
