local M = {}
local initialized = false

--- Highlight lines in current buffer
--- @param bufnr number
--- @return nil
function M.highlight(bufnr, line_start, line_end)
	line_start = line_start or 0
	line_end = line_end or vim.api.nvim_buf_line_count(bufnr)

	require("bionic-reading.highlight").highlight(bufnr, line_start, line_end)
end

--- Clear all highlights in current buffer by clearing namespace
--- @param bufnr number
--- @return nil
function M.clear(bufnr)
	require("bionic-reading.highlight").clear(bufnr)
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

	initialized = true
end

return M
