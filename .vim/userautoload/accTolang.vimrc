if exists('g:accToLang_settings_loaded')
    finish
endif
let g:accToLang_settings_loaded = 1

" the golang config is into plugin_settings.vim.

autocmd BufRead,BufNewFile *.inc set filetype=nasm
autocmd BufRead,BufNewFile *.nasm set filetype=nasm
autocmd BufRead,BufNewFile *.json set filetype=json
autocmd FileType lua setl fenc=cp932

function! s:js_conf()
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal cindent
endfunction
autocmd FileType javascript,coffee,typescript call s:js_conf()

function! s:json_conf()
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal cindent
endfunction
autocmd FileType json call s:json_conf()

" 共通設定
set textwidth=0
if exists('&colorcolumn')
    set colorcolumn=+1
    " sh,cpp,perl,vim,...の部分は自分が使う
    " プログラミング言語のfiletypeに合わせてください
    autocmd FileType sh,c,cpp,perl,vim,ruby,python,css,javascript,typescript,lua,asm,nasm setlocal textwidth=80
endif

" -------------------------------------------------------
" テンプレート
" -------------------------------------------------------
autocmd BufNewFile *.c 0r $MY_VIMRUNTIME/template/c.c
autocmd BufNewFile *.cpp 0r $MY_VIMRUNTIME/template/cpp.cpp
autocmd BufNewFile *.go 0r $MY_VIMRUNTIME/template/go.go
autocmd BufNewFile *.py 0r $MY_VIMRUNTIME/template/python.py
autocmd BufNewFile *.rb 0r $MY_VIMRUNTIME/template/ruby.rb
autocmd BufNewFile *.html 0r $MY_VIMRUNTIME/template/html5.html
autocmd BufNewFile *.js 0r $MY_VIMRUNTIME/template/javascript.js
autocmd BufNewFile *.ts 0r $MY_VIMRUNTIME/template/typescript.ts
