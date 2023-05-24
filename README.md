# bionic-reading.nvim

Toggable bionic reading in Neovim.

## Features
 - Custom highlighting amounts (hl_offsets) and style (hl_group_value)
 - Will update while in insert mode (Default on)
 - Default file types ('Text')

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

- Default Values 
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

 - `hl_offsets`

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

- `hl_group_value`

```lua
hl_group_value = {
  link = "Bold",
},
```

This table is used as the value passed to `nvim_set_hl()` as the `{val}` parameter.
Please see `:help nvim_set_hl()` for details

The highlight group created is called `BionicReadingHL`

By default the highlight group is linked to the highlight group `Bold`

NOTE -
- If your current font does not have bold version, the highlighting will not work by default
  since all it does is bold the first few characters
- If you use link, no other properties will be used

- `file_types`

```lua
file_types = { 'text' },
```

This is a table of file types that bionic-reading with highlight

- `update_in_insert`

```lua
update_in_insert = true,
```

Flag used to dictate wether or not to update in insert mode

## Commands

bionic-reading provides several user commands

- `:BRToggle` toggles the current buffers highlighting
- `:BRToggleUpdateInInsert` toggles the update_in_insert flag

## PLEASE NOTE

This is a simple plugin that I am using as a way to learn Vim, Lua and how to make NVIM plugins. Any tips/tricks/help would be appriciated.

Thank you,
FluxxField
