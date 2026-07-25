-- core/kb_toggle/init.lua — toggle keyboard between EurKEY QWERTZ and de
local M = {}

local EURKEY_FILE = "/home/alex/.config/hypr/eurkey_qwertz.xkb"
local OPTIONS = "caps:escape"

-- In-memory; resets to eurkey on Hyprland restart / config reload.
local state = {
	layout = "eurkey",
}

local function apply_eurkey()
	hl.config({
		input = {
			kb_file = EURKEY_FILE,
			kb_layout = "",
			kb_options = OPTIONS,
		},
	})
end

local function apply_de()
	hl.config({
		input = {
			kb_file = "",
			kb_layout = "de",
			kb_options = OPTIONS,
		},
	})
end

function M.toggle()
	if state.layout == "eurkey" then
		state.layout = "de"
		apply_de()
		hl.exec_cmd("notify-send 'Keyboard' 'Layout: de (German)'")
	else
		state.layout = "eurkey"
		apply_eurkey()
		hl.exec_cmd("notify-send 'Keyboard' 'Layout: EurKEY QWERTZ'")
	end
end

return M
