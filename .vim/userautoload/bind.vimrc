if exists('g:bind_settings_loaded')
    finish
endif
let g:bind_settings_loaded = 1

" -------------------------------------------------------
" バインド(プラグイン未使用)
" -------------------------------------------------------
" <Leader><Leader>で変更があれば保存
" nnoremap <Leader><Leader> :up<CR>

"ビジュアルモード時vで行末まで選択
" vnoremap v $

" 行の折り返しをしている時に見た目の次の行へ移動する
nnoremap j gj
nnoremap k gk

" 現在なんという関数の中にいるか表示する
nnoremap [f [[k:let t=getline(".")<CR>``:echo t<CR>

" Windowsで矩形選択を正常に動作
if has('win32') || has('win64')
    nmap <C-v> <C-v>
    cmap <C-v> <C-v>
endif

" c* or cg* でカーソル下のキーワードを置換
nnoremap <expr> c* ':%s/' . expand('<cword>') . '/' . input('All replace "' . expand('<cword>') . '" to: ') . '/g'
vnoremap <expr> c* ':s/' . expand('<cword>') . '/' . input('All replace "' . expand('<cword>') . '" to: ') . '/g'
nnoremap <expr> cg* ':%s/' . expand('<cword>') . '/' . input('Replace while checking: "' . expand('<cword>') . '" to:') . '/cg'
vnoremap <expr> cg* ':s/' . expand('<cword>') . '/' . input('Replace while checking: "' . expand('<cword>') . '" to:') . '/cg'

" vimでカーソル位置の単語とヤンクした文字列を置換する
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy   c<C-r>0<ESC>:let@/=@1<CR>:noh<CR>

if g:use_dvorak
    " 画面分割
    nnoremap <silent>; <Nop>
    nnoremap <silent>;j <C-w>j
    nnoremap <silent>;k <C-w>k
    nnoremap <silent>;l <C-w>l
    nnoremap <silent>;h <C-w>h
    nnoremap <silent>;J <C-w>J
    nnoremap <silent>;K <C-w>K
    nnoremap <silent>;L <C-w>L
    nnoremap <silent>;H <C-w>H
    nnoremap <silent>;r <C-w>r
    nnoremap <silent>;= <C-w>=
    nnoremap <silent>;w <C-w>w
    nnoremap <silent>;o <C-w>_<C-w>|
    nnoremap <silent>;O <C-w>=
    nnoremap <silent>;t :<C-u>tabnew<CR>
    nnoremap <silent>;c :<C-u>tabclose<CR>
    nnoremap <silent>;n gt
    nnoremap <silent>;p gT
    nnoremap <silent>;s :<C-u>sp<CR>
    nnoremap <silent>;v :<C-u>vs<CR>
    nnoremap <silent>;q :<C-u>q<CR>

    " バッファ操作
    nnoremap <silent>;p :bprevious<CR>
    nnoremap <silent>;n :bnext<CR>
    nnoremap <silent>;b :b#<CR>
    nnoremap <silent>;f :bf<CR>
    nnoremap <silent>;g :bl<CR>
    nnoremap <silent>;m :bm<CR>
    nnoremap <silent>;Q :bdelete<CR>
    nnoremap <silent>;QQ :Kwbd<CR>
else
    " 画面分割
    nnoremap <silent>s <Nop>
    nnoremap <silent>sj <C-w>j
    nnoremap <silent>sk <C-w>k
    nnoremap <silent>sl <C-w>l
    nnoremap <silent>sh <C-w>h
    nnoremap <silent>sJ <C-w>J
    nnoremap <silent>sK <C-w>K
    nnoremap <silent>sL <C-w>L
    nnoremap <silent>sH <C-w>H
    nnoremap <silent>sr <C-w>r
    nnoremap <silent>s= <C-w>=
    nnoremap <silent>sw <C-w>w
    nnoremap <silent>so <C-w>_<C-w>|
    nnoremap <silent>sO <C-w>=
    nnoremap <silent>st :<C-u>tabnew<CR>
    nnoremap <silent>sc :<C-u>tabclose<CR>
    nnoremap <silent>sn gt
    nnoremap <silent>sp gT
    nnoremap <silent>ss :<C-u>sp<CR>
    nnoremap <silent>sv :<C-u>vs<CR>
    nnoremap <silent>sq :<C-u>q<CR>

    " バッファ操作
    nnoremap <silent>sp :bprevious<CR>
    nnoremap <silent>sn :bnext<CR>
    nnoremap <silent>sb :b#<CR>
    nnoremap <silent>sf :bf<CR>
    nnoremap <silent>sg :bl<CR>
    nnoremap <silent>sm :bm<CR>
    nnoremap <silent>sQ :bdelete<CR>
    nnoremap <silent>sQQ :Kwbd<CR>
end

" レイアウトを崩さずバッファを閉じる
com! Kwbd let kwbd_bn= bufnr("%")|enew|exe "bdel ".kwbd_bn|unlet kwbd_bn 

" " -------------------------------------------------------
" " Quickfix
" " -------------------------------------------------------
" command -bang -nargs=? QFix call QFixToggle(<bang>0)
" function! QFixToggle(forced)
"   if exists("g:qfix_win") && a:forced == 0
"     cclose
"     unlet g:qfix_win
"   else
"     copen 10
"     let g:qfix_win = bufnr("$")
"   endif
" endfunction

" nmap <silent> co :QFix<CR>
" nmap <silent> cn :cn<CR>
" nmap <silent> cp :cp<CR>
" nmap <silent> vn :lnext<CR>
" nmap <silent> vp :lprev<CR>

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
        SrcExpl
    endif
    VimFilerBufferDir -split -simple -winwidth=30 -no-quit
    TagbarOpen
endfunction
command! -nargs=0 IDE call s:ide_open(0)
command! -nargs=0 IDE2 call s:ide_open(1)
