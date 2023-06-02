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

return Config
