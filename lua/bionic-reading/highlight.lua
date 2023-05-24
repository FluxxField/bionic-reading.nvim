local config = require('bionic-reading.config')

local get_current_buf = vim.api.nvim_get_current_buf
local create_user_command = vim.api.nvim_create_user_command
local create_autocmd = vim.api.nvim_create_autocmd


local M = {
  active_buffers = {},
  namespace = vim.api.nvim_create_namespace('bionic_reading'),
  hl_group = "BionicReadingHL"
}

function M.activate_buf(bufnr)
  M.active_buffers[bufnr] = true
end

function M.deactiviate_buf(bufnr)
  M.active_buffers[bufnr] = nil
end

function M.check_active_buf(bufnr)
  return M.active_buffers[bufnr] ~= nil
end

function M.clear()
  local bufnr = get_current_buf()

  M.deactiviate_buf(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

function M.highlight()
  local bufnr = get_current_buf()

  M.activate_buf(bufnr)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for line_index, line in ipairs(lines) do
    for word_index, word in string.gmatch(line, '()([^%s%p%d]+)') do
      local word_length = string.len(word)
      local word_length_str = tostring(word_length)
      local hl_end = 0

      local hl_offset = config.options.hl_offsets[word_length_str]

      if hl_offset then
        hl_end = hl_offset
      else
        hl_end = math.floor(word_length * config.options.hl_offsets['default'] + 0.5)
      end

      local line_start = line_index - 1
      local col_start = word_index - 1
      local col_end = word_index - 1 + hl_end

      vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hl_group, line_start, col_start, col_end)
    end
  end
end

function M.highlight_line(bufnr, line_index, line)
  if not bufnr or not line_index or not line then
    return
  end

  for word_index, word in string.gmatch(line, '()([^%s%p%d]+)') do
    local word_length = string.len(word)
    local word_length_str = tostring(word_length)
    local hl_end = 0

    local hl_offset = config.options.hl_offsets[word_length_str]

    if hl_offset then
      hl_end = hl_offset
    else
      hl_end = math.floor(word_length * config.options.hl_offsets['default'] + 0.5)
    end

    local line_start = line_index - 1
    local col_start = word_index - 1
    local col_end = word_index - 1 + hl_end

    vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hl_group, line_start, col_start, col_end)
  end
end

local group = vim.api.nvim_create_augroup('bionic_reading', { clear = true })
local file_types = config.options.file_types

if vim.tbl_isempty(file_types) then
  file_types = "*"
end

-- autocmds
create_autocmd('ColorScheme', {
  pattern = '*',
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, M.hl_group, config.options.hl_group_value)
  end
})

create_autocmd('FileType', {
  pattern = file_types,
  group = group,
  callback = function(args)
    if not M.check_active_buf(args.buf) then
      return
    end

    M.highlight()
  end
})

-- create_autocmd('InsertLeave', {
--   pattern = '*',
--   group = group,
--   callback = function(args)
--     if not M.check_active_buf(args.buf) then
--       return
--     end
--
--     M.highlight()
--   end
-- })

create_autocmd('TextChangedI', {
  pattern = '*',
  group = group,
  callback = function(args)
    if not M.check_active_buf(args.buf) or not config.options.update_in_insert then
      return
    end

    local col = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(args.buf, col - 1, col, false)[1]

    M.highlight_line(args.buf, col, line)
  end
})

-- user commands
create_user_command("BRToggle", function()
  local bufnr = get_current_buf()
  if not require("bionic-reading.utils").check_file_types() then
    if vim.fn.exists("g:loaded_notify") == 1 then
      require("notify")("Not a valid filetype. Please add file type to your config", "error", {
        title = "BionicReading",
      })
    else
      print("BionicReading: Not a valid filetype. Please add file type to config")
    end
    return
  end

  if M.check_active_buf(bufnr) then
    M.clear()
  else
    M.highlight()
  end
end, {})

create_user_command('BRToggleUpdateInInsert', function()
  if config.options.update_in_insert then
    config.options.update_in_insert = false
  else
    config.options.update_in_insert = true
  end
end, {})

return M
