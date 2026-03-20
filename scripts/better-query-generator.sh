#!/bin/bash
# better-query-generator.sh
# Generate good research queries with topic rotation

set -euo pipefail

RESEARCH_DIR="/home/gene/.openclaw/workspace/dotfiles"
LOG_FILE="$RESEARCH_DIR/logs/query-generator.log"

# Better seed topics with full phrases
SEED_TOPICS=(
    "bash shell prompt performance issues slow"
    "readline inputrc vi mode configuration problems"
    "fzf fuzzy finder git workflow integration"
    "tmux terminal multiplexer session management"
    "shell script bootstrap installation setup"
    "vim neovim editor LSP autocomplete performance"
    "CI CD pipeline bash shell script issues"
    "git version control large repository performance"
    "terminal emulator rendering display problems"
    "Linux macOS Windows shell script compatibility"
    "zsh bash shell comparison differences"
    "command line productivity tools utilities"
    "terminal multiplexer screen tmux alternatives"
    "bash shell script debugging troubleshooting"
    "bash command completion tab completion issues"
    "terminal color scheme theme readability"
    "SSH remote session persistence management"
    "package manager brew apt yum performance"
    "dotfiles configuration management systems"
    "development environment setup automation"
)

# Get last used topics from log
get_last_topics() {
    if [[ -f "$LOG_FILE" ]]; then
        tail -5 "$LOG_FILE" | grep -o "topics:.*" | cut -d: -f2- | tr ',' '\n' | xargs echo
    else
        echo ""
    fi
}

# Generate queries avoiding recent topics
generate_queries() {
    local last_topics="$1"
    local queries=()
    
    # Shuffle topics
    local shuffled_topics=($(printf "%s\n" "${SEED_TOPICS[@]}" | shuf))
    
    for topic in "${shuffled_topics[@]:0:6}"; do  # Use first 6 shuffled topics
        # Check if this topic was recently used
        local recently_used=false
        for last in $last_topics; do
            if echo "$topic" | grep -qi "$last" || echo "$last" | grep -qi "$topic"; then
                recently_used=true
                break
            fi
        done
        
        if [[ "$recently_used" == false ]]; then
            # Create 1-2 queries per topic
            queries+=("$topic 2026")
            # Sometimes add a variation
            if [[ $((RANDOM % 2)) -eq 0 ]]; then
                queries+=("$(echo "$topic" | sed 's/ / vs /') comparison")
            fi
        fi
        
        # Stop when we have 8 queries
        [[ ${#queries[@]} -ge 8 ]] && break
    done
    
    # If we don't have enough, add some fallbacks
    while [[ ${#queries[@]} -lt 8 ]]; do
        queries+=("terminal workflow optimization 2026")
        queries+=("developer productivity command line")
        queries+=("shell scripting best practices")
        queries+=("modern development environment setup")
    done
    
    # Return unique queries, limit to 8
    printf "%s\n" "${queries[@]}" | head -8 | sort -u
}

# Main execution
mkdir -p "$(dirname "$LOG_FILE")"

last_topics=$(get_last_topics)
echo "Last topics used: $last_topics" | tee -a "$LOG_FILE"

queries=$(generate_queries "$last_topics")

echo "=== GENERATED RESEARCH QUERIES ==="
echo "$queries" | awk '{print NR ". " $0}'

# Log the topics used in this generation
topics_used=$(echo "$queries" | head -4 | sed 's/ 2026//g; s/ vs.*//g; s/ comparison//g' | xargs)
echo "$(date -Iseconds) | topics: $topics_used | queries: $(echo "$queries" | tr '\n' ', ')" >> "$LOG_FILE"

echo ""
echo "Use these queries for web_search to find NEW pain points."