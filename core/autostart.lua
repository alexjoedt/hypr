local M = {}

function M.setup()
    -- Autostart necessary processes (like notifications daemons, status bars, etc.)
    hl.on("hyprland.start", function()
        hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
        hl.exec_cmd("walker --gapplication-service")
        hl.exec_cmd("wl-paste --type text --watch cliphwist store")
        hl.exec_cmd("wl-paste --type image --watch cliphist store")
        hl.exec_cmd("wl-paste --primary --watch cliphist store")
        hl.exec_cmd("hyprpm reload -n")
        hl.exec_cmd("hyprpaper")
        --hl.exec_cmd("qs")
        hl.exec_cmd("qs -c noctalia-shell")
        hl.exec_cmd("noctalia")
        hl.exec_cmd("hyprctl reload -q")
        hl.exec_cmd("hypridle -q")
        hl.exec_cmd("systemctl --user restart elephant")
    end)
end

return M
