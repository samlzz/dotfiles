-- Windows, workspaces, and layers, converted from hyprland.conf.
-- See https://wiki.hypr.land/configuring/core/rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
-- hl.window_rule({
--     name = "fix-xwayland-drags",
--     match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--     no_initial_focus = true,
-- })

-- For swayosd notification
hl.window_rule({
    name = "swayosd-server",
    match = { class = "^swayosd-server$" },
    float = true,
    size = { 280, 60 },
    move = { "(monitor_w/2)-100", "80" },
    no_initial_focus = true,
})

-- Floating terminal
hl.window_rule({
    name = "term-float",
    match = { class = "^term-float.*$" },
    float = true,
    size = { 1460, 1020 },
    center = true,
})

-- Floating and overlay terminal
hl.window_rule({
    name = "term-float-overlay",
    match = { class = "^term-float\\.overlay.*$" },
    no_initial_focus = true,
    pin = true,
})

-- WayWea -- top-left, just below waybar
hl.window_rule({
    name = "term-float-overlay-waywea",
    match = { class = "^term-float\\.overlay\\.waywea$" },
    size = { 720, 400 },
    move = { "10", "50" },
    dim_around = true,
})

hl.config({
    decoration = {
        dim_around = 0.40,
    },
})

-- Clock popup - bottom left, below Waywea
hl.window_rule({
    name = "term-float-overlay-clock",
    match = { class = "^term-float\\.overlay\\.clock$" },
    size = { 720, 400 },
    move = { "10", "(monitor_h - 410)" },
})

-- Blurred fs_popup
hl.layer_rule({
    name = "blur-fspopup",
    match = { namespace = "^(com\\.fspopup\\.GtkApplication)$" },
    blur = true,
})

hl.layer_rule({
    name = "blur-waybar",
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.5,
})
