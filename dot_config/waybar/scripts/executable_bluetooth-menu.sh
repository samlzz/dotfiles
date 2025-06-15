#!/usr/bin/env bash

TPATH="${XDG_STATE_HOME:-$HOME/.local/share}/bluetooth_menu"
mkdir -p "$TPATH"

DEVICE_LIST_FILE="$TPATH/known_devices.txt"

CLEAN_UP_LIST=(
    "$DEVICE_LIST_FILE"
    "$TPATH"
)

MENU_OPTIONS=(
    "󰂱  Enable Bluetooth"
    "󰂲  Disable Bluetooth"
	"  List devices"
    "󰥰  Device Info"
    "󰂰  Connect"
    "󰗿  Disconnect"
)

function spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr" >&2
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b" >&2
    done
    printf "      \b\b\b\b\b\b" >&2
}

function toggle_power() {
    local state
    state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
    if [[ "$state" == "yes" ]]; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
}

function disconnect_device() {
    local mac
    mac=$(bluetoothctl info | grep "Device" | awk '{print $2}')
    [[ -n "$mac" ]] && bluetoothctl disconnect "$mac"
}

function get_devices() {
    bluetoothctl scan on >/dev/null 2>&1 &
    sleep 3

    > "$DEVICE_LIST_FILE"
    bluetoothctl devices | grep "^Device" | while read -r _ mac name_rest; do
        if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
            echo "$mac $name_rest (trusted)" >> "$DEVICE_LIST_FILE"
        else
            echo "$mac $name_rest" >> "$DEVICE_LIST_FILE"
        fi
    done
}
function set_devices() {
	get_devices &
	spinner $!
}

function show_devices() {
	local message="$1"

	cat "$DEVICE_LIST_FILE" | rofi -dmenu -i -p "$message" | awk '{print $1}'
}

function connect_device() {
	selection=$(show_devices "Choose device to connect:")
    [[ -z "$selection" ]] && return

    local choice
    choice=$(printf "${MENU_OPTIONS[4]}\n󰘝  Remember (trust)" | rofi -dmenu -p "Action:")
    case "$choice" in
        "${MENU_OPTIONS[4]}") bluetoothctl connect "$selection" ;;
        "󰘝  Remember (trust)") bluetoothctl trust "$selection" ;;
    esac
}

function extract_connected_info() {
    local mac="$1"

    [[ -z "$mac" ]] && { echo "❌ Aucun périphérique connecté"; return 1; }

    local line trimmed
    bluetoothctl info "$mac" | while IFS= read -r line; do
        trimmed=$(echo "$line" | xargs)
        case "$trimmed" in
            "Device "*)
                echo "🔗 $trimmed"
                ;;
            "Name:"*)
                echo "📛 Nom:${trimmed#*:}"
                ;;
            "Alias:"*)
                echo "🔤 Alias:${trimmed#*:}"
                ;;
            "Class:"*)
                echo "🏷  Classe:${trimmed#*:}"
                ;;
            "Icon:"*)
                echo "🎧 Type:${trimmed#*:}"
                ;;
            "Connected:"*)
                echo "📶 Connecté:${trimmed#*:}"
                ;;
            "Paired:"*)
                echo "🔐 Jumelé:${trimmed#*:}"
                ;;
            "Trusted:"*)
                echo "⭐️ Confiance:${trimmed#*:}"
                ;;
            "Modalias:"*)
                echo "🧬 Modalias:${trimmed#*:}"
                ;;
            "UUID:"*"Audio "*)
                echo "🎵 ${trimmed#UUID: }"
                ;;
            # Ignore all [NEW] or other metadata
            "[NEW "*)
                ;;
        esac
    done
}

function device_info() {
    local connected_mac
    connected_mac=$(bluetoothctl devices | while read -r _ mac _; do
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            echo "$mac"
            break
        fi
    done)

	extract_connected_info "$connected_mac" | rofi -dmenu -p "Connected Device Info:" \
            -theme-str 'window { width: 800px; height: 400px; }' \
            -theme-str 'entry { width: 800px; }'
}

function list_devices_info() {
	local selected
	selected=$(show_devices "Available devices:")
    [[ -z "$selected" ]] && return

	extract_connected_info "$selected" | rofi -dmenu -p "Connected Device Info:" \
            -theme-str 'window { width: 800px; height: 400px; }' \
            -theme-str 'entry { width: 800px; }'
}

# 0 "󰂱  Enable Bluetooth"
# 1 "󰂲  Disable Bluetooth"
# 2 "  List devices"
# 3 "󰥰  Device Info"
# 4 "󰂰  Connect"
# 5 "󰗿  Disconnect"

function rofi_cmd() {
    local options
    local state
    state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

    if [[ "$state" == "yes" ]]; then
        options+="${MENU_OPTIONS[1]}"
        options+="\n${MENU_OPTIONS[2]}"
		state=$(bluetoothctl info | grep "Connected:" | awk '{print $2}')
		if [[ "$state" == "yes" ]]; then
			options+="\n${MENU_OPTIONS[3]}"
			options+="\n${MENU_OPTIONS[4]}"
			options+="\n${MENU_OPTIONS[5]}"
		else
			options+="\n${MENU_OPTIONS[4]}"
		fi
    else
        options+="${MENU_OPTIONS[0]}"
    fi

    echo -e "$options" | rofi -dmenu -mouse -i -p "Bluetooth Menu:"         -theme-str 'window { width: 400px; height: 200px; }'         -theme-str 'entry { width: 400px; }'
}

function run_cmd() {
    case "$1" in
        "${MENU_OPTIONS[0]}") bluetoothctl power on; main ;;
        "${MENU_OPTIONS[1]}") bluetoothctl power off ;;
		"${MENU_OPTIONS[2]}") set_devices; list_devices_info; main;;
        "${MENU_OPTIONS[3]}") device_info; main ;;
        "${MENU_OPTIONS[4]}") set_devices; connect_device; main ;;
        "${MENU_OPTIONS[5]}") disconnect_device ;;
        *) return ;;
    esac
}

function clean_up() {
    for item in "${CLEAN_UP_LIST[@]}"; do
        [[ -e "$item" ]] && { [[ -d "$item" ]] && rmdir "$item" || rm "$item"; }
    done
}

function main() {
    local choice
    choice=$(rofi_cmd)
    run_cmd "$choice"
    clean_up
}

main
