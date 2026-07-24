-- core/layout_toggle.lua — toggle workspace 1 between dwindle and scrolling
local M = {}

local WS = "1"
local LAYOUTS = { dwindle = "scrolling", scrolling = "dwindle" }

local function workspace_1()
	for _, ws in ipairs(hl.get_workspaces() or {}) do
		if tostring(ws.id) == WS or tostring(ws.name) == WS then
			return ws
		end
	end
	return nil
end

function M.toggle_ws1()
	local ws = workspace_1()
	local current = (ws and ws.tiled_layout) or "dwindle"
	local next_layout = LAYOUTS[current] or "scrolling"

	hl.workspace_rule({ workspace = WS, layout = next_layout })
	hl.dispatch(hl.dsp.exec_cmd("notify-send 'Workspace 1' 'Layout: " .. next_layout .. "'"))
end

return M
