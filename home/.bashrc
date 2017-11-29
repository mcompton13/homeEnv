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


# Shell Options
# #############

# Don't wait for job termination notification
set -o notify

# Turn on extended globbing, needed for PS1 to work correctly.
shopt -s extglob

# Now the pipeline's return status is the value of the last (rightmost) command
# to exit with a non-zero status, or 0 if all commands exit sucessfully.
set -o pipefail

# When changing directory small typos can be ignored by bash for example,
# cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# Turn on bash programmable completion enhancements, if it has not already been
# enabled, exists, and the shell is configured for it. Any completions you add
# in ~/.bash_completion are sourced last.
if [ -n "${INTERACTIVE_SHELL}" -a -z "${BASH_COMPLETION}" -a -f /etc/bash_completion ] && shopt -q progcomp; then
    source /etc/bash_completion
elif [ -n "${INTERACTIVE_SHELL}" -a -z "${BASH_COMPLETION}" -a -f /usr/local/etc/bash_completion ] && shopt -q progcomp; then
    source /usr/local/etc/bash_completion
fi

# Overwrite bash_completion functions so it doesn't expand ~
if [ -n "${BASH_COMPLETION}" ]; then
    function _expand()
    {
        return 0
    }

    function __expand_tilde_by_ref()
    {
        return 0
    }
fi


# History Options
# ###############

# Location of the history file
export HISTFILE="${HOME}/.bash_history"

# Location of the ALL history file (all commands from all time, no duplicates removed)
export HISTALLFILE="${HOME}/.bash_history.all"

# Keep a reasonable amount of history in memory.
export HISTSIZE=90000

# Large history file to hold lots of history.
export HISTFILESIZE=400000

# Store time in history file and display it for history command with this format
export HISTTIMEFORMAT=$(echo -e "%Y/%m/%d(${txtYlw}%H:%M:%S${txtRst}) ")

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:bg:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls:la:ll:cd' # Ignore the ls commands as well

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Use PgUp and PgDn to rerun the previous command through sudo
bind '"\e[5~": "\C-p\C-asudo \C-e"'
bind '"\e[6~": "\C-p\C-asudo \C-e"'
# Use PgUp and PgDn to Search through command history
#bind '"M-\e[6~": history-search-forward'
#bind '"M-\e[5~": history-search-backward'


HISTFILESIZE=$((${HISTSIZE} * 2))
HISTCOPYSIZE=$((${HISTSIZE} - 50))

# Duplicates history to /dev/null so the HISTALLFILE doesn't get a bunch of
# duplicate entries when running history command below
alias history='_bash_history_sync3 /dev/null; builtin history'
alias history_all="(builtin history -c && HISTFILE=${HISTALLFILE} builtin history -r && builtin history)"

function _bash_history_sync3() {
    local historyAllFile="${HISTALLFILE}"
    if [ -w "${1}" ]; then
        historyAllFile=${1}
    fi

    local lineCount=$(wc -l < ${HISTFILE})

    # Save the new history entries to the history file
    builtin history -a

    local newLineCount=$(wc -l < ${HISTFILE})
    newLineCount=$((${newLineCount} - ${lineCount}))

    #echo "historyAllFile: ${historyAllFile} LineCount: ${lineCount} NewCount: ${newLineCount}"

    if [[ ${newLineCount} -gt 0 ]]; then
        # Get the new lines and append it to the full history file
        local newLine=$(echo "$(tail -n${newLineCount} ${HISTFILE})" | tee -a ${historyAllFile})
        # Version with the the timestamp striped and the following regex symbols escaped: -].[^$*~/\
        local escapedNewLine=$(echo "${newLine}" | tail -n+2 | sed -E 's!([-]|[].[^$*~/\])!\\\1!g')

        # Now use ed to remove any previous reference to the command and add it to
        # end of the .bash_history file.
ed -s ${HISTFILE} <<EOF
\$ke
\$a
${newLine}
.
1,'eg/^${escapedNewLine}$/^,.d
w
EOF

    fi

    # Clear...
    builtin history -c
    # ...and reload the rewritten history from the .bash_history file
    builtin history -r
}


# Functions
# #########

# Adds up the values of all the characters of a string plus the length of the
# string
function calc_string_code {
    local str="${1}"
    local strCode=0
    local i=0

    while test -n "${str}" ; do
        i=$(($i + 1))
        char=${str:0:1}
        charCode=$(printf '%d' "'${char}")
        strCode=$(($strCode + ($i * $charCode)))
        str=${str:1}
    done

    echo $(($strCode + 2 * $i))
}

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
        local w="";
        local i="";
        ref=$(git symbolic-ref HEAD 2> /dev/null) || return 1
        git diff --no-ext-diff --quiet || w="*";
        git diff --no-ext-diff --cached --quiet || i="+";
        echo -n ${ref#refs/heads/}${w}${i}
    }
else
    function parse_git_branch {
        return 1
    }
fi

# Returns a string containing the name of the current hg branch if in a
# hg project directory.
if [ "$(hg --version 2>&-)" ]; then
    function parse_hg_branch {
        branch=$(hg identify -b 2>&-) || return 1
        echo -n ${branch}
    }
else
    function parse_hg_branch {
        return 1
    }
fi

# Returns a string containing the name of the current svn branch if in a
# svn project directory.
if [ "$(svn --version 2>/dev/null)" ]; then
    function parse_svn_branch {
        if [ ! -d ".svn" ]; then return 1; fi
        info=$(svn info 2>/dev/null) || return 1
        echo -n "$(echo -n "${info}" | sed -ne 's#^URL: .*/\([^/]*/\(\(trunk\)\|\(branches\|tags\)/\([^/]*\)\)\)/\?.*#\3\5#p ')"
    }
else
    function parse_svn_branch {
        return 1
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
    _bash_history_sync3

    local TERMWIDTH=${COLUMNS:=80} # Default to 80 chars wide if not set

    # Update variables that may have changed after executing the last command
    promptPWD=$(parse_pwd "$(dirs +0)" $(( (${TERMWIDTH} - 20) / 2 )) ) # Length of PWD based on TERMWIDTH
    titlePWD=$(parse_pwd "${PWD}" $(( ${TERMWIDTH} - 45 )) ) # Length of PWD based on TERMWIDTH
    titlePromptBranch=$(parse_hg_branch || parse_git_branch || parse_svn_branch)

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
        local jobRegex="^\[${cmdArg}\][+-]\{0,1\}"
        if [[ "${cmdArg}" == "+" ]] || [[ "${cmdArg}" == "-" ]]; then
            jobRegex="^\[[0-9]\{1,3\}\]${cmdArg}"
        fi
        # Use the name of the command from the jobs command
        cmdTitle=$(jobs 2>&- | grep "${jobRegex}" | sed -e "s/${jobRegex}[ ][ ]*[[:alpha:]][[:alpha:]]*[^[:alpha:]][^[:alpha:]]*//g")
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


    # Reset text color to the terminal default for the command output
    echo -n "${txtRst}" > $(tty)
}

preexec_install

# Bash Prompt
#############

# Colors and info used for the prompt
titlePromptUser=""
promptColor="\[${txtRst}\]"
promptUserColor="\[${bldGrn}\]"

user=$(whoami)
# Only show the user if it's not my normal username 'mcompton'
if [ ! "${user}" = "mcompton" ]; then
    if [ "${UID}" = "0" ]; then
        promptColor="\[${bldRed}\]"
        promptUserColor="\[${bldRed}\]"
    fi
    titlePromptUser=${user}
    titleHost=${HOSTNAME%%.*}
fi

titleHost=""
titleSep=" \xe2\x80\x94 "

if [ -n "${REMOTE_SHELL}" ]; then
    # Only show the hostname in the title if we're on a remote machine
    titleHost=${HOSTNAME%%.*}
    # Change the separator so it works on all remote machines
    titleSep=" -- "
fi

defaultColor="\[${txtRst}\]"
if [ -n "${REMOTE_SHELL}" ] && [[ ${numColors} -gt 2 ]]; then
    hostNameCode=$(calc_string_code "${HOSTNAME}")
    colorCode=$(($hostNameCode % $numColors))
    hostColor="\[${undTxt}${bldTxt}$(tput setaf $colorCode)\]"
else
    hostColor="\[${bldCyn}\]"
fi
pwdColor="\[${bldBlu}\]"
branchColor="\[${bldPur}\]"

# Set the prompt
PS1="${defaultColor}["\
"\${titlePromptUser/!([:blank:])/${promptUserColor}\${titlePromptUser}${defaultColor}@}"\
"${hostColor}\h${defaultColor}:"\
"${pwdColor}\${promptPWD}${defaultColor}"\
"\${titlePromptBranch/!([:blank:])/|${branchColor}\${titlePromptBranch}${defaultColor}}"\
"]${promptColor}\\$ "


fi # closing if [ -n "$PS1" ]; then
