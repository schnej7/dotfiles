function sauce() {
  source ~/.bashrc
}

function giff() {
  FILES=$(git diff --name-only $1 | fzf -m --preview "git diff $1 {} | bat --style=numbers --color=always")
  git diff $1 $FILES
}

function branch() {
  git branch -a --sort=-committerdate | \
  fzf --no-sort --header 'git checkout' \
      --preview 'branch=$(echo {} | sed "s/^[ *]*//" | sed "s#remotes/origin/##"); git log $branch --color=always' | \
  awk '{print $1}' | \
  sed 's#remotes/origin/##' | \
  xargs git checkout
}

function master() {
  git checkout master
}

# Get line count by contributer
function kill-count(){
    git ls-files -z | xargs -0rn 1 -P "$(nproc)" -I{} sh -c 'git blame -w -M -C -C --line-porcelain -- {} | grep -I --line-buffered "^author "' | sort -f | uniq -ic | sort -n
}

# inplace sed alias
function sedi() {
  sed -i $@
}

# src ack (ignore non src directories)
function sack(){
  ack "$@" --ignore-dir=dist --ignore-dir=node_modules --ignore-dir=coverage --ignore-dir=test_results
}

# Recursive replace all
function replace(){
    if [[ $1 && $2 && $3 ]]; then
        MATCH_COUNT=0
        FILE_COUNT=0
        ACK_FILES=$(sack -l $1 $3)
        for FILE in $ACK_FILES; do
            printf "${sh_grn}$FILE${sh_nc}\n"
            sack -C 1 $1 $FILE
            MATCH=`sack $1 $FILE | wc -l`
            MATCH_COUNT=$(expr $MATCH_COUNT + $MATCH)
            FILE_COUNT=$(expr $FILE_COUNT + 1)
            sedi s/$1/$2/g $FILE
            echo
        done
        printf "${sh_grn}success ${sh_cyn}$MATCH_COUNT${sh_nc} replacements in ${sh_cyn}$FILE_COUNT${sh_nc} files\n"
    else
        echo "No args $1, $2, $3"
        echo "replace string1 string2 directory"
    fi
}

# Get dir size on disk
function dirspace(){
    if [[ $1 ]]; then
        du -ch $1 | grep total
    else
        echo "No args"
    fi
}

# Rename a screen session
function renameScreen(){
    NEW_NAME=$(echo $@ | sed 's/.*\///g')
    screen -X sessionname $NEW_NAME
    export STY=$(echo $STY | sed "s/\..*/.$NEW_NAME/g")
}

# Alias vi to vim
function vi(){
    vim $@
}

# Rename screen session to file opened in vim
function vim(){
    renameScreen $@
    /usr/bin/vim $@
}

# Case insensitive find
function fa(){
    /usr/bin/find . -iname "$@";
}

# Case insensitive find exclude dist and node_modules
function f(){
    /usr/bin/find . -type d \( -path ./node_modules -o -path ./dist \) -prune -o -iname "$@" | grep -v "dist\|node_modules";
}

# Open all files matching name in vim
function o() {
  if [[ $1 ]]; then
    local FILES_STR=$(f $@)
    local FILES=( $FILES_STR )
  fi
  if [[ $1 && -z "${FILES[@]}" ]]; then
    printf "${sh_cyn}$@${sh_red} does not match any files${sh_nc}\n"
  elif [[ $1 && ${#FILES[@]} -eq 1 ]]; then
    vim ${FILES[0]}
  else
    if [[ "$FILES_STR" ]]; then
      local FILE=$(printf '%s\n' "$FILES_STR" | fzf -m)
    else
      local FILE=$(fzf -m)
    fi
    if [[ ${FILE} ]]; then
      vim -O $FILE
    fi
  fi
}

# Open all files in vim which contain a string
function osack(){
  FILES_STR=$(sack -l $@)
  FILES=( $FILES_STR )
  if [[ -z "${FILES[@]}" ]]; then
    printf "${sh_cyn}$@${sh_red} not found in any files${sh_nc}\n"
  elif [[ ${#FILES[@]} -eq 1 ]]; then
    vim ${FILES[0]}
  else
    FILE=$(printf '%s\n' "$FILES_STR" | fzf -m)
    if [ -z "${FILE}" ]; then
      vim -p $FILES_STR
    else
      vim -O $FILE
    fi
  fi
}

# List all screen sessions
function sl(){
    screen -list | grep -o "^[[:space:]]\+[0-9]*.*" | sed -e 's/(.*$//g' | sed -e "s/\s*//g"
}

# Kill all screen sessions
function ksl(){
    screen -list | grep -o "^[[:space:]]\+[0-9]*.*" | sed -e 's/(.*$//g' | sed -e "s/\s*//g" | xargs kill
}

# List all detached screen sessions
function dsl(){
    screen -ls | grep detached | grep -o "^[[:space:]]\+[0-9]*.*" | sed -e 's/(.*$//g' | sed 's/\..*//g'
}

# Kill all detached screen sessions
function kdsl(){
    screen -ls | grep detached | grep -o "^[[:space:]]\+[0-9]*.*" | sed -e 's/(.*$//g' | sed 's/\..*//g' | xargs kill
}

# Attach to the first detached screen session
function rs(){
    FIRST_SCREEN=$(dsl | sort | head -1)
    if [[ "$FIRST_SCREEN" != "" && "" == "$(echo $STY)" ]]; then
        screen -x $FIRST_SCREEN
    fi
}

# Attach to the first detached screen session or create a new screen session
function s(){
    FIRST_SCREEN=$(dsl | sort | head -1)
    if [[ "$FIRST_SCREEN" != "" && "" == "$(echo $STY)" ]]; then
        screen -x $FIRST_SCREEN
    elif [[ "" == "$(echo $STY)" ]]; then
        screen -q
    fi
}

# Create a new screen session
function ns(){
    if [[ "" == "$(echo $STY)" ]]; then
        screen -q
    fi
}

# Attach to a screen session with the specified name
function x(){
    if [[ "" == "$(echo $STY)" ]]; then
        screen -x $@;
    fi
}

# Delete a git tag locally and on origin
function deleteTag(){
  git tag --delete $1
  git push origin :refs/tags/$1
}

# Alias definitions.
if [ -f ~/.llm.bash ]; then
    . ~/.llm.bash
fi
