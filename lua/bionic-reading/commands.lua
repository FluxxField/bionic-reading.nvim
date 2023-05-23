local bionic_reading = require("bionic-reading")
local utils = require("bionic-reading.utils")
local highlighting = require("bionic-reading.highlighting")

local M = {}

local create_user_command = vim.api.nvim_create_user_command
local create_autocmd = vim.api.nvim_create_autocmd

-- user commands
function M.create_user_commands()
  create_user_command("BionicReadingToggle", function()
    local bufnr = vim.api.nvim_get_current_buf()

    if utils.check_active_buf(bufnr) then
      highlighting.clear()
    else
      highlighting.highlight()
    end
  end, {})

  create_user_command('BionicReadingUpdateInInsert', function()
    if bionic_reading.config.updateInInsert then
      bionic_reading.config.updateInInsert = false
    else
      bionic_reading.config.updateInInsert = true
    end
  end, {})
end

-- autocmds
function M.create_autocmds()
  local group = vim.api.nvim_create_augroup('bionic_reading', { clear = true })
  local fileTypes = bionic_reading.config.fileTypes

  if not vim.tbl_isempty(fileTypes) then
    create_autocmd('FileType', {
      pattern = fileTypes,
      group = group,
      callback = function(args)
        if utils.check_active_buf(args.bufnr) then
          bionic_reading.highlight()
        end
      end
    })
  end

  create_autocmd('InsertLeave', {
    pattern = '*',
    group = group,
    callback = function(args)
      if utils.check_active_buf(args.bufnr) then
        bionic_reading.highlight()
      end
    end
  })

  create_autocmd('TextChangedI', {
    pattern = '*',
    group = group,
    callback = function(args)
      if utils.check_active_buf(args.bufnr) and bionic_reading.config.updateInInsert then
        bionic_reading.highlight()
      end
    end
  })
end

return M
