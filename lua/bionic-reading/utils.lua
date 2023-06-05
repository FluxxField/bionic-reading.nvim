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

-- NOTE: syllables are made of 3 things: onset, nucleus, coda
-- We only care about the first nucleus (vowel) and the preceding onset (consonant/consonant cluster)
function Utils.highlight_on_first_syllable(word)
	-- NOTE: y is a semi-vowel/consonant and cannot always be considered a vowel
	local vowels = { a = true, e = true, i = true, o = true, u = true, y = true }
	local coda_exceptions = { g = true }

	if word == nil or word == "" then
		return 0
	end

	if #word <= 3 then
		return 1
	end

	for char_index = 1, #word do
		local char = string.lower(word:sub(char_index, char_index))
		local is_vowel = vowels[char] ~= nil

		-- find first vowel
		if not is_vowel then
			goto continue
		else
			-- if the first vowel is the last letter, we dont want to highlight the whole word
			if char_index == #word then
				return math.floor(#word / 2)
			end
		end

		-- coda is the consonant(s) that follow the nucleus
		local coda = 1
		local next_char_index = char_index + coda
		local next_char = string.lower(word:sub(next_char_index, next_char_index))
		local next_char_is_vowel = vowels[next_char] ~= nil

		-- vowel cluster, no coda for vowel clusters (roughly) because onsets are greedy
		if next_char_is_vowel then
			-- we dont want to highlight the whole word
			if next_char_index + coda == #word then
				return math.floor(#word / 2)
			end

			return next_char_index
		else
			if coda_exceptions[next_char] ~= nil then
				local second_coda_index = next_char_index + coda

				if string.lower(word:sub(second_coda_index, second_coda_index)) == "h" then
					coda = 2
				end
			end

			-- we dont want to highlight the whole word
			if char_index + coda == #word then
				return math.floor(#word / 2)
			end

			return char_index + coda
		end

		::continue::
	end
end

return Utils
