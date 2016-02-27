#!/bin/sh

currentDir=$(cd $(dirname $0) && pwd)

# create link.
for f in .??*
do
    [ "$f" = ".git" ] && continue
    [ "$f" = ".gitignore" ] && continue

    ln -snfv $currentDir/"$f" "$HOME"/"$f"
done

# run init scripts.
for f in etc/init/*.sh
do
    sh $f
done

echo 'Dotfiles install processes are completed.'
