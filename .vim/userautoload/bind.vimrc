if exists('g:bind_settings_loaded')
    finish
endif
let g:bind_settings_loaded = 1

" -------------------------------------------------------
" バインド(プラグイン未使用)
" -------------------------------------------------------
" <Leader><Leader>で変更があれば保存
" nmap <Leader><Leader> :up<CR>

"ビジュアルモード時vで行末まで選択
" vmap v $

" 行の折り返しをしている時に見た目の次の行へ移動する
nmap j gj
nmap k gk

" Windowsで矩形選択を正常に動作
if has('win32') || has('win64')
    nmap <C-v> <C-v>
    cmap <C-v> <C-v>
endif

" c* or cg* でカーソル下のキーワードを置換
nmap <expr> c* ':%s/' . expand('<cword>') . '/' . input('All replace "' . expand('<cword>') . '" to: ') . '/g'
vmap <expr> c* ':s/' . expand('<cword>') . '/' . input('All replace "' . expand('<cword>') . '" to: ') . '/g'
nmap <expr> cg* ':%s/' . expand('<cword>') . '/' . input('Replace while checking: "' . expand('<cword>') . '" to:') . '/cg'
vmap <expr> cg* ':s/' . expand('<cword>') . '/' . input('Replace while checking: "' . expand('<cword>') . '" to:') . '/cg'

" vimでカーソル位置の単語とヤンクした文字列を置換する
nmap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nmap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vmap <silent> cy   c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>

" 画面分割
nmap <silent>s <Nop>
nmap <silent>sj <C-w>j
nmap <silent>sk <C-w>k
nmap <silent>sl <C-w>l
nmap <silent>sh <C-w>h
nmap <silent>sJ <C-w>J
nmap <silent>sK <C-w>K
nmap <silent>sL <C-w>L
nmap <silent>sH <C-w>H
nmap <silent>sr <C-w>r
nmap <silent>s= <C-w>=
nmap <silent>sw <C-w>w
nmap <silent>so <C-w>_<C-w>|
nmap <silent>sO <C-w>=
nmap <silent>st :<C-u>tabnew<CR>
nmap <silent>sc :<C-u>tabclose<CR>
nmap <silent>sn gt
nmap <silent>sp gT
nmap <silent>ss :<C-u>sp<CR>
nmap <silent>sv :<C-u>vs<CR>
nmap <silent>sq :<C-u>q<CR>

" バッファ操作
nmap <silent>sp :bprevious<CR>
nmap <silent>sn :bnext<CR>
nmap <silent>sb :b#<CR>
nmap <silent>sf :bf<CR>
nmap <silent>sg :bl<CR>
nmap <silent>sm :bm<CR>
nmap <silent>sQ :bdelete<CR>
nmap <silent>sQQ :Kwbd<CR>

" レイアウトを崩さずバッファを閉じる
com! Kwbd let kwbd_bn= bufnr("%")|enew|exe "bdel ".kwbd_bn|unlet kwbd_bn

" -------------------------------------------------------
" Quickfix
" -------------------------------------------------------
command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction

nmap <silent> co :QFix<CR>
nmap <silent> cn :cn<CR>
nmap <silent> cp :cp<CR>
nmap <silent> vn :lnext<CR>
nmap <silent> vp :lprev<CR>

" -------------------------------------------------------
" コマンド
" -------------------------------------------------------
" ウィンドウを4分割するコマンド
command! -nargs=0 W4 wincmd o|lefta sp|lefta vs|wincmd w|bn|wincmd w|bn|bn|lefta vs|wincmd w|bn|wincmd w

"現バッファの差分表示(変更箇所の表示)
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
"ファイルまたはバッファ番号を指定して差分表示。#なら裏バッファと比較
command! -nargs=? -complete=file Diff if '<args>'=='' | browse vertical diffsplit|else| vertical diffsplit <args>|endif

" IDEのように表示する
function! s:ide_open(srcexpl)
    SM6

    if a:srcexpl == 1
        if !exists('b:Source_Explorer')
            SrcExpl
        endif
    endif
    if !exists('b:NERDTree')
        NERDTree
    endif
    if !exists('b:Tagbar')
        TagbarOpen
    endif
endfunction
command! -nargs=0 IDE call s:ide_open(0)
command! -nargs=0 IDE2 call s:ide_open(1)
