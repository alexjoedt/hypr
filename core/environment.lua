local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")

    -- NVIDIA Wayland configuration (added by nvidia-installer)
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("GBM_BACKEND", "nvidia-drm")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")
    hl.config({ cursor = { no_hardware_cursors = true } })
end

return M
