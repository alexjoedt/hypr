-- core/alttab.lua — Alt+Tab: cycle windows across all workspaces in MRU order.
--
-- _mru   : list of window addresses ordered by last focus time,
--          _mru[1] = oldest, _mru[#_mru] = current.
-- _atidx : index into _mru while cycling; nil = not currently cycling.
-- _atskip: address of the window we just focused ourselves so the
--          window.active event doesn't reset _atidx mid-cycle.
--
-- Resets to empty on Hyprland restart / config reload, same as the other
-- in-memory state in this config (see core/monitors.lua's state table).
local M = {}

local _mru    = {}
local _atidx  = nil
local _atskip = nil

-- Register the MRU-tracking listener. Call once during startup.
function M.setup()
    hl.on("window.active", function(w)
        if _atskip == w.address then
            -- This focus was triggered by our own cycling dispatch; ignore.
            _atskip = nil
            return
        end
        -- Any manual focus resets the cycling position.
        _atidx = nil
        -- Move this window to the end of the MRU list (most recent).
        for i = #_mru, 1, -1 do
            if _mru[i] == w.address then table.remove(_mru, i) end
        end
        table.insert(_mru, w.address)
    end)
end

local function cycle(direction)
    -- Build a lookup of currently open windows.
    local valid = {}
    for _, w in ipairs(hl.get_windows()) do valid[w.address] = w end

    -- Prune any closed windows from the MRU list.
    local clean = {}
    for _, addr in ipairs(_mru) do
        if valid[addr] then table.insert(clean, addr) end
    end
    _mru = clean

    if #_mru == 0 then return end

    -- First keypress: start at second-to-last entry (previous window).
    -- Subsequent keypresses: continue in the chosen direction.
    if _atidx == nil then
        _atidx = #_mru - 1
    else
        _atidx = _atidx + direction
    end

    -- Wrap around the list.
    if _atidx < 1     then _atidx = #_mru end
    if _atidx > #_mru then _atidx = 1     end

    local addr = _mru[_atidx]
    local win  = valid[addr]
    if not win then return end

    -- Mark this address so window.active doesn't clear _atidx.
    _atskip = addr
    -- focuswindow with address: prefix switches workspace automatically.
    hl.dispatch(hl.dsp.focus({ window = "address:" .. addr }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end

function M.prev() cycle(-1) end
function M.next() cycle(1)  end

return M
