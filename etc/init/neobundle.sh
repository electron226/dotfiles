#!/bin/sh

#currentDir=$(cd $(dirname $0) && pwd)
failFlag=false

# Do you have git?
if ! type "git"; then
    failFlag=true
fi
# Do you have curl?
if ! type "curl"; then
    failFlag=true
fi

if $failFlag -eq true; then
    echo 'You must to install the non-existent command.'
    return
fi

# install neobundle.vim
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > neobundle.sh
sh neobundle.sh
rm -f neobundle.sh
