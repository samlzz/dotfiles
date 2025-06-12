#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="/var/log/idle.log"
BAT_PATH="/sys/class/power_supply/BAT*/capacity"
AC_PATH="/sys/class/power_supply/ACAD/online"

lock_session() {
    command -v lock-session >/dev/null 2>&1 || {
        printf "lock-session command not found\n" >&2
        return 1
    }
    lock-session
}

turn_off_dpms() {
    hyprctl dispatch dpms off
}

enable_power_saving_features() {
    if grep -q 0 "$AC_PATH"; then
        powerprofilesctl set power-saver || printf "Failed to set power-saver profile\n" >&2
        brightnessctl set 30% || printf "Failed to set brightness\n" >&2
        nmcli radio wifi off || printf "Failed to disable Wi-Fi\n" >&2
        rfkill block bluetooth || printf "Failed to block Bluetooth\n" >&2
    fi
}

handle_suspend_hibernate() {
    local bat; bat=$(cat "$BAT_PATH" 2>/dev/null | head -n1)

    if [[ -z "${bat// }" ]]; then
        printf "%s — Failed to read battery\n" "$(date '+%F %T')" >> "$LOG_FILE"
        systemctl suspend-then-hibernate
        return
    fi

    if [[ "$bat" -le 15 ]]; then
        printf "%s — Battery %s%% — Hibernate\n" "$(date '+%F %T')" "$bat" >> "$LOG_FILE"
        systemctl hibernate
    else
        printf "%s — Battery %s%% — Suspend-then-Hibernate\n" "$(date '+%F %T')" "$bat" >> "$LOG_FILE"
        systemctl suspend-then-hibernate
    fi
}

turn_on_dpms_and_restore() {
    hyprctl dispatch dpms on
    nmcli radio wifi on || printf "Failed to enable Wi-Fi\n" >&2
    rfkill unblock bluetooth || printf "Failed to unblock Bluetooth\n" >&2
}

main() {
    swayidle -w \
        timeout 120 "$(declare -f lock_session); lock_session" \
        timeout 180 "$(declare -f turn_off_dpms enable_power_saving_features); turn_off_dpms; enable_power_saving_features" \
        resume "$(declare -f turn_on_dpms_and_restore); turn_on_dpms_and_restore" \
        timeout 300 "$(declare -f turn_on_dpms_and_restore handle_suspend_hibernate); turn_on_dpms_and_restore; handle_suspend_hibernate" \
        before-sleep "$(declare -f lock_session); lock_session"
}

main

