local Config = {}

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
	update_in_insert_mode = true,
}

function Config._setup(opts)
	Config.opts = vim.tbl_deep_extend("keep", opts or {}, defaults)

	vim.validate({
		auto_highlight = { Config.opts.auto_highlight, "boolean" },
		file_types = { Config.opts.file_types, "table" },
		hl_group_value = { Config.opts.hl_group_value, "table" },
		hl_offsets = { Config.opts.hl_offsets, "table" },
		update_in_insert_mode = { Config.opts.update_in_insert_mode, "boolean" },
	})
end

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
