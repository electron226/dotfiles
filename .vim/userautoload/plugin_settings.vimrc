" -------------------------------------------------------
" include paths use omni complements and other scripts.
" -------------------------------------------------------
" Define include Paths.
if !exists('s:include_paths_cpp')
    let s:include_paths_cpp = []
endif

if has('win32') || has('win64') || has('win32unix')
    " mingw settings.
    if isdirectory(expand('$MINGW_HOME'))
        let s:mingw_path = expand('$MINGW_HOME')
    else
        let s:mingw_path = 'f:/local/mingw64'
    endif
    let s:mingw_build_target = 'x86_64-w64-mingw32'
    let s:mingw_gcc_version = '4.8.2'

    " Windows
    let s:include_paths_cpp = filter(
                \ [
                \   'F:/local/lib/igloo-igloo.1.1.1',
                \ ] +
                \ split(glob('f:/local/lib/*/include'), '\n') +
                \ split(glob(s:mingw_path . '/include/c++/*'), '\n') +
                \ split(glob(s:mingw_path . '/include/*/c++/*'), '\n') +
                \ split(glob(s:mingw_path . '/include/*'), '\n') +
                \ split(glob(s:mingw_path . '/lib/gcc/' . s:mingw_build_target . '/' . s:mingw_gcc_version . '/*'), '\n') +
                \ split(glob(s:mingw_path . '/' . s:mingw_build_target . '/include/*'), '\n'),
                \ 'isdirectory(v:val)')
else
    " Linux
    let s:include_paths_cpp = filter(
                \ split(glob('/include/c++/*'), '\n') +
                \ split(glob('/include/*/c++/*'), '\n') +
                \ split(glob('/include/*'), '\n'),
                \ 'isdirectory(v:val)')
endif

" Boost Path
if !isdirectory(expand('$BOOST_ROOT'))
    if has('win32') || has('win64')
        " Windows
        call add(s:include_paths_cpp, expand('f:/local/lib/boost/include/boost-1_55'))
    else
        " Ubuntu
        call add(s:include_paths_cpp, expand('/usr/include/boost'))
    endif
else
    call add(s:include_paths_cpp, expand('$BOOST_ROOT') . '/include/boost-1_55')
endif

" s:clang_path = Path in clang.dll or libclang.so or libclang.dll.
" be using clang_complete.
if isdirectory(expand('$LLVM_HOME'))
    let s:libclang_path = split(globpath('$LLVM_HOME', 'bin/**/libclang.*'), '\n')[0]
    let s:clang_path = strpart(s:libclang_path, 0, match(s:libclang_path, 'libclang.*') - 1)
else
    if has('win32') || has('win64')
        " Windows
        let s:clang_path = expand('F:/local/llvm/build/bin/Release')
    else
        " OS X | UNIX | Ubuntu
        let s:clang_path = expand('/usr/local/bin')
    endif
endif

if !isdirectory(s:clang_path) ||
            \ !(filereadable(expand(s:clang_path . '/libclang.dll')) ||
            \ filereadable(expand(s:clang_path . '/libclang.so'))) ||
            \ !filereadable(expand(s:clang_path . '/clang.exe'))
    echo "Can't detect libclang.dll or libclang.so -&gt; " . s:clang_path
endif

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

"普通に開く
nnoremap <silent> <Leader>fn :<C-u>VimFiler<CR>

"現在開いているバッファのディレクトリを開く
nnoremap <silent> <Leader>fd :<C-u>VimFilerBufferDir -quit<CR>

"現在開いているバッファをIDE風に開く
"nnoremap <silent> ,f :<C-u>VimFilerBufferDir
"            \  -split -simple -direction=botright -winwidth=35 -no-quit<CR>
nnoremap <silent> <Leader>f :<C-u>VimFilerBufferDir
            \ -split -simple -winwidth=30 -no-quit<CR>


" -------------------------------------------------------
" unite.vim
" -------------------------------------------------------
" 入力モードで開始する
let g:unite_enable_start_insert=1

" ウインドウ一覧
nnoremap <silent> <Leader>uw :<C-u>Unite window<CR>
" バッファ一覧
nnoremap <silent> <Leader>ub :<C-u>Unite buffer<CR>
" ブックマーク一覧
nnoremap <silent> <Leader>uk :<C-u>Unite bookmark<CR>
" ファイル一覧
nnoremap <silent> <Leader>uf
            \ :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> <Leader>ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> <Leader>um :<C-u>Unite file_mru<CR>
" 全部乗せ
nnoremap <silent> <Leader>ua :<C-u>UniteWithBufferDir
            \ -buffer-name=files buffer file_mru bookmark file<CR>

" カーソル下のキーワードを含む行を表示
nnoremap <silent> <Leader>ul :<C-u>UniteWithCursorWord -no-quit line<CR>

" unite.vim上でのキーマッピング
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    " 単語単位からパス単位で削除するように変更
    "imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

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
"    nnoremap <silent> <Leader>ubu :<C-u>Unite build<CR>
"    nnoremap <silent> <Leader>ubut :<C-u>Unite build:!<CR>

" -------------------------------------------------------
" unite-tag
" -------------------------------------------------------
"    nnoremap <silent> <Leader>ut :<C-u>Unite tag<CR>
"    nnoremap <silent> <Leader>utf :<C-u>Unite tag/file<CR>
"    nnoremap <silent> <Leader>uti :<C-u>Unite tag/include<CR>
"
"    " unite-tagで表示する
"    command!
"        \ -nargs=? PopupTags
"        \ call <SID>TagsUpdate()
"        \ |Unite tag:<args>
"
" neocomplete が作成した tag ファイルのパスを tags に追加する
"function! s:TagsUpdate()
"    " include している tag ファイルが毎回同じとは限らないので毎回初期化
"    setlocal tags=
"    for filename in neocomplete#sources#include#get_include_files(bufnr('%'))
"        execute "setlocal tags+=".neocomplete#cache#encode_name('tags_output', filename)
"    endfor
"endfunction
"
"    function! s:get_func_name(word)
"        let end = match(a:word, '<\|[\|(')
"        return end == -1 ? a:word : a:word[ : end-1 ]
"    endfunction
"
"    " カーソル下のワード(word)で絞り込み
"    noremap <silent> g<C-]> :<C-u>execute "PopupTags ".expand('<cword>')<CR>
"
"    " カーソル下のワード(WORD)で ( か < か [ までが現れるまでで絞り込み
"    " 例)
"    " boost::array<std::stirng... → boost::array で絞り込み
"    noremap <silent> G<C-]> :<C-u>execute "PopupTags "
"        \.substitute(<SID>get_func_name(expand('<cWORD>')), '\:', '\\\:', "g")<CR>

" -------------------------------------------------------
" unite-gtag
" -------------------------------------------------------
"    nnoremap <silent> <Leader>ugt :<C-u>Unite gtags/context<CR>
"    nnoremap <silent> <Leader>ugtr :<C-u>Unite gtags/ref<CR>
"    nnoremap <silent> <Leader>ugtd :<C-u>Unite gtags/def<CR>
"    nnoremap <silent> <Leader>ugtg :<C-u>Unite gtags/grep<CR>
"    nnoremap <silent> <Leader>ugta :<C-u>Unite gtags/completion<CR>

" -------------------------------------------------------
" unite-outline
" -------------------------------------------------------
"    nnoremap <silent> <Leader>uo :<C-u>Unite outline<CR>

" -------------------------------------------------------
" unite-grep
" -------------------------------------------------------
"    " unite-grepのキーマップ
"    " 選択した文字列をunite-grep
"    vnoremap /g y:Unite grep::-iHRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>


" -------------------------------------------------------
" neocomplete
" -------------------------------------------------------
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

" キャッシュ保存先
if has('win32') || has('win64')
    let g:neocomplete#data_directory = 'D:/.neocomplete'
elseif has('macunix')
    let g:neocomplete#data_directory = '/Volumes/RamDisk/.neocomplete'
else
    let g:neocomplete#data_directory = '/tmp/.neocomplete'
endif

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

" Define include.
let s:neocomplete_include_paths_cpp = join(s:include_paths_cpp, ',')

if !exists('g:neocomplete#sources#include#paths')
    let g:neocomplete#sources#include#paths = {}
endif
let g:neocomplete#sources#include#paths = {
            \ 'c' : s:neocomplete_include_paths_cpp,
            \ 'cpp' : s:neocomplete_include_paths_cpp,
            \ }

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
"autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'


" -------------------------------------------------------
" neosnippet
" -------------------------------------------------------
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-m>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"            \ "\<Plug>(neosnippet_expand_or_jump)"
"            \ : pumvisible() ? "\<C-n>" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"            \ "\<Plug>(neosnippet_expand_or_jump)"
"            \ : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif

if !exists("g:neosnippet#snippets_directory")
    let g:neosnippet#snippets_directory = ""
endif
let g:neosnippet#snippets_directory=$MY_VIMRUNTIME . '/snippets'

" c/c++ include paths to string.
let s:include_paths_string = ''
for path in s:include_paths_cpp
    if (!isdirectory(path))
        echo "Can't detect directory. : " . path
    endif

    " msvc
    "let s:include_paths_string = s:include_paths_string . '/I ' . path . ' '
    " mingw64
    let s:include_paths_string = s:include_paths_string . '-I ' . path . ' '
endfor

" -------------------------------------------------------
" clang_complete
" -------------------------------------------------------
let g:neocomplete#force_overwrite_completefunc = 1

if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
let g:neocomplete#force_omni_input_patterns.objc = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#force_omni_input_patterns.objcpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

let g:clang_auto_select=0
let g:clang_complete_auto=0

let g:clang_use_library=1
let g:clang_debug=1

let g:clang_library_path = s:clang_path
let g:clang_exec = expand(s:clang_path . '/clang.exe')

" Build msvc
" You must compile clang on msvc of 64 bit If you use windows of 64 bit.
let g:clang_user_options =
            \ '"' . s:include_paths_string . '"' .
            \ ' -std=c++11' .
            \ ' 2> NUL || exit 0"'
" Build mingw32
"let g:clang_user_options =
"            \ '"' . s:include_paths_string . '"' .
"            \ ' -std=c++11 -fms-extensions -fmsc-version=1300 -fgnu-runtime' .
"            \ ' -D__MSVCRT_VERSION__=0x700 -D_WIN32_WINNT=0x0500' .
"            \ ' -include malloc.h'

" -------------------------------------------------------
" vim-marching
" -------------------------------------------------------
"" clang コマンドの設定
"let g:marching_clang_command = 'clang.exe'
"
"" オプションを追加する場合
"let g:marching_clang_command_option="-std=c++11"
"
"" インクルードディレクトリのパスを設定
"let g:marching_include_paths = s:include_paths_cpp
"
"" neocomplete.vim と併用して使用する場合
"let g:marching_enable_neocomplete = 1
"
"if !exists('g:neocomplete#force_omni_input_patterns')
"    let g:neocomplete#force_omni_input_patterns = {}
"endif
"
"let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
"
"" 処理のタイミングを制御する
"" 短いほうがより早く補完ウィンドウが表示される
"set updatetime=200
"
"" オムニ補完時に補完ワードを挿入したくない場合
"imap <buffer> <C-x><C-o> <Plug>(marching_start_omni_complete)
"
"" キャッシュを削除してからオムに補完を行う
"imap <buffer> <C-x><C-x><C-o> <Plug>(marching_force_start_omni_complete)
"
"" 非同期ではなくて、同期処理でコード補完を行う場合
""let g:marching_backend = "sync_clang_command"

" -------------------------------------------------------
" vim-clang-format
" -------------------------------------------------------
autocmd FileType c,cpp,objc nmap <buffer><leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vmap <buffer><leader>cf :ClangFormat<CR>
" base style.
" llvm, google, chromium, or mozilla
"let g:clang_format#code_style = 'google'

" Coding style options as dictionary.
let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11",
            \ "BreakBeforeBraces" : "Stroustrup"}

" -------------------------------------------------------
" vim-stargate
" -------------------------------------------------------
" インクルードディレクトリのパスを設定
let g:stargate#include_paths = {
            \	"cpp" : s:include_paths_cpp
            \}


" -------------------------------------------------------
" OmniSharp
" -------------------------------------------------------
autocmd FileType cs call s:csharp_settings()
function! s:csharp_settings()
    let g:neocomplete#force_overwrite_completefunc = 1

    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
    let g:neocomplete#force_omni_input_patterns.cs = '.*'

    " recommended key-mappings of C#.
    inoremap <expr>.  neocomplcache#close_popup() . "."
    inoremap <expr>(  neocomplcache#close_popup() . "("
    inoremap <expr>)  neocomplcache#close_popup() . ")"
    inoremap <expr><space>  neocomplcache#close_popup() . " "
    inoremap <expr>;  neocomplcache#close_popup() . ";"

    "This is the default value, setting it isn't actually necessary
    "let g:OmniSharp_host = "http://localhost:2000"

    "Set the type lookup function to use the preview window instead of the status line
    let g:OmniSharp_typeLookupInPreview = 1

    "Showmatch significantly slows down omnicomplete
    "when the first match contains parentheses.
    set noshowmatch

    "Super tab settings
    "let g:SuperTabDefaultCompletionType = 'context'
    "let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"
    "let g:SuperTabDefaultCompletionTypeDiscovery = ["&omnifunc:<c-x><c-o>","&completefunc:<c-x><c-n>"]
    "let g:SuperTabClosePreviewOnPopupClose = 1

    "don't autoselect first item in omnicomplete, show if only one item (for preview)
    set completeopt=longest,menuone,preview

    nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
    " Builds can run asynchronously with vim-dispatch installed
    "nnoremap <F5> :wa!<cr>:OmniSharpBuildAsync<cr>

    nnoremap <F12> :OmniSharpGotoDefinition<cr>
    nnoremap gd :OmniSharpGotoDefinition<cr>
    nnoremap <leader>fi :OmniSharpFindImplementations<cr>
    nnoremap <leader>ft :OmniSharpFindType<cr>
    nnoremap <leader>fs :OmniSharpFindSymbol<cr>
    nnoremap <leader>fu :OmniSharpFindUsages<cr>
    nnoremap <leader>fm :OmniSharpFindMembersInBuffer<cr>
    nnoremap <leader>tt :OmniSharpTypeLookup<cr>
    "I find contextual code actions so useful that I have it mapped to the spacebar
    nnoremap <space> :OmniSharpGetCodeActions<cr>

    " rename with dialog
    nnoremap <leader>nm :OmniSharpRename<cr>
    nnoremap <F2> :OmniSharpRename<cr>
    " rename without dialog - with cursor on the symbol to rename... ':Rename newname'
    command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")
    " Force OmniSharp to reload the solution. Useful when switching branches etc.
    nnoremap <leader>rl :OmniSharpReloadSolution<cr>
    nnoremap <leader>cf :OmniSharpCodeFormat<cr>
    nnoremap <leader>tp :OmniSharpAddToProject<cr>
    " (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
    nnoremap <leader>ss :OmniSharpStartServer<cr>
    nnoremap <leader>sp :OmniSharpStopServer<cr>
    nnoremap <leader>th :OmniSharpHighlightTypes<cr>

    "Don't ask to save when changing buffers (i.e. when jumping to a type definition)
    set hidden
endfunction

" -------------------------------------------------------
" jedi.vim
" https://github.com/davidhalter/jedi-vim
" -------------------------------------------------------
autocmd FileType python call s:jedi_settings()
function! s:jedi_settings()
    autocmd FileType python setlocal omnifunc=jedi#Complete

    let g:jedi#popup_on_dot = 0

    let g:jedi#goto_command = "<leader>jg"
    let g:jedi#get_definition_command = "<leader>jd"
    let g:jedi#rename_command = "<leader>jr"
    let g:jedi#related_names_command = "<leader>jn"
    let g:jedi#pydoc = "K"
    let g:jedi#autocompletion_command = "<C-Space>"
endfunction

" -------------------------------------------------------
" javacomplate
" -------------------------------------------------------
"let s:javacomp = neobundle#get("javacomplete")
"function! s:javacomp.hooks.on_source(bundle)
"    autocmd Filetype java setlocal omnifunc=javacomplete#Complete
"    autocmd Filetype java setlocal completefunc=javacomplete#CompleteParamsInfo
"endfunction
"unlet s:javacomp

" -------------------------------------------------------
" RSense
" -------------------------------------------------------
"let s:rsense = neobundle#get("rsense")
"function! s:rsense.hooks.on_source(bundle)
"    let g:rsenseUseOmniFunc = 1
"
"    if filereadable(expand('$MY_VIMRUNTIME/bundle/rsense/bin/rsense'))
"        let g:rsenseHome = expand('$MY_VIMRUNTIME/bundle/rsense')
"
"        if !exists('g:neocomplete#force_omni_input_patterns')
"          let g:neocomplete#force_omni_input_patterns = {}
"        endif
"        let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"
"        let g:neocomplete#force_overwrite_completefunc = 1
"    endif
"endfunction
"unlet s:rsense


" -------------------------------------------------------
" switch.vim
" -------------------------------------------------------
nmap - :Switch<CR>
let g:switch_custom_definitions =
            \ [
            \   [ 'TRUE', 'FALSE' ]
            \ ]

" -------------------------------------------------------
" Gundo
" -------------------------------------------------------
nmap <Leader>g :GundoToggle<CR>

" -------------------------------------------------------
" vim-easymotion
" -------------------------------------------------------
let g:EasyMotion_leader_key = ';'
let g:EasyMotion_keys='abcdefghijklmnopqrstuvwxyz'

" -------------------------------------------------------
" open-browser.vim
" -------------------------------------------------------
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

" -------------------------------------------------------
" MultipleSearch
" -------------------------------------------------------
let g:MultipleSearchMaxColors = 8
let g:MultipleSearchColorSequence =
            \ "red, yellow, blue, green, magenta, cyan, gray, brown"
let g:MultipleSearchTextColorSequence =
            \ "white, black, white, black, white, black, black, white"

" -------------------------------------------------------
" vim-textmanip
" -------------------------------------------------------
" 選択したテキストの移動
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)

" 行の複製
xmap <C-d> <Plug>(textmanip-duplicate-down)
nmap <C-d> <Plug>(textmanip-duplicate-down)
xmap <C-D> <Plug>(textmanip-duplicate-up)
nmap <C-D> <Plug>(textmanip-duplicate-up)

" toggle insert/replace with <F10>
"nmap <F10> <Plug>(textmanip-toggle-mode)
"xmap <F10> <Plug>(textmanip-toggle-mode)

" use allow key to force replace movement
xmap  <Up>     <Plug>(textmanip-move-up-r)
xmap  <Down>   <Plug>(textmanip-move-down-r)
xmap  <Left>   <Plug>(textmanip-move-left-r)
xmap  <Right>  <Plug>(textmanip-move-right-r)

" -------------------------------------------------------
" vim-indent-guides
" -------------------------------------------------------
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey

let g:indent_guides_enable_on_vim_startup = 1

" -------------------------------------------------------
" vim-altr
" -------------------------------------------------------
nmap <Leader>k <Plug>(altr-forward)
nmap <Leader>j <Plug>(altr-back)

" Javascript(jasmine)
call altr#define('public/javascripts/%.js',
            \ 'spec/javascripts/%Spec.js',
            \ 'spec/javascripts/helpers/%Helper.js'
            \ )

" For Ruby tdd(RSpec)
call altr#define('%.rb', 'spec/%_spec.rb')

" For rails tdd(RSpec)
call altr#define('app/models/%.rb',
            \ 'spec/models/%_spec.rb',
            \ 'spec/factories/%s.rb'
            \ )
call altr#define('app/controllers/%.rb', 'spec/controllers/%_spec.rb')
call altr#define('app/helpers/%.rb', 'spec/helpers/%_spec.rb')

" -------------------------------------------------------
" emmet-vim
" -------------------------------------------------------
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
"
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
autocmd FileType c,cpp,python call s:doxygen()
function! s:doxygen()
    nmap <Leader>d :Dox<CR>
    nmap <Leader>da :DoxAuthor<CR>
    nmap <Leader>dl :DoxLic<CR>
    nmap <Leader>du :DoxUndoc<CR>
    nmap <Leader>db :DoxBlock<CR>

    autocmd FileType c,cpp call s:doxygen_cpp()
    function! s:doxygen_cpp()
        let g:DoxygenToolkit_returnTag="@retval "
    endfunction
endfunction

" -------------------------------------------------------
" simple-javascript-indenter
" -------------------------------------------------------
" この設定入れるとshiftwidthを1にしてインデントしてくれる
let g:SimpleJsIndenter_BriefMode = 1
" この設定入れるとswitchのインデントがいくらかマシに
let g:SimpleJsIndenter_CaseIndentLevel = -1

" -------------------------------------------------------
" JSON.vim
" -------------------------------------------------------
au! BufRead,BufNewFile *.json set filetype=json

autocmd FileType json call s:json_settings()
function! s:json_settings()
    setl autoindent
    setl formatoptions=tcq2l
    setl textwidth=78 shiftwidth=2
    setl softtabstop=2 tabstop=8
    setl expandtab
    setl foldmethod=syntax
endfunction


" -------------------------------------------------------
" The NERD Commenter
" -------------------------------------------------------
let NERDSpaceDelims = 1
",caで追加するコメントタイプを以下の拡張子のファイルは/* */にする
"let NERD_c_alt_style=1
"let NERD_cpp_alt_style=1
"let NERD_h_alt_style=1
"let NERD_java_alt_style=1


" -------------------------------------------------------
" tagbar
" -------------------------------------------------------
nmap <silent> <Leader>tg :TagbarToggle<CR>


" -------------------------------------------------------
" SrcExpl
" -------------------------------------------------------
" 機能ON/OFF
" The switch of the Source Explorer
nmap <silent> <Leader>s :SrcExplToggle<CR>

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
            \ "__Gundo_Preview__"
            \ ]


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

let s:clangcpp_cmdopt = '--std=c++11'
if has('unix') || has('macunix')
    let s:clangcpp_cmdopt += '--stdlib=libc++'
endif

let s:clangcpp_cmdopt += s:include_paths_string

if executable("clang++")
    let g:quickrun_config['cpp'] = {'type': 'cpp/clang++11'}
    let g:quickrun_config['cpp/clang++11'] = {
                \ 'cmdopt': s:clangcpp_cmdopt,
                \ 'type': 'cpp/clang++'
                \ }
else
    let g:quickrun_config['cpp'] = {'type': 'cpp/g++11'}
    let g:quickrun_config['cpp/g++11'] = {
                \ 'cmdopt': s:clangcpp_cmdopt,
                \ 'type': 'cpp/g++'
                \ }
endif

" -------------------------------------------------------
" Syntastic
" -------------------------------------------------------
let g:syntastic_auto_loc_list = 1 " エラー時に自動的にロケーションリストを開く

let g:syntastic_mode_map = { 'mode': 'active',
            \ 'active_filetypes': [],
            \ 'passive_filetypes': [] }

" html5
"let g:syntastic_html_validator_api = 'http://localhost:8888'
"let g:syntastic_html_checkers = ['validator']
"let g:syntastic_html_validator_parser = 'html5'

" JavaScript
let g:syntastic_javascript_checkers = ['jshint']

" C++
if has('win32') || has('win64')
    let g:syntastic_cpp_compiler_options = '--std=c++11'
else
    let g:syntastic_cpp_compiler_options = '--std=c++11 --stdlib=libc++'
endif

let g:syntastic_cpp_compiler_options += s:include_paths_string

if executable("clang++")
    let g:syntastic_cpp_compiler = 'clang++'
endif

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
