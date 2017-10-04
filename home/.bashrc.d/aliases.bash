# Aliases
# #######

# Some example alias instructions
# If these are enabled they will be used instead of any instructions they may
# mask. For example, alias rm='rm -i' will mask the rm application. To override
# the alias use a \ before, ie \rm will call the real rm not the alias.

# NOTE: SHOULD USE ~/.ssh/config INSTEAD, SEE http://linux.die.net/man/5/ssh_config
# Enable use of SSH agent and X-Forwarding by default
#alias ssh='ssh -A -X'

# Make sudo an alias so other aliases get expanded and work in the sudo env
alias sudo='sudo  '

# Alias all of the executables in the user's home bin to their full path so
# that they will work in sudo
if [ -d ${HOME}/bin ]; then
    for f in ${HOME}/bin/*; do
        if [ -x ${f} ]; then
            alias ${f##*/}="${f}"
        fi
    done
    unset f
fi

# Interactive operation...
alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -FRX'                       # raw control characters
alias more='LESS_IS_MORE=1 less'             # Use less in place of more
alias whence='type -a'                       # where, of a sort
alias grep='smartpage 1 grep --color=always' # show differences in color, page results
alias find='smartpage find'                  # page results
alias dmesg='smartpage dmesg'                # page results
# Alias vim to vi if vim was found on the system
if [ "${EDITOR}" = "vim" ]; then
    alias vi='vim'
fi

alias tree='smartpage 1 tree -C'

# Some shortcuts for different directory listings
# Using colors and page results when output to TTY
if [ "${SYS}" = "BSD" ]; then
    alias ls='COLUMNS=$(tput cols) CLICOLOR_FORCE=1 smartpage 1 ls -GC -h'
elif [ "${SYS}" = "LINUX" ]; then
    alias ls='smartpage 2 ls --color=always -w${COLUMNS} -hC --group-directories-first'
fi
alias la='ls -A'   # all but . and ..
alias ll='ls -Al'  # all with long detailed list

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

