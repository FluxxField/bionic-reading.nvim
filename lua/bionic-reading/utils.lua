local M = { activeBuffers = {} }

function M.activate_buf(bufnr)
  M.activeBuffers[bufnr] = true
end

function M.deactiviate_buf(bufnr)
  M.activeBuffers[bufnr] = nil
end

function M.check_active_buf(bufnr)
  return M.activeBuffers[bufnr] ~= nil
end

return M
