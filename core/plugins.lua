local M = {}

function M.setup()
    local function loaded(name)
        return hl.plugin ~= nil and hl.plugin[name] ~= nil
    end

    local opts = {}
    if loaded("scrolloverview") then
        opts.scrolloverview = {
            gesture_distance = 200,
            scale = 0.5,
            workspace_gap = 50,
            layout = "vertical",
        }
    end
    if loaded("alttab") then
        opts.alttab = {
            release_key = "Alt_L",
            include_special = 0,
            animations = 1,
        }
    end
    if next(opts) then
        hl.config({ plugin = opts })
    end

    -- hl.define_submap("hyprexpo", function()
    -- hl.bind("left",      function() hl.plugin.hyprexpo.kb_focus("left") end)
    -- hl.bind("right",      function() hl.plugin.hyprexpo.kb_focus("right") end)
    -- hl.bind("up",      function() hl.plugin.hyprexpo.kb_focus("up") end)
    -- hl.bind("down",      function() hl.plugin.hyprexpo.kb_focus("down") end)
    -- hl.bind("return", function() hl.plugin.hyprexpo.kb_confirm() end)
    -- hl.bind("escape", function() hl.plugin.hyprexpo.expo("cancel") end)
    -- end)

    local function so(fn, ...)
        local args = { ... }
        return function()
            local p = hl.plugin and hl.plugin.scrolloverview
            if p and p[fn] then
                p[fn](table.unpack(args))
            end
        end
    end

    hl.define_submap("scrolloverview", function()
        hl.bind("left", so("navigate", "left"))
        hl.bind("right", so("navigate", "right"))
        hl.bind("up", so("navigate", "up"))
        hl.bind("down", so("navigate", "down"))
        hl.bind("return", function()
            local p = hl.plugin and hl.plugin.scrolloverview
            if p then
                p.window("select")
                p.overview("off")
            end
        end)
        hl.bind("escape", so("overview", "off"))
    end)
end

return M
