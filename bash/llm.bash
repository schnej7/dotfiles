function capture_and_report_test_output() {
    local output_file="$1" # File to capture the command output
    local fail_file="/tmp/failing_tests.txt" # Temporary file to store failing test filenames
    
    # Check if output file is provided
    if [[ -z "$output_file" ]]; then
        echo "Error: Please provide the output file as an argument."
        return 1
    fi
    
    # Clear any existing data
    > "$output_file"
    > "$fail_file"
    
    # Function to clean up resources
    function cleanup() {
        # Remove temporary files
        rm -f "$fail_file"
        echo "Cleanup complete."
    }
    
    # Set up trap for Ctrl+C and normal exit
    trap cleanup SIGINT EXIT
    
    echo "Running test command and capturing output..."
    
    # Process the piped input line by line
    while IFS= read -r line; do
        # Echo the line to terminal in real-time
        echo "$line"
        
        # Append the line to the output file
        echo "$line" >> "$output_file"
        
        # Detect failing tests - look for FAIL lines and file paths
        if [[ "$line" =~ ^FAIL ]]; then
            if [[ "$line" =~ ^FAIL[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
                echo "${BASH_REMATCH[2]}" >> "$fail_file"
            fi
        fi
        
        # Look for file paths in error messages
        if [[ "$line" =~ \(([^:]+\.(spec|test)\.(js|ts|tsx)):[0-9]+ ]]; then
            echo "${BASH_REMATCH[1]}" >> "$fail_file"
        fi
    done
    
    echo "Tests completed."
    
    # Determine the base branch
    local base_branch=$(git merge-base --fork-point $(git branch --show-current) 2>/dev/null || 
                       git main-branch 2>/dev/null || 
                       echo "master")
    
    echo "Parent branch determined as: $base_branch"
    
    # Generate LLM prompt for fixing failing tests
    echo "Generating LLM prompt..."
    local llm_prompt="Below is the output of failing tests. Please analyze and provide fixes for the issues:\n\n"
    llm_prompt+="$(cat "$output_file")"
    
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
