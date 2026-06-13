local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
    -- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

    -- Example window rule
    -- hl.window_rule({ match = { class = "kitty", title = "kitty" }, float = true })
    hl.workspace_rule({ workspace = "1", layout = "scrolling" }) -- no gaps on workspace 1
    -- Ignore maximize requests from apps. You'll probably like this.
    -- hl.window_rule({
    --     name  = "suppress-maximize-events",
    --     match = { class = ".*" },
    --     suppress_event = "maximize",
    -- })

    -- Fix some dragging issues with XWayland
    -- hl.window_rule({
    --     name  = "fix-xwayland-drags",
    --     match = {
    --         class      = "^$",
    --         title      = "^$",
    --         xwayland   = true,
    --         float      = true,
    --         fullscreen = false,
    --         pin        = false,
    --     },
    --     no_focus = true,
    -- })
end

return M
