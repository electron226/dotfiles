scriptencoding utf-8

"----------------------------------------
" ユーザーランタイムパス設定
"----------------------------------------
"Windows, unixでのruntimepathの違いを吸収するためのもの。
"$MY_VIMRUNTIMEはユーザーランタイムディレクトリを示す。
":echo $MY_VIMRUNTIMEで実際のパスを確認できます。
if isdirectory($HOME . '/.vim')
    let $MY_VIMRUNTIME = $HOME.'/.vim'
    let $MY_VIMDIR = $HOME
elseif isdirectory($HOME . '\vimfiles')
    let $MY_VIMRUNTIME = $HOME.'\vimfiles'
    let $MY_VIMDIR = $HOME
elseif isdirectory($VIM . '\vimfiles')
    let $MY_VIMRUNTIME = $VIM.'\vimfiles'
    let $MY_VIMDIR = $VIM
endif

"ランタイムパスを通す必要のあるプラグインを使用する場合、
"$MY_VIMRUNTIMEを使用すると Windows/Linuxで切り分ける必要が無くなります。
"例) vimfiles/qfixapp (Linuxでは~/.vim/qfixapp)にランタイムパスを通す場合
"set runtimepath+=$MY_VIMRUNTIME/qfixapp

"----------------------------------------
" システム設定
"----------------------------------------
"mswin.vimを読み込む
"source $MY_VIMRUNTIME/mswin.vim
"behave mswin

" -------------------------------------------------------
" 設定ファイル読み込み
" -------------------------------------------------------
"set runtimepath+=$MY_VIMRUNTIME
runtime! expand('$MY_VIMRUNTIME') . /userautoload/*.vimrc
