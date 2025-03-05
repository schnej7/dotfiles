eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# add colors to ls
alias ls='ls -G'

# inplace sed alias
function sedi() {
  sed -i '' $@
}
