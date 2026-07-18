local M = {}

function M.setup()
	-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
	hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

	hl.bind("switch:on:Lid Switch", function()
		local monitors = hl.get_monitors()

		if #monitors > 1 then
			-- 1. Finde den Namen des externen Monitors heraus
			local ext_monitor_name = ""
			for _, mon in ipairs(monitors) do
				if mon.name ~= "eDP-1" then
					ext_monitor_name = mon.name
					break
				end
			end

			-- 2. Hole alle Workspaces und verschiebe die von eDP-1 auf den externen Monitor
			local workspaces = hl.get_workspaces()
			for _, ws in ipairs(workspaces) do
				if ws.monitor == "eDP-1" then
					-- Hyprland Dispatcher nutzen, um den Workspace rüberzuziehen
					hl.exec_cmd("hyprctl dispatch moveworkspacetomonitor " .. ws.id .. " " .. ext_monitor_name)
				end
			end

			-- 3. Erst danach den internen Monitor sicher deaktivieren
			hl.exec_cmd("hyprctl keyword monitor 'eDP-1, disable'")
		else
			-- Kein externer Monitor -> Mobiler Betrieb
			hl.exec_cmd("hyprlock")
			hl.exec_cmd("systemctl suspend")
		end
	end, { locked = true })

	-- Beim Aufklappen (Lid geöffnet)
	hl.bind("switch:off:Lid Switch", function()
		-- Den internen Monitor wieder aktivieren
		-- (Passe 'preferred, auto, 1' an deine Standard-Monitor-Settings an, falls nötig)
		hl.exec_cmd("hyprctl keyword monitor 'eDP-1, preferred, auto, 1'")
	end, { locked = true })
end -- <--- DIESES END HAT GEFEHLT! Schließt function M.setup()

return M
