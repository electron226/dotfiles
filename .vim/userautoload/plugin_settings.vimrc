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
            let l:libclang_path = globpath('$LLVM_HOME', 'Release\bin\libclang.dll')
        else
            let l:libdir = expand('F:\local\llvm\build\Release\bin')
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
    if has('win32') || has('win64') || has('win32unix')
        " mingw settings.
        if isdirectory(expand('$MINGW_HOME'))
            let l:mingw_path = expand('$MINGW_HOME')
        else
            let l:mingw_path = 'F:/local/mingw64'
        endif

        " if executable('gcc')
        "     let l:target = ""
        "     let l:gcc_ver = ""

        "     let l:gcc_list = systemlist("gcc -v")
        "     for l in l:gcc_list
        "         let l:temp = matchstr(l, 'Target: \zs.*')
        "         if len(l:temp) > 0
        "             let l:target = l:temp
        "             continue
        "         endif

        "         let l:temp = matchstr(l, 'gcc version \zs[0-9.]\+')
        "         if len(l:temp) > 0
        "             let l:gcc_ver = l:temp
        "             continue
        "         endif
        "     endfor

        "     let l:mingw_build_target = l:target
        "     let l:mingw_gcc_version = l:gcc_ver
        " endif

        " Windows
        let l:include_paths_cpp = filter(
                    \ [
                    \ ] +
                    \ split(glob('f:/local/lib/*/include'), '\n') +
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

    " Boost Path
    let l:boost_root = expand('$BOOST_ROOT')
    if !isdirectory(l:boost_root)
        if has('win32') || has('win64')
            let l:boost_root = 'f:/local/lib/boost'
        else
            let l:boost_root = '/usr/include/boost'
        endif
    endif

    if has('win32') || has('win64')
        let l:boost_include_path = split(glob(l:boost_root . '/include/*'), '\n')[0]
    else
        let l:boost_include_path = split(glob(l:boost_root . '/*'), '\n')[0]
    endif

    if isdirectory(l:boost_include_path)
        call add(l:include_paths_cpp, l:boost_include_path)
    else
        echo "Boost library isn't found."
    endif

    return l:include_paths_cpp
endfunction

au FileType c,cpp,objc,objcpp call s:setCppIncludePaths()
function! s:setCppIncludePaths()
    let s:include_paths_cpp = s:getCppIncludePaths()
    let s:include_paths_string_mingw =
                \ len(s:include_paths_cpp) > 0 ?
                \ '-I "' . join(s:include_paths_cpp, '" -I "') . '"' :
                \ ''

    " neocomplete
    " Define include.
    let s:neocomplete_include_paths_cpp = join(s:include_paths_cpp, ',')

    if !exists('g:neocomplete#sources#include#paths')
        let g:neocomplete#sources#include#paths = {}
    endif
    let g:neocomplete#sources#include#paths = {
                \ 'c' : s:neocomplete_include_paths_cpp,
                \ 'cpp' : s:neocomplete_include_paths_cpp,
                \ }

    " vim-stargate
    let g:stargate#include_paths['cpp'] = s:include_paths_cpp

    " clang_complete
    let g:clang_user_options =
                \ s:include_paths_string_mingw .
                \ ' -std=c++1y'
    if has('win32') || has('win64')
        " Build msvc
        " You must compile clang on msvc of 64 bit If you use windows of 64 bit.
        let g:clang_user_options += ' 2> NUL || exit 0"'
    else
        " linuxでオムニ変換が正常に行われない
        let g:clang_user_options += ' -stdlib=libc++'
    endif

    " Syntastic
    let g:syntastic_cpp_compiler_options = g:syntastic_cpp_compiler_options . s:include_paths_string_mingw

    " vim-quickrun
    let s:clangcpp_cmdopt = s:clangcpp_cmdopt . s:include_paths_string_mingw

    if executable("clang++")
        let g:quickrun_config['cpp/clang++1y'] = {
                    \ 'cmdopt': s:clangcpp_cmdopt,
                    \ "exec" : "%c %o -fsyntax-only %s:p",
                    \ }
        let g:quickrun_config['cpp'] = {'type': 'cpp/clang++1y'}
    else
        let g:quickrun_config['cpp/g++1y'] = {
                    \ 'cmdopt': s:clangcpp_cmdopt,
                    \ }
        let g:quickrun_config['cpp'] = {'type': 'cpp/g++1y'}
    endif
endfunction

" -------------------------------------------------------
" Vimproc
" -------------------------------------------------------
if has('mac')
    let g:vimproc_dll_path =
                \ $MY_VIMRUNTIME . '/bundle/vimproc/autoload/vimproc_mac.so'
elseif has('win64')
    let g:vimproc_dll_path =
                \ $MY_VIMRUNTIME . '/bundle/vimproc/autoload/vimproc_win64.dll'
elseif has('win32')
    let g:vimproc_dll_path =
                \ $MY_VIMRUNTIME . '/bundle/vimproc/autoload/vimproc_win32.dll'
endif

" -------------------------------------------------------
" vimfiler
" -------------------------------------------------------
" vimデフォルトのエクスプローラをvimfilerで置き換える
let g:vimfiler_as_default_explorer = 1

" セーフモード無効
let g:vimfiler_safe_mode_by_default = 0

"現在開いているバッファをIDE風に開く
nnoremap <silent> <Leader>f :<C-u>VimFilerBufferDir
            \ -split -simple -winwidth=30 -no-quit<CR>

" -------------------------------------------------------
" ctrlp.vim
" -------------------------------------------------------
" CtrlP to scan for dotfiles and dotdirs.
let g:ctrlp_show_hidden = 1

" -------------------------------------------------------
" unite.vim
" -------------------------------------------------------
call unite#custom#profile('default', 'context', {
            \ 'start_insert': 1,
            \ 'winheight': 10,
            \ 'direction': 'botright',
            \ })

" The items of in .gitignore doesn't display in the result of the unite.vim.
function! s:unite_setGitIgnoreSource()
    let l:sources = []
    let l:file = getcwd() . '/.gitignore'
    let l:dir = getcwd() . '/.git'
    if filereadable(l:file)
        for l:line in readfile(l:file)
            " a line of comment and empty line are skipping.
            if l:line !~ "^#\\|^\s\*$"
                call add(l:sources, l:line)
            endif
        endfor
    endif

    if isdirectory(l:dir)
        call add(l:sources, '.git')
    endif

    let l:pattern = escape(join(sources, '|'), './|')
    call unite#custom#source('file_rec,file_rec/async,file_rec/git', 'ignore_pattern', l:pattern)
endfunction

call s:unite_setGitIgnoreSource()

" Enable yank history.
let g:unite_source_history_yank_enable = 1

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
endif

" ウインドウ/TAB一覧
nnoremap <silent> <Leader>uw :<C-u>Unite window tab<CR>
" バッファ/ブックマーク一覧
nnoremap <silent> <Leader>ub :<C-u>Unite buffer bookmark<CR>
" ファイル一覧
nnoremap <silent> <Leader>uf :<C-u>Unite file<CR>
" ファイル履歴一覧
nnoremap <silent> <Leader>um :<C-u>Unite file_mru<CR>
" 再帰的なファイル一覧
function! DispatchUniteFileRecAsyncOrGit()
    if isdirectory(getcwd()."/.git")
        Unite file_rec/git:!
    else
        if has('win32') || has('win64')
            Unite file_rec
        else
            Unite file_rec/async:!
        endif
    endif
endfunction
nnoremap <silent> <Leader>uu :<C-u>call DispatchUniteFileRecAsyncOrGit()<CR>
" レジスタ一覧
nnoremap <silent> <Leader>ur :<C-u>Unite -buffer-name=register register<CR>
" ヤンク履歴
nnoremap <silent> <Leader>uy :<C-u>Unite history/yank<CR>
" 全部乗せ
nnoremap <silent> <Leader>ua :<C-u>Unite window buffer bookmark tab file_rec register history/yank<CR>

" grep検索
nnoremap <silent> <Leader>ug  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
" grep検索結果の再呼出
nnoremap <silent> <Leader>up  :<C-u>UniteResume search-buffer<CR>

" カーソル下のキーワードを含む行を表示
nnoremap <silent> <Leader>uc :<C-u>UniteWithCursorWord -no-quit line<CR>

" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    " 単語単位からパス単位で削除するように変更
    imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

    " ウィンドウを分割して開く
    nmap <silent> <buffer> <expr> <C-j> unite#do_action('split')
    imap <silent> <buffer> <expr> <C-j> unite#do_action('split')

    " ウィンドウを縦に分割して開く
    nmap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
    imap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')

    " ESCキーを2回押すと終了する
    nmap <silent><buffer> <ESC><ESC> q
    imap <silent><buffer> <ESC><ESC> <ESC>q
endfunction

" -------------------------------------------------------
" unite-build
" -------------------------------------------------------
" nnoremap <silent> <Leader>ubu :<C-u>Unite build<CR>
" nnoremap <silent> <Leader>ubut :<C-u>Unite build:!<CR>

" -------------------------------------------------------
" unite-tag
" -------------------------------------------------------
" nnoremap <silent> <Leader>ut :<C-u>Unite tag<CR>
" nnoremap <silent> <Leader>utf :<C-u>Unite tag/file<CR>
" nnoremap <silent> <Leader>uti :<C-u>Unite tag/include<CR>

" " path にヘッダーファイルのディレクトリを追加することで
" " neocomplcache が include 時に tag ファイルを作成してくれる
" set path+=$LIBSTDCPP
" set path+=$BOOST_LATEST_ROOT

" " unite-tagで表示する
" command!
"             \ -nargs=? PopupTags
"             \ call <SID>TagsUpdate()
"             \ |Unite tag:<args>

" " neocomplete が作成した tag ファイルのパスを tags に追加する
" function! s:TagsUpdate()
"     " include している tag ファイルが毎回同じとは限らないので毎回初期化
"     setlocal tags=
"     for filename in neocomplete#sources#include#get_include_files(bufnr('%'))
"         execute "setlocal tags+=".neocomplete#cache#encode_name('tags_output', filename)
"     endfor
" endfunction

" function! s:get_func_name(word)
"     let end = match(a:word, '<\|[\|(')
"     return end == -1 ? a:word : a:word[ : end-1 ]
" endfunction

" " カーソル下のワード(word)で絞り込み
" noremap <silent> g<C-]> :<C-u>execute "PopupTags ".expand('<cword>')<CR>

" " カーソル下のワード(WORD)で ( か < か [ までが現れるまでで絞り込み
" " 例)
" " boost::array<std::stirng... → boost::array で絞り込み
" noremap <silent> G<C-]> :<C-u>execute "PopupTags "
"             \.substitute(<SID>get_func_name(expand('<cWORD>')), '\:', '\\\:', "g")<CR>

" -------------------------------------------------------
" unite-gtag
" -------------------------------------------------------
" nnoremap <silent> <Leader>ugt :<C-u>Unite gtags/context<CR>
" nnoremap <silent> <Leader>ugtr :<C-u>Unite gtags/ref<CR>
" nnoremap <silent> <Leader>ugtd :<C-u>Unite gtags/def<CR>
" nnoremap <silent> <Leader>ugtg :<C-u>Unite gtags/grep<CR>
" nnoremap <silent> <Leader>ugta :<C-u>Unite gtags/completion<CR>

" -------------------------------------------------------
" unite-outline
" -------------------------------------------------------
" " ソースの関数一覧表示
" nnoremap <silent> <Leader>uo :<C-u>Unite outline<CR>
" " ソースの関数一覧を上下分割で常に表示
" nnoremap <silent> <Leader>uoh :<C-u>Unite -winheight=15 -no-quit outline<CR>
" " ソースの関数一覧を左右分割で常に表示
" nnoremap <silent> <Leader>uov :<C-u>Unite -vertical -winwidth=25 -no-quit outline<CR>

" " -------------------------------------------------------
" " alpaca_tags
" " -------------------------------------------------------
" let g:alpaca_tags#config = {
"             \ '_' : '-R --sort=yes --languages=+Ruby --languages=-js,JavaScript',
"             \ 'js' : '--languages=+js',
"             \ '-js' : '--languages=-js,JavaScript',
"             \ 'vim' : '--languages=+Vim,vim',
"             \ 'php' : '--languages=+php',
"             \ '-vim' : '--languages=-Vim,vim',
"             \ '-style': '--languages=-css,scss,js,JavaScript,html',
"             \ 'scss' : '--languages=+scss --languages=-css',
"             \ 'css' : '--languages=+css',
"             \ 'java' : '--languages=+java $JAVA_HOME/src',
"             \ 'ruby': '--languages=+Ruby',
"             \ 'coffee': '--languages=+coffee',
"             \ '-coffee': '--languages=-coffee',
"             \ 'bundle': '--languages=+Ruby',
"             \ 'c': '--languages=+c',
"             \ 'cpp': '--languages=+c,cpp',
"             \ 'cs': '--languages=+c#',
"             \ 'py': '--languages=+python',
"             \ }

" -------------------------------------------------------
" neocomplete
" -------------------------------------------------------
let s:bundle = neobundle#get("neocomplete")
function! s:bundle.hooks.on_source(bundle)
    " これをしないと候補選択時にScratch ウィンドウが開いてしまう
    set completeopt=menuone

    " More neocomplete candidates.
    let g:neocomplete#max_list = 100

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

    " " Define include.
    " let s:neocomplete_include_paths_cpp = join(s:include_paths_cpp, ',')

    " if !exists('g:neocomplete#sources#include#paths')
    "     let g:neocomplete#sources#include#paths = {}
    " endif
    " let g:neocomplete#sources#include#paths = {
    "             \ 'c' : s:neocomplete_include_paths_cpp,
    "             \ 'cpp' : s:neocomplete_include_paths_cpp,
    "             \ }

    if !exists('g:neocomplete#sources#include#patterns')
        let g:neocomplete#sources#include#patterns = {}
    endif
    let g:neocomplete#sources#include#patterns = {
                \ 'c' : '^\s*#\s*include',
                \ 'cpp' : '^\s*#\s*include',
                \ }

    if !exists('g:neocomplete#ctags_arguments')
        let g:neocomplete#ctags_arguments = {}
    endif

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        return neocomplete#smart_close_popup() . "\<CR>"
        " For no inserting <CR> key.
        "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplete#close_popup()
    inoremap <expr><C-e>  neocomplete#cancel_popup()
    " Close popup by <Space>.
    "inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

    " For cursor moving in insert mode(Not recommended)
    "inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
    "inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
    "inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
    "inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
    " Or set this.
    "let g:neocomplete#enable_cursor_hold_i = 1
    " Or set this.
    "let g:neocomplete#enable_insert_char_pre = 1

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
endfunction
unlet s:bundle

" -------------------------------------------------------
" clang_complete
" -------------------------------------------------------
let s:bundle = neobundle#get("clang_complete")
function! s:bundle.hooks.on_source(bundle)
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

    " let g:clang_user_options =
    "             \ s:include_paths_string_mingw .
    "             \ ' -std=c++1y'

    " " Build msvc
    " if has('win32') || has('win64')
    "     " You must compile clang on msvc of 64 bit If you use windows of 64 bit.
    "     let g:clang_user_options += ' 2> NUL || exit 0"'
    " else
    "     " linuxでオムニ変換が正常に行われない
    "     let g:clang_user_options += ' -stdlib=libc++'
    " endif
endfunction
unlet s:bundle

" " -------------------------------------------------------
" " vim-ruby
" " -------------------------------------------------------
" let s:bundle = neobundle#get("vim-ruby")
" function! s:bundle.hooks.on_source(bundle)
"     if !exists('g:neocomplete#force_omni_input_patterns')
"         let g:neocomplete#force_omni_input_patterns = {}
"     endif

"     let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
" endfunction
" unlet s:bundle

" -------------------------------------------------------
" OmniSharp
" -------------------------------------------------------
let s:bundle = neobundle#get("Omnisharp")
function! s:bundle.hooks.on_source(bundle)
    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
    let g:neocomplete#force_omni_input_patterns.cs = '[^.]\.\%(\u\{2,}\)\?'

    " recommended key-mappings of C#.
    inoremap <expr>.  neocomplcache#close_popup() . "."
    inoremap <expr>(  neocomplcache#close_popup() . "("
    inoremap <expr>)  neocomplcache#close_popup() . ")"
    inoremap <expr><space>  neocomplcache#close_popup() . " "
    inoremap <expr>;  neocomplcache#close_popup() . ";"

    "This is the default value, setting it isn't actually necessary
    let g:OmniSharp_host = "http://localhost:2000"

    "Set the type lookup function to use the preview window instead of the status line
    "let g:OmniSharp_typeLookupInPreview = 1

    "Timeout in seconds to wait for a response from the server
    let g:OmniSharp_timeout = 1

    "Showmatch significantly slows down omnicomplete
    "when the first match contains parentheses.
    set noshowmatch
    "Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
    "autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

    "Super tab settings
    "let g:SuperTabDefaultCompletionType = 'context'
    "let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"
    "let g:SuperTabDefaultCompletionTypeDiscovery = ["&omnifunc:<c-x><c-o>","&completefunc:<c-x><c-n>"]
    "let g:SuperTabClosePreviewOnPopupClose = 1

    "don't autoselect first item in omnicomplete, show if only one item (for preview)
    "remove preview if you don't want to see any documentation whatsoever.
    set completeopt=longest,menuone,preview
    " Fetch full documentation during omnicomplete requests.
    " There is a performance penalty with this (especially on Mono)
    " By default, only Type/Method signatures are fetched. Full documentation can still be fetched when
    " you need it with the :OmniSharpDocumentation command.
    " let g:omnicomplete_fetch_documentation=1

    "Move the preview window (code documentation) to the bottom of the screen, so it doesn't move the code!
    "You might also want to look at the echodoc plugin
    set splitbelow

    " Synchronous build (blocks Vim)
    "autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
    " Builds can also run asynchronously with vim-dispatch installed
    autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuildAsync<cr>

    "The following commands are contextual, based on the current cursor position.

    autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
    nnoremap <leader>fi :OmniSharpFindImplementations<cr>
    nnoremap <leader>ft :OmniSharpFindType<cr>
    nnoremap <leader>fs :OmniSharpFindSymbol<cr>
    nnoremap <leader>fu :OmniSharpFindUsages<cr>
    nnoremap <leader>fm :OmniSharpFindMembersInBuffer<cr>
    " cursor can be anywhere on the line containing an issue for this one
    nnoremap <leader>x  :OmniSharpFixIssue<cr>
    nnoremap <leader>fx :OmniSharpFixUsings<cr>
    nnoremap <leader>tt :OmniSharpTypeLookup<cr>
    nnoremap <leader>dc :OmniSharpDocumentation<cr>

    "" Get Code Issues and syntax errors
    "let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']
    "autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

    "show type information automatically when the cursor stops moving
    autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()
    " this setting controls how long to pause (in ms) before fetching type / symbol information.
    set updatetime=500
    " Remove 'Press Enter to continue' message when type information is longer than one line.
    set cmdheight=2

    " Contextual code actions (requires CtrlP)
    nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
    " Run code actions with text selected in visual mode to extract method
    vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>

    " rename with dialog
    nnoremap <leader>nm :OmniSharpRename<cr>
    nnoremap <F2> :OmniSharpRename<cr>
    " rename without dialog - with cursor on the symbol to rename... ':Rename newname'
    command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

    " Force OmniSharp to reload the solution. Useful when switching branches etc.
    nnoremap <leader>rl :OmniSharpReloadSolution<cr>
    nnoremap <leader>cf :OmniSharpCodeFormat<cr>
    " Load the current .cs file to the nearest project
    nnoremap <leader>tp :OmniSharpAddToProject<cr>
    " Automatically add new cs files to the nearest project on save
    autocmd BufWritePost *.cs call OmniSharp#AddToProject()
    " (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
    nnoremap <leader>ss :OmniSharpStartServer<cr>
    nnoremap <leader>sp :OmniSharpStopServer<cr>

    " Add syntax highlighting for types and interfaces
    nnoremap <leader>th :OmniSharpHighlightTypes<cr>
    "Don't ask to save when changing buffers (i.e. when jumping to a type definition)
    set hidden
endfunction
unlet s:bundle

" -------------------------------------------------------
" jedi.vim
" https://github.com/davidhalter/jedi-vim
" -------------------------------------------------------
let s:jedi = neobundle#get("jedi-vim")
function! s:jedi.hooks.on_source(bundle)
    autocmd FileType python setlocal completeopt-=preview
    autocmd FileType python setlocal omnifunc=jedi#completions

    let g:jedi#completions_enabled = 0
    let g:jedi#auto_vim_configuration = 0

    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
    let g:neocomplete#force_omni_input_patterns.python = '\h\w*\|[^. \t]\.\w*'

    let g:jedi#goto_definitions_command = "<leader>jd"
    let g:jedi#documentation_command    = "K"
    let g:jedi#usages_command           = "<leader>jn"
    let g:jedi#completions_command      = "<C-Space>"
    let g:jedi#rename_command           = "<leader>jr"
    let g:jedi#show_call_signatures     = "1"
endfunction
unlet s:jedi

" -------------------------------------------------------
" neosnippet
" -------------------------------------------------------
let s:bundle = neobundle#get("neosnippet")
function! s:bundle.hooks.on_source(bundle)
    let g:neosnippet#enable_snipmate_compatibility = 1

    " Plugin key-mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-m>     <Plug>(neosnippet_expand_target)

    " SuperTab like snippets behavior.
    " imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
    "             \ "\<Plug>(neosnippet_expand_or_jump)"
    "             \ : pumvisible() ? "\<C-n>" : "\<TAB>"
    " smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
    "             \ "\<Plug>(neosnippet_expand_or_jump)"
    "             \ : "\<TAB>"

    " For snippet_complete marker.
    if has('conceal')
        set conceallevel=2 concealcursor=i
    endif

    if !exists("g:neosnippet#snippets_directory")
        let g:neosnippet#snippets_directory = ""
    endif
    let g:neosnippet#snippets_directory=$MY_VIMRUNTIME . '/bundle/vim-snippets/snippets'
endfunction
unlet s:bundle

" -------------------------------------------------------
" vim-clang-format
" -------------------------------------------------------
let s:bundle = neobundle#get("vim-clang-format")
function! s:bundle.hooks.on_source(bundle)
    autocmd FileType c,cpp,objc nmap <buffer><Leader>cf :<C-u>ClangFormat<CR>
    autocmd FileType c,cpp,objc vmap <buffer><Leader>cf :ClangFormat<CR>
    " base style.
    " llvm, google, chromium, or mozilla
    "let g:clang_format#code_style = 'google'

    " Coding style options as dictionary.
    let g:clang_format#style_options = {
                \ "AccessModifierOffset" : -4,
                \ "AllowShortIfStatementsOnASingleLine" : "true",
                \ "AlwaysBreakTemplateDeclarations" : "true",
                \ "Standard" : "C++11"
                \ }
endfunction
unlet s:bundle

" -------------------------------------------------------
" vim-go
" :GoInstallBinaries in root after :NeoBundleInstall,
" -------------------------------------------------------
let s:bundle = neobundle#get("vim-go")
function! s:bundle.hooks.on_source(bundle)
    au FileType go nmap <Leader>ds <Plug>(go-implements)
    au FileType go nmap <Leader>di <Plug>(go-info)
    au FileType go nmap <Leader>dd <Plug>(go-doc)
    au FileType go nmap <Leader>dv <Plug>(go-doc-vertical)
    au FileType go nmap <Leader>db <Plug>(go-doc-browser)
    au FileType go nmap <Leader>dr <Plug>(go-run)
    au FileType go nmap <Leader>db <Plug>(go-build)
    au FileType go nmap <Leader>dt <Plug>(go-test)
    au FileType go nmap <Leader>dc <Plug>(go-coverage)
    au FileType go nmap vd <Plug>(go-def)
    au FileType go nmap <Leader>vs <Plug>(go-def-split)
    au FileType go nmap <Leader>vv <Plug>(go-def-vertical)
    au FileType go nmap <Leader>vt <Plug>(go-def-tab)
    au FileType go nmap <Leader>de <Plug>(go-rename)

    let g:go_snippet_engine = "neosnippet"

    "Disable opening browser after posting to your snippet to play.golang.org
    "let g:go_play_open_browser = 0

    "By default vim-go shows errors for the fmt command, to disable it
    "let g:go_fmt_fail_silently = 1

    "Enable goimports to automatically insert import paths instead of gofmt
    let g:go_fmt_command = "goimports"

    "Disable auto fmt on save
    " let g:go_fmt_autosave = 0

    "By default binaries are installed to $GOBIN or $GOPATH/bin. To change it:
    "let g:go_bin_path = expand("~/.gotools")
    "let g:go_bin_path = "/home/fatih/.mypath"      "or give absolute path

    " " By default syntax-highlighting for Functions, Methods and Structs is disabled. To change it:
    " let g:go_highlight_functions = 1
    " let g:go_highlight_methods = 1
    " let g:go_highlight_structs = 1
endfunction
unlet s:bundle

autocmd FileType go call s:golang_settings()
function! s:golang_settings()
    exe "set rtp+=".globpath($GOPATH, 'src/github.com/nsf/gocode/vim')

    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
	let g:neocomplete#force_omni_input_patterns.go = '\h\w\.\w*'
endfunction

" -------------------------------------------------------
" vim-stargate
" -------------------------------------------------------
let s:bundle = neobundle#get("vim-stargate")
function! s:bundle.hooks.on_source(bundle)
    " インクルードディレクトリのパスを設定
    if !exists('g:stargate#include_paths')
        let g:stargate#include_paths = {}
    endif
    " let g:stargate#include_paths['cpp'] = s:include_paths_cpp
endfunction
unlet s:bundle

" -------------------------------------------------------
" switch.vim
" -------------------------------------------------------
nmap <silent> <C-j> :<C-u>Switch<CR>
let g:switch_custom_definitions =
            \ [
            \   [ 'TRUE', 'FALSE' ],
            \   {
            \         '\(\k\+\)'    : '''\1''',
            \       '''\(.\{-}\)''' :  '"\1"',
            \        '"\(.\{-}\)"'  :   '\1',
            \   },
            \ ]

" " -------------------------------------------------------
" " Gundo
" " -------------------------------------------------------
" nmap <Leader>g :GundoToggle<CR>

" -------------------------------------------------------
" vim-easymotion
" -------------------------------------------------------
" Disable default mapping.
" let g:EasyMotion_do_mapping = 0
" map <Leader><Leader> <Plug>(easymotion-prefix)
if g:use_dvorak
    map s <Plug>(easymotion-prefix)
else
    map ; <Plug>(easymotion-prefix)
end

" 2-character search motion
" overwrite to f{char}, and t{char} of default key binding.
nmap f <Plug>(easymotion-s2)
nmap t <Plug>(easymotion-t2)

" n-character search motion
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
" map  n <Plug>(easymotion-next)
" map  N <Plug>(easymotion-prev)

" hjkl motions
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion

" Smartcase & Smartsign
let g:EasyMotion_smartcase = 1

let g:EasyMotion_use_smartsign_us = 1 " US layout
"let g:EasyMotion_use_smartsign_jp = 1 " JP layout

" Migemo feature
if has('migemo')
    let g:EasyMotion_use_migemo = 1
endif

" " -------------------------------------------------------
" " open-browser.vim
" " -------------------------------------------------------
" let g:netrw_nogx = 1 " disable netrw's gx mapping.
" nmap gx <Plug>(openbrowser-smart-search)
" vmap gx <Plug>(openbrowser-smart-search)
"
" " ググる
" nnoremap <Leader>gg :<C-u>OpenBrowserSearch<Space><C-r><C-w><Enter>

" -------------------------------------------------------
" vim-expand-region
" -------------------------------------------------------
map <SPACE> <Plug>(expand_region_expand)
map <S-SPACE> <Plug>(expand_region_shrink)

" -------------------------------------------------------
" vim-textmanip
" -------------------------------------------------------
" use Enter and Shift-Enter to insert blank line.
" which is useful since I enforce duplicate with '-r(replace' mode.
nmap <CR>   <Plug>(textmanip-blank-below)
nmap <S-CR> <Plug>(textmanip-blank-above)
xmap <CR>   <Plug>(textmanip-blank-below)
xmap <S-CR> <Plug>(textmanip-blank-above)

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

" -------------------------------------------------------
" vim-indent-guides
" -------------------------------------------------------
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey

let g:indent_guides_enable_on_vim_startup = 1

" -------------------------------------------------------
" emmet-vim
" -------------------------------------------------------
let s:bundle = neobundle#get("emmet-vim")
function! s:bundle.hooks.on_source(bundle)
    " オムニ補完
    let g:use_emmet_complete_tag = 1

    " キーマップ
    let g:user_emmet_expandabbr_key = '<Leader>z,'
    let g:user_emmet_expandword_key = '<Leader>z;'
    let g:user_emmet_balancetaginward_key = '<Leader>zd'
    let g:user_emmet_balancetagoutward_key = '<Leader>zD'
    let g:user_emmet_next_key = '<Leader>zn'
    let g:user_emmet_prev_key = '<Leader>zN'
    let g:user_emmet_imagesize_key = '<Leader>zi'
    let g:user_emmet_togglecomment_key = '<Leader>z/'
    let g:user_emmet_splitjointag_key = '<Leader>zj'
    let g:user_emmet_removetag_key = '<Leader>zk'
    let g:user_emmet_anchorizeurl_key = '<Leader>za'
    let g:user_emmet_anchorizesummary_key = '<Leader>zA'
    let g:user_emmet_mergelines_key = '<Leader>zm'
    let g:user_emmet_codepretty_key = '<Leader>zc'

    let g:user_emmet_settings = {
                \  'lang': "jp",
                \  'html': {
                \       'default_attributes': {
                \           'link:less': [
                \               { 'rel': 'stylesheet/less',
                \                 'type': 'text/css',
                \                 'href': '|style.less',
                \                 'media': 'all'
                \               }
                \           ],
                \       },
                \   },
                \ }
endfunction
unlet s:bundle

" -------------------------------------------------------
" vim-jsdoc
" -------------------------------------------------------
autocmd FileType html,javascript,coffee call s:jsdoc()
function! s:jsdoc()
    nmap <Leader>d :JsDoc<CR>
endfunction

" -------------------------------------------------------
" DoxygenToolkit.vim
" -------------------------------------------------------
let s:bundle = neobundle#get("DoxygenToolkit.vim")
function! s:bundle.hooks.on_source(bundle)
    nmap <Leader>dc :Dox<CR>
    nmap <Leader>da :DoxAuthor<CR>
    nmap <Leader>dl :DoxLic<CR>
    nmap <Leader>du :DoxUndoc<CR>
    nmap <Leader>db :DoxBlock<CR>

    autocmd FileType c,cpp call s:doxygen_cpp()
    function! s:doxygen_cpp()
        let g:DoxygenToolkit_returnTag="@retval "
    endfunction
endfunction
unlet s:bundle

" -------------------------------------------------------
" simple-javascript-indenter
" -------------------------------------------------------
let s:bundle = neobundle#get("simple-javascript-indenter")
function! s:bundle.hooks.on_source(bundle)
    " この設定入れるとshiftwidthを1にしてインデントしてくれる
    let g:SimpleJsIndenter_BriefMode = 1
    " この設定入れるとswitchのインデントがいくらかマシに
    let g:SimpleJsIndenter_CaseIndentLevel = -1
endfunction
unlet s:bundle

" -------------------------------------------------------
" JSON.vim
" -------------------------------------------------------
au! BufRead,BufNewFile *.json set filetype=json

let s:bundle = neobundle#get("JSON.vim")
function! s:bundle.hooks.on_source(bundle)
    setl autoindent
    setl formatoptions=tcq2l
    setl textwidth=78 shiftwidth=2
    setl softtabstop=2 tabstop=8
    setl expandtab
    setl foldmethod=syntax
endfunction
unlet s:bundle

" -------------------------------------------------------
" tagbar
" -------------------------------------------------------
nmap <silent> <Leader>t :TagbarToggle<CR>

let s:bundle = neobundle#get("tagbar")
function! s:bundle.hooks.on_source(bundle)
    " you should run for use 'go get -u github.com/jstemmer/gotags'
    let g:tagbar_type_go = {
                \ 'ctagstype' : 'go',
                \ 'kinds'     : [
                \ 'p:package',
                \ 'i:imports:1',
                \ 'c:constants',
                \ 'v:variables',
                \ 't:types',
                \ 'n:interfaces',
                \ 'w:fields',
                \ 'e:embedded',
                \ 'm:methods',
                \ 'r:constructor',
                \ 'f:functions'
                \ ],
                \ 'sro' : '.',
                \ 'kind2scope' : {
                \ 't' : 'ctype',
                \ 'n' : 'ntype'
                \ },
                \ 'scope2kind' : {
                \ 'ctype' : 't',
                \ 'ntype' : 'n'
                \ },
                \ 'ctagsbin'  : 'gotags',
                \ 'ctagsargs' : '-sort -silent'
                \ }
endfunction
unlet s:bundle

" -------------------------------------------------------
" SrcExpl
" -------------------------------------------------------
" 機能ON/OFF
" The switch of the Source Explorer
nmap <silent> <Leader>s :SrcExplToggle<CR>

let s:bundle = neobundle#get("SrcExpl")
function! s:bundle.hooks.on_source(bundle)
    " Set the height of Source Explorer window
    "let g:SrcExpl_winHeight = 8
    " Set 100 ms for refreshing the Source Explorer
    let g:SrcExpl_refreshTime = 100

    " Set "Enter" key to jump into the exact definition context
    "let g:SrcExpl_jumpKey = "<ENTER>"

    " Set "Space" key for back from the definition context
    "let g:SrcExpl_gobackKey = "<SPACE>"

    " // Enable/Disable the local definition searching, and note that this is not
    " // guaranteed to work, the Source Explorer doesn't check the syntax for now.
    " // It only searches for a match with the keyword according to command 'gd'
    "let g:SrcExpl_searchLocalDef = 1

    " // Do not let the Source Explorer update the tags file when opening
    let g:SrcExpl_isUpdateTags = 0

    " // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to
    " //  create/update a tags file
    let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."

    "
    " // Set "<F12>" key for updating the tags file artificially
    let g:SrcExpl_updateTagsKey = "<Leader>su"

    " // Set "<F3>" key for displaying the previous definition in the jump list
    "let g:SrcExpl_prevDefKey = "<F3>"
    "
    " // Set "<F4>" key for displaying the next definition in the jump list
    "let g:SrcExpl_nextDefKey = "<F4>"

    " SrcExplが競合を避けるために知っておくべきバッファ
    let g:SrcExpl_pluginList = [
                \ "__Tag_bar__",
                \ "[vimfiler] - default",
                \ "Source_Explorer",
                \ "[場所リスト][-]",
                \ "GoToFile",
                \ "YankRing",
                \ "__Gundo_Preview__",
                \ "swoopBuf"
                \ ]
endfunction
unlet s:bundle

" -------------------------------------------------------
" vim-hier
" -------------------------------------------------------
let g:hier_enabled = 1

" -------------------------------------------------------
" quickrun.vim
" -------------------------------------------------------
let g:quickrun_config = {
            \ "_" : {
            \     "hook/quickfix_replate_tempname_to_bufnr/enable_exit" : 1,
            \     "hook/quickfix_replate_tempname_to_bufnr/priority_exit" : -10,
            \     "outputter/buffer/split": "botright",
            \ },
            \ }
let s:clangcpp_cmdopt = '-std=c++1y'
if has('unix') || has('macunix')
    let s:clangcpp_cmdopt += ' -stdlib=libc++'
endif

" let s:clangcpp_cmdopt = s:clangcpp_cmdopt . s:include_paths_string_mingw

" if executable("clang++")
"     let g:quickrun_config['cpp/clang++1y'] = {
"                 \ 'cmdopt': s:clangcpp_cmdopt,
"                 \ "exec" : "%c %o -fsyntax-only %s:p",
"                 \ }
"     let g:quickrun_config['cpp'] = {'type': 'cpp/clang++1y'}
" else
"     let g:quickrun_config['cpp/g++1y'] = {
"                 \ 'cmdopt': s:clangcpp_cmdopt,
"                 \ }
"     let g:quickrun_config['cpp'] = {'type': 'cpp/g++1y'}
" endif

" -------------------------------------------------------
" Syntastic
" -------------------------------------------------------
let g:syntastic_auto_loc_list = 1 " エラー時に自動的にロケーションリストを開く

let g:syntastic_mode_map = { 'mode': 'active',
            \ 'active_filetypes': [],
            \ 'passive_filetypes': [],
            \ }

" JavaScript
let g:syntastic_javascript_checkers = ['jshint']

" C++
let g:syntastic_cpp_compiler_options = '-std=c++1y'
if has('unix') || has('macunix')
    let g:syntastic_cpp_compiler_options += ' -stdlib=libc++'
endif
" let g:syntastic_cpp_compiler_options = g:syntastic_cpp_compiler_options . s:include_paths_string_mingw

if executable("clang++")
    let g:syntastic_cpp_compiler = 'clang++'
endif

" " ignore python for use python-mode.
" let g:syntastic_ignore_files = ['\.py$']

"with lightline
let g:lightline = {
      \ 'active': {
      \   'right': [ [ 'syntastic', 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ }
      \ }
let g:syntastic_mode_map = { 'mode': 'passive' }
augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost * call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

" -------------------------------------------------------
" vim-smartinput
" -------------------------------------------------------
" 括弧内でのスペース入力と削除
call smartinput#map_to_trigger('i', '<Space>', '<Space>', '<Space>')
call smartinput#map_to_trigger('i', '<BS>', '<BS>', '<BS>')
call smartinput#define_rule({
            \ 'at'    : '(\%#)',
            \ 'char'  : '<Space>',
            \ 'input' : '<Space><Space><Left>'
            \ })
call smartinput#define_rule({
            \ 'at'    : '( \%# )',
            \ 'char'  : '<BS>',
            \ 'input' : '<Del><BS>'
            \ })
call smartinput#define_rule({
            \   'at'    : '\[\%#\]',
            \   'char'  : '<Space>',
            \   'input' : '<Space><Space><Left>'
            \   })
call smartinput#define_rule({
            \   'at'    : '\[ \%# \]',
            \   'char'  : '<BS>',
            \   'input' : '<Del><BS>'
            \   })
call smartinput#define_rule({
            \   'at'    : '{\%#}',
            \   'char'  : '<Space>',
            \   'input' : '<Space><Space><Left>'
            \   })
call smartinput#define_rule({
            \   'at'    : '{ \%# }',
            \   'char'  : '<BS>',
            \   'input' : '<Del><BS>'
            \   })
call smartinput#define_rule({
            \   'at'    : '<\%#>',
            \   'char'  : '<Space>',
            \   'input' : '<Space><Space><Left>',
            \   })
call smartinput#define_rule({
            \   'at'    : '< \%# >',
            \   'char'  : '<BS>',
            \   'input' : '<Del><BS>',
            \   })

" C/C++
call smartinput#map_to_trigger('i', ';', ';', ';')
call smartinput#define_rule({
            \   'at'       : ';\%#',
            \   'char'     : ';',
            \   'input'    : '<BS>::',
            \   'filetype' : ['cpp'],
            \   })
" boost:: の補完
call smartinput#define_rule({
            \   'at'       : '\<b;\%#',
            \   'char'     : ';',
            \   'input'    : '<BS>oost::',
            \   'filetype' : ['cpp'],
            \   })
" std:: の補完
call smartinput#define_rule({
            \   'at'       : '\<s;\%#',
            \   'char'     : ';',
            \   'input'    : '<BS>td::',
            \   'filetype' : ['cpp'],
            \   })
" comment
call smartinput#map_to_trigger('i', '*', '*', '*')
call smartinput#define_rule({
            \   'at'       : '/\%#',
            \   'char'     : '*',
            \   'input'    : '*  */<Left><Left><Left>',
            \   'filetype' : ['c', 'cpp'],
            \   })

" Ruby
call smartinput#map_to_trigger('i', '#', '#', '#')
call smartinput#define_rule({
            \   'at'       : '\%#',
            \   'char'     : '#',
            \   'input'    : '#{}<Left>',
            \   'filetype' : ['ruby'],
            \   'syntax'   : ['Constant', 'Special'],
            \   })

call smartinput#map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')
call smartinput#define_rule({
            \   'at' : '\({\|\<do\>\)\s*\%#',
            \   'char' : '<Bar>',
            \   'input' : '<Bar><Bar><Left>',
            \   'filetype' : ['ruby'],
            \    })

" Vim Script
call smartinput#define_rule({
            \   'at'       : '\\\%(\|%\|z\)\%#',
            \   'char'     : '(',
            \   'input'    : '(\)<Left><Left>',
            \   'filetype' : ['vim'],
            \   'syntax'   : ['String'],
            \   })

" -------------------------------------------------------
" vim-submode
" -------------------------------------------------------
call submode#enter_with('bufmove', 'n', '', 's>', '<C-w>>')
call submode#enter_with('bufmove', 'n', '', 's<', '<C-w><')
call submode#enter_with('bufmove', 'n', '', 's+', '<C-w>+')
call submode#enter_with('bufmove', 'n', '', 's-', '<C-w>-')
call submode#map('bufmove', 'n', '', '>', '<C-w>>')
call submode#map('bufmove', 'n', '', '<', '<C-w><')
call submode#map('bufmove', 'n', '', '+', '<C-w>+')
call submode#map('bufmove', 'n', '', '-', '<C-w>-')

" -------------------------------------------------------
" vim-multiple-cursors
" -------------------------------------------------------
" let g:multi_cursor_use_default_mapping = 0
"
" let g:multi_cursor_next_key='<C-n>'
" let g:multi_cursor_prev_key='<C-p>'
" let g:multi_cursor_skip_key='<C-x>'
" let g:multi_cursor_quit_key='<Esc>'

" " -------------------------------------------------------
" " yankround.vim
" " -------------------------------------------------------
" nmap p <Plug>(yankround-p)
" xmap p <Plug>(yankround-p)
" nmap P <Plug>(yankround-P)
" nmap gp <Plug>(yankround-gp)
" xmap gp <Plug>(yankround-gp)
" nmap gP <Plug>(yankround-gP)
" nmap <C-p> <Plug>(yankround-prev)
" nmap <C-n> <Plug>(yankround-next)
"
" " 履歴取得数
" let g:yankround_max_history = 50

" -------------------------------------------------------
" sass-compile
" -------------------------------------------------------
let s:bundle = neobundle#get("sass-compile.vim")
function! s:bundle.hooks.on_source(bundle)
    "" 編集したファイルから遡るフォルダの最大数
    let g:sass_compile_cdloop = 5

    " ファイル保存時に自動コンパイル（1で自動実行）
    let g:sass_compile_auto = 0

    " 自動コンパイルを実行する拡張子
    let g:sass_compile_file = ['scss', 'sass']

    " cssファイルが入っているディレクトリ名（前のディレクトリほど優先）
    let g:sass_compile_cssdir = ['css', 'stylesheet']

    " コンパイル実行前に実行したいコマンドを設定
    " 例：growlnotifyによる通知
    " let g:sass_compile_beforecmd = "growlnotify -t 'sass-compile.vim' -m 'start sass compile.'"

    " コンパイル実行後に実行したいコマンドを設定
    " 例：growlnotifyによる通知(${sasscompileresult}は実行結果)
    " let g:sass_compile_aftercmd = "growlnotify -t 'sass-compile.vim' -m ${sasscompileresult}"
endfunction
unlet s:bundle

" -------------------------------------------------------
"  codic-complete for codic.
" -------------------------------------------------------
inoremap <silent> <C-x><C-t> <C-R>=<SID>codic_complete()<CR>
function! s:codic_complete()
  let line = getline('.')
  let start = match(line, '\k\+$')
  let cand = s:codic_candidates(line[start :])
  call complete(start +1, cand)
  return ''
endfunction
function! s:codic_candidates(arglead)
  let cand = codic#search(a:arglead, 30)
  " error
  if type(cand) == type(0)
    return []
  endif
  " english -> english terms
  if a:arglead =~# '^\w\+$'
    return map(cand, '{"word": v:val["label"], "menu": join(map(copy(v:val["values"]), "v:val.word"), ",")}')
  endif
  " japanese -> english terms
  return s:reverse_candidates(cand)
endfunction
function! s:reverse_candidates(cand)
  let _ = []
  for c in a:cand
    for v in c.values
      call add(_, {"word": v.word, "menu": !empty(v.desc) ? v.desc : c.label })
    endfor
  endfor
  return _
endfunction

" -------------------------------------------------------
" vim-easy-align
" -------------------------------------------------------
" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
" vmap <Enter> <Plug>(EasyAlign)
vmap ga <Plug>(EasyAlign)
vmap gl <Plug>(LiveEasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
nmap gl <Plug>(LiveEasyAlign)

" -------------------------------------------------------
" vim-swoop
" -------------------------------------------------------
" You can disabledefault mapping by:
let g:swoopUseDefaultKeyMap = 0

if g:use_dvorak
    nmap <Leader>b :call Swoop()<CR>
    vmap <Leader>b :call SwoopSelection()<CR>
    nmap <Leader>m :call SwoopMulti()<CR>
    vmap <Leader>m :call SwoopMultiSelection()<CR>
else
    nmap <Leader>n :call Swoop()<CR>
    vmap <Leader>n :call SwoopSelection()<CR>
    nmap <Leader>m :call SwoopMulti()<CR>
    vmap <Leader>m :call SwoopMultiSelection()<CR>
end

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
