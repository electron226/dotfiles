" -------------------------------------------------------
" コーディング
" -------------------------------------------------------
filetype indent on             " ファイル形式別インデントロード
set enc=utf-8                  " デフォルトの文字コード
set ffs=unix,dos,mac           " 改行コード
set tabstop=4                  " タブの画面上での幅
set shiftwidth=4
set autoindent                 " 自動的にインデントする (noautoindent:インデントしない)
set smartindent
set cindent
set expandtab                  " タブをスペースに展開する (noexpandtab:展開しない)
set backspace=indent,eol,start " バックスペースでインデントや改行を削除できるようにする
set showmatch                  " 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set formatoptions+=mM          " テキスト挿入中の自動折り返しを日本語に対応させる

" -------------------------------------------------------
" 補完・履歴
" -------------------------------------------------------
set wildmenu           " コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildchar=<tab>     " コマンド補完を開始するキー
set wildmode=list:full " リスト表示，最長マッチ
set history=1000       " コマンド・検索パターンの履歴数
set complete+=k        " 補完に辞書ファイル追加

" -------------------------------------------------------
" 表示
" -------------------------------------------------------
syntax on
colorscheme molokai " テーマ
set shortmess+=I " 起動時のメッセージを表示しない
set number       " 行番号を非表示 (number:表示)
set ruler        " ルーラーを表示 (noruler:非表示)
set nolist       " タブや改行を表示 (list:表示)
set wrap         " 長い行を折り返して表示 (nowrap:折り返さない)
set title        " タイトルを表示
set showmatch    " 括弧の対応をハイライト
set showcmd      " コマンドをステータス行に表示
"set fdm=indent   " 折りたたみの指定
set laststatus=2 " 常にステータス行を表示 (詳細は:he laststatus)

" -------------------------------------------------------
" 検索
" -------------------------------------------------------
set wrapscan " 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set nohlsearch
set noincsearch
set ignorecase
set smartcase

" tags
"set tags=tags,/**3/tags

" -------------------------------------------------------
" その他
" -------------------------------------------------------
filetype plugin on

set hid
" クリップボードをデフォルトのレジスタとして指定。後にYankRingを使うので
" 'unnamedplus'が存在しているかどうかで設定を分ける必要がある
if has('unnamedplus')
    " set clipboard& clipboard+=unnamedplus " 2013-07-03 14:30 unnamed 追加
    set clipboard& clipboard+=unnamedplus,unnamed
else
    " set clipboard& clipboard+=unnamed,autoselect 2013-06-24 10:00 autoselect 削除
    set clipboard& clipboard+=unnamed
endif

" Backup and Swap
set nobackup
set nowritebackup
set noswapfile
set noundofile
"set backup
"set swapfile
"if has('win32') || has('win64')
"	set backupdir=G:/vim/backup
"	set directory=G:/vim/swap
"else
"	set backupdir=/tmp/vim/backup
"	set directory=/tmp/vim/swap
"endif

" QuickFixを自動で開く
autocmd QuickfixCmdPost make,grep,grepadd,vimgrep if len(getqflist()) != 0 | copen | endif

" コメント行の改行した時に自動的にコメントアウトされるのを無効化
" autocmd FileType * setlocal formatoptions-=ro"
