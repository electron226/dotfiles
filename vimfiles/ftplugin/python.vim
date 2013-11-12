" plugin first input string is deleted when autocompleting, when you use jedi-vim.
if g:jedi#popup_on_dot
    inoremap <buffer> . .<C-R>=jedi#do_popup_on_dot() ? "\<lt>C-X>\<lt>C-O>\<lt>C-P>" : ""<CR>
end
