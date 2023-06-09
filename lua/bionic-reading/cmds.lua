local Highlight = require("bionic-reading.highlight")
local Utils = require("bionic-reading.utils")

local get_current_buf = vim.api.nvim_get_current_buf

--- Commands module
--- @module CMDS
local CMDS = {}

--- highlight on colorscheme change
--- @return nil
function CMDS._set_hl_on_colorscheme()
	local Config = require("bionic-reading.config")

	vim.api.nvim_set_hl(0, Highlight.hl_group, Config.opts.hl_group_value)
end

--- highlight on file type change
--- @return nil
function CMDS._highlight_on_filetype()
	local Buffers = require("bionic-reading.buffers")
	local Config = require("bionic-reading.config")
	local bufnr = get_current_buf()

	-- if buffer is active, we have already highlighted the file
	if Buffers:check_active_buf(bufnr) or not Utils.check_file_types() or not Config.opts.auto_highlight then
		return
	end

	Highlight.highlight(bufnr, 0, vim.api.nvim_buf_line_count(bufnr))
end

--- highlight on text changed
--- @return nil
function CMDS._highlight_on_textchanged()
	local Buffers = require("bionic-reading.buffers")
	local Config = require("bionic-reading.config")
	local bufnr = get_current_buf()

	if not Buffers:check_active_buf(bufnr) or not Utils.check_file_types() or not Config.opts.update_in_insert_mode then
		return
	end

	-- getpos returns an array of [bufnr, lnum, col, off], 1 based index
	local line_start = vim.fn.getpos("'[")[2] - 1
	local line_end = vim.fn.getpos("']")[2]

	Highlight.highlight(bufnr, line_start, line_end)
end

--- highlight on text changed in insert mode
--- @return nil
function CMDS._highlight_on_textchangedI()
	local Buffers = require("bionic-reading.buffers")
	local Config = require("bionic-reading.config")
	local bufnr = get_current_buf()

	if not Buffers:check_active_buf(bufnr) or not Config.opts.update_in_insert_mode or not Utils.check_file_types() then
		return
	end

	-- nvim_win_get_cursor returns an array of [lnum, col], 1 based indexing
	local line_start = vim.api.nvim_win_get_cursor(0)[1] - 1
	local line_end = line_start + 1

	Highlight.highlight(bufnr, line_start, line_end)
end

--- toggle highlighting
--- @return nil
function CMDS._toggle()
	local Config = require("bionic-reading.config")
	local Buffers = require("bionic-reading.buffers")
	local bufnr = get_current_buf()

	-- check if file type is in config
	if not Utils.check_file_types() then
		local input = "n"

		-- Prompt user if we can
		if Config.opts.prompt_user then
			input = vim.fn.input("Would you like to highlight the current file type? (y/n): ")
		end

		-- If user does not want to highlight current file type, return
		if not Utils.prompt_answer(input) then
			Utils.notify(
				"Cannot highlight current buffer.\nPlease add file type to your config if you would like to",
				"error",
				""
			)

			return
		else
			-- Add file type to config
			Config._update("file_types", { [vim.bo.filetype] = { "any" } })
		end
	end

	if Buffers:check_active_buf(bufnr) then
		Utils.notify("BionicReading disabled", "info", "")
		Highlight.clear(bufnr)
	else
		Utils.notify("BionicReading enabled", "info", "")
		Highlight.highlight(bufnr, 0, vim.api.nvim_buf_line_count(bufnr))
	end
end

--- toggle update in insert mode
--- @return nil
function CMDS._toggle_update_insert_mode()
	local Config = require("bionic-reading.config")
	local new_value = not Config.opts.update_in_insert_mode

	local success = Config._update("update_in_insert_mode", new_value)

	if success then
		Utils.notify("Update while in insert mode is now " .. (new_value and "enabled" or "disabled"), "info", "")
	end
end

--- toggle auto highlight
--- @return nil
function CMDS._toggle_auto_highlight()
	local Config = require("bionic-reading.config")
	local new_value = not Config.opts.auto_highlight

	local success = Config._update("auto_highlight", new_value)

	if success then
		Utils.notify("Auto highlight is now " .. (new_value and "enabled" or "disabled"), "info", "")
	end
end

return CMDS
