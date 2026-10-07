-- core/resize_cycle/init.lua — step window width: SUPER + R, then SUPER + arrows (resize submap)
--   left  → one step smaller (⅓ min)
--   right → one step larger (full width max; a solo tiled window then maximizes)
--   up    → jump to max width
--   down  → solo tiled window: centered 50% column (core/focus)
-- Resizes the active window in-place without changing its floating state.
-- The current step is derived from the window's actual width on every call,
-- so mouse resizes and monitor moves never leave stale state behind.
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

local _sizes = { 0.33, 0.5, 0.667, 1 }
local _eps = 0.03 -- gaps make a "full width" window slightly narrower than the monitor
local _solo_rules = {} -- [workspace name] = gaps_out rule handle of the last solo step

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

local function _is_solo(win)
	if win.floating then
		return false
	end
	local ws = hl.get_active_workspace()
	return ws ~= nil and _tiled_count(ws.name) <= 1
end

-- Selector for "this workspace while it has exactly one tiled window", so a
-- narrowed solo width doesn't squeeze windows opened next to it later.
-- Named workspaces have negative ids, so match those by name instead.
local function _solo_selector(ws)
	if ws.id > 0 then
		return "r[" .. ws.id .. "-" .. ws.id .. "] w[t1]"
	end
	return "n[s:" .. ws.name .. "] n[e:" .. ws.name .. "] w[t1]"
end

local function _is_maximized(win)
	return (win.fullscreen or 0) ~= 0
end

local function _unmaximize()
	hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset" }))
end

local function _current_fraction(win, mon)
	local usable = require("core.windows").usable_width(mon)
	return (win.size and win.size.x or usable) / usable
end

-- Full width keeps the default gaps_out on the left and right. Returns false
-- when the size can't be applied (full width in dwindle with siblings).
local function _apply(win, mon, size)
	local mon_w = require("core.windows").usable_width(mon)
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
		require("core.focus").reset(ws.id)
		local base = require("core.windows").single_window_gaps(mon)
		local side_gap = size == 1 and gap or math.floor((mon_w - math.floor(mon_w * size)) / 2)
		if _solo_rules[ws.name] then
			_solo_rules[ws.name]:set_enabled(false)
		end
		_solo_rules[ws.name] = hl.workspace_rule({
			workspace = _solo_selector(ws),
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

local function _active()
	local win = hl.get_active_window()
	local mon = hl.get_active_monitor()
	if not win or not mon then
		return nil
	end
	return win, mon
end

function M.grow()
	local win, mon = _active()
	if not win or _is_maximized(win) then
		return
	end

	local cur = _current_fraction(win, mon)
	for _, size in ipairs(_sizes) do
		if size > cur + _eps then
			_apply(win, mon, size)
			return
		end
	end

	if _is_solo(win) then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "set" }))
	end
end

function M.shrink()
	local win, mon = _active()
	if not win then
		return
	end
	if _is_maximized(win) then
		_unmaximize()
		return
	end

	local cur = _current_fraction(win, mon)
	for i = #_sizes, 1, -1 do
		if _sizes[i] < cur - _eps then
			_apply(win, mon, _sizes[i])
			return
		end
	end
end

function M.max()
	local win, mon = _active()
	if not win or _is_maximized(win) then
		return
	end
	if not _apply(win, mon, 1) then
		_apply(win, mon, _sizes[#_sizes - 1])
	end
end

function M.center()
	local win = _active()
	if not win or not _is_solo(win) then
		return
	end
	if _is_maximized(win) then
		_unmaximize()
	end
	require("core.focus").enable()
end

-- SUPER + ALT + F: jump straight to full width. Dwindle with siblings has no
-- full-width split, so it toggles maximize instead.
function M.full_width()
	local win, mon = _active()
	if not win then
		return
	end

	if not _apply(win, mon, 1) then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
	end
end

return M
