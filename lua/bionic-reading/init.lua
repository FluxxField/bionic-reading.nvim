local utils = require('bionic-reading.utils')
local commands = require('bionic-reading.commands')

local M = {}

M.config = {
  fileTypes = { 'text' },
  updateInInsert = true,
  hlGroupOptions = { link = 'Bold' },
  hlValues = {
    ['default'] = 0.4
  }
}

function M.setup(config)
  -- config
  utils.check_config(config)
  M.config = vim.tbl_deep_extend('force', M.config, config or {})

  -- buffers
  M.activeBuffers = {}

  -- highlights
  M.hlGroup = "BionicReadingHL"
  M.namespace = vim.api.nvim_create_namespace('bionic-reading')
  vim.api.nvim_set_hl(0, M.hlGroup, M.config.hlGroupOptions)

  -- commands
  commands.create_user_commands()
  commands.create_autocmds()
end

return M
