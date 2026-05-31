local M = {}

function M.setup()
    -- Autostart necessary processes (like notifications daemons, status bars, etc.)
    hl.on("hyprland.start", function()
        hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
        hl.exec_cmd("wayle panel start") -- wallpaper + bar + notifications (replaces swww-daemon)
        hl.exec_cmd("walker --gapplication-service")
        --hl.exec_cmd(terminal)
        --hl.exec_cmd("nm-applet")
    end)
end

return M
