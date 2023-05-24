local config = require("bionic-reading.config")
local highlight = require("bionic-reading.highlight")

local M = {}

function M.setup(opts)
  config.extend(opts)

  highlight.insert_highlights()
  highlight.create_autocmds()
  highlight.create_user_commands()
end

return M
