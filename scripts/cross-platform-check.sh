#!/usr/bin/env bash

# Minimal cross-platform shell script compatibility checker
# Checks for GNU vs BSD utility differences between Linux and macOS
# Usage: ./scripts/cross-platform-check.sh [file1.sh] [file2.sh] ...

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_file() {
    local file="$1"
    local issues=0
    
    echo "Checking: $file"
    
    # Check 1: sed -r vs -E
    if grep -q "sed.*-r" "$file"; then
        echo -e "${YELLOW}  Warning:${NC} sed -r is GNU-specific, use -E for portability"
        echo "    Fix: Change 'sed -r' to 'sed -E'"
        ((issues++))
    fi
    
    # Check 2: grep -P (Perl regex)
    if grep -q "grep.*-P" "$file"; then
        echo -e "${YELLOW}  Warning:${NC} grep -P is GNU-specific, not available on macOS"
        echo "    Fix: Use alternative regex or install GNU grep"
        ((issues++))
    fi
    
    # Check 3: date format differences
    if grep -q "date.*-d" "$file"; then
        echo -e "${YELLOW}  Warning:${NC} date -d is GNU-specific"
        echo "    Fix: Use 'date -v' on macOS or rewrite logic"
        ((issues++))
    fi
    
    # Check 4: stat format differences
    if grep -q "stat.*-c" "$file"; then
        echo -e "${YELLOW}  Warning:${NC} stat -c is GNU-specific"
        echo "    Fix: Use 'stat -f' on macOS"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}  ✓ No compatibility issues found${NC}"
    else
        echo "  Total issues: $issues"
    fi
    
    return $issues
}

main() {
    local total_issues=0
    local files_to_check=()
    
    # If files provided, check them; otherwise check all .sh files
    if [[ $# -gt 0 ]]; then
        files_to_check=("$@")
    else
        files_to_check=( $(find . -name "*.sh" -type f | head -20) )
    fi
    
    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]]; then
            check_file "$file"
            total_issues=$((total_issues + $?))
        fi
    done
    
    echo ""
    echo "=== Summary ==="
    if [[ $total_issues -eq 0 ]]; then
        echo -e "${GREEN}All checks passed!${NC}"
    else
        echo -e "${YELLOW}Found $total_issues potential compatibility issues${NC}"
        echo "Review warnings above for GNU/BSD differences"
    fi
}

main "$@"
