# bionic-reading.nvim

Togglable and customizable bionic reading for Neovim!

![demo gif](assets/bionic-reading-demo.gif)

## Features
 - No dependencies!
 - Custom highlighting amounts and highlighting style
 - Toggable update while in insert mode
 - File types restricted
 - Highlighting stays after colorscheme changes
 - Toggable auto highlighting of files when opened 
 - Uses [nvim-notify](https://github.com/rcarriga/nvim-notify) for notifications if available 
 - Now prompts to highlight file if file type is not in your config
 - Can enable/disable prompting ^
 - *NEW*: Added saccade_cadence to control how often words are highlighted
 - *NEW*: Added user command to set saccade_cadence

## TODO
- [x] Add ability to toggle auto highlighting
- [x] Add support for nvim-notify
- [x] Prompt user to highlight file IF file type is not in config
- [x] Add ability to toggle user prompt
- [ ] Investigate treesitter highlighting
- [x] Add saccade cadence
- [x] Add user command to set saccade cadence
- [ ] Add syllable algorithm
- [ ] Expose highlight and clear
- [ ] ????
- [ ] Profit (Disclosure: meme)

## Requirements

In order for the default styling to work, you will need to make sure your terminal and fonts allow for bold text.
The default styling just bolds the text. So, if your terminal is not showing bold text, it will look like the plugin
does not work

iTerm2:
```
iTerm2 -> Settings... -> Profiles -> Text -> Text Rendering -> enable "Draw bold text in bold font"
```

Terminal:
```
Terminal -> Settings... -> Profiles -> Text -> enable "Use bold fonts"
```

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

If you are happy with the default options, simply call `setup`.

Please see configuration and default options code [here](lua/bionic-reading/config.lua)

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

Config options and what they do.

Please see configuration and default options code [here](lua/bionic-reading/config.lua)

### Default 
```lua
{
  auto_highlight = true,
  file_types = { 'text' },
  hl_group_value = {
    link = "Bold",
  },
  hl_offsets = {
    ['1'] = 1,
    ['2'] = 1,
    ['3'] = 2,
    ['4'] = 2,
    ['default'] = 0.4,
  },
  prompt_user = true,
	saccade_cadence = 1,
  update_in_insert_mode = true,
}
```

### auto_highlight

```lua
auto_highlight = true,
```

A flag used to control if a file is automatically highlighted on `FileType` and `BufEnter`.

Please see [Autocmds](#Autocmds) below for more info

### file_types

```lua
file_types = { 'text' },
```

This is a table of file types that bionic-reading will highlight automatically if enabled

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

This table is used to determine the number of characters of a word to highlight based on length.

And word lengths no explicitly defined default to 0.4 (unless overridden). Value must be between 0 and 1.
This represents how much of the word to highlight as a percentage. For example 0.3 highlights 30% of the word,
0.4 highlights 40%, etc.

### prompt_user

```lua
prompt_user = true,
```

Flag used to dictate if the user is prompted when attempting to highlight a file not in `file_types`

### saccade_cadenc

```
saccade_cadence = 1,
```

Used to control how often a word is highlighted. A cadence of 1 means every word.
A cadence of 2 means every other word. So on and so forth

### update_in_insert_mode

```lua
update_in_insert_mode = true,
```

Flag used to dictate whether or not to update in insert mode

Please see [Autocmds](#Autocmds) below for more info

## Commands

bionic-reading provides several user commands.

Please see autocmd code [here](lua/bionic-reading/cmds.lua)

- `:BRToggle` toggles the current buffers highlighting, will prompt to highlight current file
  if the file is not in configs
- `:BRToggleUpdateInsertMode` toggles the update_in_insert_mode flag
- `:BRToggleAutoHighlight` toggles the auto_highlight flag
- `:BRSaccadeCadence {num}` used to set saccade_cadence outside of the config

## Autocmds

autocmd group name is `bionic_reading`. Creates the `BionicReadingHL` highlight group on ColorScheme change.

Please see autocmd code [here](lua/bionic-reading/cmds.lua)

- `ColorScheme` - Applies bionic reading highlighting on buffer open if the buffer is in file_types
- `FileType` - Applies highlighting to buffer when the file type changes or the buffer is entered 
- `TextChanged` - Applies highlight to buf when the text changes (past and delete)
- `TextChangedI` - Applies highlighting to current line while in insert mode

## Insperation

Thank you to JellyApple102 and nullchilly for foundation. Because of them I was able create my own plugin with help and insperation from them

[easyread.nvim](https://github.com/JellyApple102/easyread.nvim)

[fsread.nvim](https://github.com/nullchilly/fsread.nvim)

## PLEASE NOTE

This plugin was created with the purpose to learn Nvim, lua, and how to create a plugin. This is not a new idea. See Insperation above
