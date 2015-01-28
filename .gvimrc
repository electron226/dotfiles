scriptencoding utf-8

""""""""""""""""""""""""""""""
"Window位置の保存と復帰
""""""""""""""""""""""""""""""
let s:infofile = '~/.vimpos'

function! s:SaveWindowParam(filename)
  redir => pos
  exec 'winpos'
  redir END
  let pos = matchstr(pos, 'X[-0-9 ]\+,\s*Y[-0-9 ]\+$')
  let file = expand(a:filename)
  let str = []
  let cmd = 'winpos '.substitute(pos, '[^-0-9 ]', '', 'g')
  cal add(str, cmd)
  let l = &lines
  let c = &columns
  cal add(str, 'set lines='. l.' columns='. c)
  silent! let ostr = readfile(file)
  if str != ostr
    call writefile(str, file)
  endif
endfunction

augroup SaveWindowParam
  autocmd!
  execute 'autocmd SaveWindowParam VimLeave * call s:SaveWindowParam("'.s:infofile.'")'
augroup END

if filereadable(expand(s:infofile))
  execute 'source '.s:infofile
endif
unlet s:infofile

" -------------------------------------------------------
" ここから独自設定
" -------------------------------------------------------
" menu の文字化け対策
source $VIMRUNTIME/delmenu.vim
set langmenu=ja_jp.utf-8
source $VIMRUNTIME/menu.vim

" -------------------------------------------------------
" デザイン
" -------------------------------------------------------
set guioptions-=T
set guioptions-=m

if has('win32') || has('win64')
    " Enable DirectWrite
    "set rop=type:directx
    set guifont=Ricty\ Diminished\ Discord:h12
else
    set guifont=Ricty\ Discord\ 12
endif

highlight CursorIM guibg=Purple guifg=NONE " IME ON時のカーソルの色を設定
set iminsert=0 imsearch=0 " 挿入モード・検索モードでのデフォルトのIME状態設定

set mouse=a	" どのモードでもマウスを使えるようにする
set nomousefocus " マウスの移動でフォーカスを自動的に切替えない
set mousehide " 入力時にマウスポインタを隠す

" -------------------------------------------------------
" ウィンドウ
" -------------------------------------------------------
set columns=120 " ウインドウの幅
set lines=50 " ウインドウの高さ
set cmdheight=1 " コマンドラインの高さ

" -------------------------------------------------------
" その他
" -------------------------------------------------------
set shortmess+=I " 起動時のメッセージを表示しない
set visualbell t_vb= "画面点滅と、ビープ音を削除
