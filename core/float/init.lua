-- core/float/init.lua — floating-window helpers: centered toggle + pop-out (pin)
local M = {}

-- Toggle float: center + resize with 100px top/bottom gap.
-- Only resize/center when going tiled → floating; a plain un-float should
-- just restore the window to its tiled position without any extra work.
function M.toggle_centered()
	local win = hl.get_active_window()
	local is_floating = win and win.floating -- snapshot BEFORE dispatch (proxy tables eval lazily)
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

	-- only resize/center when going tiled → floating (handle both boolean false and integer 0)
	if win and is_floating ~= true and is_floating ~= 1 then
		local gap = 70
		local mon = hl.get_active_monitor()
		if mon then
			local w = math.floor(mon.width / mon.scale * 0.5)
			local h = math.floor(mon.height / mon.scale - 1 * gap)
			hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
		end
		hl.dispatch(hl.dsp.window.center({}))
	end
end

local FIT_MARGIN = 20 -- keep in sync with general.gaps_out in core/visual.lua

-- Make every floating window on `ws` fit its monitor: shrink windows that
-- are larger than the (logical) monitor area and re-center windows that
-- stick out of it. Windows that already fit are left untouched so manual
-- placement survives. Needed after a workspace migrates between displays
-- of different size (external monitor unplugged / plugged in).
function M.fit_workspace(ws)
	local mon = ws.monitor
	if not mon then
		return
	end
	local scale = mon.scale or 1
	local mw, mh = math.floor(mon.width / scale), math.floor(mon.height / scale)
	local mx, my = mon.x or 0, mon.y or 0
	local max_w, max_h = mw - 2 * FIT_MARGIN, mh - 2 * FIT_MARGIN

	for _, w in ipairs(hl.get_workspace_windows(ws.id) or {}) do
		if w.floating == true or w.floating == 1 then
			local ok, ax, ay, sw, sh = pcall(function()
				return w.at.x, w.at.y, w.size.x, w.size.y
			end)
			if ok then
				local sel = "address:" .. w.address
				local nw, nh = math.min(sw, max_w), math.min(sh, max_h)
				local oversized = nw ~= sw or nh ~= sh
				local offscreen = ax < mx or ay < my or ax + nw > mx + mw or ay + nh > my + mh
				if oversized then
					hl.dispatch(hl.dsp.window.resize({ x = nw, y = nh, window = sel }))
				end
				if oversized or offscreen then
					hl.dispatch(hl.dsp.window.center({ window = sel }))
				end
			end
		end
	end
end

function M.fit_all()
	for _, ws in ipairs(hl.get_workspaces() or {}) do
		M.fit_workspace(ws)
	end
end

-- Pop out: float + pin (follows across workspaces).
function M.popout()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.pin())
end

return M
