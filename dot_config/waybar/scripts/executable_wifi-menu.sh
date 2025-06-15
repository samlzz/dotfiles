#!/usr/bin/env bash

INTERFACE="wlan0"

TPATH="${XDG_STATE_HOME:-$HOME/.local/share}/wifi_menu"
mkdir -p "$TPATH"

RAW_NETWORK_FILE="$TPATH/nmcli_rofi_menu_ssid_raw.txt"
NETWORK_FILE="$TPATH/nmcli_rofi_menu_ssid_structured.txt"
TEMP_PASSWORD_FILE="$TPATH/nmcli_rofi_menu_temp_ssid_password.txt"

CLEAN_UP_LIST=(
    "$RAW_NETWORK_FILE"
    "$NETWORK_FILE"
    "$TEMP_PASSWORD_FILE"
    "$TPATH"
)

MENU_OPTIONS=(
    "󱛄  Refresh"
    "  Enable Wi-Fi"
    "󰖪  Disable Wi-Fi"
    "󱚾  Network Info"
    "󱚸  Scan Networks"
    "󱚽  Connect"
    "󱛅  Disconnect"
)

wifi=()
ssid=()

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

function power_on() {
    nmcli radio wifi on
    sleep 2
}

function power_off() {
    nmcli radio wifi off
}

function disconnect() {
    local active_ssid
    active_ssid=$(nmcli -t -f GENERAL.CONNECTION dev show "$INTERFACE" | cut -d ':' -f2)
    [[ -n "$active_ssid" ]] && nmcli con down id "$active_ssid"
}

function check_interface_status() {
    local status
    status=$(nmcli device status | grep "^$INTERFACE" | awk '{print $3}')
    [[ "$status" == "disconnected" || "$status" == "connected" ]] && echo "ON" || echo "OFF"
}

function check_wifi_status() {
    local status
    status=$(nmcli device status | grep "^$INTERFACE" | awk '{print $3}')
    [[ "$status" == "connected" ]] && echo "ON" || echo "OFF"
}

function helper_get_networks() {
    if ! nmcli --fields SSID,SECURITY,SIGNAL device wifi list ifname "$INTERFACE" --rescan yes > "$RAW_NETWORK_FILE"; then
        printf "Failed to scan Wi-Fi networks\n" >&2
        return 1
    fi

    {
        echo "SSID,SECURITY,SIGNAL"
        awk 'NR>1 && $1!="" {print $0}' "$RAW_NETWORK_FILE" | sed -E 's/  +/,/g'
    } > "$NETWORK_FILE"

    sed -e 's/\*\*\*\*/████/g' \
        -e 's/\*\*\*/███░/g' \
        -e 's/\*\*/██░░/g' \
        -e 's/\*/█░░░/g' \
        -e 's/░░░░/░░░░/g' \
        "$NETWORK_FILE" > "${NETWORK_FILE}.tmp" && mv "${NETWORK_FILE}.tmp" "$NETWORK_FILE"
}

function get_networks() {
    ssid=()
    local security=()
    local signal=()

	helper_get_networks &
	local get_pid=$!
	spinner "$get_pid"
	wait "$get_pid"
	if [ $? -eq 0 ]; then
		return 1
	fi

    while IFS=',' read -r col1 col2 col3; do
        ssid+=("$col1")
        security+=("$col2")
        signal+=("$col3")
    done < <(tail -n +2 "$NETWORK_FILE")

    for ((i = 0; i < ${#ssid[@]}; i++)); do
        wifi+=("${signal[$i]} ${ssid[$i]} (${security[$i]})")
    done
}

function connect_to_known_network() {
    local selected_ssid=$1

    nmcli con up id "$selected_ssid" ifname "$INTERFACE" >/dev/null 2>&1 &
    local nmcli_pid=$!

    spinner "$nmcli_pid"
    wait "$nmcli_pid"

    nmcli -t -f GENERAL.STATE dev show "$INTERFACE" | grep -q "100"
	return 0
}

function connect_to_network() {
    local selected_ssid="${ssid[$1]}"
    local known
    known=$(nmcli -g NAME con show | grep -xF "$selected_ssid")

    if [[ -n "$known" ]]; then
        if connect_to_known_network "$selected_ssid" ; then return 1; fi 
    fi

    rofi -dmenu -password -p "Enter password for $selected_ssid:" \
        -theme-str 'window { width: 500px; height: 50px; }' \
        -theme-str 'entry { width: 500px; }' \
        > "$TEMP_PASSWORD_FILE"

    local pass
    pass=$(<"$TEMP_PASSWORD_FILE")

    if [[ -z "$pass" ]]; then
        printf "No password entered\n" >&2
        return 1
    fi

    if ! nmcli dev wifi connect "$selected_ssid" password "$pass" ifname "$INTERFACE" | grep -q "successfully activated"; then
        rofi -e "Error connecting to $selected_ssid"
    fi
}

function wifi_status() {
    local raw_output; raw_output=$(nmcli -t dev show "$INTERFACE" 2>/dev/null)
    if [[ -z "$raw_output" ]]; then
        printf "Impossible de récupérer l'état du périphérique %s\n" "$INTERFACE" >&2
        return
    fi

    local keys values line key value
    local -a formatted_lines
    local max_key_length=0

    while IFS=':' read -r key value; do
        [[ -z "$key" || -z "$value" ]] && continue
        keys+=("$key")
        values+=("$value")
        (( ${#key} > max_key_length )) && max_key_length=${#key}
    done <<< "$raw_output"

    for ((i=0; i<${#keys[@]}; i++)); do
        printf -v line "%-*s  %s" "$max_key_length" "${keys[i]}" "${values[i]}"
        formatted_lines+=("$line")
    done

    local selected_index; selected_index=$(
        printf "%s\n" "${formatted_lines[@]}" | \
        rofi -dmenu -mouse -i -p "Network Info:" \
        -theme-str 'window { width: 700px; height: 400px; }' \
        -theme-str 'entry { width: 700px; }' \
        -format i
    )

    [[ -z "$selected_index" || "$selected_index" -lt 0 ]] && return

    printf "%s" "${values[selected_index]}" | xclip -selection clipboard
}

function scan() {
    local selected_wifi_index=1

    while (( selected_wifi_index == 1 )); do
        wifi=("󱚷  Return")
        wifi+=("󱛇  Rescan")

        if ! get_networks; then
            return
        fi

        selected_wifi_index=$(
            printf "%s\n" "${wifi[@]}" | \
            rofi -dmenu -mouse -i -p "SSID:" \
                -theme-str 'window { width: 400px; height: 300px; }' \
                -theme-str 'entry { width: 400px; }' \
                -format i
        )
    done

    if [[ -n "$selected_wifi_index" ]] && (( selected_wifi_index > 1 )); then
        connect_to_network "$((selected_wifi_index - 2))"
    fi
}

function rofi_cmd() {
    local options="${MENU_OPTIONS[0]}"
    local interface_status
    interface_status=$(check_interface_status)

    if [[ "$interface_status" == "OFF" ]]; then
        options+="\n${MENU_OPTIONS[1]}"
    else
        options+="\n${MENU_OPTIONS[2]}"
        local wifi_status_value
        wifi_status_value=$(check_wifi_status)
        if [[ "$wifi_status_value" == "OFF" ]]; then
            options+="\n${MENU_OPTIONS[5]}"
        else
            options+="\n${MENU_OPTIONS[3]}"
            options+="\n${MENU_OPTIONS[4]}"
            options+="\n${MENU_OPTIONS[6]}"
        fi
    fi

    local choice
    choice=$(echo -e "$options" | \
        rofi -dmenu -mouse -i -p "Wi-Fi Menu:" \
            -theme-str 'window { width: 400px; height: 200px; }' \
            -theme-str 'entry { width: 400px; }'
    )

    echo "$choice"
}

#  0-  "󱛄  Refresh"
#  1-  "  Enable Wi-Fi"
#  2-  "󰖪  Disable Wi-Fi"
#  3-  "󱚾  Network Info"
#  4-  "󱚸  Scan Networks"
#  5-  "󱚽  Connect"
#  6-  "󱛅  Disconnect"


function run_cmd() {
    case "$1" in
        "${MENU_OPTIONS[0]}")
            sleep 2
            main
            ;;
        "${MENU_OPTIONS[1]}")
            power_on
            main
            ;;
        "${MENU_OPTIONS[2]}")
            power_off
            ;;
        "${MENU_OPTIONS[3]}")
            wifi_status
            main
            ;;
        "${MENU_OPTIONS[4]}" | "${MENU_OPTIONS[5]}")
            scan
            main
            ;;
        "${MENU_OPTIONS[6]}")
            disconnect
            ;;
        *)
            return
            ;;
    esac
}

function clean_up() {
    for item in "${CLEAN_UP_LIST[@]}"; do
        [[ -e "$item" ]] && { [[ -d "$item" ]] && rmdir "$item" || rm "$item"; }
    done
}

function main() {
    local chosen_option
    chosen_option=$(rofi_cmd)
    run_cmd "$chosen_option"
    clean_up
}

main

