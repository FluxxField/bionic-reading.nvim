local api = vim.api

--- Highlight class
--- @class Highlight
--- @field namespace number
--- @field hl_group string
local Highlight = {
	namespace = api.nvim_create_namespace("bionic_reading"),
	hl_group = "BionicReadingHL",
}

--- Clear all highlights in current buffer by clearing namespace
--- @return nil
function Highlight:clear()
	local Buffers = require("bionic-reading.buffers")
	local bufnr = api.nvim_get_current_buf()

	Buffers:deactivate_buf(bufnr)
	api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
end

--- Highlight lines in current buffer
--- @param line_start number
--- @param line_end number
--- @return nil
function Highlight:highlight(line_start, line_end)
	local Buffers = require("bionic-reading.buffers")
	local Config = require("bionic-reading.config")

	-- default to highlight all lines
	if not line_start or not line_end then
		line_start = 0
		line_end = -1
	end

	local bufnr = api.nvim_get_current_buf()

	Buffers:activate_buf(bufnr)

	-- zero based indexing, end is exclusive
	local lines = api.nvim_buf_get_lines(bufnr, line_start, line_end, false)

	-- iterate over lines and words and highlight
	for line_index, line in ipairs(lines) do
		for word_index, word in string.gmatch(line, "()([^%s%p%d]+)") do
			local word_length = string.len(word)
			local word_length_str = tostring(word_length)
			local hl_end = 0

			-- offset tells us how many characters to highlight
			local hl_offset = Config.opts.hl_offsets[word_length_str]

			if hl_offset then
				hl_end = hl_offset
			else
				hl_end = math.floor(word_length * Config.opts.hl_offsets["default"] + 0.5)
			end

			-- cannot just use line_index because line_start is not always 0, zero based indexing
			local line_to_hl = line_start + line_index - 1
			local col_start = word_index - 1
			local col_end = col_start + hl_end

			-- Applies highlight to the word, zero based indexing
			api.nvim_buf_add_highlight(bufnr, self.namespace, self.hl_group, line_to_hl, col_start, col_end)
		end
	end
end

local function init()
	local Config = require("bionic-reading.config")

	api.nvim_set_hl(0, Highlight.hl_group, Config.opts.hl_group_value)
end

init()

return Highlight
