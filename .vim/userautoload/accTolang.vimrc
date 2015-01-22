" the golang config is into plugin_settings.vim.

" NASM
au BufRead,BufNewFile *.inc set filetype=nasm
au BufRead,BufNewFile *.nasm set filetype=nasm

" Python PEP8準拠
autocmd FileType python call s:python_settings()
function! s:python_settings()
    setl autoindent
    setl smartindent
    setl cinwords=if,elif,else,for,while,try,except,finally,def,class
    setl expandtab tabstop=8 shiftwidth=4 softtabstop=4
    setl textwidth=80 colorcolumn=80
    setl enc=utf-8
    
    " Execute python script F5
    function! s:ExecPy()
        exe "!" . &ft . " %"
    endfunction
    command! Exec call <SID>ExecPy()
    map <silent> <F5> :call <SID>ExecPy()<CR>
endfunction

" Ruby
autocmd FileType ruby call s:ruby_settings()
function! s:ruby_settings()
    setl autoindent
    setl smartindent
    setl cinwords=if,elsif,else,unless,for,while,begin,rescue,def,class,module
    setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
    setl textwidth=80 colorcolumn=80
endfunction

" HTML
autocmd FileType html call s:html_settings()
autocmd FileType xhtml call s:html_settings()
function! s:html_settings()
    setl indentexpr&
endfunction

" Lua
"autocmd FileType lua setl fenc=cp932

" Javascript
autocmd FileType html,javascript call s:javascript_settings()
function! s:javascript_settings()
    setl expandtab tabstop=2 shiftwidth=2 softtabstop=2

    "if executable('fixjsstyle')
    "    " 開いているファイルのgjslintのエラー箇所を付属のfixjsstyleで修正する
    "    nmap <silent><buffer><Leader>e <Plug>ModifyByFixJsStyle
    "    nmap <script><silent><buffer><Plug>ModifyByFixJsStyle
    "                \ :call <SID>ModifyByFixJsStyle()<CR>
    "    if !exists('s:ModifyByFixJsStyle')
    "        function! s:ModifyByFixJsStyle()
    "            let a:cursor = getpos('.')

    "            silent! execute '!fixjsstyle %'
    "            silent! execute 'e %'

    "            call setpos('.', a:cursor)
    "        endfunction
    "    endif
    "endif
endfunction

" 共通設定
set textwidth=0
if exists('&colorcolumn')
    set colorcolumn=+1
    " sh,cpp,perl,vim,...の部分は自分が使う
    " プログラミング言語のfiletypeに合わせてください
    autocmd FileType sh,c,cpp,perl,vim,ruby,python,haskell,scheme,css,javascript,lua,opencl,asm,nasm setlocal textwidth=80
endif

" -------------------------------------------------------
" テンプレート
" -------------------------------------------------------
au BufNewFile *.c 0r $MY_VIMRUNTIME/template/c.txt
au BufNewFile *.cpp 0r $MY_VIMRUNTIME/template/cpp.txt
au BufNewFile *.go 0r $MY_VIMRUNTIME/template/go.txt
au BufNewFile *.py 0r $MY_VIMRUNTIME/template/python.txt
au BufNewFile *.rb 0r $MY_VIMRUNTIME/template/ruby.txt
au BufNewFile *.html 0r $MY_VIMRUNTIME/template/html5.html
au BufNewFile *.js 0r $MY_VIMRUNTIME/template/javascript.js
