local Utils = require("bionic-reading.utils")

local api = vim.api

--- Highlight class
--- @module Highlight
local Highlight = {
	hl_group = "BionicReadingHL",
	namespace = api.nvim_create_namespace("bionic_reading")
}


--- Apply highlighting to buffer
--- @param bufnr number
--- @param line_start number
--- @param line_end number
--- @return nil
local function _apply_highlighting(bufnr, line_start, line_end)
	bufnr = bufnr or api.nvim_get_current_buf()
	line_start = line_start or 0
	line_end = line_end or api.nvim_buf_line_count(bufnr)

	local lines = api.nvim_buf_get_lines(bufnr, line_start, line_end, false)

	for line_index, line in ipairs(lines) do
		for word_index, word in string.gmatch(line, "()([^%s%p%d]+)") do
			local line_to_hl = line_start + line_index - 1
			local col_start = word_index - 1
			local col_end = col_start

			col_end = col_start + Utils.highlight_on_first_syllable(word)

			api.nvim_buf_add_highlight(bufnr, Highlight.namespace, Highlight.hl_group, line_to_hl, col_start, col_end)
		end
	end
end

--- Highlight buffer using treesitter
--- @param bufnr number
--- @param line_start number
--- @param line_end number
--- @return boolean true if treesitter parser is available, false otherwise
local function _treesitter_highlight(bufnr, line_start, line_end)
	local Config = require("bionic-reading.config")

	bufnr = bufnr or api.nvim_get_current_buf()
	line_start = line_start or 0
	line_end = line_end or vim.api.nvim_buf_line_count(bufnr)

	local ok = pcall(vim.treesitter.get_parser, bufnr)

	if not ok then
		return false
	end

	-- pos is 0-indexed
	local root = vim.treesitter.get_node({ bufnr = bufnr, pos = { line_start, line_end } })

	if not root then
		return false
	end

	-- Make sure we have the top-level node
	if line_start == 0 and line_end == vim.api.nvim_buf_line_count(bufnr) then
		local parent = root:parent()

		while parent do
			root = parent
			parent = parent:parent()
		end
	end

	local filetype_node_types = Config.opts.file_types[vim.bo.filetype]

	-- Early return, if node_type is 'any' then highlight to line_end
	if type(filetype_node_types) == 'string' and filetype_node_types == 'any' then
		_apply_highlighting(bufnr, line_start, line_end);

		return true
	end

	Utils.navigate_tree(root, function(node)
		for _, node_type in ipairs(filetype_node_types) do
			if node_type == 'any' or node_type == node:type() then
				local row_start = node:range()

				_apply_highlighting(bufnr, row_start, row_start + 1)
			end
		end
	end)

	return true
end

--- Clear all highlights in current buffer by clearing namespace
--- @param bufnr number
--- @return nil
function Highlight.clear(bufnr)
	local Buffers = require("bionic-reading.buffers")

	bufnr = bufnr or api.nvim_get_current_buf()

	Buffers:deactivate_buf(bufnr)
	api.nvim_buf_clear_namespace(bufnr, Highlight.namespace, 0, -1)
end

--- Highlight lines in current buffer
--- @param bufnr number
--- @param line_start number
--- @param line_end number
--- @return nil
function Highlight.highlight(bufnr, line_start, line_end)
	local Config = require("bionic-reading.config")
	local Buffers = require("bionic-reading.buffers")
	local ok = false

	bufnr = bufnr or api.nvim_get_current_buf()
	line_start = line_start or 0
	line_end = line_end or api.nvim_buf_line_count(bufnr)

	Buffers:activate_buf(bufnr)

	if Config.opts.treesitter then
		ok = _treesitter_highlight(bufnr, line_start, line_end)

		if ok then
			return
		end
	end

	-- If treesitter is not enabled or it failed to highlight, fallback to regex
	if not ok then
		_apply_highlighting(bufnr, line_start, line_end)
	end
end

local function init()
	local Config = require("bionic-reading.config")

	api.nvim_set_hl(0, Highlight.hl_group, Config.opts.hl_group_value)
end

init()

return Highlight
