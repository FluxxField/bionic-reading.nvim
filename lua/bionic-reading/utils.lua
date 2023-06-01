local config = require("bionic-reading.config")

local M = {}

function M.check_file_types()
  local correct_file_type = false

  for _, file_type in ipairs(config.options.file_types) do
    if vim.bo.filetype == file_type then
      correct_file_type = true
      break
    end
  end

  return correct_file_type
end

return M
