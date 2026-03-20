#!/usr/bin/env bash

# Cross-platform shell script compatibility checker
# Detects GNU vs BSD utility differences and suggests fixes
# Usage: ./cross-platform-check.sh [script1.sh] [script2.sh] ...

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Platform detection
PLATFORM="$(uname -s)"
IS_MACOS=false
IS_LINUX=false

case "$PLATFORM" in
    Darwin*) IS_MACOS=true ;;
    Linux*) IS_LINUX=true ;;
esac

# Statistics
TOTAL_ISSUES=0
TOTAL_FILES=0
TOTAL_LINES=0

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print issue with context
print_issue() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    local issue="$4"
    local fix="$5"
    
    echo -e "${RED}✗ Issue found in ${file}:${line_num}${NC}"
    echo -e "  ${YELLOW}Line:${NC} ${line}"
    echo -e "  ${YELLOW}Problem:${NC} ${issue}"
    echo -e "  ${YELLOW}Suggested fix:${NC} ${fix}"
    echo ""
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
}

# Check sed in-place editing
check_sed_inplace() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    if echo "$line" | grep -q "sed.*-i[[:space:]]*[^']"; then
        if echo "$line" | grep -q "sed.*-i[[:space:]]*'[^']*'"; then
            # Check if it's GNU style without backup extension
            if echo "$line" | grep -q "sed.*-i[[:space:]]*'[^']*'[[:space:]]*[^[:space:]]"; then
                print_issue "$file" "$line_num" "$line" \
                    "GNU sed -i without backup extension may fail on BSD/macOS" \
                    "Use: sed -i '' 's/old/new/g' file (macOS) or sed -i.bak 's/old/new/g' file (portable)"
            fi
        fi
    fi
}

# Check grep -P (Perl regex)
check_grep_p() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    if echo "$line" | grep -q "grep.*-P"; then
        print_issue "$file" "$line_num" "$line" \
            "grep -P (Perl-compatible regex) not available on macOS" \
            "Use grep -E with POSIX ERE or rewrite pattern without PCRE features"
    fi
}

# Check date command differences
check_date() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    # Check for GNU date -d
    if echo "$line" | grep -q "date.*-d"; then
        print_issue "$file" "$line_num" "$line" \
            "date -d is GNU-specific, not available on macOS" \
            "Use: date -j -f '%Y-%m-%d' '2023-10-01' +%s (macOS) or implement platform detection"
    fi
    
    # Check for date --iso-8601
    if echo "$line" | grep -q "date.*--iso-8601"; then
        print_issue "$file" "$line_num" "$line" \
            "date --iso-8601 is GNU-specific" \
            "Use: date +%Y-%m-%dT%H:%M:%S for portable ISO 8601 format"
    fi
    
    # Check for date -v (macOS relative dates)
    if echo "$line" | grep -q "date.*-v" && $IS_LINUX; then
        print_issue "$file" "$line_num" "$line" \
            "date -v is BSD/macOS-specific, not available on Linux" \
            "Use: date -d 'yesterday' (Linux) or implement platform detection"
    fi
}

# Check find command syntax
check_find() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    # Check for find without path before options
    if echo "$line" | grep -q "^[[:space:]]*find[[:space:]]*-"; then
        print_issue "$file" "$line_num" "$line" \
            "find command missing path before options (BSD strict)" \
            "Always specify path first: find . -name '*.sh' not find -name '*.sh' ."
    fi
    
    # Check for find -delete
    if echo "$line" | grep -q "find.*-delete"; then
        print_issue "$file" "$line_num" "$line" \
            "find -delete may have different behavior on BSD vs GNU" \
            "Consider using -exec rm {} \\; for more predictable behavior"
    fi
}

# Check stat command differences
check_stat() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    if echo "$line" | grep -q "stat[[:space:]]"; then
        # Check for GNU stat -c
        if echo "$line" | grep -q "stat.*-c"; then
            print_issue "$file" "$line_num" "$line" \
                "stat -c is GNU-specific format option" \
                "Use: stat -f %z (macOS) or wc -c for file size portably"
        fi
        
        # Check for BSD stat -f
        if echo "$line" | grep -q "stat.*-f" && $IS_LINUX; then
            print_issue "$file" "$line_num" "$line" \
                "stat -f is BSD/macOS-specific format option" \
                "Use: stat -c %s (Linux) or wc -c for file size portably"
        fi
    fi
}

# Check head/tail flags
check_head_tail() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    # Check for head -n -NUM (negative numbers)
    if echo "$line" | grep -q "head.*-n[[:space:]]*-[0-9]"; then
        print_issue "$file" "$line_num" "$line" \
            "head -n -NUM (negative count) behavior differs between GNU and BSD" \
            "Use tail for excluding last N lines instead"
    fi
    
    # Check for tail -n +NUM
    if echo "$line" | grep -q "tail.*-n[[:space:]]*+[0-9]"; then
        print_issue "$file" "$line_num" "$line" \
            "tail -n +NUM (start from line) may have different behavior" \
            "Test carefully or use sed/awk for more predictable line selection"
    fi
}

# Check xargs differences
check_xargs() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    # Check for xargs -r (GNU extension)
    if echo "$line" | grep -q "xargs.*-r"; then
        print_issue "$file" "$line_num" "$line" \
            "xargs -r (no run if empty) is GNU extension" \
            "Use: xargs -r on Linux, or pipe to test -n 1 on macOS"
    fi
    
    # Check for xargs -I replacement string
    if echo "$line" | grep -q "xargs.*-I[[:space:]]*[^{]"; then
        print_issue "$file" "$line_num" "$line" \
            "xargs -I requires replacement string (usually {})" \
            "Use: xargs -I {} command {} or check replacement string syntax"
    fi
}

# Check awk/gawk variations
check_awk() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    # Check for gawk-specific features
    if echo "$line" | grep -q "gawk[[:space:]]"; then
        print_issue "$file" "$line_num" "$line" \
            "gawk (GNU awk) may not be available on all systems" \
            "Use 'awk' and avoid GNU-specific extensions"
    fi
    
    # Check for @include (gawk extension)
    if echo "$line" | grep -q "@include"; then
        print_issue "$file" "$line_num" "$line" \
            "@include is gawk extension" \
            "Use source files with cat or separate awk scripts"
    fi
}

# Check shebang portability
check_shebang() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    if [[ $line_num -eq 1 ]] && [[ "$line" =~ ^#! ]]; then
        # Check for hardcoded /bin/bash
        if echo "$line" | grep -q "^#!/bin/bash"; then
            print_issue "$file" "$line_num" "$line" \
                "Hardcoded /bin/bash may point to different versions" \
                "Use: #!/usr/bin/env bash for better portability"
        fi
        
        # Check for /bin/sh (could be bash, dash, etc.)
        if echo "$line" | grep -q "^#!/bin/sh"; then
            echo -e "${YELLOW}⚠ Note in ${file}:${line_num}${NC}"
            echo -e "  ${YELLOW}Line:${NC} ${line}"
            echo -e "  ${YELLOW}Note:${NC} /bin/sh varies between systems (bash, dash, etc.)"
            echo -e "  ${YELLOW}Suggestion:${NC} Test with target system's /bin/sh or use specific shell"
            echo ""
        fi
    fi
}

# Check echo with -e flag
check_echo() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    if echo "$line" | grep -q "echo.*-e"; then
        print_issue "$file" "$line_num" "$line" \
            "echo -e (escape sequences) behavior differs between shells" \
            "Use printf for portable escape sequences: printf 'line1\\nline2\\n'"
    fi
}

# Check ps command differences
check_ps() {
    local file="$1"
    local line_num="$2"
    local line="$3"
    
    if echo "$line" | grep -q "ps[[:space:]]"; then
        # Check for Linux-specific ps -eo
        if echo "$line" | grep -q "ps.*-eo"; then
            print_issue "$file" "$line_num" "$line" \
                "ps -eo format is Linux-specific" \
                "Use ps aux or ps -ef for more portable output"
        fi
        
        # Check for BSD-style ps aux vs Unix-style ps -ef
        if echo "$line" | grep -q "ps[[:space:]]*aux" && $IS_LINUX; then
            echo -e "${BLUE}ℹ Info in ${file}:${line_num}${NC}"
            echo -e "  ${YELLOW}Line:${NC} ${line}"
            echo -e "  ${YELLOW}Note:${NC} ps aux works on Linux but column order may differ from BSD"
            echo -e "  ${YELLOW}Suggestion:${NC} Use specific column names or test output format"
            echo ""
        fi
    fi
}

# Main checking function
check_file() {
    local file="$1"
    local line_num=0
    
    echo -e "${BLUE}🔍 Checking ${file}...${NC}"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))
        
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Run all checks
        check_shebang "$file" "$line_num" "$line"
        check_sed_inplace "$file" "$line_num" "$line"
        check_grep_p "$file" "$line_num" "$line"
        check_date "$file" "$line_num" "$line"
        check_find "$file" "$line_num" "$line"
        check_stat "$file" "$line_num" "$line"
        check_head_tail "$file" "$line_num" "$line"
        check_xargs "$file" "$line_num" "$line"
        check_awk "$file" "$line_num" "$line"
        check_echo "$file" "$line_num" "$line"
        check_ps "$file" "$line_num" "$line"
    done < "$file"
    
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_LINES=$((TOTAL_LINES + line_num))
}

# Print summary
print_summary() {
    echo -e "\n${BLUE}📊 Summary${NC}"
    echo -e "  Files checked: ${TOTAL_FILES}"
    echo -e "  Total lines: ${TOTAL_LINES}"
    echo -e "  Issues found: ${TOTAL_ISSUES}"
    
    if [[ $TOTAL_ISSUES -eq 0 ]]; then
        echo -e "\n${GREEN}✅ No cross-platform issues found!${NC}"
    else
        echo -e "\n${YELLOW}⚠ Found ${TOTAL_ISSUES} potential cross-platform issue(s)${NC}"
        echo -e "  Review the suggestions above to make scripts more portable."
    fi
}

# Print usage
print_usage() {
    echo "Cross-platform shell script compatibility checker"
    echo "Detects GNU vs BSD utility differences between Linux and macOS"
    echo ""
    echo "Usage: $0 [options] [file1.sh] [file2.sh] ..."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo "  -r, --recursive Check all .sh files in current directory"
    echo ""
    echo "Examples:"
    echo "  $0 script.sh              # Check a single script"
    echo "  $0 *.sh                   # Check all .sh files"
    echo "  $0 -r                     # Recursively check all .sh files"
    echo ""
    echo "Checks for:"
    echo "  • sed in-place editing (-i vs -i '')"
    echo "  • grep -P (Perl regex) availability"
    echo "  • date command differences (-d vs -j -f)"
    echo "  • find command syntax variations"
    echo "  • stat command format differences (-c vs -f)"
    echo "  • head/tail flag differences"
    echo "  • xargs variations (-r flag)"
    echo "  • awk/gawk compatibility"
    echo "  • Shebang portability"
    echo "  • echo -e vs printf"
    echo "  • ps command output format"
}

# Print version
print_version() {
    echo "cross-platform-check.sh v1.0.0"
    echo "Cross-platform shell script compatibility checker"
    echo "Detects GNU vs BSD utility differences"
}

# Main execution
main() {
    local recursive=false
    local files=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            -v|--version)
                print_version
                exit 0
                ;;
            -r|--recursive)
                recursive=true
                shift
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                print_usage
                exit 1
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done
    
    # If no files specified and not recursive, show usage
    if [[ ${#files[@]} -eq 0 ]] && ! $recursive; then
        print_usage
        exit 0
    fi
    
    # Recursive mode
    if $recursive; then
        echo -e "${BLUE}🔍 Recursively checking all .sh files...${NC}"
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find . -name "*.sh" -type f -print0 2>/dev/null)
    fi
    
    # Check if we have files to process
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Error: No .sh files found to check" >&2
        exit 1
    fi
    
    # Check each file
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            check_file "$file"
        else
            echo -e "${RED}Error: File not found: $file${NC}" >&2
        fi
    done
    
    print_summary
}

# Run main function with all arguments
main "$@"