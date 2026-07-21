local M = {}

function M.setup(opts)
	opts = opts or {}

	local terminal = opts.terminal or "kitty"
	local fileManager = opts.fileManager or "dolphin"
	local menu = opts.menu or "wofi --show drun"
	local mainMod = opts.mainMod or "SUPER"

	-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
	hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal), { description = "Terminal" })
	hl.bind(mainMod .. " + W", hl.dsp.window.close(), { description = "Close window" })
	hl.bind(mainMod .. " + M", hl.dsp.exit(), { description = "Exit Hyprland" })
	hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "File manager" })
	hl.bind(mainMod .. " + P", require("core.float").toggle_centered, { description = "Toggle float (centered)" })
	hl.bind(mainMod .. " + O", require("core.float").popout, { description = "Pop out (float + pin)" })
	hl.bind(mainMod .. " + SHIFT + F", require("core.focus").toggle, { description = "Focus mode" }) -- focus mode: center 1-2 windows
	hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu), { description = "App launcher" })
	--hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo(),        { description = "Toggle pseudo-tile"     }) -- dwindle
	-- hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit")) -- dwindle
	hl.bind(mainMod .. " + minus", hl.dsp.layout("togglesplit"), { description = "Toggle split direction" }) -- dwindle: toggle vertical/horizontal split
	hl.bind(mainMod .. " + SHIFT + O", function()
		hl.plugin.scrolloverview.overview("toggle")
	end, { description = "Workspace overview" }) -- workspace overview (scroll overview)

	-- Lock screen (hypridle lock_cmd → single hyprlock instance)
	hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock --quiet --grace 1"), {
		description = "Lock screen",
	})

	-- Toggle laptop display (off by default when an external monitor is connected)
	hl.bind(
		mainMod .. " + ALT + M",
		require("core.monitors").toggle_extend,
		{ description = "Toggle laptop display (extend/off)" }
	)

	-- Borrow a window from another workspace / return it (hypr-borrow.sh)
	hl.bind(
		mainMod .. " + B",
		hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-borrow.sh pull"),
		{ description = "Borrow window" }
	)
	hl.bind(
		mainMod .. " + SHIFT + B",
		hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-borrow.sh return"),
		{ description = "Return borrowed window" }
	)

	-- Screenshots (saved to ~/Pictures/Screenshots/)
	-- Print: grab the whole screen and save it directly
	hl.bind(
		"Print",
		hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"),
		{ description = "Screenshot (full screen)" }
	)
	-- Super + Print (or Super + Shift + P): select an area, annotate with satty, copy to clipboard and save
	hl.bind(
		mainMod .. " + Print",
		hl.dsp.exec_cmd(
			'mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | satty -f - --copy-command wl-copy -o ~/Pictures/Screenshots/%Y%m%d_%H%M%S.png'
		),
		{ description = "Screenshot (select area + annotate)" }
	)
	hl.bind(
		mainMod .. " + SHIFT + P",
		hl.dsp.exec_cmd(
			'mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | satty -f - --copy-command wl-copy -o ~/Pictures/Screenshots/%Y%m%d_%H%M%S.png'
		),
		{ description = "Screenshot (select area + annotate)" }
	)

	-- Walker launcher (elephant window provider)
	hl.bind(
		mainMod .. " + SHIFT + W",
		hl.dsp.exec_cmd("walker --provider windows"),
		{ description = "Walker (windows)" }
	)

	hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("walker --provider clipboard"), {
		description = "Walker (clipboard)",
	})

	-- Launch numbr with Super+Shift+N
	hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("numbr"), { description = "Calculator" })

	-- Keybindings cheatsheet
	hl.bind(
		mainMod .. " + SHIFT + U",
		hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-keybindings.sh"),
		{ description = "Show keybindings" }
	)

	-- Move focus with mainMod + vim keys / arrow keys
	hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
	hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
	hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
	hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
	hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
	hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
	hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
	hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

	-- Swap windows with mainMod + SHIFT + vim keys / arrow keys
	hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }), { description = "Swap window left" })
	hl.bind(
		mainMod .. " + SHIFT + L",
		hl.dsp.window.swap({ direction = "right" }),
		{ description = "Swap window right" }
	)
	hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
	hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }), { description = "Swap window down" })
	hl.bind(
		mainMod .. " + SHIFT + left",
		hl.dsp.window.swap({ direction = "left" }),
		{ description = "Swap window left" }
	)
	hl.bind(
		mainMod .. " + SHIFT + right",
		hl.dsp.window.swap({ direction = "right" }),
		{ description = "Swap window right" }
	)
	hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
	hl.bind(
		mainMod .. " + SHIFT + down",
		hl.dsp.window.swap({ direction = "down" }),
		{ description = "Swap window down" }
	)

	-- Alt + Tab: cycle windows across all workspaces in MRU order (core/alttab.lua)
	require("core.alttab").setup()
	hl.bind("ALT + Tab", require("core.alttab").prev, { description = "Alt+Tab: previous window (global MRU)" })
	hl.bind("ALT + SHIFT + Tab", require("core.alttab").next, { description = "Alt+Tab: next window (global MRU)" })

	-- Groups (tabbed windows)
	hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle window group" }) -- create / dissolve group
	hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock_active(), { description = "Lock window group" }) -- lock group (no auto-join)
	hl.bind(mainMod .. " + Tab", hl.dsp.group.next(), { description = "Next tab in group" })
	hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev(), { description = "Previous tab in group" })

	-- Switch workspaces with mainMod + [0-9]
	-- Move active window to a workspace with mainMod + SHIFT + [0-9]
	for i = 1, 9 do
		hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }), { description = "Switch to workspace " .. i })
		hl.bind(
			mainMod .. " + SHIFT + " .. i,
			hl.dsp.window.move({ workspace = i }),
			{ description = "Move window to workspace " .. i }
		)
	end
	hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }), { description = "Switch to workspace 10" })
	hl.bind(
		mainMod .. " + SHIFT + 0",
		hl.dsp.window.move({ workspace = 10 }),
		{ description = "Move window to workspace 10" }
	)

	-- Special workspace (scratchpad)
	hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
	hl.bind(
		mainMod .. " + SHIFT + S",
		hl.dsp.window.move({ workspace = "special:magic" }),
		{ description = "Move window to scratchpad" }
	)

	-- Scroll through existing workspaces with mainMod + scroll
	hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
	hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

	-- Cycle through existing workspaces with mainMod + CTRL + vim keys / arrow keys
	hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
	hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
	hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
	hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })

	-- Move/resize windows with mainMod + LMB/RMB and dragging
	hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window (drag)" })
	hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window (drag)" })

	-- Cycle window size: SUPER + R → ¾ → ⅔ → ½ → ⅓ → ¼ → reset (core/resize_cycle.lua)
	hl.bind(
		mainMod .. " + R",
		require("core.resize_cycle").cycle,
		{ description = "Cycle window size (¾ → ⅔ → ½ → ⅓ → ¼ → reset)" }
	)

	hl.bind(mainMod .. " + comma", hl.dsp.layout("consume_or_expel prev"))
	hl.bind(mainMod .. " + period", hl.dsp.layout("consume_or_expel next"))
	-- Laptop multimedia keys for volume and LCD brightness
	hl.bind(
		"XF86AudioRaiseVolume",
		hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
		{ locked = true, repeating = true, description = "Volume up" }
	)
	hl.bind(
		"XF86AudioLowerVolume",
		hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
		{ locked = true, repeating = true, description = "Volume down" }
	)
	hl.bind(
		"XF86AudioMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
		{ locked = true, repeating = true, description = "Mute audio" }
	)
	hl.bind(
		"XF86AudioMicMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
		{ locked = true, repeating = true, description = "Mute microphone" }
	)
	hl.bind(
		"XF86MonBrightnessUp",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
		{ locked = true, repeating = true, description = "Brightness up" }
	)
	hl.bind(
		"XF86MonBrightnessDown",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
		{ locked = true, repeating = true, description = "Brightness down" }
	)

	-- Requires playerctl
	hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next track" })
	hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })
	hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })
	hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous track" })
end

return M
