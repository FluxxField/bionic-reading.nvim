local bionic_reading = require("bionic-reading")

local M = {}

function M.check_config(config)
  if config.fileTypes then
    M.config.fileTypes = {}
  end
end

function M.activate_buf(bufnr)
  bionic_reading.activeBuffers[bufnr] = true
end

function M.deactiviate_buf(bufnr)
  bionic_reading.activeBuffers[bufnr] = nil
end

function M.check_active_buf(bufnr)
  return bionic_reading.activeBuffers[bufnr] ~= nil
end

return M
