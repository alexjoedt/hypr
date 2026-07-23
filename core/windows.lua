local M = {}

-- Exposed so other modules (e.g. core/resize_cycle.lua's Super+R size-cycle
-- toggle) can reuse the same monitor-aware gap calculation to emulate
-- resizing a lone tiled window (dwindle has no sibling split to resize
-- against when a window is alone on its workspace).

-- ─── Single-window auto-centering (resolution-aware) ─────────────────────────
-- Gaps are computed from each monitor's *logical* width (physical px ÷ scale).
-- Thresholds and multipliers can be freely adjusted here.
--
-- Workspace selector breakdown:
--   w[t1]     → workspace has exactly 1 tiled window  ("t" = tiled, "1" = count)
--   m[NAME]   → scoped to a specific monitor by name (e.g. "eDP-1", "DP-1")
-- Combining them gives each monitor its own rule, so gaps scale with the display.
-- The rule activates when the tiled count reaches 1 and lifts automatically when
-- a second window appears — normal multi-window gaps are never affected.
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/#workspace-selectors

local function single_window_gaps(m)
	-- Logical width accounts for HiDPI: a 4K screen scaled ×2 behaves like 1920px.
	local lw = m.width / (m.scale or 1)

	if lw > 2560 then
		-- Ultrawide (≥21:9) or large 4K — push the window into a centred column.
		-- 13 % of logical width per side keeps the window at ~74 % of the screen.
		-- Raise the multiplier (e.g. 0.18) for an even narrower column.
		local h_gap = math.floor(lw * 0.23)
		return { top = 20, right = h_gap, bottom = 20, left = h_gap }
	elseif lw > 1920 then
		-- 1440p / QHD
		return { top = 20, right = 200, bottom = 20, left = 200 }
	else
		-- Laptop / 1080p — minimal padding
		return { top = 20, right = 20, bottom = 20, left = 20 }
	end
end

M.single_window_gaps = single_window_gaps

local function register_centering_rule(m)
	hl.workspace_rule({
		workspace = "w[t1]m[" .. m.name .. "]",
		gaps_out = single_window_gaps(m),
	})
end

function M.setup()
	-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
	-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

	-- Register rules at config-parse time so they survive config reloads.
	-- hl.get_monitors() is available here because DRM/KMS initialises monitors
	-- before the Lua config is evaluated.  On the very first boot, the list may
	-- be empty; the hyprland.start fallback covers that edge case.
	for _, m in ipairs(hl.get_monitors()) do
		register_centering_rule(m)
	end

	-- Fallback: first boot where monitors may not yet be available above.
	hl.on("hyprland.start", function()
		for _, m in ipairs(hl.get_monitors()) do
			register_centering_rule(m)
		end
	end)

	-- Hot-plug: register a rule whenever a new display is connected.
	hl.on("monitor.added", register_centering_rule)

	-- Example window rule
	-- hl.window_rule({ match = { class = "kitty", title = "kitty" }, float = true })
	--hl.workspace_rule({ workspace = "1", layout = "scrolling", layout_opts = { direction = "right"}  }) -- no gaps on workspace 1

	-- WezTerm — enable blur behind the transparent window.
	hl.layer_rule({ match = { namespace = "^(org.wezfurlong.wezterm|wezterm.*)$" }, blur = true })

	-- File managers — always float regardless of their default tile hint.
	-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
	local file_managers = { "thunar", "nautilus", "dolphin", "nemo", "pcmanfm", "spacefm", "caja" }
	for _, fm in ipairs(file_managers) do
		hl.window_rule({
			name = "float-" .. fm,
			match = { class = "^[Ii]?(" .. fm .. ")$" },
			float = true,
		})
	end
	-- numbr calculator — float, centre, and set a fixed size
	hl.window_rule({
		match  = { class = "^(numbr)$" },
		float  = true,
		size   = { 680, 520 },
		center = true,
    })

	hl.window_rule({
		match  = { class = "^(com\\.gabm\\.satty)$" },
		float  = true,
		size   = { 900, 640 },
		center = true,
	})
	-- Ignore maximize requests from apps. You'll probably like this.
	-- hl.window_rule({
	--     name  = "suppress-maximize-events",
	--     match = { class = ".*" },
	--     suppress_event = "maximize",
	-- })

	-- Fix some dragging issues with XWayland
	-- hl.window_rule({
	--     name  = "fix-xwayland-drags",
	--     match = {
	--         class      = "^$",
	--         title      = "^$",
	--         xwayland   = true,
	--         float      = true,
	--         fullscreen = false,
	--         pin        = false,
	--     },
	--     no_focus = true,
	-- })
end

return M
