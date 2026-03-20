#!/bin/bash

# Example pre-commit hook for cross-platform compatibility checking
# Save as .git/hooks/pre-commit and make executable

echo "🔍 Running cross-platform shell script compatibility check..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/cross-platform-check.sh"

# Check if the checker script exists
if [ ! -f "$CHECK_SCRIPT" ]; then
    echo "⚠  cross-platform-check.sh not found at $CHECK_SCRIPT"
    echo "Skipping compatibility check."
    exit 0
fi

# Get staged shell scripts
STAGED_SH_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$')

if [ -z "$STAGED_SH_FILES" ]; then
    echo "✅ No shell scripts staged for commit."
    exit 0
fi

echo "Checking $(echo "$STAGED_SH_FILES" | wc -l) staged shell script(s):"
echo "$STAGED_SH_FILES" | sed 's/^/  /'

# Check each staged shell script
ISSUES_FOUND=0
for file in $STAGED_SH_FILES; do
    if [ -f "$file" ]; then
        echo ""
        echo "--- Checking $file ---"
        # Run checker and capture output
        OUTPUT=$("$CHECK_SCRIPT" "$file" 2>&1)
        CHECK_RESULT=$?
        
        if [ $CHECK_RESULT -ne 0 ]; then
            echo "$OUTPUT"
            ISSUES_FOUND=1
        else
            # Extract summary from output
            SUMMARY=$(echo "$OUTPUT" | grep -A2 "📊 Summary")
            if [ -n "$SUMMARY" ]; then
                echo "$SUMMARY"
            else
                echo "✅ $file passed compatibility check"
            fi
        fi
    fi
done

echo ""
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✅ All shell scripts passed cross-platform compatibility check."
    exit 0
else
    echo "❌ Cross-platform compatibility issues found."
    echo ""
    echo "To commit anyway (not recommended for production scripts):"
    echo "  git commit --no-verify"
    echo ""
    echo "To fix issues:"
    echo "  1. Review the suggestions above"
    echo "  2. Make necessary changes"
    echo "  3. Stage fixes: git add [files]"
    echo "  4. Try committing again"
    exit 1
fi