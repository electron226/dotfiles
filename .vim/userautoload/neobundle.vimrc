let g:make = 'gmake'
if system('uname -o') =~ '^GNU/'
        let g:make = 'make'
endif

" -------------------------------------------------------
" NeoBundle
" -------------------------------------------------------
if has('vim_starting')
    set nocompatible               " be iMproved
    set runtimepath+=$MY_VIMRUNTIME/bundle/neobundle.vim
endif
call neobundle#begin(expand('$MY_VIMRUNTIME/bundle/'))

let g:neobundle#install_process_timeout = 600

" let NeoBundle manage NeoBundle
" required!
NeoBundleFetch 'Shougo/neobundle.vim'

" recommended to install
NeoBundle 'Shougo/vimproc', {
\ 'build' : {
\     'windows' : 'tools\\update-dll-mingw',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : g:make,
\    },
\ }

" after install, turn shell ~/.vim/bundle/vimproc,
" (n,g)make -f your_machines_makefile
NeoBundleLazy 'Shougo/vimshell', {
    \   'autoload' : {
    \       'commands' : [
    \           'VimShell', 'VimShellPop', 'VimShellInteractive'
    \       ]
    \   },
    \    'depends' : [ "vimproc" ]
    \ }

" 入力支援
NeoBundleLazy 'Shougo/neocomplete', {
\   "autoload": {
\       "insert": 1
\   }
\ }
NeoBundleLazy 'Shougo/neosnippet', {
\   "autoload": {
\       "insert": 1
\   }
\ }
NeoBundleLazy 'Shougo/neosnippet-snippets', {
\   "autoload": {
\       "insert": 1
\   }
\ }
NeoBundleLazy 'honza/vim-snippets', {
\   "autoload": {
\       "insert": 1
\   }
\ }

NeoBundle 'kana/vim-smartinput'
NeoBundle 'tpope/vim-surround'
NeoBundleLazy 'LeafCage/yankround.vim', {
\   "autoload": {
\     "mappings": [
\           "<Plug>(yankround-p)", "<Plug>(yankround-P)",
\           "<Plug>(yankround-gp)", "<Plug>(yankround-gP)",
\           "<Plug>(yankround-prev)", "<Plug>(yankround-next)",
\     ]
\   }
\ }
NeoBundleLazy 'sjl/gundo.vim', {
\   "autoload": {
\     "commands": [ "GundoToggle" ]
\   }
\ }
NeoBundleLazy 'AndrewRadev/switch.vim', {
\   "autoload": {
\     "commands": [ "Switch" ]
\   }
\ }
NeoBundleLazy 'terryma/vim-expand-region', {
\   "autoload": {
\     "mappings": [
\           "<Plug>(expand_region_expand)", "<Plug>(expand_region_shrink)",
\     ]
\   }
\ }

" Explorer
NeoBundleLazy 'Shougo/unite.vim', {
\   "autoload": {
\     "commands": [ "Unite", "UniteWithBufferDir", "UniteWithCurrentDir" ]
\   }
\ }
NeoBundleLazy 'Shougo/neomru.vim', {
            \ 'depends': [ "unite.vim" ]
            \ }
"NeoBundleLazy 'Shougo/unite-build', { 'depends' : [ "unite.vim" ] }
"NeoBundleLazy 'tsukkee/unite-tag', { 'depends' : [ "unite.vim" ] }
"NeoBundleLazy 'hewes/unite-gtags', { 'depends' : [ "unite.vim" ] }
NeoBundleLazy 'h1mesuke/unite-outline', {
\   'depends' : [ "unite.vim" ],
\   'autoload' : {
\       "unite_sources": "outline"
\   }
\ }
NeoBundleLazy 'Shougo/vimfiler', {
\   'depends' : [ "unite.vim" ],
\   'autoload': {
\       'commands': [ "VimFiler", "VimFilerBufferDir", "VimFilerCurrentDir", "VimFilerSplit", "VimFilerTab" ],
\       'mappings': ['<Plug>(vimfiler_switch)'],
\       'explorer': 1,
\   }
\ }
NeoBundle "wincent/Command-T", {
            \ 'build': {
            \       'windows': 'echo "Please build command-t manually."',
            \       'mac': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \       'unix': 'cd ./ruby/command-t; ruby extconf.rb; ' + g:make,
            \       'mingw32': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \       'mingw64': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \  }
            \ }

" Search
NeoBundle 'rking/ag.vim'
NeoBundle 'AtsushiM/search-parent.vim'
NeoBundleLazy 'koron/codic-vim', {
\   'autoload': {
\       'commands': [ "Codic" ],
\       'functions': [ "codic#search" ],
\   }
\ }

" Code Explorer
NeoBundleLazy 'majutsushi/tagbar', {
\   'autoload': {
\       'commands': [ "TagbarToggle" ],
\   }
\ }
NeoBundleLazy 'wesleyche/SrcExpl', {
\   'autoload': {
\       'commands': [ "SrcExplToggle" ],
\   }
\ }
" NeoBundleLazy 'chazy/cscope_maps', {
" \   'autoload' : { 'filetypes' : [ 'c', 'cpp', 'java' ] },
" \ }

" Docs
" NeoBundle 'vim-jp/vimdoc-ja'
" if !has('win32') || !has('win64')
"     NeoBundleLazy 'thinca/vim-ref', {
"         \ 'autoload': {
"         \   'commands': 'Ref'
"         \ }
"     \ }
" endif

" colorscheme
NeoBundle 'tomasr/molokai'

" 整形 & 表示 & 動作
NeoBundle "Lokaltog/vim-easymotion"
NeoBundle 't9md/vim-textmanip'
NeoBundle "airblade/vim-rooter"
NeoBundle "othree/eregex.vim"
NeoBundle "rhysd/clever-f.vim"
NeoBundle "terryma/vim-multiple-cursors"

NeoBundle "itchyny/lightline.vim"
NeoBundleLazy 'h1mesuke/vim-alignta', {
\     'autoload': {
\           'commands' : [ "Alignta", "Align" ]
\     }
\ }
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundleLazy 'tyru/open-browser.vim', {
\     'autoload': {
\           'commands': [ "OpenBrowserSearch" ],
\           'mappings': [ "<Plug>(openbrowser-smart-search)" ],
\     }
\ }
NeoBundle 'kana/vim-submode'

" コメント
NeoBundle 'tomtom/tcomment_vim'

" Doxygen
NeoBundleLazy 'DoxygenToolkit.vim', {
\     'autoload': {
\           "commands": [ "Dox", "DoxAuthor", "DoxLic", "DoxUndoc", "DoxBlock" ],
\           "filetypes": [ "c", "cpp", "python" ]
\     }
\}

" Test
NeoBundleLazy "kana/vim-altr", {
\     'autoload': {
\           'mappings': [ "<Plug>(altr-forward)", "<Plug>(altr-back)" ],
\     }
\ }
NeoBundleLazy "thinca/vim-quickrun", {
\   'autoload': {
\       'mappings': '<Plug>(quickrun)',
\       'commands': 'QuickRun'
\   }
\ }
NeoBundle 'reinh/vim-makegreen'
NeoBundle "jceb/vim-hier"
NeoBundle "dannyob/quickfixstatus"
NeoBundle 'scrooloose/syntastic'
NeoBundleLazy "http://lh-vim.googlecode.com/svn/refactor/trunk/", {
\     'autoload': { "filetypes": [ "c", "cpp", "java", "pascal", "vim" ] }
\}

" C++11
NeoBundle 'Rip-Rip/clang_complete', {
            \   'autoload' : { 'filetypes' : [ 'c', 'cpp' ] },
            \   'depends' : [ "neocomplete" ]
            \ }
NeoBundleLazy 'vim-jp/cpp-vim', {
\     'autoload': { "filetypes": [ "c", "cpp" ] }
\ }
NeoBundleLazy 'rhysd/vim-clang-format', {
\     'autoload': { "filetypes": [ "c", "cpp", "objc" ] },
\     'depends' : [ "vimproc" ]
\ }
NeoBundleLazy 'osyo-manga/vim-stargate', {
\     'autoload': { "filetypes": [ "c", "cpp", "ruby", "python" ] }
\ }

" C#
NeoBundleLazy 'nosami/Omnisharp', {
\   'autoload': {'filetypes': ['cs']},
\   'build': {
\     'windows': 'cd server; msbuild /p:Platform="Any CPU"',
\     'mac': 'cd server; xbuild',
\     'unix': 'cd server; xbuild',
\     'mingw32': 'echo "Please build Omnisharp manually."',
\     'mingw64': 'echo "Please build Omnisharp manually."'
\   },
\   'depends' : [ "neocomplete" ]
\ }

" Golang
NeoBundleLazy 'fatih/vim-go', {
            \ 'autoload': { "filetypes": [ "go" ] }
\ }
NeoBundleLazy 'Blackrush/vim-gocode', {
            \ 'autoload': { "filetypes": [ "go" ] },
            \ 'build': {
            \   'windows': 'go get -ldflags -H=windowsgui github.com/nsf/gocode',
            \   'mac': 'go get github.com/nsf/gocode',
            \   'unix': 'go get github.com/nsf/gocode',
            \   'mingw32': 'echo "Please install vim-gocode manually."',
            \   'mingw64': 'echo "Please install vim-gocode manually."'
            \ }
\ }
NeoBundleLazy 'dgryski/vim-godef', {
            \ 'autoload': { "filetypes": [ "go" ] },
            \ 'build': {
            \   'windows': 'go get -v code.google.com/p/rog-go/exp/cmd/godef && go install -v code.google.com/p/rog-go/exp/cmd/godef',
            \   'mac': 'go get -v code.google.com/p/rog-go/exp/cmd/godef && go install -v code.google.com/p/rog-go/exp/cmd/godef',
            \   'unix': 'go get -v code.google.com/p/rog-go/exp/cmd/godef && go install -v code.google.com/p/rog-go/exp/cmd/godef',
            \   'mingw32': 'echo "Please install vim-godef manually."',
            \   'mingw64': 'echo "Please install vim-godef manually."'
            \ }
\ }

" Python
NeoBundleLazy 'python.vim', {
            \     'autoload': { "filetypes": [ "python" ] },
            \ }
NeoBundleLazy "davidhalter/jedi-vim", {
\     'autoload': { "filetypes": [ "python" ] },
\     'build': {
\         'windows': 'pip install jedi',
\         'mac': 'pip install jedi',
\         'unix': 'pip install jedi',
\         'mingw32': 'echo "Please install jedi manually."',
\         'mingw64': 'echo "Please install jedi manually."'
\     },
\     'depends' : [ "neocomplete" ]
\}
NeoBundleLazy "klen/python-mode", {
            \ 'autoload': { "filetypes": [ "python" ] },
            \ 'build': {
            \   'windows': 'easy_install rope ropemode ropevim',
            \   'mac': 'easy_install rope ropemode ropevim',
            \   'unix': 'easy_install rope ropemode ropevim',
            \   'mingw32': 'echo "Please install python-mode manually."',
            \   'mingw64': 'echo "Please install python-mode manually."'
            \ }
\}

" HTML
NeoBundleLazy "mattn/emmet-vim", {
            \ 'autoload': { "filetypes": [ "html", "css", "javascript" ] }
            \ }
NeoBundleLazy 'othree/html5.vim', {
            \ 'autoload': { "filetypes": [ "html" ] }
            \ }

" CSS
NeoBundleLazy 'hail2u/vim-css3-syntax', {
            \ 'autoload': { "filetypes": [ "css", "less", "scss" ] }
            \ }
NeoBundleLazy 'css_color.vim', {
            \ 'autoload': { "filetypes": [ "css", "scss" ] },
            \ }
NeoBundleLazy 'groenewege/vim-less', {
            \ 'autoload': { "filetypes": [ "less" ] }
            \ }
NeoBundleLazy 'AtsushiM/sass-compile.vim', {
            \ 'autoload': { "filetypes": [ "scss" ] },
            \ 'depends' : [ "search-parent.vim" ]
            \ }

" JavaScript
NeoBundleLazy 'jiangmiao/simple-javascript-indenter', {
            \ 'autoload': { "filetypes": [ "html", "javascript" ] }
            \ }
NeoBundleLazy 'jelera/vim-javascript-syntax', {
            \ 'autoload': { "filetypes": [ "html", "javascript" ] }
            \ }
NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {
            \ 'autoload': { "filetypes": [ "html", "javascript", "coffee", "livescript", "typescript" ] }
            \ }
NeoBundleLazy 'marijnh/tern_for_vim', {
            \ 'autoload': { "filetypes": [ "html", "javascript", "coffee" ] },
            \ 'build': {
            \   'windows': 'npm install',
            \   'mac': 'npm install',
            \   'unix': 'npm install',
            \   'mingw32': 'echo "Please install tern_for_vim manually."',
            \   'mingw64': 'echo "Please install tern_for_vim manually."'
            \}}
NeoBundleLazy 'kchmck/vim-coffee-script', {
            \ 'autoload': { "filetypes": [ "coffee" ] }
            \ }
NeoBundleLazy 'heavenshell/vim-jsdoc', {
\     'autoload': { "filetypes": [ "html", "javascript", "coffee" ] }
\}
" React
NeoBundleLazy 'mxw/vim-jsx', {
\     'autoload': { "filetypes": [ "javascript", "jsx" ] }
\}

" version management
"NeoBundle 'git://repo.or.cz/vcscommand.git'
"NeoBundle 'tpope/vim-fugitive'
"NeoBundleLazy 'gregsexton/gitv', {
"            \   'autoload': {
"            \           'commands' : [ "Gitv" ],
"            \           'depends' : [ "vim-fugitive" ]
"            \   }
"            \ }

" Others
NeoBundleLazy 'JSON.vim', {
\     'autoload': { "filetypes": [ "json" ] }
\}

call neobundle#end()

filetype plugin indent on " required!

NeoBundleCheck
"
" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
