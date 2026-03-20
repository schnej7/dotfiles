#!/bin/bash
# generate-research-queries.sh
# Smart query generation for external insights research

set -euo pipefail

RESEARCH_DIR="/home/gene/.openclaw/workspace/dotfiles"
HISTORY_FILE="$RESEARCH_DIR/logs/research-history.json"
INSIGHTS_FILE="$RESEARCH_DIR/notes/external-insights.md"

# Seed topics with variations
declare -A SEED_TOPICS=(
    ["bash_prompt"]="bash prompt shell terminal PS1 command-line"
    ["readline_config"]="readline inputrc vi-mode cursor-shape keybindings"
    ["fzf_workflows"]="fzf fuzzy-finder fd ripgrep skim"
    ["tmux_screen"]="tmux screen multiplexer session terminal-split"
    ["shell_bootstrap"]="shell bootstrap .bashrc .zshrc profile installation"
    ["vim_neovim"]="vim neovim LSP autocomplete performance plugins"
    ["ci_cd_shell"]="CI CD pipeline bash shell script alpine docker"
    ["git_performance"]="git status performance large-repository monorepo"
    ["terminal_tools"]="terminal emulator performance rendering scrollback"
    ["cross_platform"]="Linux macOS Windows WSL compatibility differences"
)

# Generate fresh queries
generate_queries() {
    local -n history_ref=$1
    local queries=()
    
    # Analyze topic coverage from insights file
    declare -A topic_counts
    for topic in "${!SEED_TOPICS[@]}"; do
        topic_counts[$topic]=0
    done
    
    # Count occurrences in insights (simplified)
    for topic in "${!SEED_TOPICS[@]}"; do
        local primary=$(echo "$topic" | cut -d'_' -f1)
        if grep -qi "$primary" "$INSIGHTS_FILE" 2>/dev/null; then
            topic_counts[$topic]=$((topic_counts[$topic] + 1))
        fi
    done
    
    # Prioritize low-coverage topics
    for topic in "${!topic_counts[@]}"; do
        if [[ ${topic_counts[$topic]} -lt 2 ]]; then
            local keywords=(${SEED_TOPICS[$topic]})
            local primary_keyword="${keywords[0]}"
            
            # Generate query variations
            queries+=("$primary_keyword performance issues")
            queries+=("$primary_keyword configuration problems")
            queries+=("$primary_keyword slow lag")
            queries+=("$primary_keyword broken not working")
            queries+=("$primary_keyword best practices 2026")
        fi
    done
    
    # If all topics have coverage, rotate through them
    if [[ ${#queries[@]} -eq 0 ]]; then
        local current_date=$(date +%s)
        for topic in "${!SEED_TOPICS[@]}"; do
            local last_searched=0
            if [[ -n "${history_ref[$topic]:-}" ]]; then
                last_searched=${history_ref[$topic]}
            fi
            
            # Skip if searched in last 3 days
            if [[ $((current_date - last_searched)) -gt 259200 ]]; then
                local keywords=(${SEED_TOPICS[$topic]})
                local primary_keyword="${keywords[0]}"
                local secondary_keyword="${keywords[1]}"
                
                queries+=("$primary_keyword $secondary_keyword problems")
                queries+=("$primary_keyword performance optimization")
                queries+=("$primary_keyword vs alternative comparison")
                
                # Mark as searched
                history_ref[$topic]=$current_date
            fi
        done
    fi
    
    # Add some cross-topic queries
    queries+=("bash vs zsh performance comparison")
    queries+=("Linux macOS shell script compatibility")
    queries+=("terminal workflow optimization 2026")
    queries+=("developer productivity terminal tools")
    
    # Shuffle and limit to 8 queries
    echo "${queries[@]}" | tr ' ' '\n' | shuf | head -8
}

# Load search history
declare -A search_history
if [[ -f "$HISTORY_FILE" ]]; then
    while IFS='=' read -r topic timestamp; do
        search_history[$topic]=$timestamp
    done < <(jq -r '.topics | to_entries[] | "\(.key)=\(.value)"' "$HISTORY_FILE" 2>/dev/null || true)
fi

# Generate queries
echo "Generating research queries based on topic coverage..."
queries=$(generate_queries search_history)

echo "=== RESEARCH QUERIES FOR THIS RUN ==="
i=1
for query in $queries; do
    echo "$i. $query"
    i=$((i + 1))
done

# Update history file
echo "Updating research history..."
mkdir -p "$(dirname "$HISTORY_FILE")"
jq -n --arg date "$(date -Iseconds)" \
  --argjson queries "$(echo "$queries" | jq -R -s 'split("\n") | map(select(. != ""))')" \
  '{
    "last_run": $date,
    "queries": $queries,
    "topics": {}
  }' > "$HISTORY_FILE"

echo "Query generation complete. Use these for web_search calls."