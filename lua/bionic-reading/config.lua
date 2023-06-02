local Config = {}

local defaults = {
	file_types = { "text" },
	update_in_insert = true,
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
}

function Config._setup(opts)
	Config.opts = vim.tbl_deep_extend("keep", opts or {}, defaults)

	vim.validate({
		file_types = { Config.opts.file_types, "table" },
		update_in_insert = { Config.opts.update_in_insert, "boolean" },
		hl_group_value = { Config.opts.hl_group_value, "table" },
		hl_offsets = { Config.opts.hl_offsets, "table" },
	})
end

function Config._update_file_types(value)
	Config.opts.file_types = vim.tble_extend("keep", value, Config.opts.file_types)

	vim.validate({
		file_types = { Config.opts.file_types, "table" },
	})
end

function Config._update(key, value)
	local notify = require("bionic-reading.utils")

	if Config.opts[key] == nil then
		local content = "Invalid key: " .. key

		notify(content, "warn", content)
	end

	if type(key) == "table" then
		if type(value) ~= "table" then
			local content = "Value must be a table"

			notify(content, "warn", content)
		end

		Config.opts[key] = vim.tbl_deep_extend("keep", value, Config.opts[key])
	else
		Config.opts[key] = value
	end

	vim.validate({
		key = { Config.opts[key], type(Config.opts[key]) },
	})
end

return Config
