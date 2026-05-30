local M = {}

function M.setup(opts)
    opts = opts or {}

    local terminal = opts.terminal or "kitty"
    local fileManager = opts.fileManager or "dolphin"
    local menu = opts.menu or "wofi --show drun"
    local mainMod = opts.mainMod or "SUPER"

    -- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
    hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal))
    hl.bind(mainMod .. " + W",         hl.dsp.window.close())
    hl.bind(mainMod .. " + M",         hl.dsp.exit())
    hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
    hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + O",         function() -- pop out: float + pin (follows across workspaces)
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        hl.dispatch(hl.dsp.window.pin())
    end)
    hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(menu))
    hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo()) -- dwindle
    -- hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit")) -- dwindle
    hl.bind(mainMod .. " + minus",      hl.dsp.layout("togglesplit")) -- dwindle: toggle vertical/horizontal split
    hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/waybar/launch.sh"))

    -- Move focus with mainMod + vim keys / arrow keys
    hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left"  }))
    hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up"    }))
    hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down"  }))
    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

    -- Swap windows with mainMod + SHIFT + vim keys / arrow keys
    hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.swap({ direction = "left"  }))
    hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.swap({ direction = "right" }))
    hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.swap({ direction = "up"    }))
    hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.swap({ direction = "down"  }))
    hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left"  }))
    hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
    hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up"    }))
    hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down"  }))

    -- Groups (tabbed windows)
    hl.bind(mainMod .. " + G",         hl.dsp.group.toggle())          -- create / dissolve group
    hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock_active())     -- lock group (no auto-join)
    hl.bind(mainMod .. " + Tab",       hl.dsp.group.next())            -- next tab in group
    hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())          -- prev tab in group

    -- Switch workspaces with mainMod + [0-9]
    -- Move active window to a workspace with mainMod + SHIFT + [0-9]
    for i = 1, 9 do
        hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
    end
    hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
    hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

    -- Example special workspace (scratchpad)
    hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
    hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Scroll through existing workspaces with mainMod + scroll
    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    -- Cycle through existing workspaces with mainMod + CTRL + vim keys / arrow keys
    hl.bind(mainMod .. " + CTRL + H",     hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(mainMod .. " + CTRL + L",     hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Resize mode: SUPER + R to enter, arrow/vim keys to resize, ESC to exit
    -- See https://wiki.hypr.land/Configuring/Basics/Binds/#submaps
    hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

    hl.define_submap("resize", function()
        hl.bind("right", hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })
        hl.bind("left",  hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
        hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
        hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
        hl.bind("L",     hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })
        hl.bind("H",     hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })
        hl.bind("K",     hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
        hl.bind("J",     hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
        hl.bind("escape", hl.dsp.submap("reset"))
    end)

    -- Laptop multimedia keys for volume and LCD brightness
    hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
    hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

    -- Requires playerctl
    hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
end

return M
