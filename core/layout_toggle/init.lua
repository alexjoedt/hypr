-- core/layout_toggle/init.lua — toggle the active workspace between dwindle and scrolling
local M = {}

local LAYOUTS = { dwindle = "scrolling", scrolling = "dwindle" }

function M.toggle()
	local ws = hl.get_active_workspace()
	if not ws then
		return
	end

	local current = ws.tiled_layout or "dwindle"
	local next_layout = LAYOUTS[current] or "scrolling"
	-- Special workspaces have negative ids; rules only match them by name.
	local selector = ws.id > 0 and tostring(ws.id) or ws.name

	hl.workspace_rule({ workspace = selector, layout = next_layout })
	hl.dispatch(hl.dsp.exec_cmd("notify-send 'Workspace " .. ws.name .. "' 'Layout: " .. next_layout .. "'"))
end

return M
