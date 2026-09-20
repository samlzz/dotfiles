-- My programs, converted from hyprland.conf.d/programs.conf.
-- Returns a table so keybinds.lua / autostart.lua can require() it.

local home = os.getenv("HOME")

local P = {}

-- App
P.terminal = "alacritty"
P.term_float = "alacritty --class=term-float"

P.browser = "flatpak run com.brave.Browser"
P.file_manager = "nautilus"
P.music = "flatpak run dev.aunetx.deezer"

-- Interact
P.menu = "fuzzel"
P.bluetooth_menu = 'bzmenu -l custom --launcher-command "fuzzel --dmenu --config '
    .. home .. '/.config/fuzzel/bluetooth.ini"'
P.wifi_menu = 'iwmenu -l custom --launcher-command "fuzzel --dmenu --config '
    .. home .. '/.config/fuzzel/wifi.ini"'
P.clipboard_menu = home .. "/.config/hypr/scripts/cliphist-fzf.sh"
P.calc = "alacritty --class=term-float -e qalc"

-- Daemon
P.clipboard = "wl-paste --watch cliphist store --max-items 200"
P.osd = "systemctl --user enable --now swayosd.service"
P.notify = "swaync"
P.low_battery = "systemctl --user enable --now low_battery.timer"
P.idle = home .. "/.config/hypr/scripts/start_hypridle_service.sh"

P.tmux_script = home .. "/.config/hypr/scripts/tmux-boot.sh"
P.tmux_save = home .. "/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"

return P
