#!/bin/bash
# run-smart-research.sh
# Main wrapper for smart research job

set -euo pipefail

RESEARCH_DIR="/home/gene/.openclaw/workspace/dotfiles"
QUERY_SCRIPT="$RESEARCH_DIR/scripts/simple-query-generator.sh"
INSIGHTS_FILE="$RESEARCH_DIR/notes/external-insights.md"
LOG_FILE="$RESEARCH_DIR/logs/dotfiles-research.log"
RESEARCH_LOG="$RESEARCH_DIR/logs/research-execution.log"

# Create logs directory
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$RESEARCH_LOG")"

log() {
    echo "[$(date -Iseconds)] $1" | tee -a "$RESEARCH_LOG"
}

log "=== Starting smart research run ==="

# Step 1: Generate fresh queries
log "Generating fresh research queries..."
QUERIES=$("$QUERY_SCRIPT" 2>&1 | grep -A20 "=== GENERATED QUERIES ===" | tail -n +2 | head -8 | sed 's/^[0-9]*\. //')

if [[ -z "$QUERIES" ]]; then
    log "ERROR: Failed to generate queries"
    exit 1
fi

log "Generated queries:"
echo "$QUERIES" | while IFS= read -r query; do
    [[ -n "$query" ]] && log "  - $query"
done

# Step 2: Convert queries to JSON array for agent use
QUERIES_JSON=$(echo "$QUERIES" | jq -R -s 'split("\n") | map(select(. != ""))')

# Step 3: Create research instruction file for agent
INSTRUCTION_FILE="$RESEARCH_DIR/notes/research-instruction-$(date +%Y%m%d-%H%M).txt"

cat > "$INSTRUCTION_FILE" << EOF
# SMART RESEARCH INSTRUCTION
# Generated: $(date -Iseconds)

## QUERIES TO USE (generated fresh, avoiding recent topics):
$(echo "$QUERIES" | awk '{print "1. " $0}')

## WORKFLOW:
1. Use EACH of the above queries with web_search (limit 5 results per query)
2. Focus on finding NEW pain points not already in external-insights.md
3. For each useful result, capture:
   - Date: $(date +%Y-%m-%d)
   - Source URL
   - Community (GitHub, Stack Overflow, Reddit, blog, etc.)
   - Core pain point (problem, not solution)
   - Optional: Idea/tool that might help
4. Skip: Window-manager/Hyprland theming content
5. Prioritize: Performance issues, configuration problems, cross-platform gaps
6. Target: 8-10 distinct sources total across all queries

## SUCCESS CRITERIA:
- Find 1-3 NEW pain points with 2+ independent sources
- If no new corroborated pain points, report: "No new corroborated pain points found"

## OUTPUT FORMAT:
Append to external-insights.md with newest entries first.
Use standard format with ### header, **Pain Point**, **Sources**, **Idea** sections.
Tag recurring issues with "(Recurring)".

## LOGGING:
Log execution to $LOG_FILE
EOF

log "Created instruction file: $INSTRUCTION_FILE"

# Step 4: Create agent execution command
AGENT_COMMAND="cd '$RESEARCH_DIR' && cat '$INSTRUCTION_FILE' && echo '' && echo '=== EXECUTING RESEARCH ===' && echo 'Using the queries above, perform web_search for each query, analyze results, and update external-insights.md with NEW findings only.'"

log "=== Research setup complete ==="
log "Instruction file ready: $INSTRUCTION_FILE"
log "Queries generated: $(echo "$QUERIES" | wc -l)"
log ""
log "Next: Agent should read $INSTRUCTION_FILE and execute research using the provided queries."
log "Focus on finding NEW pain points not already documented."

# Output for agent
echo "=== SMART RESEARCH SETUP COMPLETE ==="
echo ""
echo "📋 INSTRUCTION FILE: $INSTRUCTION_FILE"
echo ""
echo "🔍 GENERATED QUERIES:"
echo "$QUERIES" | awk '{print "  • " $0}'
echo ""
echo "📝 NEXT STEPS:"
echo "1. Read the instruction file"
echo "2. Execute web_search for each query"
echo "3. Analyze results for NEW pain points"
echo "4. Update external-insights.md with fresh findings"
echo "5. Report 1-3 NEW corroborated pain points (or 'none found')"
echo ""
echo "📊 LOGS: $RESEARCH_LOG"