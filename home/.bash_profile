# ~/.profile: Executed by bash(1) for login shells after executing /etc/profile.

# If this file is run it indicates this is a login shell
export LOGIN_SHELL=1

# Execute .profile if it exists
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# Execute .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Turn on bash programmable completion enhancements, if it has not already been
# enabled, exists, and the shell is configured for it. Any completions you add
# in ~/.bash_completion are sourced last.
if [ -n "${INTERACTIVE_SHELL}" -a -z "${BASH_COMPLETION}" -a -f /etc/bash_completion ] && shopt -q progcomp; then
    source /etc/bash_completion
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

