local M = {}

function M.setup()
    -- Autostart necessary processes (like notifications daemons, status bars, etc.)
    hl.on("hyprland.start", function()
        hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
        hl.exec_cmd("walker --gapplication-service")
        --hl.exec_cmd(terminal)
        --hl.exec_cmd("nm-applet")
        --hl.exec_cmd("waybar & hyprpaper & firefox")
    end)
end

return M
