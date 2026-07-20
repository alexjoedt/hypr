local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

    -- Hyprland's own PATH doesn't inherit ~/.local/bin from shell rc files
    -- (it's started before/outside the interactive shell), so binds calling
    -- commands installed there (e.g. "numbr") fail to exec silently.
    hl.env("PATH", "/home/alex/.local/bin:$PATH")

    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")

    -- NVIDIA Wayland configuration (added by nvidia-installer)
    -- Not needed on this machine (AMD GPU) — kept commented for reference
    -- in case this config is ever reused on NVIDIA hardware.
    -- hl.env("LIBVA_DRIVER_NAME", "nvidia")
    -- hl.env("GBM_BACKEND", "nvidia-drm")
    -- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    -- hl.env("NVD_BACKEND", "direct")
    -- hl.config({ cursor = { no_hardware_cursors = true } }) -- NVIDIA hw cursor workaround
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
    hl.env("MOZ_ENABLE_WAYLAND", "1")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")
    hl.env("GDK_BACKEND", "wayland,x11")
end

return M
