local Config = {}

local defaults = {
  file_types = { "text" },
  update_in_insert = true,
  hl_group_value = {
    link = "Bold",
  },
  hl_offsets = {
    ["1"] = 1,
    ["2"] = 1,
    ["3"] = 2,
    ["4"] = 2,
    ["default"] = 0.4,
  },
}

local function init()
  local bionic_reading = require("bionic-reading")

  Config = vim.tbl_deep_extend("keep", bionic_reading._config or {}, defaults)

  vim.validate({
    file_types = { Config.file_types, "table" },
    update_in_insert = { Config.update_in_insert, "boolean" },
    hl_group_value = { Config.hl_group_value, "table" },
    hl_offsets = { Config.hl_offsets, "table" },
  })

  bionic_reading._config = nil
end

init()

return Config
