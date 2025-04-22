function ai_help_me_test() {
    local output_file="$1" # File to capture the command output
    shift # Remove the first argument (output file)
    local command_to_run="$@" # All remaining arguments form the command to run
    local fail_file="/tmp/failing_tests.txt" # Temporary file to store failing test filenames
    local test_descriptions="/tmp/failing_test_descriptions.txt" # Store test descriptions
    
    # Define colors for output
    local cyan='\033[0;36m'
    local green='\033[0;32m'
    local yellow='\033[0;33m'
    local red='\033[0;31m'
    local nc='\033[0m' # No Color
    
    # Check if output file is provided
    if [[ -z "$output_file" ]]; then
        echo "Error: Please provide the output file as the first argument."
        return 1
    fi
    
    # Check if command is provided
    if [[ -z "$command_to_run" ]]; then
        echo "Error: Please provide the command to run as the second argument."
        return 1
    fi
    
    # Clear any existing data
    > "$output_file"
    > "$fail_file"
    > "$test_descriptions"
    
    # Function to clean up resources
    function cleanup() {
        # Remove temporary files
        rm -f "$fail_file" "$test_descriptions"
        echo -e "${green}Cleanup complete.${nc}"
    }
    
    # Set up trap for Ctrl+C and normal exit
    trap cleanup SIGINT EXIT
    
    echo -e "${green}Running test command and capturing output...${nc}"
    
    # Execute the command and capture both stdout and stderr, show in real-time, and write to file
    eval "$command_to_run" 2>&1 | tee "$output_file"
    
    echo -e "${green}Tests completed.${nc}"
    
    # Process the captured output for failing tests
    while IFS= read -r line; do
        # Process lines for failing tests
        if [[ "$line" =~ ^FAIL[[:space:]] ]]; then
            # Extract the file path after module name
            if [[ "$line" =~ ^FAIL[[:space:]]+[^[:space:]]+[[:space:]]+(.+) ]]; then
                current_test_file="${BASH_REMATCH[1]}"
                echo "$current_test_file" >> "$fail_file"
                in_failing_test=true
            fi
        fi
        
        # Detect test description lines that follow FAIL lines
        if [[ "$in_failing_test" == true && "$line" =~ [[:space:]]*●[[:space:]] ]]; then
            if [[ "$line" =~ ●[[:space:]]+(.+) ]]; then
                current_test_desc="${BASH_REMATCH[1]}"
                echo "$current_test_file: $current_test_desc" >> "$test_descriptions"
            fi
        fi
        
        # Look for file paths in error messages
        if [[ "$line" =~ \(([^:]+\.(spec|test)\.(js|ts|tsx)):[0-9]+ ]]; then
            echo "${BASH_REMATCH[1]}" >> "$fail_file"
        fi
        
        # Reset failing test tracking when we see a PASS line
        if [[ "$line" =~ ^PASS ]]; then
            in_failing_test=false
        fi
        
        # Reset failing test tracking when we see a new test suite summary
        if [[ "$line" =~ ^Test[[:space:]]Suites: ]]; then
            in_failing_test=false
        fi
    done < "$output_file"
    
    # Determine the base branch using the algorithm:
    # 1. Get current branch name
    # 2. Iterate through git log
    # 3. For each commit, check if it's the HEAD of a branch other than current branch
    # 4. If found, that's our base branch
    local base_branch=""
    local current_branch=$(git branch --show-current)
    
    echo -e "${green}Determining parent branch by analyzing commit history...${nc}"
    echo -e "${cyan}Current branch:${nc} $current_branch"
    
    # Get the raw git log output with all branch references
    local git_log_output=$(git log --pretty=format:"%H %d" -n 100)
    
    # Process each commit in the log
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi
        
        # Extract commit hash and branch info
        local commit_hash=$(echo "$line" | awk '{print $1}')
        local branch_info=$(echo "$line" | sed -E 's/^[a-f0-9]+ //')
        
        # If we have branch info (in parentheses)
        if [[ "$branch_info" =~ \((.*)\) ]]; then
            local branches="${BASH_REMATCH[1]}"
            
            # Split by commas only, not spaces
            IFS=',' read -ra BRANCH_ARRAY <<< "$branches"
            for branch_entry in "${BRANCH_ARRAY[@]}"; do
                # Trim leading/trailing whitespace
                branch_entry=$(echo "$branch_entry" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                
                # Handle "HEAD -> branch-name" format
                if [[ "$branch_entry" == "HEAD"* && "$branch_entry" == *"->"* ]]; then
                    # Extract the branch name after the arrow
                    branch=$(echo "$branch_entry" | sed -e 's/^HEAD[[:space:]]*->[[:space:]]*//')
                else
                    branch="$branch_entry"
                fi
                
                # Skip if it's just "HEAD" or "->"
                if [[ "$branch" == "HEAD" || "$branch" == "->" ]]; then
                    continue
                fi
                
                # Skip if it's the current branch or points to current branch
                if [[ "$branch" == "$current_branch" || "$branch" == "origin/$current_branch" ]]; then
                    continue
                fi
                
                # Remove "origin/" prefix if present for comparison
                local clean_branch="$branch"
                if [[ "$clean_branch" == origin/* ]]; then
                    clean_branch="${clean_branch#origin/}"
                fi
                
                # We found a base branch
                base_branch="$clean_branch"
                local short_commit=$(echo "$commit_hash" | cut -c 1-10)
                local commit_msg=$(git log -1 --pretty=format:"%s" "$commit_hash")
                echo -e "${green}Found parent branch at commit ${cyan}$short_commit${green}:${nc} $base_branch"
                echo -e "${cyan}Commit message:${nc} $commit_msg"
                break 2  # Break out of both loops
            done
        else
            # If no branch info in the log line, try to get it directly
            local branches=$(git branch -a --contains "$commit_hash" --format="%(refname:short)" | grep -v "$current_branch")
            
            if [[ -n "$branches" ]]; then
                # Take the first branch that's not the current branch
                for branch in $branches; do
                    # Skip if it's the current branch or points to current branch
                    if [[ "$branch" == "$current_branch" || "$branch" == "origin/$current_branch" ]]; then
                        continue
                    fi
                    
                    # Remove "origin/" prefix if present
                    local clean_branch="$branch"
                    if [[ "$clean_branch" == origin/* ]]; then
                        clean_branch="${clean_branch#origin/}"
                    fi
                    
                    # We found a base branch
                    base_branch="$clean_branch"
                    local short_commit=$(echo "$commit_hash" | cut -c 1-10)
                    local commit_msg=$(git log -1 --pretty=format:"%s" "$commit_hash")
                    echo -e "${green}Found parent branch at commit ${cyan}$short_commit${green}:${nc} $base_branch"
                    echo -e "${cyan}Commit message:${nc} $commit_msg"
                    break 2  # Break out of both loops
                done
            fi
        fi
    done <<< "$git_log_output"
    
    # If we still don't have a base branch, use "master" as fallback
    if [[ -z "$base_branch" ]]; then
        base_branch="master"  # Default fallback
        echo -e "${yellow}Could not determine parent branch from commit history. Using default:${nc} ${cyan}$base_branch${nc}"
    fi
    
    # Generate LLM prompt with new format
    echo -e "${green}Generating LLM prompt...${nc}"
    local llm_prompt="The failing test output is available in the file ${output_file}, please analyze the output and determine if the failures are legitimate and/or if the tests need to be updated based on code changes and implement fixes where possible."
    
    echo -e "\n${yellow}### LLM Prompt ###${nc}"
    echo -e "$llm_prompt"
    
    # Report failing tests with descriptions
    echo -e "\n${yellow}Failing tests with descriptions:${nc}"
    if [[ -f "$test_descriptions" && -s "$test_descriptions" ]]; then
        while IFS= read -r line; do
            file_part=$(echo "$line" | cut -d':' -f1)
            desc_part=$(echo "$line" | cut -d':' -f2-)
            # Print file path in cyan, then newline, then description
            echo -e "${cyan}$file_part${nc}\n$desc_part"
        done < <(sort -u "$test_descriptions")
    else
        echo -e "No failing tests detected."
    fi
    
    # Generate list of files modified in the current branch
    git diff --name-only "$base_branch" > /tmp/modified_files.txt
    echo "$output_file" >> /tmp/modified_files.txt
    
    echo -e "\n${yellow}Modified files:${nc}"
    while IFS= read -r line; do
        echo -e "${cyan}$line${nc}"
    done < /tmp/modified_files.txt
    
    # Cleanup will be called automatically via the EXIT trap
}

# Bash completion function for ai_help_me_test
_ai_help_me_test_complete() {
    local cur prev words cword
    
    # Check if _init_completion is available (from bash-completion package)
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion || return
    else
        # Fallback implementation if _init_completion is not available
        COMPREPLY=()
        # Get the current word being completed
        cur="${COMP_WORDS[COMP_CWORD]}"
        # Get the previous word
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        # Copy the array of words in the current command line
        words=("${COMP_WORDS[@]}")
        # Get the current word position
        cword=$COMP_CWORD
    fi

    # If we're completing the first argument, suggest files
    if [ $cword -eq 1 ]; then
        # If _filedir is not available, use a basic file completion
        if declare -F _filedir >/dev/null 2>&1; then
            _filedir
        else
            # Basic file completion fallback
            COMPREPLY=($(compgen -f -- "$cur"))
        fi
        return 0
    fi

    # If we're completing the second argument, suggest available commands
    if [ $cword -eq 2 ]; then
        COMPREPLY=($(compgen -c -- "$cur"))
        return 0
    fi

    # For third and subsequent arguments, forward completion to the command
    if [ $cword -ge 3 ]; then
        # Get the command that we're wrapping (second argument)
        local cmd="${words[2]}"
        
        # Check if the command exists
        if ! command -v "$cmd" &> /dev/null; then
            return 0
        fi

        # Get the arguments for the command (everything after the command)
        local cmd_args=()
        for ((i=3; i<cword; i++)); do
            cmd_args+=("${words[i]}")
        done
        
        # Get the completion for the command
        local cmd_completion=""
        
        # Try to get the completion spec for the command
        local completion_spec=$(complete -p "$cmd" 2>/dev/null || echo "")
        
        if [[ -n "$completion_spec" ]]; then
            # Check if it uses a completion function (-F)
            if [[ "$completion_spec" =~ -F[[:space:]]+([^[:space:]]+) ]]; then
                local comp_func="${BASH_REMATCH[1]}"
                
                # Create a temporary environment to run the completion function
                local tmp_COMP_LINE="$cmd ${cmd_args[*]} $cur"
                local tmp_COMP_WORDS=("$cmd" "${cmd_args[@]}" "$cur")
                local tmp_COMP_CWORD=$((${#cmd_args[@]} + 1))
                local tmp_COMP_POINT=${#tmp_COMP_LINE}
                
                # Save original environment
                local old_COMP_LINE="$COMP_LINE"
                local old_COMP_WORDS=("${COMP_WORDS[@]}")
                local old_COMP_CWORD="$COMP_CWORD"
                local old_COMP_POINT="$COMP_POINT"
                
                # Set up environment for the completion function
                COMP_LINE="$tmp_COMP_LINE"
                COMP_WORDS=("${tmp_COMP_WORDS[@]}")
                COMP_CWORD="$tmp_COMP_CWORD"
                COMP_POINT="$tmp_COMP_POINT"
                
                # Run the completion function
                $comp_func
                
                # Save the results
                local results=("${COMPREPLY[@]}")
                
                # Restore original environment
                COMP_LINE="$old_COMP_LINE"
                COMP_WORDS=("${old_COMP_WORDS[@]}")
                COMP_CWORD="$old_COMP_CWORD"
                COMP_POINT="$old_COMP_POINT"
                
                # Set the completion results
                COMPREPLY=("${results[@]}")
                
                return 0
            elif [[ "$completion_spec" =~ -C[[:space:]]+([^[:space:]]+) ]]; then
                # Command-based completion
                local comp_cmd="${BASH_REMATCH[1]}"
                
                # Build the command line for the completion command
                local cmd_line="$cmd ${cmd_args[*]} $cur"
                
                # Run the completion command and capture the output
                COMPREPLY=($(eval "$comp_cmd" "$cmd_line" "$cur"))
                
                return 0
            fi
        fi
        
        # If we get here, we couldn't find a specific completion method
        # Try a generic approach based on the command type
        
        # Check if it's a git command
        if [[ "$cmd" == "git" && ${#cmd_args[@]} -eq 0 ]]; then
            # Git subcommands
            COMPREPLY=($(compgen -W "$(git help -a | grep -E '^  [a-z]' | awk '{print $1}' | sort -u)" -- "$cur"))
            return 0
        fi
        
        # Default to file completion
        COMPREPLY=($(compgen -f -- "$cur"))
    fi
    
    return 0
}

# Register the completion function with the ai_help_me_test command
complete -F _ai_help_me_test_complete ai_help_me_test
