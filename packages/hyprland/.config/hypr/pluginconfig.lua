-- Third-party plugin configuration.
-- hymission and HyprCapture stay hyprpm-managed compiled plugins (unchanged
-- install path, only their *config* syntax moved to Lua under `plugin.<name>`
-- in hl.config()). See their docs:
--   https://github.com/gfhdhytghd/hymission
--   https://github.com/gfhdhytghd/HyprCapture
--
-- split-monitor-workspaces is no longer a compiled plugin as of Hyprland
-- 0.55 -- it is now a pure Lua library you require() directly. It must be
-- removed from hyprpm and cloned into ~/.config/hypr/plugins instead
-- (one-time manual step, not done by this file -- see the migration notes
-- given alongside this config for the exact commands).
-- https://github.com/zjeffer/split-monitor-workspaces

package.path = package.path .. ";./?.lua;./?/init.lua"
local ok, smw = pcall(require, "plugins.split-monitor-workspaces")
if not ok then
    smw = nil
end

if smw then
    smw.setup({
        workspace_count = 5,
    })
end

hl.config({
    plugin = {
        hymission = {
            toggle_switch_mode = 0,
            debug_logs = 1,
        },
        hyprcapture = {
            allow_quick = true,
        }
    },
})

return {
    smw = smw,
}
