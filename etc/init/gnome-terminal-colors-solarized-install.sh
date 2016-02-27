#!/bin/sh

#currentDir=$(cd $(dirname $0) && pwd)
rc_path=~/.bashrc
fail_flag=false

if ! type "git"; then
    fail_flag=true
fi
if ! type "expect"; then
    fail_flag=true
fi
if ! type "curl"; then
    fail_flag=true
fi

if $fail_flag -eq true; then
    echo 'You must to install the non-existent command.'
    return
fi

# install gnome-terminal-colors-solarized
git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git gnome-terminal-colors-solarized
expect -c "
    spawn gnome-terminal-colors-solarized/set_dark.sh
    expect \"Please select a Gnome Terminal profile:\"
    send -- \"1\n\"
    expect \"(YES to continue)\"
    send -- \"YES\n\"
    interact
"
rm -fr gnome-terminal-colors-solarized

# solarized palette
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/palette" --type string "#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#00002B2B3636"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#65657B7B8383"

# dircolors install
curl https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.256dark > ~/.dircolors

comment_dircolors="# dircolors for solarized of terminal."
already_add_dircolors=$(grep --include $(basename $rc_path) -H -n -r "$comment_dircolors" $(dirname $rc_path))
if test -z $already_add_dircolors; then
    echo '' >> $rc_path
    echo $comment_dircolors >> $rc_path
    echo 'if [ -x /usr/bin/dircolors ]; then' >> $rc_path
    echo '    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"' >> $rc_path
    echo 'fi' >> $rc_path
fi
