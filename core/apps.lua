local M = {}

local defaultApps = {
    firefox = {
        cmd = "firefox",
        class = "firefox",
    },
}

local state = {
    mainMod = "SUPER",
    apps = defaultApps,
}

local function resolveSpec(appName)
    local key = tostring(appName)
    local spec = state.apps[key]

    if spec then
        return {
            name = spec.name or key,
            cmd = spec.cmd or key,
            class = spec.class,
            classPattern = spec.classPattern,
        }
    end

    return {
        name = key,
        cmd = key,
        class = key,
    }
end

local function inWorkspace(win, workspace)
    if workspace == nil then
        return true
    end

    local ws = win.workspace
    if type(ws) == "table" then
        if ws.id ~= nil then
            return tonumber(ws.id) == tonumber(workspace)
        end
        if ws.name ~= nil then
            return tostring(ws.name) == tostring(workspace)
        end
    end

    return tostring(ws) == tostring(workspace)
end

local function matchesClass(win, spec)
    local class = tostring(win.class or "")

    if spec.classPattern then
        return class:match(spec.classPattern) ~= nil
    end

    local expected = tostring(spec.class or spec.name or "")
    return class:lower() == expected:lower()
end

local function findWindow(spec, workspace)
    local fallback

    for _, win in ipairs(hl.get_windows()) do
        if matchesClass(win, spec) then
            if inWorkspace(win, workspace) then
                return win
            end
            fallback = fallback or win
        end
    end

    return fallback
end

function M.focusOrLaunch(appName, workspace)
    local spec = resolveSpec(appName)
    local win = findWindow(spec, workspace)

    if win and win.address then
        hl.dispatch(hl.dsp.focus({ window = "address:" .. win.address }))
        hl.dispatch(hl.dsp.window.bring_to_top())
        return
    end

    if workspace ~= nil then
        hl.dispatch(hl.dsp.focus({ workspace = workspace }))
    end

    hl.dispatch(hl.dsp.exec_cmd(spec.cmd))
end

function M.startOrFocus(appName, workspace, key)
    if key == nil then
        M.focusOrLaunch(appName, workspace)
        return
    end

    local keyName = tostring(key):upper()
    local description = "Start or focus " .. tostring(appName)
    if workspace ~= nil then
        description = description .. " (workspace " .. tostring(workspace) .. ")"
    end

    hl.bind(state.mainMod .. " + " .. keyName, function()
        M.focusOrLaunch(appName, workspace)
    end, { description = description })
end

function M.setup(opts)
    opts = opts or {}

    state.mainMod = opts.mainMod or "SUPER"
    state.apps = opts.apps or defaultApps

    -- Example: startOrFocus("firefox", 3, "f")
    M.startOrFocus("firefox", 3, "f")
end

return M
