local defaults = require('bionic-reading.defaults')
local highlight = require('bionic-reading.highlight')

local M = { opts = {} }

local create_user_command = vim.api.nvim_create_user_command

function M.check_opts(opts)
  if not opts then
    return
  end

  if opts.fileTypes then
    defaults.fileTypes = {}
  end
end

function M.setup(opts)
  -- config
  M.check_opts(opts)
  M.opts = setmetatable(opts or {}, { __index = M.opts })

  highlight.insert_highlights(M.opts)
  highlight.create_autocmds(M.opts)
end

create_user_command('BionicReadingUpdateInInsert', function()
  if M.opts.updateInInsert then
    M.opts.updateInInsert = false
  else
    M.opts.updateInInsert = true
  end
end, {})

return M
