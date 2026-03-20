#!/bin/bash
# simple-query-generator.sh
# Generate fresh research queries avoiding recent topics

set -euo pipefail

RESEARCH_DIR="/home/gene/.openclaw/workspace/dotfiles"
INSIGHTS_FILE="$RESEARCH_DIR/notes/external-insights.md"
LOG_FILE="$RESEARCH_DIR/logs/research-queries.log"

# Seed topics array
SEED_TOPICS=(
    "bash prompt performance"
    "readline inputrc configuration" 
    "fzf git workflows"
    "tmux session management"
    "shell bootstrap installation"
    "vim neovim LSP"
    "CI CD bash scripts"
    "git large repository performance"
    "terminal emulator issues"
    "Linux macOS shell compatibility"
    "zsh vs bash comparison"
    "command line productivity tools"
    "terminal multiplexer alternatives"
    "shell script debugging"
    "bash completion problems"
    "terminal color themes readability"
    "SSH session persistence"
    "package manager performance"
    "dotfiles management systems"
    "development environment setup"
)

# Get recent topics from insights (last 7 days)
get_recent_topics() {
    local recent_topics=()
    local one_week_ago=$(date -d "7 days ago" +%Y-%m-%d)
    
    # Extract topics from recent entries (simplified)
    if [[ -f "$INSIGHTS_FILE" ]]; then
        # Look for entries in last 7 days and extract keywords
        while IFS= read -r line; do
            if [[ "$line" =~ ^###\ (.+) ]]; then
                local topic="${BASH_REMATCH[1]}"
                # Clean up topic
                topic=$(echo "$topic" | sed 's/(Recurring)//g' | xargs)
                recent_topics+=("$topic")
            fi
        done < <(grep -A5 -B5 "$one_week_ago" "$INSIGHTS_FILE" 2>/dev/null || true)
    fi
    
    echo "${recent_topics[@]}"
}

# Generate fresh queries
generate_fresh_queries() {
    local recent_topics=("$@")
    local fresh_queries=()
    local used_topics=()
    
    # Shuffle seed topics
    local shuffled_topics=($(printf "%s\n" "${SEED_TOPICS[@]}" | shuf))
    
    for topic in "${shuffled_topics[@]}"; do
        # Check if topic is similar to recent topics
        local is_recent=false
        for recent in "${recent_topics[@]}"; do
            if echo "$topic" | grep -qi "$recent" || echo "$recent" | grep -qi "$topic"; then
                is_recent=true
                break
            fi
        done
        
        if [[ "$is_recent" == false ]] && [[ ${#fresh_queries[@]} -lt 8 ]]; then
            # Generate better query variations
            fresh_queries+=("$topic issues problems")
            fresh_queries+=("$topic slow lag performance")
            fresh_queries+=("$topic configuration setup")
            fresh_queries+=("$topic best practices 2026")
            used_topics+=("$topic")
        fi
    done
    
    # If we don't have enough queries, add some cross-topic ones
    if [[ ${#fresh_queries[@]} -lt 8 ]]; then
        fresh_queries+=("terminal workflow optimization 2026")
        fresh_queries+=("developer productivity command line tools")
        fresh_queries+=("shell scripting best practices")
        fresh_queries+=("modern terminal setup guide")
    fi
    
    # Limit to 8 queries and ensure uniqueness
    printf "%s\n" "${fresh_queries[@]}" | head -8 | sort -u
}

# Main execution
echo "=== Generating fresh research queries ==="
echo "Analyzing recent topics from insights database..."

recent_topics=$(get_recent_topics)
echo "Recent topics found: ${recent_topics[@]:0:5}..."

queries=$(generate_fresh_queries $recent_topics)

echo ""
echo "=== GENERATED QUERIES ==="
i=1
while IFS= read -r query; do
    [[ -n "$query" ]] && echo "$i. $query"
    i=$((i + 1))
done <<< "$queries"

# Log the queries
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date -Iseconds) | Generated queries: $(echo "$queries" | tr '\n' '; ')" >> "$LOG_FILE"

echo ""
echo "Use these queries for web_search calls to find NEW pain points."