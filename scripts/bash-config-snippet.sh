#!/bin/bash

# Bash configuration for cross-platform shell script checking
# Add to ~/.bashrc or ~/.bash_profile

# Cross-platform checker alias
alias shell-check='~/path/to/scripts/cross-platform-check.sh'

# Function to check all shell scripts in current directory
check-shell-scripts() {
    local dir="${1:-.}"
    echo "Checking shell scripts in $dir..."
    find "$dir" -name "*.sh" -type f -exec ~/path/to/scripts/cross-platform-check.sh {} \;
}

# Function to check scripts changed in git
git-check-shell() {
    local target="${1:-HEAD}"
    
    echo "Checking shell scripts changed since $target..."
    
    # Get changed shell scripts
    git diff --name-only "$target" -- "*.sh" | while read -r file; do
        if [ -f "$file" ]; then
            echo ""
            echo "--- $file ---"
            ~/path/to/scripts/cross-platform-check.sh "$file"
        fi
    done
}

# Function to check staged scripts before commit
git-precommit-check() {
    echo "Checking staged shell scripts..."
    
    local issues=0
    git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' | while read -r file; do
        if [ -f "$file" ]; then
            echo ""
            echo "--- $file ---"
            if ! ~/path/to/scripts/cross-platform-check.sh "$file"; then
                issues=1
            fi
        fi
    done
    
    if [ $issues -eq 0 ]; then
        echo "✅ All staged shell scripts are cross-platform compatible."
        return 0
    else
        echo "❌ Some staged scripts have compatibility issues."
        echo "Consider fixing them before committing."
        return 1
    fi
}

# Function to create portable versions of common commands
portable-commands() {
    echo "Portable alternatives for common commands:"
    echo ""
    echo "1. File size:"
    echo "   GNU:        stat -c %s file.txt"
    echo "   macOS:      stat -f %z file.txt"
    echo "   Portable:   wc -c < file.txt"
    echo ""
    echo "2. Date parsing:"
    echo "   GNU:        date -d '2023-10-01' +%s"
    echo "   macOS:      date -j -f '%Y-%m-%d' '2023-10-01' +%s"
    echo "   Portable:   Use platform detection (see examples)"
    echo ""
    echo "3. sed in-place:"
    echo "   GNU:        sed -i 's/foo/bar/g' file.txt"
    echo "   macOS:      sed -i '' 's/foo/bar/g' file.txt"
    echo "   Portable:   sed -i.bak 's/foo/bar/g' file.txt"
    echo ""
    echo "4. Find files:"
    echo "   Incorrect:  find -name '*.sh' ."
    echo "   Correct:    find . -name '*.sh'"
    echo ""
    echo "5. Shebang:"
    echo "   Avoid:      #!/bin/bash"
    echo "   Use:        #!/usr/bin/env bash"
}

# Platform detection helper function
get-platform() {
    case "$(uname -s)" in
        Darwin*)
            echo "macOS/BSD"
            ;;
        Linux*)
            echo "GNU/Linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "Windows"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# Example platform-specific function
platform-stat() {
    local file="$1"
    
    case "$(uname -s)" in
        Darwin*)
            # macOS/BSD
            stat -f %z "$file"
            ;;
        Linux*)
            # GNU/Linux
            stat -c %s "$file"
            ;;
        *)
            echo "Unsupported platform" >&2
            return 1
            ;;
    esac
}

# Test if current platform is macOS
is-macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Test if current platform is Linux
is-linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

echo "Cross-platform shell script utilities loaded."
echo "Available commands:"
echo "  shell-check [files]      - Check scripts for compatibility"
echo "  check-shell-scripts [dir]- Check all .sh files in directory"
echo "  git-check-shell [ref]    - Check shell scripts changed since git ref"
echo "  git-precommit-check      - Check staged shell scripts"
echo "  portable-commands        - Show portable alternatives"
echo "  get-platform             - Show current platform"
echo "  platform-stat file       - Get file size (platform-aware)"
echo "  is-macos                 - Returns true if on macOS"
echo "  is-linux                 - Returns true if on Linux"