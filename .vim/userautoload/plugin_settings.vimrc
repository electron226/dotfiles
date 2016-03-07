if exists('g:plugin_settings_loaded')
    finish
endif
let g:plugin_settings_loaded = 1

" for using hook of dein.vim
augroup MyAutoCmd
  autocmd!
augroup END

" if dein#tap("plugin_name")
"     function! s:test_on_source() abort
"     endfunction
"     execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
"                 \ 'call s:test_on_source()'
" endif

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
" unite.vim
" -------------------------------------------------------
if dein#tap("unite.vim")
    call unite#custom#profile('default', 'context', {
                \ 'start_insert': 1,
                \ 'winheight': 10,
                \ 'direction': 'botright',
                \ })

    " The items of in .gitignore doesn't display in the result of the unite.vim.
    function! s:unite_setGitIgnoreSource()
        let l:sources = []
        let l:file    = getcwd() . '/.gitignore'
        let l:dir     = getcwd() . '/.git'
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
        " Use ag in unite grep source.
        let g:unite_source_grep_command = 'ag'
        let g:unite_source_grep_default_opts =
                    \ '-i --vimgrep --hidden --ignore ' .
                    \ '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
        let g:unite_source_grep_recursive_opt = ''
    elseif executable('pt')
        " Use pt in unite grep source.
        " https://github.com/monochromegane/the_platinum_searcher
        let g:unite_source_grep_command = 'pt'
        let g:unite_source_grep_default_opts = '--nogroup --nocolor'
        let g:unite_source_grep_recursive_opt = ''
    elseif executable('ack-grep')
        " Use ack in unite grep source.
        let g:unite_source_grep_command = 'ack-grep'
        let g:unite_source_grep_default_opts =
                    \ '-i --no-heading --no-color -k -H'
        let g:unite_source_grep_recursive_opt = ''
    elseif executable('jvgrep')
        " For jvgrep.
        let g:unite_source_grep_command = 'jvgrep'
        let g:unite_source_grep_default_opts =
        \ '-i --exclude ''\.(git|svn|hg|bzr)'''
        let g:unite_source_grep_recursive_opt = '-R'
    endif

    function! DispatchUniteFileRecAsyncOrGit()
        if isdirectory(getcwd()."/.git")
            Unite file_rec/git:--cached:--others:--exclude-standard
        else
            Unite file_rec/async
        endif
    endfunction

    " the prefix key.
    nnoremap [unite] <Nop>
    nmap , [unite]

    nnoremap <silent> [unite]w :<C-u>Unite window tab<CR>
    nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>
    nnoremap <silent> [unite]b :<C-u>Unite buffer bookmark<CR>
    nnoremap <silent> [unite]f :<C-u>Unite file<CR>
    nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
    nnoremap <silent> [unite]d :<C-u>call DispatchUniteFileRecAsyncOrGit()<CR>
    nnoremap <silent> [unite]u :<C-u>Unite register -buffer-name=register<CR>
    nnoremap <silent> [unite]y :<C-u>Unite history/yank -toggle<CR>
    nnoremap <silent> [unite]g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
    nnoremap <silent> [unite]s :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W><CR>
    nnoremap <silent> [unite]r :<C-u>UniteResume search-buffer<CR>
    nnoremap <silent> [unite]c :<C-u>UniteWithCursorWord line -no-quit -toggle<CR>
    " unite-outline
    nnoremap <silent> [unite]o :<C-u>Unite outline<CR>

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
" vim-clang-format
" -------------------------------------------------------
if dein#tap("vim-clang-format")
    function! s:clang_format_settings() abort
        autocmd FileType c,cpp,objc nmap <buffer><Leader>cf :<C-u>ClangFormat<CR>
        autocmd FileType c,cpp,objc vmap <buffer><Leader>cf :ClangFormat<CR>
        " base style.
        " llvm, google, chromium, or mozilla. set Google by default.
        " let g:clang_format#code_style = 'Google'

        " Coding style options as dictionary.
        let g:clang_format#style_options = {
                    \ "AccessModifierOffset" : -4,
                    \ "AllowShortIfStatementsOnASingleLine" : "true",
                    \ "AlwaysBreakTemplateDeclarations" : "true",
                    \ "Standard" : "C++11"
                    \ "BreakBeforeBraces" : "Stroustrup"
                    \ }
    endfunction

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:clang_format_settings()'
endif


" -------------------------------------------------------
" OmniSharp
" -------------------------------------------------------
if dein#tap("Omnisharp")
    function! s:omnisharp_settings() abort
        autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

        if !exists('g:neocomplete#force_omni_input_patterns')
          let g:neocomplete#force_omni_input_patterns = {}
        endif
        let g:neocomplete#force_omni_input_patterns.cs = '.*[^=\);]'

        if dein#tap("ctrlp.vim")
            let g:OmniSharp_selector_ui = 'ctrlp'  " Use ctrlp.vim
        elseif dein#tap("unite.vim")
            let g:OmniSharp_selector_ui = 'unite'  " Use unite.vim
        endif

        " OmniSharp won't work without this setting
        filetype plugin on

        "This is the default value, setting it isn't actually necessary
        let g:OmniSharp_host = "http://localhost:2000"

        "Set the type lookup function to use the preview window instead of the status line
        "let g:OmniSharp_typeLookupInPreview = 1

        "Timeout in seconds to wait for a response from the server
        let g:OmniSharp_timeout = 1

        "Showmatch significantly slows down omnicomplete
        "when the first match contains parentheses.
        set noshowmatch

        "Super tab settings - uncomment the next 4 lines
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

        " Get Code Issues and syntax errors
        let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']
        " If you are using the omnisharp-roslyn backend, use the following
        " let g:syntastic_cs_checkers = ['code_checker']
        augroup omnisharp_commands
            autocmd!

            "Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
            autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

            " Synchronous build (blocks Vim)
            "autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
            " Builds can also run asynchronously with vim-dispatch installed
            autocmd FileType cs nnoremap <leader>b :wa!<cr>:OmniSharpBuildAsync<cr>
            " automatic syntax check on events (TextChanged requires Vim 7.4)
            autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

            " Automatically add new cs files to the nearest project on save
            autocmd BufWritePost *.cs call OmniSharp#AddToProject()

            "show type information automatically when the cursor stops moving
            autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()

            "The following commands are contextual, based on the current cursor position.

            autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
            autocmd FileType cs nnoremap <leader>oi :OmniSharpFindImplementations<cr>
            autocmd FileType cs nnoremap <leader>ot :OmniSharpFindType<cr>
            autocmd FileType cs nnoremap <leader>os :OmniSharpFindSymbol<cr>
            autocmd FileType cs nnoremap <leader>ou :OmniSharpFindUsages<cr>
            "finds members in the current buffer
            autocmd FileType cs nnoremap <leader>om :OmniSharpFindMembers<cr>
            " cursor can be anywhere on the line containing an issue
            autocmd FileType cs nnoremap <leader>of  :OmniSharpFixIssue<cr>
            autocmd FileType cs nnoremap <leader>ox :OmniSharpFixUsings<cr>
            autocmd FileType cs nnoremap <leader>ot :OmniSharpTypeLookup<cr>
            autocmd FileType cs nnoremap <leader>oc :OmniSharpDocumentation<cr>
            "navigate up by method/property/field
            autocmd FileType cs nnoremap <C-K> :OmniSharpNavigateUp<cr>
            "navigate down by method/property/field
            autocmd FileType cs nnoremap <C-J> :OmniSharpNavigateDown<cr>

        augroup END


        " this setting controls how long to wait (in ms) before fetching type / symbol information.
        set updatetime=500
        " Remove 'Press Enter to continue' message when type information is longer than one line.
        set cmdheight=2

        " Contextual code actions (requires CtrlP or unite.vim)
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
        nnoremap <leader>ap :OmniSharpAddToProject<cr>

        " (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
        nnoremap <leader>ss :OmniSharpStartServer<cr>
        nnoremap <leader>sp :OmniSharpStopServer<cr>

        " Add syntax highlighting for types and interfaces
        nnoremap <leader>th :OmniSharpHighlightTypes<cr>
        "Don't ask to save when changing buffers (i.e. when jumping to a type definition)
        set hidden
    endfunction

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:omnisharp_settings()'
endif

" -------------------------------------------------------
" jedi.vim
" https://github.com/davidhalter/jedi-vim
" -------------------------------------------------------
if dein#tap("jedi-vim")
    function! s:jedi_vim() abort
        autocmd FileType python setlocal completeopt-=preview
        autocmd FileType python setlocal omnifunc=jedi#completions

        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0

        if !exists('g:neocomplete#force_omni_input_patterns')
            let g:neocomplete#force_omni_input_patterns = {}
        endif
        let g:neocomplete#force_omni_input_patterns.python = '\h\w*\|[^. \t]\.\w*'

        let g:jedi#goto_command = "<leader>pd"
        let g:jedi#goto_assignments_command = "<leader>pg"
        let g:jedi#goto_definitions_command = ""
        let g:jedi#documentation_command = "K"
        let g:jedi#usages_command = "<leader>pn"
        let g:jedi#completions_command = "<C-Space>"
        let g:jedi#rename_command = "<leader>pr"
    endfunction

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:jedi_vim()'
endif

" -------------------------------------------------------
" neosnippet
" -------------------------------------------------------
if dein#tap("neosnippet")
    function! s:neosnippet_settings() abort
        let g:neosnippet#enable_snipmate_compatibility = 1

        " Plugin key-mappings.
        imap <C-k>     <Plug>(neosnippet_expand_or_jump)
        smap <C-k>     <Plug>(neosnippet_expand_or_jump)
        xmap <C-m>     <Plug>(neosnippet_expand_target)

        " SuperTab like snippets behavior.
        "imap <expr><TAB>
        " \ pumvisible() ? "\<C-n>" :
        " \ neosnippet#expandable_or_jumpable() ?
        " \    "\<TAB>" : "\<Plug>(neosnippet_expand_or_jump)"
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                    \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

        " For snippet_complete marker.
        if has('conceal')
            set conceallevel=2 concealcursor=i
        endif

        if !exists("g:neosnippet#snippets_directory")
            let g:neosnippet#snippets_directory = ""
        endif
        let g:neosnippet#snippets_directory=expand($MY_VIMRUNTIME) . '.cache/dein/repos/github.com/honza/vim-snippets/snippets'
    endfunction

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:neosnippet_settings()'
endif

" -------------------------------------------------------
" vim-go
" :GoInstallBinaries in root after the plugin install,
" -------------------------------------------------------
if dein#tap("vim-go")
    function! s:go_settings() abort
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

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:go_settings()'
endif

autocmd FileType go call s:golang_settings()
function! s:golang_settings()
    exe "set rtp+=".globpath($GOPATH, 'src/github.com/nsf/gocode/vim')

    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
	let g:neocomplete#force_omni_input_patterns.go = '\h\w\.\w*'
endfunction

" -------------------------------------------------------
" switch.vim
" -------------------------------------------------------
if dein#tap("switch.vim")
    nmap <silent> <C-j> :<C-u>Switch<CR>

    let g:switch_custom_definitions =
                \ [
                \   [ 'true', 'false' ],
                \   [ 'TRUE', 'FALSE' ],
                \   {
                \         '\(\k\+\)'    : '''\1''',
                \       '''\(.\{-}\)''' :  '"\1"',
                \        '"\(.\{-}\)"'  :   '\1',
                \   },
                \ ]
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

    " n-character search motion
    map  / <Plug>(easymotion-sn)
    omap / <Plug>(easymotion-tn)

    " These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
    " Without these mappings, `n` & `N` works fine. (These mappings just provide
    " different highlight method and have some other features )
    map  n <Plug>(easymotion-next)
    map  N <Plug>(easymotion-prev)
    
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
" vim-expand-region
" -------------------------------------------------------
if dein#tap('vim-expand-region')
    map <SPACE> <Plug>(expand_region_expand)
    map <S-SPACE> <Plug>(expand_region_shrink)
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
" vim-indent-guides
" -------------------------------------------------------
if dein#tap('vim-indent-guides')
    hi IndentGuidesOdd  ctermbg=black
    hi IndentGuidesEven ctermbg=darkgrey

    let g:indent_guides_enable_on_vim_startup = 1
endif

" -------------------------------------------------------
" emmet-vim
" -------------------------------------------------------
if dein#tap("emmet-vim")
    function! s:emmet_settings() abort
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

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:emmet_settings()'
endif

" -------------------------------------------------------
" vim-jsdoc
" -------------------------------------------------------
if dein#tap("vim-jsdoc")
    function! s:jsdoc_settings()
        nmap <Leader>d :JsDoc<CR>
    endfunction

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:jsdoc_settings()'
endif

" -------------------------------------------------------
" DoxygenToolkit.vim
" -------------------------------------------------------
if dein#tap("DoxygenToolkit.vim")
    function! s:doxygen_settings() abort
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

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:doxygen_settings()'
endif

" -------------------------------------------------------
" tagbar
" -------------------------------------------------------
if dein#tap("tagbar")
    nmap <silent> <Leader>t :TagbarToggle<CR>

    function! s:tagbar_conf() abort
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

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:tagbar_conf()'
endif

" -------------------------------------------------------
" SrcExpl
" -------------------------------------------------------
if dein#tap("SrcExpl")
    " 機能ON/OFF
    " The switch of the Source Explorer
    nmap <silent> <Leader>e :SrcExplToggle<CR>

    function! s:srcExpl_conf() abort
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
        let g:SrcExpl_updateTagsKey = "<F12>"

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

    execute 'autocmd MyAutoCmd User' 'dein#source#' . g:dein#name
            \ 'call s:srcExpl_conf()'
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
    let g:syntastic_javascript_checkers = ['jshint']

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
" lexima.vim
" -------------------------------------------------------
if dein#tap('lexima.vim')
endif

" -------------------------------------------------------
" vim-easy-align
" -------------------------------------------------------
if dein#tap('vim-easy-align')
    " Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
    " vmap <Enter> <Plug>(EasyAlign)
    vmap ga <Plug>(EasyAlign)
    vmap gl <Plug>(LiveEasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)
    nmap gl <Plug>(LiveEasyAlign)
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

" -------------------------------------------------------
" vim-polyglot
" -------------------------------------------------------
if dein#tap("vim-polyglot")
    let g:polyglot_disabled = [ 'python' ]
endif
