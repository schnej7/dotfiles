eval "$(/opt/homebrew/bin/brew shellenv)"

# Source bash completion, suppressing 'nosort' errors from newer completion
# scripts that require Bash 4.4+ (macOS ships with Bash 3.2)
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion 2> >(grep -v 'nosort: invalid option' >&2)
fi

# add colors to ls
alias ls='ls -G'

# inplace sed alias
function sedi() {
  sed -i '' $@
}
