#!/bin/sh

currentDir=$(cd $(dirname $0) && pwd)

# Do you have git?
if ! type "git"; then
    echo 'you must install git'
fi
# Do you have curl?
if ! type "curl"; then
    echo 'you must install curl'
fi

# create link.
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = ".gitignore" ] && continue

    ln -snfv $currentDir/"$f" "$HOME"/"$f"
done

# install neobundle.vim
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > neobundle.sh
sh neobundle.sh
rm -f neobundle.sh

echo 'Dotfiles install processes are completed.'
