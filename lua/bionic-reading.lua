local M = {}
local initialized = false

function M.highlight(...)
  require("bionic-reading.highlight").highlight(...)
end

function M.clear()
  require("bionic-reading.highlight").clear()
end

function M.setup(opts)
  if initialized then
    return
  end

  opts = opts or {}

  M._config = opts
  initialized = true
end

return M
