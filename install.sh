#!/bin/sh

currentDir=$(cd $(dirname $0) && pwd)

apt-get update

# Do you have git?
if ! type "git"; then
    # have not git.
    apt-get -y install git
fi

# Do you have curl?
if ! type "curl"; then
    # have not git.
    apt-get -y install curl
fi

# create link.
for f in .??*
do
    [ "$f" = ".git" ] && continue

    ln -snfv $currentDir/"$f" "$HOME"/"$f"
done

# install neobundle.vim
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > neobundle.sh
sh neobundle.sh
rm -f neobundle.sh

echo 'install processes are completed.'
