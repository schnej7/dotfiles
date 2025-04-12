function capture_and_report_test_output() {
    local output_file="$1" # File to capture the command output
    shift # Remove the first argument (output file)
    local command_to_run="$@" # All remaining arguments form the command to run
    local fail_file="/tmp/failing_tests.txt" # Temporary file to store failing test filenames
    local test_descriptions="/tmp/failing_test_descriptions.txt" # Store test descriptions
    
    # Define colors for output
    local cyan='\033[0;36m'
    local green='\033[0;32m'
    local yellow='\033[0;33m'
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
    
    # Determine the base branch
    local base_branch=$(git merge-base --fork-point $(git branch --show-current) 2>/dev/null || 
                       git main-branch 2>/dev/null || 
                       echo "master")
    
    echo -e "${green}Parent branch determined as:${nc} $base_branch"
    
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
