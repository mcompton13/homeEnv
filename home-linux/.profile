# ~/.profile: Executed by the command interpreter for login shells.
#
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.
# see /usr/share/doc/bash/examples/startup-files for examples. The files are
# located in the bash-doc package.
#
# This is a Linux specific .profile

# Source the shared .profile
source ${HOME}/.profile-common

# Setup the file type and directory colors used by ls
if [ -z "$LS_COLORS" ] && `type dircolors 2>/dev/null >&2`; then
    # Check for a color settings in user's home directory
    if [ -r ${HOME}/.dircolors ]; then
        eval "`dircolors ${HOME}/.dircolors`"
    else # Use the system default settings
        eval "`dircolors`"
    fi
fi
