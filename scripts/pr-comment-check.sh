#!/bin/bash
# PR Comment Check Script
# Run via cron to check and respond to PR comments

set -e

# Set PATH for cron environment
export PATH=/usr/local/bin:/usr/bin:/bin:/home/gene/.nvm/versions/node/v24.14.0/bin:/home/gene/.local/bin:$PATH

cd /home/gene/.openclaw/workspace/dotfiles

# Load state file
STATE_FILE="notes/pr-comment-state.json"
if [ ! -f "$STATE_FILE" ]; then
    echo '{}' > "$STATE_FILE"
fi

# Get open PRs
PRS_JSON=$(gh pr list --author gene61696-hub --state open --json number,title,url --limit 20)
PR_COUNT=$(echo "$PRS_JSON" | jq length)

echo "Found $PR_COUNT open PRs"

for i in $(seq 0 $((PR_COUNT - 1))); do
    PR_NUMBER=$(echo "$PRS_JSON" | jq -r ".[$i].number")
    PR_TITLE=$(echo "$PRS_JSON" | jq -r ".[$i].title")
    
    echo "Checking PR #$PR_NUMBER: $PR_TITLE"
    
    # Get all comments
    COMMENTS_JSON=$(gh pr view "$PR_NUMBER" --json comments,reviews 2>/dev/null || echo '{"comments":[], "reviews":[]}')
    INLINE_COMMENTS_JSON=$(gh api -X GET "repos/schnej7/dotfiles/pulls/$PR_NUMBER/comments" 2>/dev/null || echo '[]')
    
    # Combine comment IDs
    ALL_COMMENT_IDS=()
    
    # Regular comments
    REGULAR_COUNT=$(echo "$COMMENTS_JSON" | jq '.comments | length')
    for j in $(seq 0 $((REGULAR_COUNT - 1))); do
        COMMENT_ID=$(echo "$COMMENTS_JSON" | jq -r ".comments[$j].id")
        ALL_COMMENT_IDS+=("$COMMENT_ID")
    done
    
    # Review comments
    REVIEW_COUNT=$(echo "$COMMENTS_JSON" | jq '.reviews | length')
    for j in $(seq 0 $((REVIEW_COUNT - 1))); do
        REVIEW_ID=$(echo "$COMMENTS_JSON" | jq -r ".reviews[$j].id")
        ALL_COMMENT_IDS+=("$REVIEW_ID")
    done
    
    # Inline review comments
    INLINE_COUNT=$(echo "$INLINE_COMMENTS_JSON" | jq length)
    for j in $(seq 0 $((INLINE_COUNT - 1))); do
        INLINE_ID=$(echo "$INLINE_COMMENTS_JSON" | jq -r ".[$j].id")
        ALL_COMMENT_IDS+=("$INLINE_ID")
    done
    
    echo "  Found ${#ALL_COMMENT_IDS[@]} total comments/reviews"
    
    # Check each comment against state
    for COMMENT_ID in "${ALL_COMMENT_IDS[@]}"; do
        # Check if already processed
        ALREADY_PROCESSED=$(jq --arg pr "$PR_NUMBER" --arg id "$COMMENT_ID" \
            '.[$pr] // [] | any(. == $id)' "$STATE_FILE")
        
        if [ "$ALREADY_PROCESSED" = "false" ]; then
            echo "  New comment detected: $COMMENT_ID"
            # TODO: Implement comment response logic
            # For now, just log it
            echo "$(date): PR #$PR_NUMBER - New comment $COMMENT_ID" >> logs/pr-comment-watch.log
            
            # Add to state file
            jq --arg pr "$PR_NUMBER" --arg id "$COMMENT_ID" \
                '.[$pr] = (.[$pr] // []) + [$id] | unique' "$STATE_FILE" > "${STATE_FILE}.tmp"
            mv "${STATE_FILE}.tmp" "$STATE_FILE"
        fi
    done
done

echo "PR comment check complete at $(date)"