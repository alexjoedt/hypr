# Hyprland Quick Guide (This Config)

This guide is a fast reference for your current setup in [hyprland.lua](hyprland.lua).

## Overview
- Main modifier: Super (Windows key)
- Keyboard layout: de (German)
- Terminal: kitty
- File manager: dolphin
- App launcher: wofi --show drun
- Main layout: dwindle

## Basics
- Super + Return: open terminal
- Super + Space: open app launcher
- Super + E: open file manager
- Super + W: close active window
- Super + M: exit Hyprland session

## Move and Manage Windows

### Move Focus
- Super + H / L / K / J: move focus left / right / up / down (vim-style)
- Super + Left / Right / Up / Down: same, with arrow keys

### Swap Windows
- Super + Shift + H / L / K / J: swap active window left / right / up / down (vim-style)
- Super + Shift + Left / Right / Up / Down: same, with arrow keys

### Other Window Controls
- Super + T: toggle floating for active window
- Super + O: pop out — toggle floating and sticky (window follows across all workspaces)
- Super + P: toggle pseudo-tiling for active window (dwindle)
- Super + Left mouse drag: move window
- Super + Right mouse drag: resize window

### Groups (Tabbed Windows)
- Super + G: create a group from the active window (press again to dissolve)
- Super + Shift + G: lock the group — prevents new windows from auto-joining
- Super + Tab: switch to next window in group
- Super + Shift + Tab: switch to previous window in group

### Expand Windows and Change Splits
- Super + - (dash): toggle vertical/horizontal split for the active window (dwindle)
- In dwindle, window sizes change automatically when you add/remove windows.
- You can resize manually with Super + right mouse drag.

## Workspaces
### Switch Workspaces
- Super + 1..9: go to workspace 1..9
- Super + 0: go to workspace 10
- Super + Ctrl + H / Left: go to previous existing workspace
- Super + Ctrl + L / Right: go to next existing workspace
- Super + mouse wheel down: next existing workspace
- Super + mouse wheel up: previous existing workspace

### Send Windows to Workspaces
- Super + Shift + 1..9: move active window to workspace 1..9
- Super + Shift + 0: move active window to workspace 10

### Create Workspaces
- Workspaces are created automatically when you switch to a number that is not active yet, or when you move a window there.

### Special Workspace (Scratchpad)
- Super + S: toggle special workspace named magic
- Super + Shift + S: move active window to special:magic

## Useful System Shortcuts
- XF86AudioRaiseVolume: volume +5%
- XF86AudioLowerVolume: volume -5%
- XF86AudioMute: mute/unmute output
- XF86AudioMicMute: mute/unmute microphone
- XF86MonBrightnessUp: brightness +5%
- XF86MonBrightnessDown: brightness -5%
- XF86AudioNext: next track
- XF86AudioPrev: previous track
- XF86AudioPlay / XF86AudioPause: play/pause
- Super + Shift + B: run waybar launch script

## Optional Recommended Additions (Not enabled yet)
If you want fullscreen control, add this in [core/keybinding.lua](core/keybinding.lua):

```lua
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))
```

Then reload Hyprland config.

## Notes
- Media shortcuts need playerctl.
- Volume shortcuts use wpctl.
- Brightness shortcuts use brightnessctl.
- Waybar shortcut assumes ~/.config/waybar/launch.sh exists.
