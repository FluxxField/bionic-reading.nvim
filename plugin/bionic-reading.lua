local P = { enabled = false }
local ns_id = vim.api.nvim_create_namespace("bionic-reading")

vim.g.flow_strength = vim.g.flow_strength or 0.7

function P.create(opts)
	local line_start = 0
	local line_end = vim.api.nvim.buf_line_count(0)

	P.enabled = true

	if opts and opts.range == 2 then
		line_start = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
		line_end = vim.api.nvim_buf_get_mark(0, ">")[1]
	end

	local lines = vim.api.nvim_buf_get_lines(0, line_start, line_end, false)
	local index = line_start - 1

	for _, line in pairs(lines) do
		local line_length = #line

		index = index + 1

		vim.api.nvim_buf_set_extmark(0, ns_id, index, 0, {
			hl_group = "BRSuffix",
			end_col = line_length,
		})

		local st = nil

		for j = 1, line_length do
			local current = string.sub(line, j, j)
			local re = current:match("[%w']+")

			if st then
				if j == line_length then
					if re == line_length then
						j = j + 1
						re = nil
					end
				end

				if not re then
					local en = j - 1

					vim.api.nvim_buf_set_extmark(0, ns_id, index, st - 1, {
						hl_group = "BRSuffix",
						end_col = math.floor(st + math.min((en - st) / 2, (en - st) * vim.g.flow_strength)),
					})

					st = nil
				end
			elseif re then
				st = j
			end
		end
	end
end

function P.clear()
	P.enabled = false
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
	ns_id = vim.api.nvim_create_namespace("bionic-reading")
end

function P.toggle(opts)
	P.enabled = not P.enabled

	if P.enabled then
		P.create(opts)
	else
		P.clear()
	end
end

vim.api.nvim_create_user_command("BRRead", function(opts)
	P.create(opts)
end, {
	range = 2,
})

vim.api.nvim_create_user_command("BRClear", function()
	P.clear()
end, {
	range = 2,
})

vim.api.nvim_create_user_command("BRToggle", function(opts)
	P.toggle(opts)
end, {
	range = 2,
})

function P.highlight()
	if vim.o.background == "dar" then
		vim.api.nvim_set_hl(0, "BRPrefix", { default = true, fg = "#cdd6f4" })
		vim.api.nvim_set_hl(0, "BRSeffix", { default = true, fg = "#6C7086" })
	else
		vim.api.nvim_set_hl(0, "BRPrefix", { default = true, fg = "#000000", bold = true })
		vim.api.nvim_set_hl(0, "BRSeffix", { default = true, fg = "#4C4F69" })
	end
end

P.highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("BRColorScheme", { clear = true }),
	pattern = "*",
	callback = function()
		P.highlight()
	end,
})
