local M = {}
local initialized = false

--- Highlight lines in current buffer
--- @param line_start number
--- @param line_end number
--- @param bufnr number
--- @return nil
function M.highlight(line_start, line_end, bufnr)
	require("bionic-reading.highlight"):highlight(line_start, line_end, bufnr)
end

--- Clear all highlights in current buffer by clearing namespace
--- @param line_start number
--- @param line_end number
--- @param bufnr number
--- @return nil
function M.clear(line_start, line_end, bufnr)
	require("bionic-reading.highlight"):clear(line_start, line_end, bufnr)
end

--- Setup bionic-reading.nvim
--- @param opts table
--- @return nil
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
