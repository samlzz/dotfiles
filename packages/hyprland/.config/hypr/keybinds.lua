-- Keybindings, converted from hyprland.conf.d/keybinds.conf (+ fastedit.conf).
-- See https://wiki.hypr.land/configuring/core/binds/

local colors = require("colors")
local P = require("programs")
local pluginconfig = require("pluginconfig")
local smw = pluginconfig.smw

local mainMod = "SUPER"

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(mainMod .. " + Y", hl.dsp.window.float())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("SHIFT + CTRL + escape", hl.dsp.exec_cmd("powerctl lock"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exit())

----------------------
-- Launcher          --
----------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(P.terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(P.term_float))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(P.file_manager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(P.browser))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(P.music))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(P.menu))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(P.calc))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(P.clipboard_menu))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(P.clipboard_menu .. " --vault"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(P.wifi_menu))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(P.bluetooth_menu))

----------------------
-- Notifications     --
----------------------

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/toggle-pannel.sh"))

hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("swaync-client --close-latest"))
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.exec_cmd("swaync-client -C"))

----------------------
-- Move focus        --
----------------------

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

----------------------
-- Switch workspaces --
----------------------

if smw then
    for i = 1, smw.get_amount_of_workspaces() do
        local n = tostring(i)
        local key = (i == 10) and "0" or n
        hl.bind(mainMod .. " + " .. key, smw.workspace(n))
        hl.bind(mainMod .. " + SHIFT + " .. key, smw.move_to_workspace(n))
    end

    -- Interactive switch
    hl.bind(mainMod .. " + ALT + left", smw.workspace("-1"))
    hl.bind(mainMod .. " + ALT + right", smw.workspace("+1"))
    hl.bind(mainMod .. " + SHIFT + left", smw.move_to_workspace("-1"))
    hl.bind(mainMod .. " + SHIFT + right", smw.move_to_workspace("+1"))
end

-- Special workspaces
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("main"))
hl.bind(mainMod .. " + D", hl.dsp.workspace.toggle_special("dedicated"))
hl.bind(mainMod .. " + H", hl.dsp.workspace.toggle_special("hidden"))

----------------------
-- Move current window
----------------------

-- Inside a workspace
hl.bind(mainMod .. " + SHIFT + CTRL + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + CTRL + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.layout("swapcol r"))

-- Across special workspaces
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:main" }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:dedicated" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ workspace = "special:hidden" }))

-- Across monitors
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

----------------------
-- Resize current window
----------------------

-- To manipulate window with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + CTRL + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Cycle window width
-- ! Needs 'scrolling' layout
hl.bind(mainMod .. " + comma", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + period", hl.dsp.layout("colresize +conf"))

-- Set window width
hl.bind(mainMod .. " + slash", hl.dsp.layout("colresize 0.51"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("colresize 1.0"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("colresize 0.333"))

----------------------
-- Fastedit submap
----------------------

local function enterFastedit()
    hl.config({
        general = {
            col = {
                active_border = "rgb(ea76cb)",
                inactive_border = colors.pink,
            },
        },
    })
    hl.dispatch(hl.dsp.submap("fastedit"))
end

local function exitFastedit()
    hl.config({
        general = {
            col = {
                active_border = { colors = { colors.blue, colors.mauve }, angle = 45 },
                inactive_border = colors.surface0,
            },
        },
    })
    hl.dispatch(hl.dsp.submap("reset"))
end

hl.bind(mainMod .. " + A", enterFastedit)

hl.define_submap("fastedit", function()
    hl.bind("left", hl.dsp.focus({ direction = "left" }), { repeating = true })
    hl.bind("right", hl.dsp.focus({ direction = "right" }), { repeating = true })
    hl.bind("up", hl.dsp.focus({ direction = "up" }), { repeating = true })
    hl.bind("down", hl.dsp.focus({ direction = "down" }), { repeating = true })

    hl.bind("CTRL + right", hl.dsp.window.resize({ x = 25, y = 0, relative = true }))
    hl.bind("CTRL + left", hl.dsp.window.resize({ x = -25, y = 0, relative = true }))
    hl.bind("CTRL + up", hl.dsp.window.resize({ x = 0, y = -25, relative = true }))
    hl.bind("CTRL + down", hl.dsp.window.resize({ x = 0, y = 25, relative = true }))

    hl.bind("SHIFT + left", hl.dsp.window.move({ direction = "left" }))
    hl.bind("SHIFT + right", hl.dsp.window.move({ direction = "right" }))
    hl.bind("SHIFT + up", hl.dsp.window.move({ direction = "up" }))
    hl.bind("SHIFT + down", hl.dsp.window.move({ direction = "down" }))

    if smw then
        hl.bind("ALT + left", smw.move_to_workspace("-1"))
        hl.bind("ALT + right", smw.move_to_workspace("+1"))
    end

    hl.bind(mainMod .. " + A", exitFastedit)
    hl.bind("escape", exitFastedit)
end)

----------------------
-- Overview (hymission)
----------------------

if hl.plugin and hl.plugin.hymission then
    hl.bind("SUPER + TAB", function()
        hl.plugin.hymission.toggle("onlycurrentworkspace")
    end)
    hl.bind("SUPER + SHIFT + TAB", function()
        hl.plugin.hymission.toggle("forceall")
    end)

    hl.plugin.hymission.gesture({
        fingers = 3,
        direction = "vertical",
        action = "toggle",
        args = "onlycurrentworkspace",
    })
end

----------------------
-- Screenshot (hyprcapture)
----------------------

if hl.plugin and hl.plugin.hyprcapture then
    hl.bind("PRINT", hl.plugin.hyprcapture.open)
    hl.bind(mainMod .. " + PRINT", function() hl.plugin.hyprcapture.quick("window") end)
    hl.bind(mainMod .. " + SHIFT + PRINT", function() hl.plugin.hyprcapture.quick("fullscreen") end)
end

----------------------
-- Zoom              --
----------------------

-- Zoom in/out
hl.bind(mainMod .. " + CTRL + equal", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/zoom_cursor.sh +0.1"))
hl.bind(mainMod .. " + CTRL + minus", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/zoom_cursor.sh -0.1"))
-- Restore zoom factor
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/zoom_cursor.sh reset"))

----------------------
-- Multimedia        --
----------------------

-- Volume OSD
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true, repeating = true })

-- Brightness screen (OSD) and keyboard
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
hl.bind("CTRL + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d chromeos::kbd_backlight set +5%"))
hl.bind("CTRL + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d chromeos::kbd_backlight set 5%-"))

-- Caps lock
hl.bind("SHIFT + code:66", hl.dsp.exec_cmd("sleep 0.2 && swayosd-client --caps-lock"))

-- Requires playerctl
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
