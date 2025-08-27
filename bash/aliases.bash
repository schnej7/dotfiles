function sauce() {
  source ~/.bashrc
}

function giff() {
  FILES=$(git diff --name-only $1 | fzf -m --preview "git diff $1 {} | bat --style=numbers --color=always")
  git diff $1 $FILES
}

function add() {
  # Get files that need to be staged during rebase
  # This includes: unmerged paths (conflicts), modified files, new files, etc.
  local files
  files=$(git status --porcelain | grep -E '^(UU|AA|DD|AU|UA|DU|UD)' | sed 's/^...//')
  
  # If no merge conflicts, check for regular unstaged files
  if [[ -z "$files" ]]; then
    files=$(git status --porcelain | grep -E '^ M | A | D |^\?\?' | sed 's/^...//')
  fi
  
  # Sort and remove duplicates
  files=$(printf '%s\n' "$files" | sort -u)
  
  if [[ -z "$files" ]]; then
    echo "No files need to be staged."
    return 0
  fi
  
  # Use fzf to select files with appropriate preview
  local selected_files
  selected_files=$(printf '%s\n' "$files" | fzf -m \
    --header='Select files to stage (Tab: multi-select, Enter: confirm)' \
    --preview 'cd $(git rev-parse --show-toplevel) && 
                 git diff --color=always {} 2>/dev/null || git diff --cached --color=always {} 2>/dev/null || echo "New file or binary"; 
              ' \
    --preview-window=right:60%:wrap)
  
  if [[ -n "$selected_files" ]]; then
    # Convert newlines to array and add each file
    while IFS= read -r file; do
      (
        cd $(git rev-parse --show-toplevel) && [[ -n "$file" ]] && git add "$file" && echo "Staged: $file"
      )
    done <<< "$selected_files"
  fi
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

function push() {
  git push origin $GIT_BRANCH --set-upstream
}

# inplace sed alias
function sedi() {
  sed -i $@
}

# src ack (ignore non src directories)
function sack(){
  ack "$@" --ignore-dir=dist --ignore-dir=node_modules --ignore-dir=coverage --ignore-dir=test_results --ignore-dir=static --ignore-dir=npm_build
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

docker-select() {
  command -v docker >/dev/null 2>&1 || { echo "docker not found"; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; return 1; }

  # Build a tab-separated list: ID (left) | other info (right)
  local list
  list="$(docker ps --format '{{.ID}} {{.Image}}')" || return 1
  if [ -z "$list" ]; then
    echo "No running containers."
    return 0
  fi

  # Let the user pick a container in fzf
  # Ctrl+C (or Esc) will cause fzf to exit non-zero, and we just return to the shell
  local selection
  selection="$(printf '%s\n' "$list" | fzf \
    --prompt='containers> ' \
    --header=$'Enter: exec sh  |  Ctrl-C/Esc: cancel' \
    --preview 'cid=$(echo {} | cut -d" " -f1); echo -e "$(docker inspect "$cid" --format "{{.Name}} {{.Created}} {{.Path}}" | sed "s/ /\\n/g")\n\n\nLogs:\n\n$(docker logs $cid)"' \
    --with-nth=1,2,3,4,5)" || return 0

  # Extract the container ID (first field, left side)
  local cid
  cid="$(printf '%s' "$selection" | cut -d" " -f1)"

  # Enter the container with sh
  docker exec -it "$cid" sh
}

# fzf over subdirectories within $CDPATH directories
cdf() {
  command -v fzf >/dev/null || { echo "fzf not found" >&2; return 1; }

  local IFS=':' path abs selection
  local -a entries=($CDPATH) cdpath_dirs=() subdirs=()

  # First, collect all valid CDPATH directories
  for path in "${entries[@]}"; do
    [[ -z "$path" ]] && continue
    [[ "$path" == "~"* ]] && path="${path/#\~/$HOME}"
    abs="$( (builtin cd -P "$path" 2>/dev/null && pwd) )" || continue
    [[ -n "$abs" ]] && cdpath_dirs+=("$abs")
  done

  [[ ${#cdpath_dirs[@]} -eq 0 ]] && { echo "No valid CDPATH directories" >&2; return 1; }

  # Then, collect all subdirectories within those CDPATH directories
  for path in "${cdpath_dirs[@]}"; do
    while IFS= read -r -d '' subdir; do
      subdirs+=("$subdir")
    done < <(find "$path" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
  done

  [[ ${#subdirs[@]} -eq 0 ]] && { echo "No subdirectories found in CDPATH" >&2; return 1; }

  selection="$(printf '%s\n' "${subdirs[@]}" | awk '!seen[$0]++' | fzf ${1:+-q "$1"} --preview 'ls {}')" || return
  [[ -n "$selection" ]] && builtin cd -P "$selection"
}

# Interactive git commit with conventional commit format
function commit() {
  # Check if we're in a git repository
  git rev-parse --git-dir &> /dev/null
  if [[ $? -ne 0 ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Get current branch name
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -z "$branch" ]]; then
    echo "Error: Unable to determine current branch"
    return 1
  fi

  # Extract ticket number (format: LETTERS-NUMBERS from branch name)
  local ticket=""
  if [[ "$branch" =~ ^([A-Za-z]+-[0-9]+) ]]; then
    ticket="${BASH_REMATCH[1]}"
  fi

  # Get subject from environment variable
  local subject="${COMMIT_SUBJECT:-}"
  if [[ -z "$subject" ]]; then
    echo "Warning: COMMIT_SUBJECT environment variable not set"
  fi

  # Define commit types with descriptions
  local -a types=(
    "feat: Introduces a new feature to the codebase"
    "fix: Patches a bug in the codebase"
    "docs: Changes related to documentation only"
    "style: Changes that do not affect the meaning of the code"
    "refactor: Code changes that neither fix a bug nor add a feature"
    "perf: Code changes specifically for improving performance"
    "test: Adding missing tests or correcting existing tests"
    "build: Changes that affect the build system or external dependencies"
    "ci: Changes to CI/CD configuration files and scripts"
    "chore: Miscellaneous changes that don't fall into other categories"
    "revert: Reverting a previous commit"
  )

  # Use fzf to select commit type
  local selected_type=$(printf '%s\n' "${types[@]}" | fzf \
    --prompt='Select commit type: ' \
    --height=40% \
    --reverse \
    --preview='echo {}' \
    --header='Select the type of change you are committing')
  
  if [[ -z "$selected_type" ]]; then
    echo "No commit type selected. Aborting."
    return 1
  fi

  # Extract just the type part (before the colon)
  local type=$(echo "$selected_type" | cut -d':' -f1)

  # Build commit message template
  local commit_msg
  if [[ -n "$ticket" ]]; then
    commit_msg="${type}(${subject}): description [${ticket}]"
  else
    commit_msg="${type}(${subject}): description"
  fi

  # Create temporary file for commit message
  local temp_file=$(mktemp)
  echo "$commit_msg" > "$temp_file"

  # Open editor (respecting EDITOR environment variable, defaulting to vim)
  "${EDITOR:-vim}" "$temp_file"

  # Read the final message
  local final_msg=$(cat "$temp_file")
  rm "$temp_file"

  # Check if user made meaningful changes (not just the template)
  if [[ "$final_msg" = "$commit_msg" ]] || [[ -z "$final_msg" ]] || [[ "$final_msg" =~ description ]]; then
    echo "Commit message was not properly filled out. Aborting."
    return 1
  fi

  # Perform the git commit
  git commit -m "$final_msg"
}
