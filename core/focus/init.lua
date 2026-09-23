-- core/focus/init.lua — per-workspace "focus mode": center 1–2 tiled windows
local M = {}

local focused = {}            -- workspace id -> true while focus mode is on
local DEFAULT_GAPS_OUT = 20   -- keep in sync with general.gaps_out in core/visual.lua
local LAPTOP_MONITOR  = "eDP-1"  -- too narrow (1440px) for centering to be useful

-- fraction of monitor width the content should occupy
local WIDTH_ONE = 0.5         -- single window: 50% wide, centered
local WIDTH_TWO = 0.75        -- two windows: 75% total, side by side, centered

function M.toggle()
    local ws  = hl.get_active_workspace()
    local mon = hl.get_active_monitor()
    if not ws or not mon then return end

    local id = ws.id

    -- toggle OFF: restore default gaps for this workspace only
    if focused[id] then
        M.reset(id)
        return
    end

    if mon.name == LAPTOP_MONITOR then
        hl.dispatch(hl.dsp.exec_cmd(
            "notify-send 'Focus mode' 'Not available on the laptop screen'"))
        return
    end

    -- count tiled windows on the current workspace
    local tiled = 0
    for _, w in ipairs(hl.get_workspace_windows(id) or {}) do
        if w.floating ~= true and w.floating ~= 1 then
            tiled = tiled + 1
        end
    end

    -- focus mode only makes sense for 1 or 2 windows
    if tiled == 0 or tiled > 2 then
        hl.dispatch(hl.dsp.exec_cmd(
            "notify-send 'Focus mode' 'Only available with 1 or 2 windows'"))
        return
    end

    local mon_w = mon.width / mon.scale
    local frac  = (tiled == 1) and WIDTH_ONE or WIDTH_TWO
    local side  = math.floor(mon_w * (1 - frac) / 2)

    -- uniform gaps centered (horizontal + vertical)
    hl.workspace_rule({
        workspace = tostring(id),
        gaps_out  = { top = 20, right = side, bottom = 20, left = side },
    })
    focused[id] = true
end

-- Leave focus mode on one workspace (no-op if it is not in focus mode).
function M.reset(id)
    if not focused[id] then return end
    hl.workspace_rule({ workspace = tostring(id), gaps_out = DEFAULT_GAPS_OUT })
    focused[id] = nil
end

-- Leave focus mode everywhere. Used when the monitor layout changes: the
-- side gaps were computed for the monitor the workspace was on at toggle
-- time and are wrong once it lands on a different-sized display.
function M.reset_all()
    for id in pairs(focused) do
        M.reset(id)
    end
end

return M
