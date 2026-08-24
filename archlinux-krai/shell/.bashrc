#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Homebrew environment
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi


# Added by Antigravity CLI installer
export PATH="${HOME}/.local/bin:$PATH"

# opencode
export PATH=${HOME}/.opencode/bin:$PATH

# kimi-code
export PATH="${HOME}/.kimi-code/bin:$PATH"
. "$HOME/.cargo/env"
