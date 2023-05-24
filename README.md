# bionic-reading.nvim

Toggable bionic reading in Neovim.

## Features
 - Custom highlighting amounts (hl_offsets) and highlighting style (hl_group_value)
 - Toggable update while in insert mode (Default on)
 - File types restricted ('text')
 - Highlighting stays after colorscheme changes
 - Automatic highlighting of files when opened 

## Installation

Install your favorite package manager.

Example with [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'FluxxField/bionic-reading.nvim',
}
```

Example with [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'FluxxField/bionic-reading.nvim',
}
```

## Configuration

If you are happy with the default options, simply call `setup`

```lua
-- example using lazy.nvim
{
  'FluxxField/bionic-reading.nvim',
  config = function()
    require('bionic-reading').setup()
  end,
}
```

## Options

Config options and what they do

### Default 
```lua
{
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
```

### hl_offsets

```lua
hl_offsets = {
  ['1'] = 1,
  ['2'] = 1,
  ['3'] = 2,
  ['4'] = 2,
  ['default'] = 0.4,
}
```

This table is used to determin the number of characters of a word to highlight based on length.

And word lengths no explicitly defined default to 0.4 (unless overridden). Value must be between 0 and 1.
This represents how much of the word to highlight as a percentage. For example 0.3 highlights 30% of the word,
0.4 highlights 40%, ect.

### hl_group_value

```lua
hl_group_value = {
  link = "Bold",
},
```

This table is used as the value passed to `nvim_set_hl()` as the `{val}` parameter.
Please see `:help nvim_set_hl()` for details

The highlight group created is called `BionicReadingHL`

By default the highlight group is linked to the highlight group `Bold`

NOTE
- If your current font does not have bold version, the highlighting will not work by default
  since all it does is bold the first few characters
- If you use the link property, no other properties will be used

```lua
-- Example: Makes background 'red', and text 'blue' & bold
hl_group_value = {
  bg: 'red',
  fg: 'blue',
  bold = true,
},
```

### file_types

```lua
file_types = { 'text' },
```

This is a table of file types that bionic-reading with highlight

### update_in_insert

```lua
update_in_insert = true,
```

Flag used to dictate wether or not to update in insert mode

## Commands

bionic-reading provides several user commands

- `:BRToggle` toggles the current buffers highlighting
- `:BRToggleUpdateInInsert` toggles the update_in_insert flag

## Autocmds

autocmd group name is `bionic_reading`

Creates the `BionicReadingHL` highlight group on ColorScheme change

```lua
create_autocmd('ColorScheme', {
  pattern = '*',
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, M.hl_group, config.options.hl_group_value)
  end
})
```

Applies bionic reading highlighting on buffer open if the buffer is in file_types

```lua
create_autocmd('FileType', {
  pattern = file_types,
  group = group,
  callback = function(args)
    if M.check_active_buf(args.buf) then
      return
    end

    M.highlight(0, -1)
  end,
})
```

Applies highlighting to buffer when text is changed. Grabs position of pasted code to highlight

```lua
create_autocmd('TextChanged', {
  pattern = '*',
  group = group,
  callback = function(args)
    if not M.check_active_buf(args.buf) or not require('bionic-reading.utils').check_file_types() then
      return
    end

    local line_start = vim.fn.getpos("'[")[2] - 1
    local line_end = vim.fn.getpos("']")[2]

    M.highlight(line_start, line_end)
  end,
})
```

Applies highlighting to current line while in insert mode

```lua
create_autocmd('TextChangedI', {
  pattern = '*',
  group = group,
  callback = function(args)
    if not M.check_active_buf(args.buf) or not config.options.update_in_insert or not require('bionic-reading.utils').check_file_types() then
      return
    end

    local line_start = vim.api.nvim_win_get_cursor(0)[1]

    M.highlight(line_start - 1, line_start)
  end
})
```

## Insperation

Thank you to JellyApple102 and nullchilly for foundation. Because of them I was able create my own plugin with help and insperation from them

[easyread.nvim](https://github.com/JellyApple102/easyread.nvim)
[fsread.nvim](https://github.com/nullchilly/fsread.nvim)

## PLEASE NOTE

This plugin was created with the purpose to learn Nvim, lua, and how to create a plugin. This is not a new idea. See Insperation above
