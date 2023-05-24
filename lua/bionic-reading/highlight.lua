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

-- highlight
-- Highlights words in the current buffer, dictated by line_start and line_end
--
-- @param line_start number
-- @param line_end number
-- @return void
--
-- TODO: refactor to account for col_start/end? Instead of just line
function M.highlight(line_start, line_end)
  -- default to highlight all lines
  if not line_start or not line_end then
    line_start = 0
    line_end = -1
  end

  local bufnr = get_current_buf()

  M.activate_buf(bufnr)

  -- zero based indexing, end is exclusive
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_start, line_end, false)

  -- iterate over lines and words and highlight
  for line_index, line in ipairs(lines) do
    for word_index, word in string.gmatch(line, '()([^%s%p%d]+)') do
      local word_length = string.len(word)
      local word_length_str = tostring(word_length)
      local hl_end = 0

      -- offset tells us how many characters to highlight
      local hl_offset = config.options.hl_offsets[word_length_str]

      if hl_offset then
        hl_end = hl_offset
      else
        hl_end = math.floor(word_length * config.options.hl_offsets['default'] + 0.5)
      end

      -- cannot just use line_index becuase line_start is not always 0, zero based indexing
      local line_to_hl = line_start + line_index - 1
      local col_start = word_index - 1
      local col_end = col_start + hl_end

      -- Applies highlight to the word, zero based indexing
      vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hl_group, line_to_hl, col_start, col_end)
    end
  end
end

local group = vim.api.nvim_create_augroup('bionic_reading', { clear = true })
local file_types = config.options.file_types

if vim.tbl_isempty(file_types) then
  file_types = { "*" }
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
    if M.check_active_buf(args.buf) then
      return
    end

    M.highlight()
  end,
})

create_autocmd('TextChanged', {
  pattern = '*',
  group = group,
  callback = function(args)
    if not M.check_active_buf(args.buf) or not require('bionic-reading.utils').check_file_types() then
      return
    end

    -- getpos returns an array of [bufnr, lnum, col, off], 1 based indexing
    local line_start = vim.fn.getpos("'[")[2] - 1
    local line_end = vim.fn.getpos("']")[2]

    M.highlight(line_start, line_end)
  end,
})

create_autocmd('TextChangedI', {
  pattern = '*',
  group = group,
  callback = function(args)
    if not M.check_active_buf(args.buf) or not config.options.update_in_insert or not require('bionic-reading.utils').check_file_types() then
      return
    end

    -- nvim_win_get_cursor returns an array of [lnum, col], 1 based indexing
    local line_start = vim.api.nvim_win_get_cursor(0)[1]

    M.highlight(line_start - 1, line_start)
  end
})

-- user commands
create_user_command("BRToggle", function()
  local bufnr = get_current_buf()
  if not require("bionic-reading.utils").check_file_types() then
    print("BionicReading: Cannot highlight current buffer. Please add file type to config")

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
