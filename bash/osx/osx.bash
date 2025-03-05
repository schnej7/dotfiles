eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

alias ls='ls -G'
