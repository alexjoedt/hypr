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
- Super + Q: close active window
- Super + M: exit Hyprland session

## Move and Manage Windows
- Super + Left / Right / Up / Down: move focus between windows
- Super + T: toggle floating for active window
- Super + P: toggle pseudo-tiling for active window (dwindle)
- Super + Left mouse drag: move window
- Super + Right mouse drag: resize window

### Expand Windows and Change Splits (How it works here)
- In dwindle, window sizes change automatically when you add/remove windows.
- You can resize manually with Super + right mouse drag.
- A direct split-toggle bind is currently disabled in your config (the togglesplit bind is commented).

## Workspaces
### Switch Workspaces
- Super + 1..9: go to workspace 1..9
- Super + 0: go to workspace 10
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
If you want easier split and fullscreen control, add these in the keybindings section of [hyprland.lua](hyprland.lua):

```lua
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))
```

Then reload Hyprland config.

## Notes
- Media shortcuts need playerctl.
- Volume shortcuts use wpctl.
- Brightness shortcuts use brightnessctl.
- Waybar shortcut assumes ~/.config/waybar/launch.sh exists.
