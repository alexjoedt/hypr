-- core/resize_cycle.lua — cycle window size: SUPER + R → ¾ → ⅔ → ½ → ⅓ → ¼ → reset (full tile) → ¾ …
-- Resizes the active window in-place without changing its floating state.
--
-- Tiled windows need layout-specific handling:
--   - dwindle: a plain resize adjusts the split ratio with the sibling
--     node, so other windows resize to fill the freed/reclaimed space
--     (default dwindle behavior). But when the window is alone on its
--     workspace there's no sibling split to resize against at all, so a
--     plain resize is a total no-op — we emulate the size instead via
--     the workspace's gaps_out (same trick core/windows.lua already
--     uses for auto-centering a lone window).
--   - scrolling: use the layout's own colresize message, which sets an
--     exact column width fraction directly (see also
--     scrolling.fullscreen_on_one_column = false in core/visual.lua,
--     required so a solo column can actually shrink).
local M = {}

local _sizes = { 3/4, 2/3, 1/2, 1/3, 1/4 }
local _state = {}  -- [window_address] = current_index

-- Count tiled (non-floating) windows on the given workspace name.
local function _tiled_count(ws_name)
    if not ws_name then return 2 end -- unknown → assume non-solo, safest default
    local n = 0
    for _, w in ipairs(hl.get_windows()) do
        local ok, wname = pcall(function() return w.workspace.name end)
        if ok and wname == ws_name and not w.floating then
            n = n + 1
        end
    end
    return n
end

function M.cycle()
    local win = hl.get_active_window()
    if not win then return end

    local mon = hl.get_active_monitor()
    if not mon then return end

    local addr = win.address
    local idx  = (_state[addr] or 0) % #_sizes + 1
    _state[addr] = idx
    local size = _sizes[idx]

    -- Width-only toggle: keep the window's current height untouched.
    local h = win.size and win.size.y or math.floor(mon.height / mon.scale)

    if win.floating then
        -- if size == "reset" then return end -- no-op, next press continues the cycle
        local w = math.floor(mon.width / mon.scale * size)
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
        hl.dispatch(hl.dsp.window.center({}))
        return
    end

    local ws     = hl.get_active_workspace()
    local layout = ws and ws.tiled_layout or "dwindle"

    if layout == "scrolling" then
        if size == "reset" then
            hl.dispatch(hl.dsp.layout("colresize 1.0"))
        else
            hl.dispatch(hl.dsp.layout("colresize " .. size))
        end
        return
    end

    if ws and _tiled_count(ws.name) <= 1 then
        -- Solo tiled window: no sibling to resize against, so emulate
        -- the target width via the workspace's gaps_out instead.
        local base = require("core.windows").single_window_gaps(mon)
        if size == "reset" then
            hl.workspace_rule({ workspace = ws.name, gaps_out = base })
        else
            local target_w = math.floor(mon.width / mon.scale * size)
            local side_gap = math.floor((mon.width / mon.scale - target_w) / 2)
            hl.workspace_rule({
                workspace = ws.name,
                gaps_out  = { top = base.top, right = side_gap, bottom = base.bottom, left = side_gap },
            })
        end
    else
        local w = math.floor(mon.width / mon.scale * size)
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
    end
end

return M
