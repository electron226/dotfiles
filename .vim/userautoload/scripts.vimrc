if has('syntax')
    "----------------------------------------
    " 全角スペースをハイライト表示
    "----------------------------------------
    function! ZenkakuSpace()
        highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
    endfunction

    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme * call ZenkakuSpace()
        autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
    augroup END
    call ZenkakuSpace()

    "----------------------------------------
    " 行頭のスペースをハイライト
    "----------------------------------------
    augroup HighlightBeginnigTabs
      autocmd!
      autocmd ColorScheme * highlight TrailingSpaces term=underline guibg=DarkMagenta ctermbg=DarkMagenta
      autocmd VimEnter,WinEnter * match TrailingSpaces /^\t+/
    augroup END
    
    "----------------------------------------
    " 行末のスペースをハイライト
    "----------------------------------------
    augroup HighlightTrailingSpaces
      autocmd!
      autocmd ColorScheme * highlight TrailingSpaces term=underline guibg=DarkMagenta ctermbg=DarkMagenta
      autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
    augroup END
endif

"----------------------------------------
" Change current directory.
"----------------------------------------
command! -nargs=? -complete=dir -bang CD  call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction

" nnoremap <silent> <Space>cd :<C-u>CD<CR>

"----------------------------------------
" diff/patch
"----------------------------------------
if has('win32') || has('win64')
    set diffexpr=MyDiff()
    function! MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                let cmd = '""' . $VIMRUNTIME . '\diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction
endif

"----------------------------------------
" ファイルの前回閉じた場所を記憶
"----------------------------------------
if has("autocmd")
    autocmd BufReadPost * if line("'\"") > 1 && line ("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"----------------------------------------
" WinではPATHに$VIMが含まれていないときにexeを見つけ出せないので修正
"----------------------------------------
if has('win32') && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
    let $PATH = $VIM . ';' . $PATH
endif

" -------------------------------------------------------
" create directory automatically
" -------------------------------------------------------
augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)  " {{{
    if !isdirectory(a:dir) && (a:force ||
    \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}
