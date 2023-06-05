# bionic-reading.nvim

Togglable and customizable bionic reading for Neovim using syllable based highlighting!

## What is BionicReading?

`bionic-reading.nvim` is a simple but powerful Neovim plugin designed to improve
reading and writing efficiency. By highlighting the first syllable of each word,
it aims to aid comprehension and to highlight on logical sections of the code

### Syllable Algorithm

One of the standout features of `bionic-reading.nvim` is its innovative syllable
algorithm. I developed this algorithm from scratch, drawing inspiration from
linguistic studies and natural language processing techniques. The result is a
fairly precise method for  identifying syllables within words, enabling accurate
highlighting of their initial sounds

Read more below in [Why Syllable Highlighting] (#why-syllable-highlighting)

![demo gif](assets/bionic-reading-demo.gif)

## BionicReading Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Customization](#customization)
- [Mappings](#mappings)
- [Vim Commands](#vim-commands)
- [TODO](#todo)
- [Why Syllable Highlighting](#why-syllable-highlighting)

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
 - *NEW*: Can now use a syllable algorithm to highlight the first syllable in a word

## Getting Started

This section should guide you to getting your plugin up and running!

### Requirements

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

Install your favorite package manager

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'FluxxField/bionic-reading.nvim',
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'FluxxField/bionic-reading.nvim',
}
```

## Usage

Try the command `:BRToggle` to see if `bionic-reading.nvim` is installed correctly.

## Customization 

This section should help you explore the available options you have to configure
and customize `bionic-reading.nvim`.

### BionicReading setup structure

Example using lazy.nvim 

```lua
{
	'FlexxField/bionic-reading.nvim',
	config = function()
		require('bionic-reading').setup({
		  -- determines if the file types below will be
		  -- automatically highlighted on buffer open
			auto_highlight = true,
			-- the file types you want to highlight
			file_types = { 'text' },
			-- the highlighting styles applied
			-- IMPORTANT - if link is present, no other
			-- styles are applied
			hl_group_value = {
				link = "Bold",
			},
			-- dictates the characters highlighted based
			-- off of word length. key is word length and
			-- value is the number of characters highlighted
			hl_offsets = {
				['1'] = 1,
				['2'] = 1,
				['3'] = 2,
				['4'] = 2,
				['default'] = 0.4, -- defaults to 40% of the word
			},
			-- Flag used to control if the user is prompted
			-- if BRToggle is called on a file type that is not
			-- explicitly defined above
			prompt_user = true,
			-- The cadence of highlight word. Defaults to ever
			-- word. Example: 2 would be every other word
			saccade_cadence = 1,
			-- Flag used to control if the highlighting is
			-- applied while typing
			update_in_insert_mode = true,
			-- Flag used to dicate if the syllable_algorithm
			-- is used. Highlights on syllables instead of 
			-- characters based on word length
			syllable_algorithm = true,
		})
	end,
}
```

## Mappings

No mapping are added. Feel free to map as you would like

## Vim Commands

bionic-reading provides several user commands.

Please see autocmd code [here](lua/bionic-reading/cmds.lua)

```viml
" Toggle bionic reading highlighting for the current buffer
" Will prompt you if run on a file type no in the config
:BRToggle

" Toggle the update_in_insert_mode flag
:BRToggleUpdateInsertMode

" Toggles the auto_highlight flag
:BRToggleAutoHighlight

" Used to set the saccade_cadence
:BRSaccadeCadence

" Toggles the syllable_algorithm flag
:BRToggleSyllableAlgorithm
```

## TODO
- [x] Add ability to toggle auto highlighting
- [x] Add support for nvim-notify
- [x] Prompt user to highlight file IF file type is not in config
- [x] Add ability to toggle user prompt
- [ ] Investigate treesitter highlighting
- [x] Add saccade cadence
- [x] Add user command to set saccade cadence
- [x] Add syllable algorithm
- [x] Expose highlight and clear
- [ ] ????
- [ ] Profit (Disclosure: meme)

## Why Syllable Highlighting

- **Enhanced Word Recognition**: Syllable highlighting helps break down words
into smaller, more manageable units. By focusing on the first syllable,
your eyes can quickly recognize and process the core of each word. This
can be especially beneficial when dealing with long or unfamiliar terms.

- **Improved Pronunciation**: In many languages, pronunciation rules are often
tied to syllable boundaries. By highlighting the first syllable,
bionic-reading assists with proper pronunciation. It guides your eyes to
the starting point of each word, helping you sound out the syllables more
accurately.

- **Pattern Identification**: Identifying patterns in language is essential for
learning, writing, and editing. When you see words with the same highlighted
syllables clustered together, it becomes easier to identify patterns and
repetitions. This visual cue can be particularly useful for proofreading and
making stylistic improvements in your writing.

- **Mental Chunking**: Chunking is a cognitive process where information is grouped
into meaningful units. Highlighting syllables aids in chunking, allowing your
brain to process and remember words more efficiently. By breaking down words
into syllables, your mind can focus on smaller segments, making it easier to
understand and retain information.

- **Code Readability**: When working with programming languages, developers often
encounter complex variable names, function names, and class names. Highlighting
the first syllable of these identifiers can help distinguish between similar
terms, making code more readable and reducing the chances of errors caused by
confusion or misinterpretation.
