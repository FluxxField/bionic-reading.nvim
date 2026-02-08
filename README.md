```
    __    _             _                                ___                          _
   / /_  (_)___  ____  (_)____      ________  ____ _____/ (_)___  ____ _  ____ _   __(_)___ ___
  / __ \/ / __ \/ __ \/ / ___/_____/ ___/ _ \/ __ `/ __  / / __ \/ __ `/ / __ \ | / / / __ `__ \
 / /_/ / / /_/ / / / / / /__/_____/ /  /  __/ /_/ / /_/ / / / / / /_/ / / / / / |/ / / / / / / /
/_.___/_/\____/_/ /_/_/\___/     /_/   \___/\__,_/\__,_/_/_/ /_/\__, (_)_/ /_/|___/_/_/ /_/ /_/
                                                               /____/
```

Toggleable and customizable bionic reading for Neovim using syllable-based highlighting and TreeSitter.

![demo gif](assets/bionic-reading-demo.gif)

> Font: [VictorMono](https://rubjo.github.io/victor-mono/) | Config: [AstroNvim](https://astronvim.com/) with [my setup](https://github.com/FluxxField/astro_config)

## What is bionic reading?

Bionic reading is a technique that highlights the beginning of each word to guide your eyes through text faster. Your brain fills in the rest of each word automatically, improving reading speed and comprehension.

`bionic-reading.nvim` uses a custom syllable algorithm to determine how much of each word to highlight (up to 60% of the word length), giving more natural results than a fixed character count. Combined with TreeSitter, you get fine-grained control over *what* gets highlighted — only comments, only strings, or the entire file.

## Features

- No dependencies
- Syllable-based highlighting with a custom algorithm
- TreeSitter integration — highlight specific node types per filetype
- Toggleable auto-highlighting on file open
- Toggleable insert-mode updates
- Customizable highlight style (bold, italic, underline, color, etc.)
- Persistent highlighting across colorscheme changes
- Prompts before highlighting unlisted filetypes (can be disabled)
- Optional [nvim-notify](https://github.com/rcarriga/nvim-notify) support

## Requirements

The default style uses **bold** text. Make sure your terminal and font support bold rendering, or the highlighting will be invisible.

<details>
<summary>Terminal-specific settings</summary>

**iTerm2:** Settings → Profiles → Text → Text Rendering → enable "Draw bold text in bold font"

**Terminal.app:** Settings → Profiles → Text → enable "Use bold fonts"

</details>

## Installation

Install with your preferred package manager. You **must** call `setup()` for the plugin to work.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'FluxxField/bionic-reading.nvim',
  config = function()
    require('bionic-reading').setup()
  end,
}
```

### [mini.deps](https://github.com/echasnovski/mini.deps)

```lua
MiniDeps.add('FluxxField/bionic-reading.nvim')
require('bionic-reading').setup()
```

## Configuration

All options shown below are the defaults. You only need to include values you want to change.

```lua
require('bionic-reading').setup({
  -- Automatically highlight matching filetypes when a buffer is opened
  auto_highlight = true,

  -- Filetypes to highlight and which TreeSitter node types to target.
  -- Use "any" to highlight everything, or a list of node type names.
  file_types = {
    ["text"] = "any",
    ["lua"] = {
      "comment",
    },
  },

  -- Highlight style passed to nvim_set_hl() (see :help nvim_set_hl)
  hl_group_value = {
    bold = true,
  },

  -- Prompt before highlighting a filetype not listed above
  prompt_user = true,

  -- Use TreeSitter to scope highlighting (falls back to regex if unavailable)
  treesitter = true,

  -- Update highlights as you type in insert mode
  update_in_insert_mode = true,
})
```

### TreeSitter

TreeSitter lets you target specific node types per filetype. For example, the default config only highlights `comment` nodes in Lua files, leaving code untouched.

You can use any valid TreeSitter node type name for your language. To find available node types, use `:InspectTree` on a file.

You need the language parser installed for TreeSitter to work:

```vim
:TSInstall lua
```

If TreeSitter is enabled but no parser is available for the current buffer, the plugin falls back to regex-based highlighting automatically.

## Syllable Algorithm

Most bionic reading tools take a shortcut: bold the first N characters of every word (typically half). This produces awkward results — `**str**ing` splits mid-syllable, `**thro**ugh` bolds into the vowel cluster, and short words like `**t**he` barely get touched.

`bionic-reading.nvim` uses a custom syllable detection algorithm instead. It analyzes the actual structure of each word — onset, nucleus, and coda — to find where the first syllable ends, then highlights up to that point.

### How it works

1. **Short words** (1-4 characters) use a simple half-length rule since syllable boundaries aren't meaningful at that scale.
2. **Vowel cluster detection** — The algorithm recognizes 15 common vowel pairs (`ea`, `ou`, `ai`, `oo`, etc.) and treats them as a single nucleus. This keeps clusters like the `eau` in "beautiful" or the `ou` in "through" from being split.
3. **Consonant/vowel classification** — Each character is classified to locate the first nucleus. The letter `y` gets special handling: it's a consonant at the start of a word ("**y**ellow") but a vowel when it doesn't precede another vowel ("s**y**stem").
4. **Coda exceptions** — Certain consonant pairs (`gh`, `nd`, `ld`, `st`) are included with the syllable when they follow the nucleus, matching natural pronunciation ("**stri**ng", not "**str**ing").
5. **60% cap** — As a safety net, highlighting never exceeds 60% of the word length, preventing over-bolding on edge cases.

### Comparison

| Word | Fixed half | Syllable algorithm |
|------|------------|--------------------|
| `string` | **str**ing | **stri**ng |
| `through` | **thro**ugh | **throu**gh |
| `beautiful` | **beau**tiful | **beau**tiful |
| `comment` | **com**ment | **com**ment |
| `reading` | **rea**ding | **read**ing |
| `yield` | **yie**ld | **yield** |

The result is highlighting that follows how you actually read and pronounce words, not an arbitrary character count.

## Commands

```vim
" Toggle bionic reading for the current buffer.
" Prompts if the filetype is not in your config.
:BRToggle

" Toggle insert-mode highlight updates
:BRToggleUpdateInsertMode

" Toggle auto-highlighting on file open
:BRToggleAutoHighlight
```

## Keymaps

No keymaps are set by default. Example:

```lua
vim.keymap.set('n', '<leader>br', '<cmd>BRToggle<cr>', { desc = 'Toggle bionic reading' })
```

## API

The plugin exposes two functions for programmatic use:

```lua
local br = require('bionic-reading')

-- Highlight a range (0-indexed, end-exclusive). Omit args for full buffer.
br.highlight(bufnr, line_start, line_end)

-- Clear all bionic reading highlights in a buffer
br.clear(bufnr)
```

## Why syllable highlighting?

- **Word recognition** — Highlighting the first syllable lets your eyes lock onto the core of each word quickly, especially with long or unfamiliar terms.
- **Mental chunking** — Breaking words into syllable-sized units helps your brain process and retain information more efficiently.
- **Code readability** — Distinguishing similar variable names, function names, and identifiers becomes easier when their opening syllables are visually distinct.
- **Pattern identification** — Repeated syllable patterns become visible at a glance, useful for proofreading and spotting repetition.
