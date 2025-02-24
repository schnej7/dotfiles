# dotfiles
Environment Configurations

# Installation

`make` - Link base functionality

`make osx` - Link base functionality + OSX functionality

`make work` - Link base functionality + OSX functionality + private work functionality

# Features

* Improved bash prompt
* Bash aliases
* Screen configurations + utilities
* Vim configurations + plugins

## Bash Prompt

<img width="517" alt="image" src="https://github.com/user-attachments/assets/59b25b27-d96d-4775-9715-dd118a05004b" />

```
[<screen-id>](<user>@<host>)<working-dir>(<git-branchname> <git-branch-status>)
$ 
```
`git-branch-status`:
* `+` = Unstaged changes
* `x` = Staged changes not yet committed

## Bash Aliases

These are my most used aliases, there are more in [aliases.bash](https://github.com/schnej7/dotfiles/blob/main/bash/aliases.bash)

`f <filename>` - case insensitive find

`o <filename>` - open all files matching `<filename>` in vim

`ns` - new screen session

`sl` - list all screen sessions

`kill-count` - get line count in git repo by author

## Vim Quick Keys

`enter` - Toggle line numbers

`Ctrl+n` - Toggle relative line numbers

`Ctrl+h` - Hover tip

`0` - Find all references

`1` - Close all tabs but the current tab

`2` - Navigate tabs

`8` - Open quick fix

`9` - Close quick fix

`-` - Quick Fix lsp code action (suggestions to fix lsp error at cursor)
