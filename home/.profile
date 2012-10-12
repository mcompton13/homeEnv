# ~/.profile: Executed by the command interpreter for login shells.
#
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.
# see /usr/share/doc/bash/examples/startup-files for examples. The files are
# located in the bash-doc package.

# Detect which type of system

UNAME=`uname`

#TODO: Detect Linux vs. BSD
export SYS='BSD'

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Set Environment Variables
# #########################

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# Set temporary directory variables.
# Note: In Cygwin TMP and TEMP are defined in the Windows environment.  Leaving
# them set to the default Windows temporary directory can have unexpected
# consequences.
export TMP=/tmp
export TEMP=/tmp

# Set the editor to be vim, if it's installed
if [ -n "`type vim 2>&-`" ]; then
    export EDITOR="vim"
elif [ -n "`type vi 2>&-`" ]; then
    export EDITOR="vi"
fi

export numColors=2
# Variables containing escape sequences for terminal colors
if [ -n "`type tput 2>&-`" ]; then
    export numColors=`tput colors`
    export bldTxt=`tput bold`
    export undTxt=`tput smul`
    export soutTxt=`tput smso`
    export txtBlk=`tput setaf 0`  # Black - Regular
    export txtRed=`tput setaf 1`  # Red
    export txtGrn=`tput setaf 2`  # Green
    export txtYlw=`tput setaf 3`  # Yellow
    export txtBlu=`tput setaf 4`  # Blue
    export txtPur=`tput setaf 5`  # Purple
    export txtCyn=`tput setaf 6`  # Cyan
    export txtWht=`tput setaf 7`  # White
    export bldBlk=$bldTxt$txtBlk  # Black - Bold
    export bldRed=$bldTxt$txtRed  # Red
    export bldGrn=$bldTxt$txtGrn  # Green
    export bldYlw=$bldTxt$txtYlw  # Yellow
    export bldBlu=$bldTxt$txtBlu  # Blue
    export bldPur=$bldTxt$txtPur  # Purple
    export bldCyn=$bldTxt$txtCyn  # Cyan
    export bldWht=$bldTxt$txtWht  # White
    export undBlk=$undTxt$txtBlk  # Black - Underline
    export undRed=$undTxt$txtRed  # Red
    export undGrn=$undTxt$txtGrn  # Green
    export undYlw=$undTxt$txtYlw  # Yellow
    export undBlu=$undTxt$txtBlu  # Blue
    export undPur=$undTxt$txtPur  # Purple
    export undCyn=$undTxt$txtCyn  # Cyan
    export undWht=$undTxt$txtWht  # White
    export bakBlk=$soutTxt$txtBlk # Black - Background
    export bakRed=$soutTxt$txtBlk # Red
    export bakGrn=$soutTxt$txtBlk # Green
    export bakYlw=$soutTxt$txtBlk # Yellow
    export bakBlu=$soutTxt$txtBlk # Blue
    export bakPur=$soutTxt$txtBlk # Purple
    export bakCyn=$soutTxt$txtBlk # Cyan
    export bakWht=$soutTxt$txtBlk # White
    export txtRst=`tput sgr0`     # Text Reset
fi

# Setup the file type and directory colors used by ls
    if [ "$SYS" = "LINUX" ] && [ -z "$LS_COLORS" ] && `type dircolors 2>/dev/null >&2`; then
        # Check for a color settings in user's home directory
        if [ -r ${HOME}/.dircolors ]; then
            eval "`dircolors ${HOME}/.dircolors`"
        else # Use the system default settings
            eval "`dircolors`"
        fi
    elif [ "$SYS" = "BSD" ] && [ -z "$LSCOLORS" ]; then
        export LSCOLORS=ExGxFxdaCxDaDahBaDaCEC
    fi

# Set env so less uses lesspipe for more friendly behavior when viewing non-text
# input files, see lesspipe(1)
    if [ -z "$LESSOPEN" -o -z "$LESSCLOSE" ] && `type lesspipe 2>/dev/null >&2`; then
        eval "`SHELL=/bin/sh lesspipe`"
    fi

