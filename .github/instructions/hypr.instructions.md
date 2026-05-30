---
description: Apply when working on Hyprland Lua config files (hyprland.lua, core/*.lua)
applyTo: "**/*.lua"
---

## Project Overview

This is a modular Hyprland compositor configuration written in Lua using the native Hyprland Lua config API (`hl.*`).

**Entry point:** `hyprland.lua` — orchestrates module load order.  
**Modules:** `core/` — each file exports a table `M` with a `setup(opts?)` function.

## Module Structure

| File | Responsibility |
|---|---|
| `core/programs.lua` | Program defaults (terminal, file manager, menu) — plain table, no `setup()` |
| `core/environment.lua` | Wayland/NVIDIA env vars via `hl.env()` |
| `core/visual.lua` | `hl.config()` for general, decoration, animations, curves, layout, misc |
| `core/input.lua` | `hl.config({ input = … })`, gestures, per-device config |
| `core/monitors.lua` | `hl.monitor()` definitions |
| `core/windows.lua` | `hl.window_rule()` and `hl.workspace_rule()` |
| `core/keybinding.lua` | `hl.bind()` calls; accepts `opts` table with `terminal`, `fileManager`, `menu`, `mainMod` |
| `core/autostart.lua` | `hl.on("hyprland.start", …)` callbacks |

## Load Order Rules

The load order in `hyprland.lua` is intentional — **do not reorder** without good reason:

1. `programs` (required first; values passed to `keybinding.setup`)
2. `environment.setup()` — env vars must be set before anything launches
3. `visual.setup()` — curves must be defined before animations that reference them
4. `input.setup()`
5. `monitors.setup()`
6. `windows.setup()`
7. `keybinding.setup({ … })` — receives values from `programs`
8. `autostart.setup()` — runs last so all config is applied before exec

## Coding Conventions

- All modules use the **module pattern**: `local M = {} … return M`.
- Config functions are named `M.setup(opts)` with `opts = opts or {}` guard.
- Use `hl.*` global API exclusively — never call `io`, `os.execute`, or shell from Lua.
- Align related `hl.bind()` / `hl.animation()` / `hl.curve()` calls vertically for readability (see existing style in `keybinding.lua` and `visual.lua`).
- Comment blocks reference the relevant wiki URL above the relevant config section.
- Commented-out examples are kept for reference — do not delete them.
- Default values for `opts` fields should match `core/programs.lua` values.

## Hyprland Lua API Quick Reference

```lua
hl.config({ section = { key = value } })          -- set config variables
hl.env("VAR", "value")                             -- set environment variable
hl.bind("MOD + KEY", dispatcher, { flags })        -- keybind
hl.monitor({ output, mode, position, scale })      -- monitor rule
hl.window_rule({ match = {…}, … })                 -- window rule
hl.workspace_rule({ workspace = "…", … })          -- workspace rule
hl.curve("name", { type = "bezier", points = {…}}) -- animation curve
hl.animation({ leaf, enabled, speed, bezier, style }) -- animation
hl.gesture({ fingers, direction, action })         -- touchpad gesture
hl.device({ name, sensitivity, … })               -- per-device input
hl.on("hyprland.start", function() … end)          -- startup hook
hl.exec_cmd("command")                             -- run a command (inside hooks)
hl.dsp.*                                           -- dispatcher helpers
```

## Key Dispatcher Helpers

```lua
hl.dsp.exec_cmd(cmd)
hl.dsp.window.close()
hl.dsp.window.float({ action = "toggle" })
hl.dsp.window.move({ workspace = n })
hl.dsp.window.drag()
hl.dsp.window.resize()
hl.dsp.window.pseudo()
hl.dsp.window.swap({ direction = "left"|"right"|"up"|"down" })
hl.dsp.focus({ direction = "left"|"right"|"up"|"down" })
hl.dsp.layout(msg)                                           -- layout-specific dispatcher (e.g. "togglesplit" for dwindle)
hl.dsp.focus({ workspace = n|"e+1"|"e-1" })
hl.dsp.workspace.toggle_special("name")
hl.dsp.exit()
```

## Wiki Reference
First use the local documentation in `wiki/` for quick reference while editing. For deeper understanding, best practices, and troubleshooting, consult the online wiki: https://wiki.hypr.land/Configuring/


## Other

**Always update [README.md](../../README.md)** whenever you:
- Add or change keybindings
- Add new modules or features
- Change any user-visible defaults (terminal, modifier key, layout, etc.)

The README is the primary user reference — keep it in sync with the actual config.
