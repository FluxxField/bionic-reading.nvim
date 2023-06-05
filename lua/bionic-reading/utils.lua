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

local function is_vowel(char)
	-- NOTE: y is a semi-vowel/consonant. To use or not to use?
	local vowels = { "a", "e", "i", "o", "u" }

	for _, vowel in ipairs(vowels) do
		if char == vowel then
			return true
		end
	end

	return false
end

-- NOTE: syllables are made of 3 things: onset (before vowel), nucleus (vowel), coda (after vowel)
-- We only care about the first nucleus and the preceding onset
function Utils.highlight_on_first_syllable(word)
	local vowel_clusters = { "au", "ai", "ea", "ee", "ei", "eu", "ie", "io", "oa", "oe", "oi", "oo", "ou", "ue", "ui" }
	local coda_exceptions = { "gh", "nd", "ld", "st" }

	if word == nil or word == "" then
		return 0
	end

	if #word <= 4 then
		return math.floor(#word / 2)
	end

	for cur_char_index = 1, #word do
		local substring = string.lower(word:sub(cur_char_index, cur_char_index + 1))

		for _, combination in ipairs(vowel_clusters) do
			-- a vowel cluster usually doesn't have a coda
			if substring == combination then
				if cur_char_index + 1 == #word then
					return math.floor(#word / 2)
				end

				return cur_char_index + 1
			end
		end

		local char = string.lower(word:sub(cur_char_index, cur_char_index))

		if is_vowel(char) then
			-- if the first vowel is the last letter, we dont want to highlight the whole word
			if cur_char_index == #word then
				return math.floor(#word / 2)
			end

			-- coda is the consonant(s) that follow the nucleus
			local coda = 1
			local next_char_index = cur_char_index + coda
			local next_char = string.lower(word:sub(next_char_index, next_char_index + 1))

			-- check exceptions for coda
			for _, exception in ipairs(coda_exceptions) do
				if next_char == exception then
					if next_char_index + 1 == #word then
						return cur_char_index
					end

					coda = 2
				end
			end

			return cur_char_index + coda
		end
	end
end

return Utils
