local Highlight = require("bionic-reading.highlight")
local Utils = require("bionic-reading.utils")

local create_user_command = vim.api.nvim_create_user_command
local get_current_buf = vim.api.nvim_get_current_buf
local create_autocmd = vim.api.nvim_create_autocmd

--- Commands class
--- @class CMDS
--- @field group number
local CMDS = {
	group = vim.api.nvim_create_augroup("bionic_reading", { clear = true }),
}

--- Setup commands
--- @return nil
function CMDS:_setup()
	create_autocmd("ColorScheme", {
		pattern = "*",
		group = self.group,
		callback = function()
			local Config = require("bionic-reading.config")

			vim.api.nvim_set_hl(0, Highlight.hl_group, Config.opts.hl_group_value)
		end,
	})

	create_autocmd({ "FileType", "BufEnter" }, {
		pattern = "*",
		group = self.group,
		callback = function(args)
			local Buffers = require("bionic-reading.buffers")
			local Config = require("bionic-reading.config")

			if Buffers:check_active_buf(args.buf) or not Utils.check_file_types() or not Config.opts.auto_highlight then
				return
			end

			Highlight:highlight(0, -1)
		end,
	})

	create_autocmd("TextChanged", {
		pattern = "*",
		group = self.group,
		callback = function(args)
			local Buffers = require("bionic-reading.buffers")

			if not Buffers:check_active_buf(args.buf) or not Utils.check_file_types() then
				return
			end

			-- getpos returns an array of [bufnr, lnum, col, off], 1 based indexing
			local line_start = vim.fn.getpos("'[")[2] - 1
			local line_end = vim.fn.getpos("']")[2]

			Highlight:highlight(line_start, line_end)
		end,
	})

	create_autocmd("TextChangedI", {
		pattern = "*",
		group = self.group,
		callback = function(args)
			local Config = require("bionic-reading.config")
			local Buffers = require("bionic-reading.buffers")

			if
					not Buffers:check_active_buf(args.buf)
					or not Config.opts.update_in_insert
					or not Utils.check_file_types()
			then
				return
			end

			-- nvim_win_get_cursor returns an array of [lnum, col], 1 based indexing
			local line_start = vim.api.nvim_win_get_cursor(0)[1]

			Highlight:highlight(line_start - 1, line_start)
		end,
	})

	create_user_command("BRToggle", function()
		local Config = require("bionic-reading.config")
		local Buffers = require("bionic-reading.buffers")
		local bufnr = get_current_buf()

		if not Utils.check_file_types() then
			local input = vim.fn.input("Would you like to highlight the current file type? (y/n): ")

			if not Utils.prompt_answer(input) then
				Utils.notify(
					"Cannot highlight current buffer.\nPlease add file type to your config if you would like to",
					"error"
				)

				return
			else
				Config._update("file_types", { vim.bo.filetype })
			end
		end

		Utils.notify("BionicReading toggled", "info")

		if Buffers:check_active_buf(bufnr) then
			Highlight:clear()
		else
			Highlight:highlight(0, -1)
		end
	end, {})

	create_user_command("BRToggleUpdateInsertMode", function()
		local Config = require("bionic-reading.config")
		local new_value = not Config.opts.update_in_insert_mode

		local success = Config._update("update_in_insert_mode", new_value)

		if success then
			Utils.notify("Update while in insert mode is now " .. (new_value and "enabled" or "disabled"), "info")
		end
	end, {})

	create_user_command("BRToggleAutoHighlight", function()
		local Config = require("bionic-reading.config")
		local new_value = not Config.opts.auto_highlight

		local success = Config._update("auto_highlight", new_value)

		if success then
			Utils.notify("Auto highlight is now " .. (new_value and "enabled" or "disabled"), "info")
		end
	end, {})
end

return CMDS
