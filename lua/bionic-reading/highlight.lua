local Config = require("bionic-reading.config")
local Buffers = require("bionic-reading.buffers")

local get_current_buf = vim.api.nvim_get_current_buf

local Highlight = {
	namespace = vim.api.nvim_create_namespace("bionic_reading"),
	hl_group = "BionicReadingHL",
}

function Highlight:clear()
	local bufnr = get_current_buf()

	Buffers.deactiviate_buf(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
end

-- highlight
-- Highlights words in the current buffer, dictated by line_start and line_end
--
-- @param line_start number
-- @param line_end number
-- @return void
--
-- TODO: refactor to account for col_start/end? Instead of just line
function Highlight:highlight(line_start, line_end)
	-- default to highlight all lines
	if not line_start or not line_end then
		line_start = 0
		line_end = -1
	end

	local bufnr = get_current_buf()

	Buffers:activate_buf(bufnr)

	-- zero based indexing, end is exclusive
	local lines = vim.api.nvim_buf_get_lines(bufnr, line_start, line_end, false)

	-- iterate over lines and words and highlight
	for line_index, line in ipairs(lines) do
		for word_index, word in string.gmatch(line, "()([^%s%p%d]+)") do
			local word_length = string.len(word)
			local word_length_str = tostring(word_length)
			local hl_end = 0

			-- offset tells us how many characters to highlight
			local hl_offset = Config.hl_offsets[word_length_str]

			if hl_offset then
				hl_end = hl_offset
			else
				hl_end = math.floor(word_length * Config.hl_offsets["default"] + 0.5)
			end

			-- cannot just use line_index because line_start is not always 0, zero based indexing
			local line_to_hl = line_start + line_index - 1
			local col_start = word_index - 1
			local col_end = col_start + hl_end

			-- Applies highlight to the word, zero based indexing
			vim.api.nvim_buf_add_highlight(bufnr, self.namespace, self.hl_group, line_to_hl, col_start, col_end)
		end
	end
end

return Highlight
