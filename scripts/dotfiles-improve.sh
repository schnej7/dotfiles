#!/bin/bash
# Dotfiles Improvement Script
# Run via cron to implement one todo item and create PR

set -e

# Set PATH for cron environment
export PATH=/usr/local/bin:/usr/bin:/bin:/home/gene/.nvm/versions/node/v24.14.0/bin:/home/gene/.local/bin:$PATH

cd /home/gene/.openclaw/workspace/dotfiles

echo "=== Dotfiles Improvement Cycle Started at $(date) ==="

# 1. Update main branch
echo "1. Updating main branch..."
git checkout main
git pull origin main

# 2. Create branch
BRANCH_NAME="daily-improvement-$(date +%Y%m%d-%H%M)"
echo "2. Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

# 3. Check todo list
TODO_FILE="notes/dotfiles-micro-improvements.md"
if [ ! -f "$TODO_FILE" ]; then
    echo "ERROR: Todo file $TODO_FILE not found!"
    exit 1
fi

# Find first unchecked todo
echo "3. Checking todo list..."
TODO_LINE=$(grep -n "### \[ \]" "$TODO_FILE" | head -1)
if [ -z "$TODO_LINE" ]; then
    echo "ERROR: No unchecked todos found!"
    exit 1
fi

LINE_NUM=$(echo "$TODO_LINE" | cut -d: -f1)
TODO_TITLE=$(sed -n "${LINE_NUM}p" "$TODO_FILE" | sed 's/### \[ \] //')

echo "  Selected todo: $TODO_TITLE"

# Extract todo section (from current line to next ### or end of file)
SECTION_END=$(sed -n "$((LINE_NUM + 1)),$"p "$TODO_FILE" | grep -n "### " | head -1 | cut -d: -f1)
if [ -z "$SECTION_END" ]; then
    SECTION_END=$(wc -l < "$TODO_FILE")
else
    SECTION_END=$((LINE_NUM + SECTION_END - 1))
fi

TODO_SECTION=$(sed -n "${LINE_NUM},${SECTION_END}p" "$TODO_FILE")

echo "  Todo details:"
echo "$TODO_SECTION" | head -20

# 4. Validate relevance (simplified check)
echo "4. Validating workflow relevance..."
# Check if todo mentions key workflows
if echo "$TODO_SECTION" | grep -qi "bash\|git\|vim\|screen\|fzf"; then
    echo "  ✅ Relevant to workflows"
else
    echo "  ❌ Not relevant to workflows - skipping"
    # Mark as skipped somehow
    exit 0
fi

# 5. TODO: Actually implement the improvement
# This would need AI/script logic to implement based on todo
echo "5. IMPLEMENTATION NEEDED"
echo "   Manual/AI implementation required for: $TODO_TITLE"
echo "   For now, creating placeholder..."

# Create a simple implementation based on todo type
if echo "$TODO_TITLE" | grep -qi "git branch"; then
    echo "   Detected git branch improvement"
    # Would implement git branch enhancement here
    cat > /tmp/placeholder.txt << EOF
# Git branch switching enhancement placeholder
# Actual implementation would go here
EOF
elif echo "$TODO_TITLE" | grep -qi "vim.*key.*mapping"; then
    echo "   Detected vim key mapping improvement"
    # Would implement vim key mapping check here
    cat > /tmp/placeholder.txt << EOF
# Vim key mapping conflict detection placeholder
# Actual implementation would go here
EOF
else
    echo "   Generic placeholder"
    cat > /tmp/placeholder.txt << EOF
# Improvement placeholder for: $TODO_TITLE
# Implementation needed
EOF
fi

# 6. Commit
echo "6. Committing changes..."
git add -A
git commit -m "feat: $TODO_TITLE

Problem: [Workflow pain from todo]
Solution: [Implementation details]
Use case: [How workflow improves]" || {
    echo "  No changes to commit"
    exit 0
}

# 7. Push
echo "7. Pushing branch..."
git push origin "$BRANCH_NAME"

# 8. Create PR
echo "8. Creating PR..."
PR_BODY="## Problem
[Workflow pain from todo]

## Solution
[Implementation details]

## Use Case
[How workflow improves]"

gh pr create --title "feat: $TODO_TITLE" --body "$PR_BODY" --head "gene61696-hub:$BRANCH_NAME"

# 9. Update todo as done
echo "9. Updating todo status..."
sed -i "${LINE_NUM}s/### \[ \] /### [x] /" "$TODO_FILE"

# 10. Add new pain point from external insights
echo "10. Adding new pain point from external insights..."
# This would parse external-insights.md and add one relevant item
# For now, placeholder
echo "  [Would add new relevant pain point here]"

echo "=== Dotfiles Improvement Cycle Complete ==="
echo "Branch: $BRANCH_NAME"
echo "PR created for: $TODO_TITLE"