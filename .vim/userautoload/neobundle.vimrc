" -------------------------------------------------------
" NeoBundle
" -------------------------------------------------------
set nocompatible               " be iMproved
filetype off
filetype plugin indent off     " required!

if has('vim_starting')
	set runtimepath+=$MY_VIMRUNTIME/bundle/neobundle.vim/
	call neobundle#rc(expand('$MY_VIMRUNTIME/bundle/'))
endif

" let NeoBundle manage NeoBundle
" required!
NeoBundle 'Shougo/neobundle.vim'

" recommended to install
NeoBundle 'Shougo/vimproc', {
            \ 'build': {
            \       'windows': 'nmake /f Make_msvc64.mak',
            \       'mac': 'make -f make_mac.mak',
            \       'unix': 'make -f make_unix.mak',
            \       'mingw32': 'make -f make_mingw32.mak',
            \       'mingw64': 'make -f make_mingw64.mak',
            \   }
            \ }

" after install, turn shell ~/.vim/bundle/vimproc,
" (n,g)make -f your_machines_makefile
NeoBundleLazy 'Shougo/vimshell', {
    \   'autoload' : {
    \       'commands' : [
    \           'VimShell', "VimShellPop", "VimShellInteractive"
    \       ]
    \   },
    \    'depends' : [ "vimproc" ]
    \ }

" 入力支援
NeoBundle 'Shougo/neocomplete'
NeoBundle 'Shougo/neosnippet', { 'depends' : [ "neocomplete" ] }
NeoBundle 'kana/vim-smartinput'
NeoBundle 'tpope/vim-surround'
NeoBundle 'YankRing.vim'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'AndrewRadev/switch.vim'
NeoBundle 'terryma/vim-expand-region'

" Explorer
NeoBundle 'Shougo/unite.vim'
"NeoBundle 'Shougo/unite-build', { 'depends' : [ "unite.vim" ] }
"NeoBundle 'tsukkee/unite-tag', { 'depends' : [ "unite.vim" ] }
"NeoBundle 'hewes/unite-gtags', { 'depends' : [ "unite.vim" ] }
"NeoBundle 'h1mesuke/unite-outline', { 'depends' : [ "unite.vim" ] }
"NeoBundle 'Sixeight/unite-grep', { 'depends' : [ "unite.vim" ] }
NeoBundle 'Shougo/vimfiler', { 'depends' : [ "unite.vim" ] }
NeoBundle "wincent/Command-T", {
            \ 'build': {
            \       'windows': 'echo "Please build command-t manually."',
            \       'mac': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \       'unix': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \       'mingw32': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \       'mingw64': 'cd ./ruby/command-t; ruby extconf.rb; make',
            \   }
            \ }

" Code Explorer
NeoBundle 'majutsushi/tagbar'
NeoBundle 'SrcExpl'

" Vim Action
NeoBundle "Lokaltog/vim-easymotion"
NeoBundle "airblade/vim-rooter"
NeoBundle "othree/eregex.vim"
NeoBundle "DirDo.vim"
NeoBundle "rhysd/clever-f.vim"
NeoBundle "goldfeld/vim-seek"

" Docs
"NeoBundle 'vim-jp/vimdoc-ja'
if !has('win32') || !has('win64')
    NeoBundle 'thinca/vim-ref'
endif

" colorscheme
NeoBundle 'tomasr/molokai'

" 整形 & 表示
NeoBundle "itchyny/lightline.vim"
NeoBundleLazy 'MultipleSearch', {
\     'autoload': {
\           'commands' : [ "Search", "SearchBuffers", "SearchReinit" ]
\     }
\}
NeoBundle 't9md/vim-textmanip'
NeoBundleLazy 'h1mesuke/vim-alignta', {
\     'autoload': {
\           'commands' : [ "Alignta", "Align" ]
\     }
\}
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'kien/rainbow_parentheses.vim'
NeoBundle 'tyru/open-browser.vim'

" コメント
NeoBundle 'scrooloose/nerdcommenter'

" Doxygen
NeoBundleLazy 'DoxygenToolkit.vim', {
\     'autoload': { "filetypes": [ "c", "cpp", "python" ] }
\}

" Test
NeoBundle "kana/vim-altr"
NeoBundle "thinca/vim-quickrun"
NeoBundle 'reinh/vim-makegreen'
NeoBundle 'scrooloose/syntastic'
NeoBundle "jceb/vim-hier"
NeoBundle "dannyob/quickfixstatus"
NeoBundleLazy "http://lh-vim.googlecode.com/svn/refactor/trunk/", {
\     'autoload': { "filetypes": [ "c", "cpp", "java", "pascal", "vim" ] }
\}

" C++11
NeoBundle 'Rip-Rip/clang_complete', {
            \   'autoload' : { 'filetypes' : [ 'c', 'cpp' ] },
            \    'depends' : [ "neocomplete" ]
            \ }
NeoBundleLazy 'vim-jp/cpp-vim', {
\     'autoload': { "filetypes": [ "c", "cpp" ] }
\}
NeoBundleLazy 'rhysd/vim-clang-format', {
\     'autoload': { "filetypes": [ "c", "cpp", "objc" ] }
\}
NeoBundleLazy 'osyo-manga/vim-stargate', {
\     'autoload': { "filetypes": [ "c", "cpp", "ruby", "python" ] }
\}
"NeoBundleLazy 'osyo-manga/vim-reunions', {
"\     'autoload': { "filetypes": [ "c", "cpp" ] }
"\}
"NeoBundleLazy 'osyo-manga/vim-marching', {
"\     'autoload': { "filetypes": [ "c", "cpp" ] },
"\     'depends' : [ "vim-reunions", "neocomplete" ]
"\}

" C#
NeoBundleLazy 'nosami/Omnisharp', {
\   'autoload': {'filetypes': ['cs']},
\   'build': {
\     'windows': 'MSBuild.exe server/OmniSharp.sln /p:Platform="Any CPU"',
\     'mac': 'xbuild server/OmniSharp.sln',
\     'unix': 'xbuild server/OmniSharp.sln',
\   },
\   'depends' : [ "neocomplete" ]
\ }

" Python
NeoBundleLazy 'python.vim', {
            \     'autoload': { "filetypes": [ "python" ] },
            \ }
"NeoBundle 'pythoncomplete'
"jedi必須(pip install jedi)
"https://github.com/davidhalter/jedi
NeoBundleLazy "davidhalter/jedi-vim", {
\     'autoload': { "filetypes": [ "python" ] },
\     'depends' : [ "neocomplete" ]
\}
NeoBundleLazy 'sontek/rope-vim', {
\     'autoload': { "filetypes": [ "python" ] }
\}

" Ruby
"NeoBundleLazy 'vim-ruby/vim-ruby', {
"            \ 'autoload': { "filetypes": [ "ruby" ] },
"            \ }
"NeoBundleLazy 'm2ym/rsense', {
"            \ 'autoload': { "filetypes": [ "ruby" ] },
"            \ 'depends' : [ "neocomplete" ]
"            \ }
"NeoBundleLazy 'tpope/vim-rails', {
"            \ 'autoload': { "filetypes": [ "ruby" ] }
"            \ }
"NeoBundleLazy 'ecomba/vim-ruby-refactoring', {
"            \ 'autoload': { "filetypes": [ "ruby" ] }
"            \ }

" Java
"NeoBundleLazy 'javacomplete', {
"            \ 'autoload': { "filetypes": [ "java" ] },
"            \ 'depends' : [ "neocomplete" ]
"            \ }

" Scala
"NeoBundleLazy 'derekwyatt/vim-scala', {
"            \ 'autoload': { "filetypes": [ "scala" ] },
"            \ }

" HTML
NeoBundleLazy "mattn/emmet-vim", {
            \ 'autoload': { "filetypes": [ "html", "css", "javascript" ] }
            \ }
NeoBundleLazy 'othree/html5.vim', {
            \ 'autoload': { "filetypes": [ "html" ] }
            \ }

" CSS
NeoBundleLazy 'skammer/vim-css-color', {
            \ 'autoload': { "filetypes": [ "css", "less", "scss" ] }
            \ }
NeoBundleLazy 'hail2u/vim-css3-syntax', {
            \ 'autoload': { "filetypes": [ "css", "less", "scss" ] }
            \ }
NeoBundleLazy 'groenewege/vim-less', {
            \ 'autoload': { "filetypes": [ "css", "less", "scss" ] }
            \ }
NeoBundleLazy 'cakebaker/scss-syntax.vim', {
            \ 'autoload': { "filetypes": [ "css", "less", "scss" ] }
            \ }

" JavaScript
NeoBundleLazy 'jiangmiao/simple-javascript-indenter', {
            \ 'autoload': { "filetypes": [ "html", "javascript" ] }
            \ }
NeoBundleLazy 'jelera/vim-javascript-syntax', {
            \ 'autoload': { "filetypes": [ "html", "javascript" ] }
            \ }
NeoBundleLazy 'scottmcginness/vim-jquery', {
            \ 'autoload': { "filetypes": [ "html", "javascript" ] }
            \ }
NeoBundle 'kchmck/vim-coffee-script', {
            \ 'autoload': { "filetypes": [ "coffee" ] }
            \ }
"NeoBundle 'teramako/jscomplete-vim'
NeoBundleLazy 'claco/jasmine.vim', {
            \ 'autoload': { "filetypes": [ "javascript", "coffee" ] }
            \ }
NeoBundleLazy 'billyvg/coffee-jasmine-snippets', {
            \ 'autoload': { "filetypes": [ "coffee" ] }
            \ }
" jsdoc
NeoBundleLazy 'heavenshell/vim-jsdoc', {
\     'autoload': { "filetypes": [ "html", "javascript", "coffee" ] }
\}

" version management
NeoBundle 'git://repo.or.cz/vcscommand.git'
NeoBundle 'tpope/vim-fugitive'
NeoBundleLazy 'gregsexton/gitv', {
            \   'autoload': {
            \           'commands' : [ "Gitv" ],
            \           'depends' : [ "vim-fugitive" ]
            \   }
            \ }

" Others
"NeoBundleLazy 'opencl.vim', {
"\     'autoload': { "filetypes": [ "opencl" ] }
"\}
"NeoBundleLazy 'sukima/xmledit', {
"            \ 'autoload': { "filetypes": [ "html", "xml" ] }
"            \ }
NeoBundleLazy 'JSON.vim', {
\     'autoload': { "filetypes": [ "json" ] }
\}
"NeoBundleLazy 'PProvost/vim-ps1', {
"\     'autoload': { "filetypes": [ "ps1" ] }
"\}

" ...

filetype plugin indent on " required!
"
" Brief help
" :NeoBundleList          - list configured bundles
" :NeoBundleInstall(!)    - install(update) bundles
" :NeoBundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
