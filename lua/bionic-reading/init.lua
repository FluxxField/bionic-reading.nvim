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

	local Config = require("bionic-reading.config")
	local Highlight = require("bionic-reading.highlight")
	local CMDS = require("bionic-reading.cmds")
	local Buffers = require("bionic-reading.buffers")

	Config._setup(opts)

	-- Set highlight group
	vim.api.nvim_set_hl(0, Highlight.hl_group, Config.opts.hl_group_value)

	-- Register autocmds
	local augroup = vim.api.nvim_create_augroup("bionic_reading", { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		pattern = "*",
		callback = function()
			CMDS._set_hl_on_colorscheme()
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = "*",
		callback = function()
			CMDS._highlight_on_filetype()
		end,
	})

	vim.api.nvim_create_autocmd("TextChanged", {
		group = augroup,
		pattern = "*",
		callback = function()
			vim.defer_fn(function()
				CMDS._highlight_on_textchanged()
			end, 0)
		end,
	})

	vim.api.nvim_create_autocmd("TextChangedI", {
		group = augroup,
		pattern = "*",
		callback = function()
			CMDS._highlight_on_textchangedI()
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = augroup,
		pattern = "*",
		callback = function(args)
			Buffers:deactivate_buf(args.buf)
		end,
	})

	-- Register user commands
	vim.api.nvim_create_user_command("BRToggle", function()
		CMDS._toggle()
	end, {})

	vim.api.nvim_create_user_command("BRToggleUpdateInsertMode", function()
		CMDS._toggle_update_insert_mode()
	end, {})

	vim.api.nvim_create_user_command("BRToggleAutoHighlight", function()
		CMDS._toggle_auto_highlight()
	end, {})

	initialized = true
end

return M
