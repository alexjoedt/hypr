-- core/resize_cycle/init.lua — cycle window size: SUPER + R → ¾ → ⅔ → ½ → ⅓ → ¼ → reset (full tile) → ¾ …
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

local _sizes = { 1, 0.667, 0.5, 0.33 }
local _state = {} -- [window_address] = current_index

-- Count tiled (non-floating) windows on the given workspace name.
local function _tiled_count(ws_name)
	if not ws_name then
		return 2
	end -- unknown → assume non-solo, safest default
	local n = 0
	for _, w in ipairs(hl.get_windows()) do
		local ok, wname = pcall(function()
			return w.workspace.name
		end)
		if ok and wname == ws_name and not w.floating then
			n = n + 1
		end
	end
	return n
end

-- Full width keeps the default gaps_out on the left and right. Returns false
-- when the size can't be applied (full width in dwindle with siblings).
local function _apply(win, mon, size)
	local mon_w = math.floor(mon.width / mon.scale)
	local gap = (hl.get_config("general.gaps_out") or {}).left or 0

	if win.floating then
		-- Width-only toggle: keep the window's current height untouched.
		local h = win.size and win.size.y or math.floor(mon.height / mon.scale)
		local w = size == 1 and mon_w - 2 * gap or math.floor(mon_w * size)
		hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
		hl.dispatch(hl.dsp.window.center({}))
		return true
	end

	local ws = hl.get_active_workspace()
	local layout = ws and ws.tiled_layout or "dwindle"

	if layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("colresize " .. (size == 1 and "1.0" or size)))
		return true
	end

	if ws and _tiled_count(ws.name) <= 1 then
		-- Solo tiled window: no sibling to resize against, so emulate
		-- the target width via the workspace's gaps_out instead.
		local base = require("core.windows").single_window_gaps(mon)
		local side_gap = size == 1 and gap or math.floor((mon_w - math.floor(mon_w * size)) / 2)
		hl.workspace_rule({
			workspace = ws.name,
			gaps_out = { top = base.top, right = side_gap, bottom = base.bottom, left = side_gap },
		})
		return true
	end

	if size == 1 then
		return false
	end
	local h = win.size and win.size.y or math.floor(mon.height / mon.scale)
	hl.dispatch(hl.dsp.window.resize({ x = math.floor(mon_w * size), y = h }))
	return true
end

function M.cycle()
	local win = hl.get_active_window()
	local mon = hl.get_active_monitor()
	if not win or not mon then
		return
	end

	local idx = (_state[win.address] or 0) % #_sizes + 1
	_state[win.address] = idx
	_apply(win, mon, _sizes[idx])
end

-- SUPER + ALT + F: jump straight to full width. Dwindle with siblings has no
-- full-width split, so it toggles maximize instead.
function M.full_width()
	local win = hl.get_active_window()
	local mon = hl.get_active_monitor()
	if not win or not mon then
		return
	end

	_state[win.address] = 1
	if not _apply(win, mon, 1) then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
	end
end

return M
