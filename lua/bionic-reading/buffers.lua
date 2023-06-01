local Buffers = {
  active = {},
}

function Buffers:activate_buf(bufnr)
  self.active[bufnr] = true
end

function Buffers:deactivate_buf(bufnr)
  self.active[bufnr] = nil
end

function Buffers:check_active_buf(bufnr)
  return self.active[bufnr] ~= nil
end

return Buffers
