# Load bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
