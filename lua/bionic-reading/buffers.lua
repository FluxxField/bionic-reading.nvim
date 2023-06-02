--- Buffers module
--- @module Buffers
--- @usage local Buffers = require("bionic-reading.buffers")
local Buffers = {
	_active = {},
}

--- Activate buffer
--- @param bufnr number
--- @return nil
function Buffers:activate_buf(bufnr)
	self._active[bufnr] = true
end

--- Deactivate buffer
--- @param bufnr number
--- @return nil
function Buffers:deactivate_buf(bufnr)
	self._active[bufnr] = nil
end

--- Check if buffer is active
--- @param bufnr number
--- @return boolean
function Buffers:check_active_buf(bufnr)
	return self._active[bufnr] ~= nil
end

return Buffers
