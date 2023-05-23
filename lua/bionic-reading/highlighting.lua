local bionic_reading = require("bionic-reading")
local utils = require("bionic-reading.utils")

local M = {}

local get_current_buf = vim.api.nvim_get_current_buf

function M.clear()
  local bufnr = get_current_buf()

  utils.deactiviate_buf(bufnr)

  vim.api.nvim_buf_clear_namespace(bufnr, bionic_reading.namespace, 0, -1)
end

function M.highlight()
  M.clear()

  local bufnr = get_current_buf()

  utils.activate_buf(bufnr)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, line in ipairs(lines) do
    for s, w in string.gmatch(line, '()([^%s%p$d]+)') do
      local length = string.len(w)
      local stringLength = tostring(length)
      local toHL = 0
      local hlValues = bionic_reading.hlValues

      if hlValues[stringLength] then
        toHL = hlValues[stringLength]
      else
        toHL = math.floor(length * hlValues['default'] + 0.5)
      end

      vim.api.nvim_buf_add_highlight(bufnr, bionic_reading.namespace, bionic_reading.hlGroup, i - 1, s - 1, s - 1 + toHL)
    end
  end
end

return M
