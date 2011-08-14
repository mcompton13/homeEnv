# .bashrc

# 3 Cases:
# Interactive Login (Login using /bin/login, ssh, su - <USER_NAME>)
#   1. Runs /etc/profile 
#   2. Runs ~/.bash_profile, ~/.bash_login, or ~/.profile, whichever is found
#      first
#   3. One of the above is then configured to run ~/.bashrc
# Interactive Non-Login (su, xterm, gnome-terminal, run bash w/o args, scp, run
# a command remotely using ssh...)
#   1. Copy parent exported env
#   2. Run ~/.bashrc
# Non-Interactive Non-Login (running scripts, bash -c <COMMAND>)
#   1. Copy parent exported env

# Detect if this is an interactive shell
if [ -n "${PS1}" ]; then
    export INTERACTIVE_SHELL=1
fi

# Detect if this is a remote shell
if [ -n "${SSH_CLIENT:+x}" ]; then
    export REMOTE_SHELL=1
fi

# Source all of the .bash files in the ~/.bashrc.d directory
if [ -d ${HOME}/.bashrc.d ]; then
    for f in ${HOME}/.bashrc.d/*.bash; do
        if [ -r ${f} ]; then
            source ${f}
        fi
    done
    unset f
fi

# $PS1 is only set in interactive mode.
if [ -n "$PS1" ]; then
# Only run the rest in interactive mode

# Environment Variables
# #####################

if [ "$(which dircolors 2>/dev/null)" ]; then
    eval $(dircolors)
fi

# Shell Options
# #############

# See man bash for more options...

# Don't wait for job termination notification
set -o notify

# Turn on extended globbing, needed for PS1 to work correctly.
shopt -s extglob

# Now the pipeline's return status is the value of the last (rightmost) command
# to exit with a non-zero status, or 0 if all commands exit sucessfully.
set -o pipefail

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# History Options
# ###############

# Keep a reasonable amount of history in memory.
export HISTSIZE=1000 

# Large history file to hold lots of history.
export HISTFILESIZE=40960 

# Erase duplicate lines in the history.
export HISTCONTROL=erasedups:ignoredups

# Store time in history file and display it for history command with this format
export HISTTIMEFORMAT=$(echo -e "%Y/%m/%d(${txtYlw}%H:%M:%S${txtRst}) ")

#export HISTFILE="${HOME}/.bash_history.test"

# Make bash append rather than overwrite the history on disk
#shopt -s histappend

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:bg:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls:la:ll:cd' # Ignore the ls commands as well

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Use PgUp and PgDn to rerun the previous command through sudo
#bind '"\e[5~": "\C-p\C-asudo \n"'
#bind '"\e[6~": "\C-p\C-asudo \n"'
# Use PgUp and PgDn to Search through command history
#bind '"M-\e[6~": history-search-forward'
#bind '"M-\e[5~": history-search-backward'


# Functions
# #########

# Returns a string representing the current working directory that is no
# longer than $MAX_LEN characters.
function parse_pwd {
    local dirStr="$1"
    local MAX_LEN="$2"

    if [ ${#dirStr} -gt ${MAX_LEN} ]; then
        local ORIG_IFS=${IFS}
        IFS=$(echo -e "\x1F")

        local dirArr=(${dirStr//\//${IFS}})
        local first="${dirArr[0]}"
        local last="${dirArr[ $((${#dirArr[@]} - 1)) ]}"

        IFS=${ORIG_IFS}

        if [ -z ${first} ]; then
            first="/${dirArr[1]}"
        fi

        if [ $((${#first} + ${#last} + 5)) -le ${MAX_LEN} ]; then
            last="${dirStr: -$((${MAX_LEN} - ${#first} - 5))}"
            dirStr="${first}/.../${last#*/}"
        else
            dirStr="${last}"
        fi
    fi

    echo ${dirStr}
}

# Returns a string containing the name of the current git branch if in a
# git project directory.
if [ "$(git --version 2>/dev/null)" ]; then
    function parse_git_branch {
        local gitDir=$(git rev-parse --show-toplevel 2> /dev/null) || return
        # Don't show git info for a git project in the home dir
        if [[ "${gitDir}" == "${HOME}" ]]; then
            return
        fi
        local ref=$(git symbolic-ref HEAD 2> /dev/null) || return
        echo ${ref#refs/heads/}
    }
else
    function parse_git_branch {
        return
    }
fi

# Returns a string containing the name of the current svn branch if in a
# svn project directory.
if [ "$(svn --version 2>/dev/null)" ]; then
    function parse_svn_branch {
        if [ ! -d ".svn" ]; then return; fi
        info=$(svn info 2>/dev/null) || return
        echo "$(echo "${info}" | sed -ne 's#^URL: .*/\([^/]*/\(\(trunk\)\|\(branches\|tags\)/\([^/]*\)\)\)/\?.*#\3\5#p ')"
    }
else
    function parse_svn_branch {
        return
    }
fi

function cmd_timer() {
    local SHOW_DATE_MIN_DURATION=$((5 * 60)) # 5 minutes

    local startDate=$(date)
    "$@"
    local cmdRetValue=$?
    local endDate=$(date)
    local start=$(date --date="${startDate}" +%s)
    local end=$(date --date="${endDate}" +%s)
    local cmdDuration=$((end - start))
    local dateString=""
    if [[ ${cmdDuration} -ge ${SHOW_DATE_MIN_DURATION} ]]; then
        dateString="${endDate}: "
    fi

    local timerString="${txtGrn}${dateString}Finished sucessfully after "
    if [[ $cmdRetValue -ne 0 ]]; then
        timerString="${bldRed}${dateString}Failed with exit code ${cmdRetValue} after "
    fi
    echo -e "${timerString}$(print_duration ${cmdDuration})${txtRst}"
}

function print_duration() {
    local durationSeconds=$@
    if [[ ${durationSeconds} -eq 0 ]]; then
        echo "less than 1 second"
        return
    fi

    local hours=$((${durationSeconds} / 3600))
    durationSeconds=$((${durationSeconds} - (${hours} * 3600)))
    local minutes=$((${durationSeconds} / 60))
    local seconds=$((${durationSeconds} - (${minutes} * 60)))
    local hoursString=""
    local minutesString=""
    local secondsString=""

    if [[ ${hours} -gt 0  ]]; then
        hoursString="${hours}_hour"
    fi
    if [[ ${hours} -gt 1 ]]; then
        hoursString="${hoursString}s"
    fi
    if [[ ${minutes} -gt 0  ]]; then
        minutesString="${minutes}_minute"
    fi
    if [[ ${minutes} -gt 1 ]]; then
        minutesString="${minutesString}s"
    fi
    if [[ ${seconds} -gt 0  ]]; then
        secondsString="${seconds}_second"
    fi
    if [[ ${seconds} -gt 1 ]]; then
        secondsString="${secondsString}s"
    fi

    local durStringArray=("${hoursString}" "${minutesString}"  "${secondsString}")
    local durString=""
    local sep=""
    for str in ${durStringArray[@]}; do
        durString="${durString}${sep}${str}"
        sep=", "
    done

    echo "${durString//_/ }"
}

function cmd_log() {
    local opts=( "$@" )
    local CMD_NAME="${opts[0]}-$$-$(date +%s)"
    local ALL_LOG="${CMD_NAME}.log"
    local OUT_LOG="${CMD_NAME}.out"
    local ERR_LOG="${CMD_NAME}.err"

    echo "Logging to '${OUT_LOG}' and '${ERR_LOG}'"

    # Logs only stdout in the $OUT_LOG file and stderr to $ERR_LOG file
    #"$@" > >(tee "${OUT_LOG}") 2> >(tee "${ERR_LOG}" >&2)
    # Same as above, but colorize stderr red
    #"$@" > >(tee "${OUT_LOG}" | sed "s/^/$(echo -en ${txtRst})/") 2> >(tee "${ERR_LOG}" | sed "s/^/$(echo -en ${bldRed})/" >&2)
    # Logs both stdout and stderr in the $ALL_LOG file, stdout in $OUT_LOG, and
    # stderr to $ERR_LOG file
    #("$@" > >(tee "${OUT_LOG}") 2> >(tee "${ERR_LOG}" >&2)) &> >(tee -a "${ALL_LOG}") 
    # Same as above, but colorize stderr red
    ("$@" > >(tee "${OUT_LOG}" | sed "s/^/$(echo -en ${txtRst})/") 2> >(tee "${ERR_LOG}" | sed "s/^/$(echo -en ${bldRed})/" >&2)) &> >(tee "${ALL_LOG}") 
}

function precmd () {
    # Get the latest command history
    history -c
    history -r
    local TERMWIDTH=${COLUMNS:=80} # Default to 80 chars wide if not set

    # Update variables that may have changed after executing the last command
    promptPWD=$(parse_pwd "$(dirs +0)" $(( (${TERMWIDTH} - 20) / 2 )) ) # Length of PWD based on TERMWIDTH
    titlePWD=$(parse_pwd "${PWD}" $(( ${TERMWIDTH} - 45 )) ) # Length of PWD based on TERMWIDTH
    titlePromptBranch=$(parse_git_branch)$(parse_svn_branch)
    titlePromptUser=""
    promptColor=$(echo -e "${txtRst}")
    promptUserColor=$(echo -e "${bldGrn}")
    
    titleHost=""
    titleSep=" \xe2\x94\x80 "

    local user=$(whoami)
    # Only show the user if it's not my normal username 'mcompton'
    if [ ! "${user}" = "mcompton" ]; then
        if [ "${UID}" = "0" ]; then
            promptColor=$(echo -e "${bldRed}")
            promptUserColor=$(echo -e "${bldRed}")
        fi
        titlePromptUser=${user}
        titleHost=${HOSTNAME%%.*}
    fi

    if [ -n "${REMOTE_SHELL}" ]; then
        # Only show the hostname in the title if we're on a remote machine
        titleHost=${HOSTNAME%%.*}
        # Change the separator so it works on all remote machines
        titleSep=" -- "
    fi

    # Set the window title
    if [[ ! "$TERM" == linux ]]; then
        preexec_xterm_title "Terminal${titleSep}${titlePromptUser/!([:blank:])/${titlePromptUser}@}${titleHost/!([:blank:])/${titleHost}:}${titlePWD}"
    fi
    if [[ "$TERM" == screen ]]; then
        preexec_screen_title "(`preexec_screen_user_at_host`) (${titlePWD})"
    fi
}

function preexec () {
    local cmdTitle="${1//\\/\\\\}" # Escape backslashes in the command
    local cmdName=${cmdTitle%% *}

    if [[ "${cmdName}" == "fg" ]]; then
        local cmdArr=(${cmdTitle// / })
        # Only take the first arg to fg, default arg to + if none was specified
        cmdArg=${cmdArr[1]:-"+"}
        local jobRegex="^\[${cmdArg}\][+-]?"
        if [[ "${cmdArg}" == "+" ]] || [[ "${cmdArg}" == "-" ]]; then
            jobRegex="^\[[0-9]{1,3}\]\\${cmdArg}"
        fi
        # Use the name of the command from the jobs command
        cmdTitle=$(jobs 2>/dev/null | grep -E "${jobRegex}" | sed -re "s/${jobRegex}[ ]+[A-Za-Z]+[^a-zA-Z0-9]+//g")
    fi

    # Add the running command to the window title
    if [[ ! "${TERM}" == "linux" ]]; then
        preexec_xterm_title "${cmdTitle}${titleSep}${titlePromptUser/!([:blank:])/${titlePromptUser}@}${titleHost/!([:blank:])/${titleHost}:}${titlePWD}"
    fi
    if [[ "${TERM}" == "screen" ]]; then
        local cutit="$1"
        local cmdTitle=`echo "$cutit" | cut -d " " -f 1`
        if [[ "$cmdName" == "exec" ]]; then
            local cmdTitle=$(echo "${cmdTitle}" | cut -d " " -f 2)
        fi
        if [[ "$cmdName" == "screen" ]]; then
            # Since stacked screens are quite common, it would be nice to
            # just display them as '$$'.
            local cmdTitle="${PROMPTCHAR}"
        else
            local cmdTitle=":$cmdTitle"
        fi
        preexec_screen_title "${cmdTitle}${titleSep}`preexec_screen_user_at_host`:${titlePWD}"
    fi

    # Append the current command to the history file.
    history -a

    # Reset text color to the terminal default for the command output
    echo -ne "${txtRst}" > $(tty)
}

preexec_install

# Bash Prompt
#############

# Colors used for the prompt
defaultColor="\["${txtRst}"\]"
if [ -n "${REMOTE_SHELL}" ]; then
    hostColor="\["${bldPur}"\]"
else
    hostColor="\["${bldCyn}"\]"
fi
pwdColor="\["${bldBlu}"\]"
branchColor="\["${bldPur}"\]"

# Set the prompt
PS1="${defaultColor}["\
"\${titlePromptUser/!([:blank:])/\[\${promptUserColor}\]\${titlePromptUser}${defaultColor}@}"\
"${hostColor}\h${defaultColor}:"\
"${pwdColor}\${promptPWD}${defaultColor}"\
"\${titlePromptBranch/!([:blank:])/|${branchColor}\${titlePromptBranch}${defaultColor}}"\
"]\[\${promptColor}\]\\$ "


# Aliases
# #######

# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.

# Now the aliases we've defined will work in sudo
alias sudo='A=`alias` sudo  '

# Interactive operation...
alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -FRX'                          # raw control characters
alias more='LESS_IS_MORE=1 less -FRX'           # Use less in place of more
alias whence='type -a'                          # where, of a sort
alias grep='cmdless_color grep --color=always'  # show differences in color, page results
alias find='cmdless find'                       # page results
alias vi='vim'

# Some shortcuts for different directory listings
# Using colors and piped to less for tty
alias ls='cmdless_color 2 ls --color=always -w${COLUMNS} -hx --group-directories-first'
alias la='cmdless_color 2 ls --color=always -w${COLUMNS} -Ahx --group-directories-first' # all but . and ..
alias ll='cmdless_color 2 ls --color=always -w${COLUMNS} -hl --group-directories-first'  # long list

alias lasterr='cmdless lasterr'


fi # closing if [ -n "$PS1" ]; then
