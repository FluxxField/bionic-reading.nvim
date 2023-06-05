--- Config module for bionic-reading.nvim
--- @module Config
--- @usage local Config = require("bionic-reading.config")
local Config = {}

--- Default configuration options
--- @class defaults
--- @field auto_highlight (boolean) Enable/disable auto-highlighting
--- @field file_types (table) File types to enable auto-highlighting
--- @field hl_group_value (table) Highlight group value
--- @field hl_offsets (table) Highlight offsets
--- @field prompt_user (boolean) Enable/disable prompting user
--- @field saccade_cadence (number) Saccade cadence
--- @field update_in_insert_mode (boolean) Enable/disable updating in insert mode
--- @field use_syllable_algorithm (boolean) Enable/disable syllable algorithm
local defaults = {
	auto_highlight = true,
	file_types = { "text" },
	hl_group_value = {
		link = "Bold",
	},
	hl_offsets = {
		["1"] = 1,
		["2"] = 1,
		["3"] = 2,
		["4"] = 2,
		["default"] = 0.4,
	},
	prompt_user = true,
	saccade_cadence = 1,
	update_in_insert_mode = true,
	syllable_algorithm = true, -- BETA
}

--- Setup bionic-reading.nvim configuration
--- @param opts table
--- @return nil
function Config._setup(opts)
	local hl_group_value = opts.hl_group_value

	opts.hl_group_value = nil

	Config.opts = vim.tbl_deep_extend("keep", opts or {}, defaults)

	-- explicitly set the highlight group value to make sure link is not kept
	-- link overrides everything
	if type(hl_group_value) == "table" then
		Config.opts.hl_group_value = hl_group_value
	end

	vim.validate({
		auto_highlight = { Config.opts.auto_highlight, "boolean" },
		file_types = { Config.opts.file_types, "table" },
		hl_group_value = { Config.opts.hl_group_value, "table" },
		hl_offsets = { Config.opts.hl_offsets, "table" },
		prompt_user = { Config.opts.prompt_user, "boolean" },
		saccade_cadence = { Config.opts.saccade_cadence, "number" },
		update_in_insert_mode = { Config.opts.update_in_insert_mode, "boolean" },
		syllable_algorithm = { Config.opts.syllable_algorithm, "boolean" },
	})
end

--- Update bionic-reading.nvim configuration
--- @param key string|table
--- @param value any
--- @return boolean
function Config._update(key, value)
	local Utils = require("bionic-reading.utils")

	if Config.opts[key] == nil then
		local content = "Invalid key: " .. key

		Utils.notify(content, "error", content)

		return false
	end

	if type(key) == "table" then
		if type(value) ~= "table" then
			local content = "Value must be a table"

			Utils.notify(content, "error", content)

			return false
		end

		Config.opts[key] = vim.tbl_deep_extend("keep", value, Config.opts[key])
	else
		Config.opts[key] = value
	end

	vim.validate({
		key = { Config.opts[key], type(Config.opts[key]) },
	})

	return true
end

return Config
