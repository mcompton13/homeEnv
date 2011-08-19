# ~/.profile: Executed by the command interpreter for login shells.
#
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.
# see /usr/share/doc/bash/examples/startup-files for examples. The files are
# located in the bash-doc package.

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

# Variables containing escape sequences for terminal colors
export txtBlk='\e[0;30m' # Black - Regular
export txtRed='\e[0;31m' # Red
export txtGrn='\e[0;32m' # Green
export txtYlw='\e[0;33m' # Yellow
export txtBlu='\e[0;34m' # Blue
export txtPur='\e[0;35m' # Purple
export txtCyn='\e[0;36m' # Cyan
export txtWht='\e[0;37m' # White
export bldBlk='\e[1;30m' # Black - Bold
export bldRed='\e[1;31m' # Red
export bldGrn='\e[1;32m' # Green
export bldYlw='\e[1;33m' # Yellow
export bldBlu='\e[1;34m' # Blue
export bldPur='\e[1;35m' # Purple
export bldCyn='\e[1;36m' # Cyan
export bldWht='\e[1;37m' # White
export undBlk='\e[4;30m' # Black - Underline
export undRed='\e[4;31m' # Red
export undGrn='\e[4;32m' # Green
export undYlw='\e[4;33m' # Yellow
export undBlu='\e[4;34m' # Blue
export undPur='\e[4;35m' # Purple
export undCyn='\e[4;36m' # Cyan
export undWht='\e[4;37m' # White
export bakBlk='\e[40m'   # Black - Background
export bakRed='\e[41m'   # Red
export badGrn='\e[42m'   # Green
export bakYlw='\e[43m'   # Yellow
export bakBlu='\e[44m'   # Blue
export bakPur='\e[45m'   # Purple
export bakCyn='\e[46m'   # Cyan
export bakWht='\e[47m'   # White
export txtRst='\e[0m'    # Text Reset

# Setup the file type and directory colors used by ls
if [ -z "$LS_COLORS" ] && `type dircolors 2>/dev/null >&2`; then
    # Check for a color settings in user's home directory
    if [ -r ${HOME}/.dircolors ]; then
        eval "`dircolors ${HOME}/.dircolors`"
    else # Use the system default settings
        eval "`dircolors`"
    fi
fi

# Set env so less uses lesspipe for more friendly behavior when viewing non-text
# input files, see lesspipe(1)
if [ -z "$LESSOPEN" -o -z "$LESSCLOSE" ] && `type lesspipe 2>/dev/null >&2`; then
    eval "`SHELL=/bin/sh lesspipe`"
fi

