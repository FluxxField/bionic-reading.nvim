local has_notify, notify = pcall(require, "notify")
local Config = require("bionic-reading.config")
local Highlight = require("bionic-reading.highlight")
local Buffers = require("bionic-reading.buffers")
local Utils = require("bionic-reading.utils")

local create_user_command = vim.api.nvim_create_user_command
local get_current_buf = vim.api.nvim_get_current_buf
local create_autocmd = vim.api.nvim_create_autocmd

local CMDS = {
  group = vim.api.nvim_create_augroup("bionic_reading", { clear = true }),
}

local function init()
  local file_types = Config.file_types

  if vim.tbl_isempty(file_types) then
    file_types = { "*" }
  end

  -- autocmds
  create_autocmd("ColorScheme", {
    pattern = "*",
    group = CMDS.group,
    callback = function()
      vim.api.nvim_set_hl(0, Highlight.hl_group, Config.hl_group_value)
    end,
  })

  create_autocmd("FileType", {
    pattern = file_types,
    group = CMDS.group,
    callback = function(args)
      if Buffers.check_active_buf(args.buf) then
        return
      end

      Highlight:highlight(0, -1)
    end,
  })

  create_autocmd("TextChanged", {
    pattern = "*",
    group = CMDS.group,
    callback = function(args)
      if not Buffers.check_active_buf(args.buf) or not Utils.check_file_types() then
        return
      end

      -- getpos returns an array of [bufnr, lnum, col, off], 1 based indexing
      local line_start = vim.fn.getpos("'[")[2] - 1
      local line_end = vim.fn.getpos("']")[2]

      Highlight:highlight(line_start, line_end)
    end,
  })

  create_autocmd("TextChangedI", {
    pattern = "*",
    group = CMDS.group,
    callback = function(args)
      if
          not Buffers.check_active_buf(args.buf)
          or not Config.update_in_insert
          or not Utils.check_file_types()
      then
        return
      end

      -- nvim_win_get_cursor returns an array of [lnum, col], 1 based indexing
      local line_start = vim.api.nvim_win_get_cursor(0)[1]

      Highlight:highlight(line_start - 1, line_start)
    end,
  })

  -- user commands
  create_user_command("BRToggle", function()
    local bufnr = get_current_buf()
    if not Utils.check_file_types() then
      if has_notify then
        notify.notify(
          "Cannot highlight current buffer.\nPlease add file type to your config if you would like to",
          "error",
          {
            title = "BionicReading",
          }
        )
      else
        print("BionicReading: Cannot highlight current buffer. Please add file type to config")
      end

      return
    end

    if has_notify then
      notify.notify("bionic-reading toggled", "info", {
        title = "BionicReading",
      })
    end

    if Buffers:check_active_buf(bufnr) then
      Highlight:clear()
    else
      Highlight:highlight()
    end
  end, {})

  create_user_command("BRToggleUpdateInInsert", function()
    if Config.update_in_insert then
      Config.update_in_insert = false
    else
      Config.update_in_insert = true
    end
  end, {})
end

init()

return CMDS
