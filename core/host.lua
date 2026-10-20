local M = {}

-- Machine-dependent facts, read from sysfs/procfs at config-parse time.
-- Keep this the only place in the config that branches on hardware —
-- everything else adapts at runtime instead (monitor width in
-- core/windows, eDP-1 presence in core/monitors, …).

local function exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- "nvidia" = proprietary driver, "nouveau" = open driver on the same cards.
-- Both want the software cursor; only the proprietary one wants the env vars.
M.gpu = (exists("/proc/driver/nvidia/version") and "nvidia")
	or (exists("/sys/module/nouveau/initstate") and "nouveau")
	or (exists("/sys/module/amdgpu/initstate") and "amdgpu")
	or "unknown"

M.is_nvidia_card = M.gpu == "nvidia" or M.gpu == "nouveau"

return M
