local M = {}

function M.setup()
	-- Autostart necessary processes (like notifications daemons, status bars, etc.)
	hl.on("hyprland.start", function()
		hl.exec_cmd("hyprpm reload -n")
		hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
		hl.exec_cmd("walker --gapplication-service")
		hl.exec_cmd("wl-paste --type text --watch cliphist store")
		hl.exec_cmd("wl-paste --type image --watch cliphist store")
		hl.exec_cmd("wl-paste --primary --watch cliphist store")
		--hl.exec_cmd("hyprpaper")
		hl.exec_cmd("qs")
		--hl.exec_cmd("qs -c noctalia-shell")
		--hl.exec_cmd("noctalia")
		hl.exec_cmd("hypridle -q")
		-- Firefox/libwebrtc braucht XDG_SESSION_TYPE=wayland fuer PipeWire-Screensharing.
		-- hl.env setzt Variablen nur im Hyprland-Prozess; elephant laeuft als systemd
		-- user service und braucht sie aus der systemd user environment. Import vor
		-- dem Restart verketten, damit elephant sie sicher erbt.
		hl.exec_cmd(
			'sh -c "dbus-update-activation-environment --systemd XDG_SESSION_TYPE XDG_SESSION_DESKTOP MOZ_ENABLE_WAYLAND && systemctl --user restart elephant"'
		)
	end)
end

return M
