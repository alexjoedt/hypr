# Hyprland Config — Quick Reference

> A modular Hyprland setup written in Lua. Entry point: [hyprland.lua](hyprland.lua) — all modules live under [core/](core/).

---

## Setup at a Glance

| Setting          | Value                  |
|------------------|------------------------|
| Modifier key     | `SUPER` (Windows key)  |
| Keyboard layout  | `de` (German)          |
| Terminal         | `wezterm`              |
| File manager     | `nautilus`             |
| App launcher     | `walker`               |
| Tiling layout    | `dwindle`              |

---

## Quickstart

The five shortcuts you need to know on day one:

| Shortcut | Action |
|---|---|
| `SUPER` + `Return` | Open terminal |
| `SUPER` + `Space` | Open app launcher |
| `SUPER` + `F` | Start or focus Firefox on workspace 3 |
| `SUPER` + `E` | Open file manager |
| `SUPER` + `W` | Close active window |
| `SUPER` + `M` | Exit Hyprland |
| `SUPER` + `SHIFT` + `/` or `-` (on DE) | Show all keybindings |

---

## Window Navigation — Full Reference

### Focus

Move keyboard focus between windows using vim-style keys or arrow keys.

| Shortcut | Direction |
|---|---|
| `SUPER` + `H` or `SUPER` + `←` | Focus left |
| `SUPER` + `L` or `SUPER` + `→` | Focus right |
| `SUPER` + `K` or `SUPER` + `↑` | Focus up |
| `SUPER` + `J` or `SUPER` + `↓` | Focus down |

### Swap / Move Windows

Reorder windows within the tiling layout.

| Shortcut | Action |
|---|---|
| `SUPER` + `SHIFT` + `H` or `SUPER` + `SHIFT` + `←` | Swap window left |
| `SUPER` + `SHIFT` + `L` or `SUPER` + `SHIFT` + `→` | Swap window right |
| `SUPER` + `SHIFT` + `K` or `SUPER` + `SHIFT` + `↑` | Swap window up |
| `SUPER` + `SHIFT` + `J` or `SUPER` + `SHIFT` + `↓` | Swap window down |

### Window State

Toggle how a window behaves in the layout.

| Shortcut | Action |
|---|---|
| `SUPER` + `P` | Toggle floating (centered) |
| `SUPER` + `SHIFT` + `F` | Toggle Focus mode (centered layout) |
| `SUPER` + `O` | Pop out — floating + sticky (follows you across all workspaces) |
| `SUPER` + `-` | Toggle split direction (vertical ↔ horizontal) for dwindle |
| `SUPER` + Left mouse drag | Move floating window |
| `SUPER` + Right mouse drag | Resize window |

### Cycle Window Size

Press `SUPER` + `R` to pull a tiled (or floating) window out into a centered floating window and cycle through preset widths. Useful for quickly popping a tiled window into a usable floating size without touching the mouse.

| Shortcut | Action |
|---|---|
| `SUPER` + `R` | Cycle size: ½ → ⅓ → ¼ monitor width (full height) |

Each press floats the window (if not already), resizes it, and re-centers it. The cycle is per-window and wraps back to ½ after ¼.

### Groups (Tabbed Windows)

Stack multiple windows into a single tile and switch between them with a tab bar.

| Shortcut | Action |
|---|---|
| `SUPER` + `G` | Create group (press again to dissolve) |
| `SUPER` + `SHIFT` + `G` | Lock group — prevents new windows from auto-joining |
| `SUPER` + `Tab` | Switch to next window in group |
| `SUPER` + `SHIFT` + `Tab` | Switch to previous window in group |

---

## Workspaces

### Switch

| Shortcut | Action |
|---|---|
| `SUPER` + `1` … `9` | Go to workspace 1–9 |
| `SUPER` + `0` | Go to workspace 10 |
| `SUPER` + `CTRL` + `H` or `SUPER` + `CTRL` + `←` | Previous existing workspace |
| `SUPER` + `CTRL` + `L` or `SUPER` + `CTRL` + `→` | Next existing workspace |
| `SUPER` + scroll down | Next existing workspace |
| `SUPER` + scroll up | Previous existing workspace |

> Workspaces are created automatically — just switch to a number that doesn't exist yet.

### Send Window to Workspace

| Shortcut | Action |
|---|---|
| `SUPER` + `SHIFT` + `1` … `9` | Move active window to workspace 1–9 |
| `SUPER` + `SHIFT` + `0` | Move active window to workspace 10 |

### Special Workspace (Scratchpad)

A hidden workspace you can summon and dismiss at any time — great for a persistent terminal or notes window.

| Shortcut | Action |
|---|---|
| `SUPER` + `S` | Toggle `magic` scratchpad |
| `SUPER` + `SHIFT` + `S` | Send active window to scratchpad |

---

## Displays

The laptop screen (`eDP-1`) is automatically disabled whenever an external monitor is connected — any open workspaces on it are moved to the external monitor first. Unplugging the external monitor re-enables the laptop screen automatically. Closing the lid always disables the laptop screen while an external monitor is present (and locks + suspends when there isn't one); opening the lid re-applies the normal policy.

| Shortcut | Action |
|---|---|
| `SUPER` + `ALT` + `M` | Toggle "extend" mode — keep the laptop screen on alongside an external monitor |

---

## System & Media Shortcuts

### Media

> Requires `playerctl`.

| Key | Action |
|---|---|
| `XF86AudioPlay` / `XF86AudioPause` | Play / Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

### Volume

> Controlled via `wpctl`.

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume −5% |
| `XF86AudioMute` | Mute / unmute output |
| `XF86AudioMicMute` | Mute / unmute microphone |

### Brightness

> Controlled via `brightnessctl`.

| Key | Action |
|---|---|
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness −5% |

### Misc

| Shortcut | Action |
|---|---|
| `Print` | Screenshot whole screen → `~/Pictures/Screenshots/` |
| `SUPER` + `Print` | Select an area, annotate with `satty`, copy to clipboard + save |
| `SUPER` + `/` | Open interactive keybindings cheatsheet (walker) |

---

## Optional: Fullscreen

Not enabled by default. To add fullscreen support, open [core/keybinding.lua](core/keybinding.lua) and add:

```lua
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))
```

Then reload the Hyprland config.
