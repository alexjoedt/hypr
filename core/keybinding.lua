local M = {}

function M.setup(opts)
    opts = opts or {}

    local terminal = opts.terminal or "kitty"
    local fileManager = opts.fileManager or "dolphin"
    local menu = opts.menu or "wofi --show drun"
    local mainMod = opts.mainMod or "SUPER"

    -- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
    hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(terminal),    { description = "Terminal"      })
    hl.bind(mainMod .. " + W",         hl.dsp.window.close(),        { description = "Close window"  })
    hl.bind(mainMod .. " + M",         hl.dsp.exit(),                { description = "Exit Hyprland" })
    hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager), { description = "File manager"  })
    hl.bind(mainMod .. " + P",         function() -- toggle float: center + resize with 100px top/bottom gap
        local win        = hl.get_active_window()
        local is_floating = win and win.floating  -- snapshot BEFORE dispatch (proxy tables eval lazily)
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        -- only resize/center when going tiled → floating (handle both boolean false and integer 0)
        if win and is_floating ~= true and is_floating ~= 1 then
            local gap = 100
            local mon = hl.get_active_monitor()
            if mon then
                local w = math.floor(mon.width  / mon.scale * 0.5)
                local h = math.floor(mon.height / mon.scale - 2 * gap)
                hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
            end
            hl.dispatch(hl.dsp.window.center({}))
        end
    end, { description = "Toggle float (centered)" })
    hl.bind(mainMod .. " + O",         function() -- pop out: float + pin (follows across workspaces)
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        hl.dispatch(hl.dsp.window.pin())
    end, { description = "Pop out (float + pin)" })
    hl.bind(mainMod .. " + SHIFT + F", require("core.focus").toggle,  { description = "Focus mode"             }) -- focus mode: center 1-2 windows
    hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(menu),         { description = "App launcher"           })
    --hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo(),        { description = "Toggle pseudo-tile"     }) -- dwindle
    -- hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit")) -- dwindle
    hl.bind(mainMod .. " + minus",     hl.dsp.layout("togglesplit"),  { description = "Toggle split direction" }) -- dwindle: toggle vertical/horizontal split
    hl.bind(mainMod .. " + SHIFT + O", function() hl.plugin.hyprexpo.expo("toggle") end,
                                                                       { description = "Workspace overview"     }) -- workspace overview

    -- Lock screen
    hl.bind(mainMod .. " + ALT + L",   hl.dsp.exec_cmd("hyprlock --quiet --grace 1"),
                                                                       { description = "Lock screen"            })

    -- Borrow a window from another workspace / return it (hypr-borrow.sh)
    hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-borrow.sh pull"),
                                                                       { description = "Borrow window"          })
    hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-borrow.sh return"),
                                                                       { description = "Return borrowed window" })

    -- Screenshots (saved to ~/Pictures/Screenshots/)
    -- Print: grab the whole screen and save it directly
    hl.bind("Print",               hl.dsp.exec_cmd('mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png'),
                                                                       { description = "Screenshot (full screen)"           })
    -- Super + Print: select an area, annotate with satty, copy to clipboard and save
    hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd('mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | satty -f - --copy-command wl-copy -o ~/Pictures/Screenshots/%Y%m%d_%H%M%S.png'),
                                                                       { description = "Screenshot (select area + annotate)" })

    -- Walker launcher (elephant window provider)
    hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("walker --provider windows"),
                                                                       { description = "Walker (windows)"       })

    hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("walker --provider clipboard"),
                                                                        { description = "Walker (clipboard)"        })

    -- Launch numbr with Super+Shift+N
    hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("numbr"),
                                                                       { description = "Calculator"               })

    -- Keybindings cheatsheet
    hl.bind(mainMod .. " + SHIFT + minus",     hl.dsp.exec_cmd("~/.config/hypr/scripts/hypr-keybindings.sh"),
                                                                       { description = "Show keybindings"       })

    -- Move focus with mainMod + vim keys / arrow keys
    hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left"  }), { description = "Focus left"  })
    hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
    hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up"    }), { description = "Focus up"    })
    hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down"  }), { description = "Focus down"  })
    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }), { description = "Focus left"  })
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }), { description = "Focus up"    })
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }), { description = "Focus down"  })

    -- Swap windows with mainMod + SHIFT + vim keys / arrow keys
    hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.swap({ direction = "left"  }), { description = "Swap window left"  })
    hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.swap({ direction = "right" }), { description = "Swap window right" })
    hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.swap({ direction = "up"    }), { description = "Swap window up"    })
    hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.swap({ direction = "down"  }), { description = "Swap window down"  })
    hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left"  }), { description = "Swap window left"  })
    hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }), { description = "Swap window right" })
    hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up"    }), { description = "Swap window up"    })
    hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down"  }), { description = "Swap window down"  })

        -- Alt + Tab: cycle windows across all workspaces in MRU order.
    --
    -- _mru   : list of window addresses ordered by last focus time,
    --          _mru[1] = oldest, _mru[#_mru] = current.
    -- _atidx : index into _mru while cycling; nil = not currently cycling.
    -- _atskip: address of the window we just focused ourselves so the
    --          window.active event doesn't reset _atidx mid-cycle.
    local _mru   = {}
    local _atidx = nil
    local _atskip = nil

    hl.on("window.active", function(w)
        if _atskip == w.address then
            -- This focus was triggered by our own cycling dispatch; ignore.
            _atskip = nil
            return
        end
        -- Any manual focus resets the cycling position.
        _atidx = nil
        -- Move this window to the end of the MRU list (most recent).
        for i = #_mru, 1, -1 do
            if _mru[i] == w.address then table.remove(_mru, i) end
        end
        table.insert(_mru, w.address)
    end)

    local function _alt_tab(direction)
        -- Build a lookup of currently open windows.
        local valid = {}
        for _, w in ipairs(hl.get_windows()) do valid[w.address] = w end

        -- Prune any closed windows from the MRU list.
        local clean = {}
        for _, addr in ipairs(_mru) do
            if valid[addr] then table.insert(clean, addr) end
        end
        _mru = clean

        if #_mru == 0 then return end

        -- First keypress: start at second-to-last entry (previous window).
        -- Subsequent keypresses: continue in the chosen direction.
        if _atidx == nil then
            _atidx = #_mru - 1
        else
            _atidx = _atidx + direction
        end

        -- Wrap around the list.
        if _atidx < 1     then _atidx = #_mru end
        if _atidx > #_mru then _atidx = 1     end

        local addr = _mru[_atidx]
        local win  = valid[addr]
        if not win then return end

        -- Mark this address so window.active doesn't clear _atidx.
        _atskip = addr
        -- focuswindow with address: prefix switches workspace automatically.
        hl.dispatch(hl.dsp.focus({ window = "address:" .. addr }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end

    hl.bind("ALT + Tab",         function() _alt_tab(-1) end, { description = "Alt+Tab: previous window (global MRU)" })
    hl.bind("ALT + SHIFT + Tab", function() _alt_tab( 1) end, { description = "Alt+Tab: next window (global MRU)"     })

    -- Groups (tabbed windows)
    hl.bind(mainMod .. " + G",           hl.dsp.group.toggle(),      { description = "Toggle window group"   }) -- create / dissolve group
    hl.bind(mainMod .. " + SHIFT + G",   hl.dsp.group.lock_active(), { description = "Lock window group"     }) -- lock group (no auto-join)
    hl.bind(mainMod .. " + Tab",         hl.dsp.group.next(),        { description = "Next tab in group"     })
    hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev(),        { description = "Previous tab in group" })

    -- Switch workspaces with mainMod + [0-9]
    -- Move active window to a workspace with mainMod + SHIFT + [0-9]
    for i = 1, 9 do
        hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }),       { description = "Switch to workspace " .. i  })
        hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
    end
    hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }),              { description = "Switch to workspace 10"         })
    hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }),        { description = "Move window to workspace 10"    })

    -- Special workspace (scratchpad)
    hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),            { description = "Toggle scratchpad"         })
    hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to scratchpad" })

    -- Scroll through existing workspaces with mainMod + scroll
    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace"     })
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

    -- Cycle through existing workspaces with mainMod + CTRL + vim keys / arrow keys
    hl.bind(mainMod .. " + CTRL + H",     hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
    hl.bind(mainMod .. " + CTRL + L",     hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace"     })
    hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
    hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace"     })

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window (drag)"   })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window (drag)" })

    -- Cycle window size: SUPER + R → ½ → ⅓ → ¼ → ½ …
    -- Resizes the active window in-place (tiled or floating) without changing its floating state.
    local _cycle_sizes = { 1/2, 1/3, 1/4 }
    local _cycle_state = {}  -- [window_address] = current_index

    hl.bind(mainMod .. " + R", function()
        local win = hl.get_active_window()
        if not win then return end

        local mon = hl.get_active_monitor()
        if not mon then return end

        local addr = win.address
        local idx  = (_cycle_state[addr] or 0) % #_cycle_sizes + 1
        _cycle_state[addr] = idx

        local gap = 100
        local w   = math.floor(mon.width  / mon.scale * _cycle_sizes[idx])
        local h   = math.floor(mon.height / mon.scale - 2 * gap)
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
    end, { description = "Cycle window size (½ → ⅓ → ¼)" })

    -- Laptop multimedia keys for volume and LCD brightness
    hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up"       })
    hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Volume down"     })
    hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, description = "Mute audio"      })
    hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true, description = "Mute microphone" })
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true, description = "Brightness up"   })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true, description = "Brightness down" })

    -- Requires playerctl
    hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Next track"     })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause"     })
    hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause"     })
    hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Previous track" })
end

return M
