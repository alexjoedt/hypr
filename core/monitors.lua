local M = {}

-- ─── Laptop vs. external display policy ──────────────────────────────────────
-- Default: the internal panel (eDP-1) is disabled whenever an external
-- monitor is connected. Toggle `extend_laptop` (SUPER + ALT + M) to keep
-- both displays active instead.
--
-- Resets to the default (false) on Hyprland restart / config reload, same
-- as the other in-memory state in this config (see core/alttab.lua's
-- _mru and core/resize_cycle.lua's _state).

local state = {
	extend_laptop = false,
}

local function get_external_monitors()
	local external = {}
	for _, mon in ipairs(hl.get_monitors()) do
		if mon.name ~= "eDP-1" then
			table.insert(external, mon)
		end
	end
	return external
end

local function migrate_workspaces_off_edp1(target_name)
	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.monitor == "eDP-1" then
			hl.dispatch(hl.dsp.workspace.move({ workspace = ws.id, monitor = target_name }))
		end
	end
end

-- NOTE: `hyprctl keyword` does not work on this Hyprland version's Lua-based
-- config engine ("keyword can't work with non-legacy parsers"), so runtime
-- changes must go through hl.monitor() directly. Re-enabling a previously
-- disabled output requires passing `disabled = false` explicitly — omitting
-- the field does not clear a prior `disabled = true` rule (confirmed by
-- testing live: the screen stayed off until `disabled = false` was passed
-- alongside mode/position/scale).
local function enable_edp1()
	hl.monitor({ output = "eDP-1", disabled = false, mode = "preferred", position = "auto", scale = 1 })
end

local function disable_edp1(migrate_to)
	if migrate_to then
		migrate_workspaces_off_edp1(migrate_to)
	end
	hl.monitor({ output = "eDP-1", disabled = true })
end

-- Re-evaluate and apply the current display policy. Safe to call repeatedly
-- (idempotent) — this is the single source of truth called from every
-- trigger (startup, hotplug, lid open).
local function apply_display_policy()
	local external = get_external_monitors()

	if #external == 0 then
		-- No external monitor: laptop screen is always on.
		enable_edp1()
		return
	end

	if state.extend_laptop then
		-- External connected, but user wants both displays active.
		enable_edp1()
	else
		-- External connected, default policy: laptop screen off.
		disable_edp1(external[1].name)
	end
end

function M.toggle_extend()
	state.extend_laptop = not state.extend_laptop
	apply_display_policy()

	local msg = state.extend_laptop
		and "Laptop screen: extended (both displays on)"
		or "Laptop screen: off when external connected"
	hl.exec_cmd("notify-send 'Displays' '" .. msg .. "'")
end

function M.setup()
	-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
	hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

	-- Apply policy now (covers both the initial config load at startup and
	-- every subsequent `hyprctl reload`). On the very first boot, monitors
	-- may not be enumerable yet at this point (same caveat as
	-- core/windows.lua), so hyprland.start is kept as a fallback. Also
	-- re-applied whenever an external monitor is hot-plugged or removed.
	-- Ignore eDP-1 itself in the event handlers below — we control it
	-- directly via enable/disable_edp1, and it fires its own added/removed
	-- events when toggled.
	apply_display_policy()
	hl.on("hyprland.start", apply_display_policy)
	hl.on("monitor.added", function(mon)
		if mon.name ~= "eDP-1" then
			apply_display_policy()
		end
	end)
	hl.on("monitor.removed", function(mon)
		if mon.name ~= "eDP-1" then
			apply_display_policy()
		end
	end)

	-- Lid closed: the panel is physically covered either way, so always
	-- disable it when an external monitor is present, regardless of
	-- extend_laptop. With no external monitor, lock and suspend instead.
	hl.bind("switch:on:Lid Switch", function()
		local external = get_external_monitors()

		if #external > 0 then
			hl.exec_cmd("notify-send 'Lid closed' 'Laptop screen off (external monitor connected)'")
			disable_edp1(external[1].name)
		else
			hl.exec_cmd("notify-send 'Lid closed' 'Locking and suspending…'")
			hl.exec_cmd("hyprlock")
			hl.exec_cmd("systemctl suspend")
		end
	end, { locked = true })

	-- Lid opened: re-evaluate normally (respects extend_laptop again).
	hl.bind("switch:off:Lid Switch", function()
		apply_display_policy()
	end, { locked = true })
end

return M
