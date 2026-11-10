# Memory: hypr

<!-- Alex's Hyprland Lua config (0.55+) -->

---

## 2026-07-21 — Initial setup

**What**: Initialized repo memory.

**Why**: Starting work on this codebase; want a persistent record across conversations.

**Details**:
- Repo: local hyprland config at ~/.config/hypr
- Stack: Hyprland 0.55.4 Lua config (hyprland.lua + core/*.lua)
- Entry: hyprland.lua requires core modules

**Remaining**: nothing

## 2026-07-21 — Fix hypr-keybindings.lua scan (layer_rule)

**What**: Added missing `hl.layer_rule` mock to `scripts/hypr-keybindings.sh` so Lua keybind scan succeeds.

**Why**: `core/windows.lua` calls `hl.layer_rule` for WezTerm blur; the scanner's mock `hl` table only had `window_rule`/`workspace_rule`, so scan died with "attempt to call a nil value (field 'layer_rule')".

**Details**:
- Fix: one line in the mock table: `layer_rule = function() end`
- Verified: lua scan now finds 89 bindings

**Remaining**: nothing
## 2026-07-21 — Fix broken exec keybinds (PATH)

**What**: Fixed hl.env PATH so Super+Enter, screenshots, Super+N launch, and other exec binds work again.

**Why**: Partial keybind failure — workspace/focus binds worked, every exec_cmd bind failed silently.

**Details**:
- Root cause: `core/environment.lua` had `hl.env("PATH", "/home/alex/.local/bin:$PATH")`
- `hl.env` does NOT expand `$PATH` (wiki: use os.getenv). Spawn env became literal `/home/alex/.local/bin:$PATH`
- `exec_cmd` runs via `sh -c`; sh lives in /usr/bin → all execs fail
- Pure dispatchers (focus workspace, close window) unaffected — matches symptoms
- Evidence: child PIDs numbr/scratch had `PATH=/home/alex/.local/bin:$PATH`; absolute `/usr/bin/touch` worked, bare `touch` did not
- Fix: rebuild PATH with os.getenv, fallback to a clean system PATH if getenv is empty/poisoned/missing /usr/bin, then prepend ~/.local/bin
- Reload is enough; full Hyprland restart not required once PATH is clean

**Remaining**: nothing

## 2026-07-21 — Fix hypr-keybindings.lua scan (layer_rule)

**What**: Added missing `hl.layer_rule` mock to `scripts/hypr-keybindings.sh` so Lua keybind scan succeeds.

**Why**: `core/windows.lua` calls `hl.layer_rule` for WezTerm blur; the scanner's mock `hl` table only had `window_rule`/`workspace_rule`, so scan died with "attempt to call a nil value (field 'layer_rule')".

**Details**:
- Fix: one line in the mock table: `layer_rule = function() end`
- Verified: lua scan now finds 89 bindings

**Remaining**: nothing

## 2026-07-21 — Fix satty window rule class

**What**: Changed satty window rule match from `^(satty)$` to `^(com\.gabm\.satty)$`.

**Why**: Rule never applied — satty's app_id/class is `com.gabm.satty` (also StartupWMClass in the desktop file), not bare `satty`. Title is `satty`; class is the reverse-DNS id. Confirmed via hyprctl: floating stayed false.

**Details**:
- File: core/windows.lua
- Evidence: `hyprctl clients` while satty open → class/initialClass `com.gabm.satty`, floating false under old rule

**Remaining**: nothing

## 2026-07-24 — WS1 dwindle/scrolling layout toggle

**What**: Super+Shift+T toggles workspace 1 between dwindle and scrolling.

**Why**: Wanted a quick flip of WS1 layout without changing the global default or other workspaces.

**Details**:
- New: `core/layout_toggle.lua` — reads WS1 `tiled_layout`, applies `hl.workspace_rule({ workspace = "1", layout = next })`
- Bind: `core/keybinding.lua` Super+Shift+T
- Runtime rule only; reload resets WS1 to dwindle
- notify-send shows the new layout name

**Remaining**: nothing

## 2026-07-25 — Restructure core/ mains vs helpers

**What**: Moved helper modules into `core/<name>/init.lua` packages; mains stay flat.

**Why**: Keep config entry modules visible at top level; nest behavior helpers.

**Details**:
- Helpers: alttab, float, focus, layout_toggle, resize_cycle → `core/*/init.lua`
- Mains unchanged: windows, keybinding, monitors, visual, input, … 
- Requires stay `require("core.alttab")` — Hyprland package.path already has `?/init.lua`
- Updated README, hypr.instructions.md, path comments; keybindings scanner package.path
- Verified: hyprctl reload ok, helper bind descriptions present (100 binds)

**Remaining**: nothing

## 2026-11-10 — Fix black screen after unplugging external with eDP-1 off

**What**: `core/monitors.lua` no longer counts `FALLBACK`/`HEADLESS-*` outputs as external monitors; `monitor.removed` excludes the removed output and re-applies the policy via a 1s oneshot `hl.timer`.

**Why**: Lid closed + only external active, then unplug → Hyprland moved workspaces to its placeholder output `FALLBACK`. `get_external_monitors()` treated it as external, so eDP-1 stayed disabled, also on lid open → black screen until reboot.

**Details**:
- Evidence: hwmd log `moveworkspacev2: unknown monitor "FALLBACK"` at unplug; logind "Lid opened" 6s later, Hyprland still running
- Not physically re-tested yet (needs unplug with lid closed)

**Remaining**: verify with a real unplug
