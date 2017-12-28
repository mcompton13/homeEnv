# ~/.profile: Executed by the command interpreter for login shells.
#
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.
# see /usr/share/doc/bash/examples/startup-files for examples. The files are
# located in the bash-doc package.
#
# This is a BSD specific .profile

# Source the shared .profile
source .profile-common

# Setup the file type and directory colors used by ls
if [ -z "$LSCOLORS" ]; then
    export LSCOLORS=ExGxFxdaCxDaDahBaDaCEC
    export LS_COLORS="di=01;34:fi=0:ln=01;36:pi=33;40:so=33;40:bd=33;40:cd=33;40:mi=0:ex=01;32:*.rpm=90"
fi
