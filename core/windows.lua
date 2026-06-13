local M = {}

-- ─── Single-window auto-centering ────────────────────────────────────────────
-- Adjust these two values to control how a lone tiled window is inset.
-- On an ultrawide monitor, raise left_right_gap (e.g. 600–800) so the window
-- doesn't stretch across the full 21:9 width.
local top_bottom_gap = 20   -- vertical inset (px) from the monitor edge
local left_right_gap = 450  -- horizontal inset (px); increase for ultrawides
-- ─────────────────────────────────────────────────────────────────────────────

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
    -- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

    -- "w[t1]" selects any workspace that currently contains exactly ONE tiled
    -- window ("t" = tiled, "1" = count of one).  The rule is dynamic: it
    -- applies when the count reaches one and is removed when a second tiled
    -- window appears, so normal multi-window gaps are restored automatically.
    -- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/#workspace-selectors
    hl.workspace_rule({
        workspace = "w[t1]",
        gaps_out  = {
            top    = top_bottom_gap,
            right  = left_right_gap,
            bottom = top_bottom_gap,
            left   = left_right_gap,
        },
    })

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
