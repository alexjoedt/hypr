-- core/float.lua — floating-window helpers: centered toggle + pop-out (pin)
local M = {}

-- Toggle float: center + resize with 100px top/bottom gap.
-- Only resize/center when going tiled → floating; a plain un-float should
-- just restore the window to its tiled position without any extra work.
function M.toggle_centered()
    local win        = hl.get_active_window()
    local is_floating = win and win.floating  -- snapshot BEFORE dispatch (proxy tables eval lazily)
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

    -- only resize/center when going tiled → floating (handle both boolean false and integer 0)
    if win and is_floating ~= true and is_floating ~= 1 then
        local gap = 100
        local mon = hl.get_active_monitor()
        if mon then
            local w = math.floor(mon.width  / mon.scale * 0.5)
            local h = math.floor(mon.height / mon.scale - 2 * gap)
            hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
        end
        hl.dispatch(hl.dsp.window.center({}))
    end
end

-- Pop out: float + pin (follows across workspaces).
function M.popout()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin())
end

return M
