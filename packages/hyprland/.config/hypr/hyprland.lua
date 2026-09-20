-- Hyprland config, migrated from hyprlang (hyprland.conf) to Lua.
-- See https://wiki.hypr.land/configuring/

require("style")

----------------
--- MONITORS ---
----------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "DP-4", mode = "highres", position = "auto-up", scale = 1 })

---------------------------------
--- ENVIRONMENT VARIABLES     ---
---------------------------------
-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("CLIPHIST_TERMINAL", "alacritty")

-------------------
--- PERMISSIONS ---
-------------------

-- See https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({ ecosystem = { enforce_permissions = true } })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------
--- INPUT     ---
-----------------

-- https://wiki.hypr.land/configuring/core/config-options/#input
hl.config({
    input = {
        kb_layout = "fr",
        kb_variant = "us",
        kb_model = "",
        kb_options = "caps:escape_shifted_capslock",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
        },
    },
})

-- https://wiki.hypr.land/configuring/core/binds/gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

require("pluginconfig")

require("windowrules")

require("keybinds")

require("autostart")

---------------------
--- ENABLE LOGS    ---
---------------------

hl.config({
    debug = {
        disable_logs = false,
        gl_debugging = true,
    },
})
