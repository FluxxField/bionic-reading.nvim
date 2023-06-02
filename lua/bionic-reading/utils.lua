local Config = require("bionic-reading.config")

local Utils = {}

function Utils.check_file_types()
	local correct_file_type = false

	for _, file_type in ipairs(Config.opts.file_types) do
		if vim.bo.filetype == file_type then
			correct_file_type = true
			break
		end
	end

	return correct_file_type
end

function Utils.notify(content, type, fallback)
	local has_notify, notify = pcall(require, "notify")
	local title = "Bionic Reading"

	if has_notify then
		notify.notify(content, type, {
			title = title,
		})
	elseif fallback then
		print(title .. ": " .. fallback)
	end
end

return Utils
