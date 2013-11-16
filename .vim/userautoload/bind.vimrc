" -------------------------------------------------------
" バインド(プラグイン未使用)
" -------------------------------------------------------
" <Leader><Leader>で変更があれば保存
nnoremap <Leader><Leader> :up<CR>

"ビジュアルモード時vで行末まで選択
vnoremap v $

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
