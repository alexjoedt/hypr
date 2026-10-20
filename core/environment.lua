local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

    -- Hyprland's own PATH doesn't inherit ~/.local/bin from shell rc files
    -- (it's started before/outside the interactive shell), so binds calling
    -- commands installed there (e.g. "numbr") fail to exec silently.
    --
    -- hl.env does NOT expand $VAR — use os.getenv() (wiki Environment-variables).
    -- Never write "...:$PATH" as a string: it becomes a literal and breaks every
    -- exec bind (sh, wezterm, grim, obsidian, … all live under /usr/bin).
    local path = os.getenv("PATH") or ""
    if path == "" or path:find("%$PATH", 1) or not path:find("/usr/bin", 1, true) then
        path = "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
    end
    if not path:find("/home/alex/.local/bin", 1, true) then
        path = "/home/alex/.local/bin:" .. path
    end
    hl.env("PATH", path)

    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")

    -- GPU-dependent bits. This config runs on an NVIDIA desktop and an AMD
    -- laptop; core.host reads the actual driver from sysfs, so the same files
    -- work on both. AMD needs nothing here.
    local host = require("core.host")

    if host.gpu == "nvidia" then
        -- Proprietary driver only (wiki/Nvidia). GBM_BACKEND is obsolete.
        hl.env("LIBVA_DRIVER_NAME", "nvidia")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
        hl.env("NVD_BACKEND", "direct") -- needs libva-nvidia-driver
    end

    if host.is_nvidia_card then
        -- Hardware cursor planes flicker on nouveau and on some proprietary
        -- setups. Software cursor costs nothing noticeable; drop this branch
        -- if the proprietary driver ever handles it cleanly.
        hl.config({ cursor = { no_hardware_cursors = true } })
    end
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
    hl.env("MOZ_ENABLE_WAYLAND", "1")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")
    hl.env("GDK_BACKEND", "wayland,x11")
end

return M
