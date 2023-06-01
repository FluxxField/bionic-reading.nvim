local M = {}

local defaults = {
  file_types = { 'text' },
  update_in_insert = true,
  hl_group_value = {
    link = "Bold",
  },
  hl_offsets = {
    ['1'] = 1,
    ['2'] = 1,
    ['3'] = 2,
    ['4'] = 2,
    ['default'] = 0.4,
  }
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

function M.extend(opts)
  M.options = vim.tbl_deep_extend("force", M.options or defaults, opts or {})
end

M.setup()

return M
