local M = {}

function M.setup()
    hl.config({
        plugin = {
            -- hyprexpo = {
            --     columns = 3,
            --     gaps_in = 5,
            --     gaps_out = 0,
            --     bg_col = "rgb(111111)",
            --     workspace_method = "center current",
            --     gesture_distance = 200,
            --     cancel_key = "escape",
            --     show_cursor = 1,
            --     keynav_enable = 1,
            -- },
            scrolloverview = {
                gesture_distance = 200,
                scale = 0.5,
                workspace_gap = 50,
                layout = "vertical",
            },
        },
    })

    -- hl.define_submap("hyprexpo", function()
    -- hl.bind("left",      function() hl.plugin.hyprexpo.kb_focus("left") end)
    -- hl.bind("right",      function() hl.plugin.hyprexpo.kb_focus("right") end)
    -- hl.bind("up",      function() hl.plugin.hyprexpo.kb_focus("up") end)
    -- hl.bind("down",      function() hl.plugin.hyprexpo.kb_focus("down") end)
    -- hl.bind("return", function() hl.plugin.hyprexpo.kb_confirm() end)
    -- hl.bind("escape", function() hl.plugin.hyprexpo.expo("cancel") end)
    -- end)

    hl.define_submap("scrolloverview", function()
        hl.bind("left",   hl.plugin.scrolloverview.navigate("left"))
        hl.bind("right",  hl.plugin.scrolloverview.navigate("right"))
        hl.bind("up",     hl.plugin.scrolloverview.navigate("up"))
        hl.bind("down",   hl.plugin.scrolloverview.navigate("down"))
        hl.bind("return", function()
            hl.plugin.scrolloverview.window("select")
            hl.plugin.scrolloverview.overview("off")
        end)
        hl.bind("escape", hl.plugin.scrolloverview.overview("off"))
    end)
end

return M
