if exists('g:loaded_bionic_reading')
  finish
endif

let g:loaded_bionic_reading = 1

" HACK: use defer_fn since TreeSitter is doing something that's removing
" highlight on TextChange/BufWritePost
augroup bionic_reading
	autocmd!
	autocmd ColorScheme * lua require("bionic-reading.cmds")._set_hl_on_colorscheme()
	autocmd FileType * lua require("bionic-reading.cmds")._highlight_on_filetype()
	autocmd TextChanged * lua vim.defer_fn(function()require("bionic-reading.cmds")._highlight_on_textchanged()end, 0)
	autocmd TextChangedI * lua require("bionic-reading.cmds")._highlight_on_textchangedI()
augroup end

command! BRToggle lua require("bionic-reading.cmds")._toggle()
command! BRToggleUpdateInsertMode lua require("bionic-reading.cmds")._toggle_update_insert_mode()
command! BRToggleAutoHighlight lua require("bionic-reading.cmds")._toggle_auto_highlight()
