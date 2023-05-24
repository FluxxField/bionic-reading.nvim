local utils = require("bionic-reading.utils")

local create_user_command = vim.api.nvim_create_user_command
local get_current_buf = vim.api.nvim_get_current_buf
local create_autocmd = vim.api.nvim_create_autocmd

local M = {}

M.namespace = vim.api.nvim_create_namespace('bionic_reading')
M.hl_group = "BionicReadingHL"

function M.insert_highlights()
  local config = require("bionic-reading.config")

  if (vim.fn.hlexists(M.hl_group) == 1) then
    return
  end

  vim.api.nvim_set_hl(0, M.hl_group, config.options.hl_group_options)
end

function M.clear()
  local bufnr = get_current_buf()
  utils.deactiviate_buf(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

function M.highlight()
  local config = require("bionic-reading.config")

  M.clear()

  local bufnr = get_current_buf()

  utils.activate_buf(bufnr)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for line_index, line in ipairs(lines) do
    for word_index, word in string.gmatch(line, '()([^%s%p%d]+)') do
      local word_length = string.len(word)
      local word_length_str = tostring(word_length)
      local toHl = 0

      if config.options.hl_values[word_length_str] then
        toHl = config.options.hl_values[word_length_str]
      else
        toHl = math.floor(word_length * config.options.hl_values['default'] + 0.5)
      end

      local line_start = line_index - 1
      local col_start = word_index - 1
      local col_end = word_index - 1 + toHl

      vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.hl_group, line_start, col_start, col_end)
    end
  end
end

function M.create_autocmds()
  local config = require("bionic-reading.config")
  local group = vim.api.nvim_create_augroup('bionic_reading', { clear = true })
  local fileTypes = config.options.file_types

  if not vim.tbl_isempty(fileTypes) then
    create_autocmd('FileType', {
      pattern = fileTypes,
      group = group,
      callback = function(args)
        if utils.check_active_buf(args.bufnr) then
          M.highlight()
        end
      end
    })
  end

  create_autocmd('InsertLeave', {
    pattern = '*',
    group = group,
    callback = function(args)
      if utils.check_active_buf(args.bufnr) then
        M.highlight()
      end
    end
  })

  create_autocmd('TextChangedI', {
    pattern = '*',
    group = group,
    callback = function(args)
      if utils.check_active_buf(args.bufnr) and config.options.update_in_insert then
        M.highlight()
      end
    end
  })
end

function M.create_user_commands()
  local config = require("bionic-reading.config")

  create_user_command("BionicReadingToggle", function()
    local bufnr = get_current_buf()
    local correctFileType = false

    for _, fileType in ipairs(config.options.file_types) do
      if vim.bo.filetype == fileType then
        correctFileType = true
        break
      end
    end

    if not correctFileType then
      print("BionicReading: Not a valid filetype. Please add to config")
      return
    end

    if utils.check_active_buf(bufnr) then
      M.clear()
    else
      M.highlight()
    end
  end, {})

  create_user_command('BionicReadingUpdateInInsert', function()
    if config.options.update_in_insert then
      config.options.update_in_insert = false
    else
      config.options.update_in_insert = true
    end
  end, {})
end

M.insert_highlights()
M.create_autocmds()
M.create_user_commands()

return M
