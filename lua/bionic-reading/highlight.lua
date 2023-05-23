local utils = require("bionic-reading.utils")

local M = {}

local get_current_buf = vim.api.nvim_get_current_buf
local create_user_command = vim.api.nvim_create_user_command
local create_autocmd = vim.api.nvim_create_autocmd
local namespace = vim.api.nvim_create_namespace('bionic-reading')
local hlGroup = "BionicReadingHL"

function M.insert_highlights(opts)
  vim.api.nvim_set_hl(0, hlGroup, opts.hlGroupOptions)
end

function M.clear()
  local bufnr = get_current_buf()

  utils.deactiviate_buf(bufnr)

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end

function M.highlight()
  M.clear()

  local bufnr = get_current_buf()

  utils.activate_buf(bufnr)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    for s, w in string.gmatch(line, '()([^%s%p$d]+)') do
      local length = string.len(w)
      local stringLength = tostring(length)
      local toHL = 0
      local hlValues = defaults.hlValues

      if hlValues[stringLength] then
        toHL = hlValues[stringLength]
      else
        toHL = math.floor(length * hlValues['default'] + 0.5)
      end

      vim.api.nvim_buf_add_highlight(bufnr, namespace, hlGroup, i - 1, s - 1, s - 1 + toHL)
    end
  end
end

function M.create_autocmds(opts)
  local group = vim.api.nvim_create_augroup('bionic_reading', { clear = true })
  local fileTypes = opts.fileTypes

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
      if utils.check_active_buf(args.bufnr) and opts.updateInInsert then
        M.highlight()
      end
    end
  })
end

create_user_command("BionicReadingToggle", function()
  local bufnr = get_current_buf()

  if utils.check_active_buf(bufnr) then
    M.clear()
  else
    M.highlight()
  end
end, {})


return M
