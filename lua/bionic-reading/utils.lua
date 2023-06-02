--- Utils module
--- @module Utils
--- @usage local Utils = require("bionic-reading.utils")
local Utils = {}

--- Check if file type is correct
--- @return boolean
function Utils.check_file_types()
	local Config = require("bionic-reading.config")
	local correct_file_type = false

	for _, file_type in ipairs(Config.opts.file_types) do
		if vim.bo.filetype == file_type then
			correct_file_type = true
			break
		end
	end

	return correct_file_type
end

--- Send notification using nvim-notify, fallback to print
--- @param content string
--- @param type string
--- @param fallback string
--- @return nil
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

--- Handles user input from prompt
--- @param input string
--- @return boolean
function Utils.prompt_answer(input)
	if input == "y" or input == "Y" or input == "Yes" or input == "YES" then
		return true
	end

	return false
end

return Utils
