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
	-- Named and special workspaces have negative ids; rules match them by name.
	local selector = tostring(ws.id)
	if ws.id <= 0 then
		selector = ws.name:find("^special:") and ws.name or ("name:" .. ws.name)
	end

	hl.workspace_rule({ workspace = selector, layout = next_layout })
	hl.dispatch(hl.dsp.exec_cmd("notify-send 'Workspace " .. ws.name .. "' 'Layout: " .. next_layout .. "'"))
end

return M
