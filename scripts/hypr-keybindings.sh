#!/bin/bash
# hypr-keybindings.sh — Display Hyprland keybindings in walker
# Dependencies: lua, walker
# Optional:     jq (monitor-height detection)

HYPR_DIR="${HOME}/.config/hypr"

# ── Lua scan: mock hl.* and extract (keys, description) pairs ─────────────────
keybindings=$(HYPR_DIR="${HYPR_DIR}" lua <<'LUA'
local hypr_dir = os.getenv("HYPR_DIR")

-- Noop proxy: absorbs any chain of index/call operations
local function noop()
  local t = {}
  return setmetatable(t, {
    __index = function() return noop() end,
    __call  = function() return noop() end,
  })
end

-- Binding collector
local bindings   = {}
local submap_ctx = nil   -- non-nil while inside a define_submap callback

local function bind_fn(keys, _, opts)
  if type(opts) ~= "table" then return end
  local desc = opts.description
  if type(desc) ~= "string" or desc == "" then return end
  local key = submap_ctx and ("(" .. submap_ctx .. ") " .. keys) or keys
  table.insert(bindings, key .. "\t" .. desc)
end

-- Mock hl global — only bind() and define_submap() are functional
hl = {
  bind           = bind_fn,
  unbind         = function() end,
  define_submap  = function(name, fn)
    submap_ctx = name
    fn()
    submap_ctx = nil
  end,
  on                    = function() end,
  get_monitors          = function() return {} end,
  get_active_workspace  = function() return nil end,
  get_active_monitor    = function() return nil end,
  get_active_window     = function() return nil end,
  get_workspace_windows = function() return {} end,
  dispatch       = function() end,
  timer          = function() end,
  config         = function() end,
  env            = function() end,
  monitor        = function() end,
  window_rule    = function() end,
  workspace_rule = function() end,
  curve          = function() end,
  animation      = function() end,
  gesture        = function() end,
  device         = function() end,
  permission     = function() end,
  exec_cmd       = function() return noop() end,
  dsp            = noop(),
  plugin         = noop(),
}

-- Override require: fall back to a noop module on any error
local _orig_require = require
require = function(mod)
  local ok, result = pcall(_orig_require, mod)
  if ok then return result end
  return setmetatable({}, {
    __index = function() return function() return noop() end end,
  })
end

package.path = hypr_dir .. "/?.lua;" .. package.path

local ok, err = pcall(dofile, hypr_dir .. "/hyprland.lua")
if not ok then
  io.stderr:write("hypr-keybindings: lua scan error: " .. tostring(err) .. "\n")
  os.exit(1)
end

for _, line in ipairs(bindings) do
  io.write(line .. "\n")
end
LUA
) || { echo "Lua scan failed" >&2; exit 1; }

if [[ -z $keybindings ]]; then
  echo "No keybindings found. Add { description = \"...\" } to hl.bind() calls." >&2
  exit 1
fi

# Compute walker window height (40% of focused monitor, fallback 1080)
monitor_height=$(hyprctl monitors -j 2>/dev/null \
  | jq -r '.[] | select(.focused == true) | .height' 2>/dev/null \
  || true)
if [[ ! $monitor_height =~ ^[0-9]+$ ]] || ((monitor_height <= 0)); then
  monitor_height=1080
fi
menu_height=$((monitor_height * 40 / 100))

# Format: left-align key combo in a 34-char column, then description
printf '%s\n' "$keybindings" \
  | awk -F'\t' '{ printf "%-34s  %s\n", $1, $2 }' \
  | walker --dmenu -p 'Keybindings…' --width 950 --height "$menu_height" > /dev/null
