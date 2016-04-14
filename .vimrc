scriptencoding utf-8

" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END

"----------------------------------------
" ユーザーランタイムパス設定
"----------------------------------------
"Windows, unixでのruntimepathの違いを吸収するためのもの。
"$MY_VIMRUNTIMEはユーザーランタイムディレクトリを示す。
":echo $MY_VIMRUNTIMEで実際のパスを確認できます。
if isdirectory($HOME . '/.vim')
    let $MY_VIMRUNTIME = $HOME . '/.vim'
elseif isdirectory($HOME . '\vimfiles')
    let $MY_VIMRUNTIME = $HOME . '\vimfiles'
elseif isdirectory($VIM . '\vimfiles')
    let $MY_VIMRUNTIME = $VIM . '\vimfiles'
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

"----------------------------------------
" need set the options before the plugins install.
"----------------------------------------
" for vimproc.
let g:vimproc#download_windows_dll = 1

"----------------------------------------
" dein.vim
"----------------------------------------
let s:dein_dir = expand('$MY_VIMRUNTIME/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

let s:toml = expand('$MY_VIMRUNTIME/userautoload/dein.toml')
let s:lazy_toml = expand('$MY_VIMRUNTIME/userautoload/dein_lazy.toml')

if has('vim_starting')
    if &compatible
        set nocompatible               " Be iMproved
    endif

    if &runtimepath !~# '/dein.vim'
        if !isdirectory(s:dein_repo_dir)
            execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
        endif
        execute 'set runtimepath^=' . s:dein_repo_dir
    endif
endif

if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir, [ expand('<sfile>'), s:toml, s:lazy_toml ])
    call dein#load_toml(s:toml, { 'lazy': 0 })
    call dein#load_toml(s:lazy_toml, { 'lazy': 1 })
    call dein#end()
    call dein#save_state()
endif

if dein#check_install()
    call dein#install()
endif

" -------------------------------------------------------
" 設定ファイル読み込み
" -------------------------------------------------------
set runtimepath+=$MY_VIMRUNTIME/userautoload/
runtime! *.vimrc
