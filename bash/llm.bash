function capture_and_report_test_output() {
    local output_file="$1" # File to capture the command output
    shift # Remove the first argument (output file)
    local command_to_run="$@" # All remaining arguments form the command to run
    local fail_file="/tmp/failing_tests.txt" # Temporary file to store failing test filenames
    local test_descriptions="/tmp/failing_test_descriptions.txt" # Store test descriptions
    
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
        echo "Cleanup complete."
    }
    
    # Set up trap for Ctrl+C and normal exit
    trap cleanup SIGINT EXIT
    
    echo "Running test command and capturing output..."
    
    # Execute the command and capture both stdout and stderr
    # Use tee to display output in real-time while also saving to file
    eval "$command_to_run" 2>&1 | tee "$output_file"
    
    echo "Tests completed."
    
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
    
    echo "Parent branch determined as: $base_branch"
    
    # Generate LLM prompt for fixing failing tests
    echo "Generating LLM prompt..."
    local llm_prompt="Below is the output of failing tests. Please analyze and provide fixes for the issues:\n\n"
    llm_prompt+="$(cat "$output_file")"
    
    # Report failing tests with descriptions
    if [[ -f "$test_descriptions" && -s "$test_descriptions" ]]; then
        echo -e "\nFailing tests with descriptions:"
        sort -u "$test_descriptions"
        llm_prompt+="\n\nFailing tests with descriptions:\n$(sort -u "$test_descriptions")"
    fi
    
    # Report failing test files
    if [[ -f "$fail_file" && -s "$fail_file" ]]; then
        echo -e "\nFailing test files:"
        sort -u "$fail_file"
        llm_prompt+="\n\nFailing test files:\n$(sort -u "$fail_file")"
    else
        echo -e "\nNo failing tests detected."
    fi
    
    echo -e "\n### LLM Prompt ###"
    echo -e "$llm_prompt"
    
    # Generate list of files modified in the current branch
    echo "Generating list of modified files..."
    git diff --name-only "$base_branch" > /tmp/modified_files.txt
    echo "$output_file" >> /tmp/modified_files.txt
    echo -e "\nModified files:"
    cat /tmp/modified_files.txt
    
    # Cleanup will be called automatically via the EXIT trap
}
