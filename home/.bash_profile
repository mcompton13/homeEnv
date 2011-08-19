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

