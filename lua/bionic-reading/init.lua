local config = require("bionic-reading.config")
require("bionic-reading.highlight")

local M = {}

function M.setup(opts)
  config.extend(opts)
end

return M
