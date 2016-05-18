if exists('g:plugin_settings_loaded')
    finish
endif
let g:plugin_settings_loaded = 1

" -------------------------------------------------------
" include paths use omni complements and other scripts.
" -------------------------------------------------------
function! s:getClangLibraryPath()
    if has('win32') || has('win64')
        " When you are building clang,
        " you should change a path of mingw in llvm\tools\clang\lib\Frontend\InitHeaderSearch.cpp
        if isdirectory(expand('$LLVM_HOME'))
            let l:libclang_path = globpath('$LLVM_HOME', 'bin\libclang.dll')
        else
            let l:libdir = expand('E:\local\llvm\bin')
            let l:libclang_path = globpath(l:libdir, 'libclang.dll')
        endif

        let l:libclang_path = strpart(l:libclang_path, 0, strridx(l:libclang_path, '\libclang.dll'))
    else
        let l:bindir        = expand('/usr/bin')
        let l:libdir        = expand('/usr/lib')
        let l:libclang_path = globpath(l:libdir, 'libclang.so')
        let l:libclang_path = strpart(l:libclang_path, 0, strridx(l:libclang_path, '/libclang.so'))
    endif

    if glob(l:libclang_path) == ''
        echo "Can't detect libclang.dll or libclang.so."
        echo l:libclang_path
    endif

    return l:libclang_path
endfunction

function! s:getCppIncludePaths()
    if has('win32') || has('win64')
        " mingw settings.
        if isdirectory(expand('$MINGW_HOME'))
            let l:mingw_path = expand('$MINGW_HOME')
        else
            let l:mingw_path = 'e:/local/mingw-w64/*/mingw64'
        endif

        " Windows
        let l:include_paths_cpp = filter(
                    \ [
                    \ ] +
                    \ split(glob('e:/local/lib/*/include'), '\n') +
                    \ split(glob(l:mingw_path . '/include'), '\n') +
                    \ split(glob(l:mingw_path . '/include/*'), '\n') +
                    \ split(glob(l:mingw_path . '/*/include'), '\n') +
                    \ split(glob(l:mingw_path . '/*/include/*'), '\n'),
                    \ 'isdirectory(v:val)')
    else
        " Linux
        let l:include_paths_cpp = filter(
                    \ split(glob('/usr/include'), '\n') +
                    \ split(glob('/usr/include/*'), '\n') +
                    \ split(glob('/usr/local/include'), '\n') +
                    \ split(glob('/usr/local/include/*'), '\n'),
                    \ 'isdirectory(v:val)')
    endif

    return l:include_paths_cpp
endfunction

if !exists('g:include_paths_string')
    let g:include_paths_string = ''
endif

au FileType c,cpp,objc,objcpp call s:setCppIncludePaths()
function! s:setCppIncludePaths()
    if exists('g:cppIncludePath_initialized')
        return
    else
        let g:cppIncludePath_initialized = 1
    endif

    let l:include_paths_cpp = s:getCppIncludePaths()
    if len(l:include_paths_cpp) > 0
        let g:include_paths_string = join(l:include_paths_cpp, ',')
        execute 'set path ^=' . g:include_paths_string
    endif
endfunction

" -------------------------------------------------------
" NERDTree
" -------------------------------------------------------
if dein#tap("nerdtree")
    map <C-n> :NERDTreeToggle<CR>
endif

" -------------------------------------------------------
" ctrlp.vim
" -------------------------------------------------------
if dein#tap("ctrlp.vim")
    " CtrlP to scan for dotfiles and dotdirs.
    let g:ctrlp_show_hidden = 1

    if has('win32') || has('win64')
        set wildignore+=*\\node_modules\\*
    else
        set wildignore+=*/node_modules/*
    endif

    if executable('ag')
        "let g:ctrlp_use_caching=0
        let s:ctrlp_options =
                    \ ' -i --nocolor --nogroup --hidden
                    \ --ignore .cache
                    \ --ignore .git
                    \ --ignore .svn
                    \ --ignore .hg
                    \ --ignore .DS_Store
                    \ --ignore "**/*.pyc"
                    \ -g "" '

        if has('win32') || has('win64')
            let g:ctrlp_user_command = 'ag' . s:ctrlp_options . '%s'
        else
            let g:ctrlp_user_command = 'ag %s' . s:ctrlp_options
        endif
    endif
endif

" -------------------------------------------------------
" neocomplete
" -------------------------------------------------------
if dein#tap("neocomplete")
    " これをしないと候補選択時にScratch ウィンドウが開いてしまう
    set completeopt=menuone

    " More neocomplete candidates.
    let g:neocomplete#max_list = 100

    "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    " Define dictionary.
    let g:neocomplete#sources#dictionary#dictionaries = {
                \ 'default' : '',
                \ 'vimshell' : $HOME.'/.vimshell_hist',
                \ 'scheme' : $HOME.'/.gosh_completions'
                \ }

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
        " For no inserting <CR> key.
        "return pumvisible() ? "\<C-y>" : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " Close popup by <Space>.
    "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

    " AutoComplPop like behavior.
    "let g:neocomplete#enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt+=longest
    "let g:neocomplete#enable_auto_select = 1
    "let g:neocomplete#disable_auto_complete = 1
    "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    "autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    "autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
        let g:neocomplete#sources#omni#input_patterns = {}
    endif
    "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

    " For perlomni.vim setting.
    " https://github.com/c9s/perlomni.vim
    "let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
endif

" -------------------------------------------------------
" clang_complete
" -------------------------------------------------------
if dein#tap("clang_complete")
    function! s:clang_complete_options() abort
        if !exists('g:neocomplete#force_omni_input_patterns')
          let g:neocomplete#force_omni_input_patterns = {}
        endif
        let g:neocomplete#force_omni_input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)\w*'
        let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
        let g:neocomplete#force_omni_input_patterns.objc = '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'
        let g:neocomplete#force_omni_input_patterns.objcpp = '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)\|\h\w*::\w*'

        let g:clang_debug          = 0
        let g:clang_complete_copen = 1

        let g:clang_auto_select    = 0
        let g:clang_complete_auto  = 1

        " conceal in insert (i), normal (n) and visual (v) modes
        set concealcursor=inv
        " hide concealed text completely unless replacement character is defined
        set conceallevel=2
        let g:clang_conceal_snippets = 1

        let g:clang_use_library  = 1
        let g:clang_library_path = s:getClangLibraryPath()

        let g:clang_user_options = ' -std=c++11'

        " Build msvc
        if has('win32') || has('win64')
            " You must compile clang on msvc of 64 bit If you use windows of 64 bit.
            let g:clang_user_options += ' 2> NUL || exit 0"'
        else
            " linuxでオムニ変換が正常に行われない
            let g:clang_user_options += ' -stdlib=libc++'
        endif
    endfunction

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:clang_complete_options()'
endif

" -------------------------------------------------------
" vim-easymotion
" -------------------------------------------------------
if dein#tap('vim-easymotion')
    " Disable default mapping.
    " let g:EasyMotion_do_mapping = 0
    " map <Leader><Leader> <Plug>(easymotion-prefix)
    map ; <Plug>(easymotion-prefix)

    " 2-character search motion
    " overwrite to f{char}, and t{char} of default key binding.
    nmap f <Plug>(easymotion-s2)
    nmap t <Plug>(easymotion-t2)

    " " n-character search motion
    " map  / <Plug>(easymotion-sn)
    " omap / <Plug>(easymotion-tn)

    " " These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
    " " Without these mappings, `n` & `N` works fine. (These mappings just provide
    " " different highlight method and have some other features )
    " map  n <Plug>(easymotion-next)
    " map  N <Plug>(easymotion-prev)
    
    " hjkl motions (already set (easymotion-j) and (easymotion-k) by default)
    map ;h <Plug>(easymotion-linebackward)
    " map ;j <Plug>(easymotion-j)
    " map ;k <Plug>(easymotion-k)
    map ;l <Plug>(easymotion-lineforward)

    " Overwin motions
    nmap <Leader>f <Plug>(easymotion-overwin-f)
    xmap <Leader>f <Plug>(easymotion-bd-f)
    omap <Leader>f <Plug>(easymotion-bd-f)
    nmap <Leader>s <Plug>(easymotion-overwin-f2)
    xmap <Leader>s <Plug>(easymotion-bd-f2)
    omap <Leader>s <Plug>(easymotion-bd-f2)
    nmap <Leader>l <Plug>(easymotion-overwin-line)
    xmap <Leader>l <Plug>(easymotion-bd-jk)
    omap <Leader>l <Plug>(easymotion-bd-jk)
    nmap <Leader>w <Plug>(easymotion-overwin-w)
    xmap <Leader>w <Plug>(easymotion-bd-w)
    omap <Leader>w <Plug>(easymotion-bd-w)

    " repeat
    map ;r <Plug>(easymotion-repeat)

    let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion

    " Smartcase & Smartsign
    let g:EasyMotion_smartcase = 1

    let g:EasyMotion_use_smartsign_us = 1 " US layout
    "let g:EasyMotion_use_smartsign_jp = 1 " JP layout

    " Migemo feature
    if has('migemo')
        let g:EasyMotion_use_migemo = 1
    endif
endif

" -------------------------------------------------------
" vim-textmanip
" -------------------------------------------------------
if dein#tap('vim-textmanip')
    " use Enter and Shift-Enter to insert blank line.
    " which is useful since I enforce duplicate with '-r(replace' mode.
    augroup MyGroup
        function! s:textmanip_space()
            if &filetype !=? 'help'
                nmap <CR>   <Plug>(textmanip-blank-below)
                nmap <S-CR> <Plug>(textmanip-blank-above)
                xmap <CR>   <Plug>(textmanip-blank-below)
                xmap <S-CR> <Plug>(textmanip-blank-above)
            else
                nmap <CR>   <CR>
                nmap <S-CR> <S-CR>
                xmap <CR>   <CR>
                xmap <S-CR> <S-CR>
            endif
        endfunction

        autocmd!
        autocmd BufEnter * call s:textmanip_space()
    augroup END

    " 選択したテキストの移動
    xmap <C-j> <Plug>(textmanip-move-down)
    xmap <C-k> <Plug>(textmanip-move-up)
    xmap <C-h> <Plug>(textmanip-move-left)
    xmap <C-l> <Plug>(textmanip-move-right)

    " 行の複製
    xmap <C-c> <Plug>(textmanip-duplicate-down)
    nmap <C-c> <Plug>(textmanip-duplicate-down)
    xmap <S-c> <Plug>(textmanip-duplicate-up)
    nmap <S-c> <Plug>(textmanip-duplicate-up)

    xmap <S-k> <Plug>(textmanip-duplicate-up)
    xmap <S-j> <Plug>(textmanip-duplicate-down)
    xmap <S-h> <Plug>(textmanip-duplicate-left)
    xmap <S-l> <Plug>(textmanip-duplicate-right)

    " use allow key to force replace movement
    xmap  <Up>     <Plug>(textmanip-move-up-r)
    xmap  <Down>   <Plug>(textmanip-move-down-r)
    xmap  <Left>   <Plug>(textmanip-move-left-r)
    xmap  <Right>  <Plug>(textmanip-move-right-r)

    " toggle insert/replace with <F10>
    nmap <F10> <Plug>(textmanip-toggle-mode)
    xmap <F10> <Plug>(textmanip-toggle-mode)
endif

" -------------------------------------------------------
" Syntastic
" -------------------------------------------------------
if dein#tap('syntastic')
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_mode_map = {
                \ 'mode': 'active',
                \ 'active_filetypes': [],
                \ 'passive_filetypes': [],
                \ }

    " C/C++
    let s:gccOptions = '-Wall -Wextra -pedantic -Werror -Wshadow -Wstrict-overflow -fno-strict-aliasing'

    if !exists('g:syntastic_c_compiler_options')
        let g:syntastic_c_compiler_options = ''
    endif
    if !exists('g:syntastic_cpp_compiler_options')
        let g:syntastic_cpp_compiler_options = ''
    endif

    let g:syntastic_c_compiler_options += '-std=c11'
    let g:syntastic_cpp_compiler_options += '-std=c++11'
    if has('unix') || has('macunix')
        let g:syntastic_c_compiler_options += ' -stdlib=libc'
        let g:syntastic_cpp_compiler_options += ' -stdlib=libc++'
    endif

    if executable("clang")
        let g:syntastic_c_compiler = 'clang++'
    else " gcc
        let g:syntastic_c_compiler_options += ' ' . s:gccOptions
    endif

    if executable("clang++")
        let g:syntastic_cpp_compiler = 'clang++'
    else " g++
        let g:syntastic_cpp_compiler_options += ' ' . s:gccOptions
    endif

    " CSS
    let g:syntastic_css_csslint_args = '--ignore=adjoining-classes'

    " JavaScript
    let g:syntastic_javascript_checkers = ['eslint']

    " TypeScript
    "let g:syntastic_typescript_checkers = ['tslint']

    " " ignore python for use python-mode.
    " let g:syntastic_ignore_files = ['\.py$']
endif

" -------------------------------------------------------
" lightline.vim
" -------------------------------------------------------
if dein#tap("lightline.vim")
    let g:lightline = {
          \ 'colorscheme': 'wombat',
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark'] ],
          \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
          \ },
          \ 'component_function': {
          \   'fugitive': 'LightLineFugitive',
          \   'filename': 'LightLineFilename',
          \   'fileformat': 'LightLineFileformat',
          \   'filetype': 'LightLineFiletype',
          \   'fileencoding': 'LightLineFileencoding',
          \   'mode': 'LightLineMode',
          \   'ctrlpmark': 'CtrlPMark',
          \ },
          \ 'component_expand': {
          \   'syntastic': 'SyntasticStatuslineFlag',
          \ },
          \ 'component_type': {
          \   'syntastic': 'error',
          \ },
          \ 'subseparator': { 'left': '|', 'right': '|' }
          \ }

    function! LightLineModified()
      return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
    endfunction

    function! LightLineReadonly()
      return &ft !~? 'help' && &readonly ? 'RO' : ''
    endfunction

    function! LightLineFilename()
      let fname = expand('%:t')
      return fname == 'ControlP' ? g:lightline.ctrlp_item :
            \ fname == '__Tagbar__' ? g:lightline.fname :
            \ fname =~ '__Gundo\|NERD_tree' ? '' :
            \ &ft == 'vimfiler' ? vimfiler#get_status_string() :
            \ &ft == 'unite' ? unite#get_status_string() :
            \ &ft == 'vimshell' ? vimshell#get_status_string() :
            \ ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
            \ ('' != fname ? fname : '[No Name]') .
            \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
    endfunction

    function! LightLineFugitive()
      try
        if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
          let mark = ''  " edit here for cool mark
          let _ = fugitive#head()
          return strlen(_) ? mark._ : ''
        endif
      catch
      endtry
      return ''
    endfunction

    function! LightLineFileformat()
      return winwidth(0) > 70 ? &fileformat : ''
    endfunction

    function! LightLineFiletype()
      return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
    endfunction

    function! LightLineFileencoding()
      return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
    endfunction

    function! LightLineMode()
      let fname = expand('%:t')
      return fname == '__Tagbar__' ? 'Tagbar' :
            \ fname == 'ControlP' ? 'CtrlP' :
            \ fname == '__Gundo__' ? 'Gundo' :
            \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
            \ fname =~ 'NERD_tree' ? 'NERDTree' :
            \ &ft == 'unite' ? 'Unite' :
            \ &ft == 'vimfiler' ? 'VimFiler' :
            \ &ft == 'vimshell' ? 'VimShell' :
            \ winwidth(0) > 60 ? lightline#mode() : ''
    endfunction

    function! CtrlPMark()
      if expand('%:t') =~ 'ControlP'
        call lightline#link('iR'[g:lightline.ctrlp_regex])
        return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
              \ , g:lightline.ctrlp_next], 0)
      else
        return ''
      endif
    endfunction

    let g:ctrlp_status_func = {
      \ 'main': 'CtrlPStatusFunc_1',
      \ 'prog': 'CtrlPStatusFunc_2',
      \ }

    function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
      let g:lightline.ctrlp_regex = a:regex
      let g:lightline.ctrlp_prev = a:prev
      let g:lightline.ctrlp_item = a:item
      let g:lightline.ctrlp_next = a:next
      return lightline#statusline(0)
    endfunction

    function! CtrlPStatusFunc_2(str)
      return lightline#statusline(0)
    endfunction

    let g:tagbar_status_func = 'TagbarStatusFunc'

    function! TagbarStatusFunc(current, sort, fname, ...) abort
        let g:lightline.fname = a:fname
      return lightline#statusline(0)
    endfunction

    if !exists('g:syntastic_mode_map')
        let g:syntastic_mode_map = {}
    endif
    let g:syntastic_mode_map['mode'] = 'passive'

    augroup AutoSyntastic
      autocmd!
      autocmd BufWritePost * call s:syntastic()
    augroup END
    function! s:syntastic()
      SyntasticCheck
      call lightline#update()
    endfunction

    let g:unite_force_overwrite_statusline = 0
    let g:vimfiler_force_overwrite_statusline = 0
    let g:vimshell_force_overwrite_statusline = 0
endif

" -------------------------------------------------------
" vim-swoop
" -------------------------------------------------------
if dein#tap('vim-swoop')
    " You can disabledefault mapping by:
    let g:swoopUseDefaultKeyMap = 0

    nmap <Leader>n :call Swoop()<CR>
    vmap <Leader>n :call SwoopSelection()<CR>
    nmap <Leader>m :call SwoopMulti()<CR>
    vmap <Leader>m :call SwoopMultiSelection()<CR>

    " " set search case insensitive
    " let g:swoopIgnoreCase = 1
    " " Disable quick regex mode
    " let g:swoopPatternSpaceInsertsWildcard = 0
    " " Disable auto insert mode
    " let g:swoopAutoInserMode = 0
    " " Change default layout
    " let g:swoopWindowsVerticalLayout = 1
    " " Lazy Filetype Load
    " let g:swoopLazyLoadFileType = 0
    " " Edit default HightLight
    " let g:swoopHighlight = ["hi! link SwoopBufferLineHi Warning", "hi! link SwoopPatternHi Error"]
endif
