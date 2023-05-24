local M = { active_buffers = {} }

function M.activate_buf(bufnr)
  M.active_buffers[bufnr] = true
end

function M.deactiviate_buf(bufnr)
  M.active_buffers[bufnr] = nil
end

function M.check_active_buf(bufnr)
  return M.active_buffers[bufnr] ~= nil
end

return M
