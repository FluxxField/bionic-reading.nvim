local M = {}
local initialized = false

function M.setup(opts)
	if initialized then
		return
	end

	opts = opts or {}

	require("bionic-reading.config")._setup(opts)
	require("bionic-reading.cmds"):_setup()

	initialized = true
end

return M
