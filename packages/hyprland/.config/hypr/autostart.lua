-- Autostart, converted from hyprland.conf.d/autostart.conf.
-- See https://wiki.hypr.land/configuring/core/autostart/

local P = require("programs")

hl.on("hyprland.start", function()
    -- Reset keyboard backlight
    hl.exec_cmd("brightnessctl -rd chromeos::kbd_backlight")

    hl.exec_cmd("hyprpm reload -n")
    -- hl.exec_cmd(os.getenv("HOME") .. "/.local/share/hyprland/plugins/hyprcorners")

    hl.exec_cmd("hyprpaper")
    -- hl.exec_cmd("swww-daemon --format xrgb")
    -- hl.exec_cmd("swww img ~/Pictures/wallpapers/evening-sky.png")
    -- hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/album-wall.sh")

    hl.exec_cmd(P.clipboard)

    hl.exec_cmd(P.osd)
    hl.exec_cmd(P.notify)

    hl.exec_cmd(P.low_battery)
    hl.exec_cmd(P.idle)

    hl.exec_cmd("waybar")

    hl.exec_cmd(P.tmux_script)
end)

hl.on("hyprland.shutdown", function()
    hl.exec_cmd(P.tmux_save)
end)
