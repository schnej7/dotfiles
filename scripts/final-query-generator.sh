#!/bin/bash
# final-query-generator.sh
# Simple, reliable query generator

set -euo pipefail

# Curated query list - manually maintained to avoid repetition
QUERIES=(
    "bash shell prompt slow performance issues 2026"
    "readline inputrc vi mode cursor shape configuration problems"
    "fzf fuzzy finder git integration workflow optimization"
    "tmux terminal multiplexer session attach detach confusion"
    "shell script bootstrap .bashrc .zshrc installation failures"
    "vim neovim LSP language server protocol performance lag"
    "CI CD pipeline bash script alpine linux compatibility issues"
    "git large repository monorepo status command slow"
    "terminal emulator rendering scrollback buffer problems"
    "Linux macOS Windows shell script cross platform compatibility"
    "zsh vs bash shell performance comparison differences"
    "command line productivity tools workflow optimization"
    "terminal multiplexer screen vs tmux comparison"
    "bash shell script debugging error handling issues"
    "bash command completion tab autocomplete not working"
    "terminal color scheme theme contrast readability problems"
    "SSH remote session persistence reconnect automation"
    "package manager brew apt yum dnf slow performance"
    "dotfiles configuration management git sync issues"
    "development environment setup automation tools"
    "terminal workflow optimization productivity 2026"
    "shell scripting best practices error handling"
    "modern command line tools developer productivity"
    "terminal customization configuration performance"
    "command line interface CLI usability issues"
    "shell environment variable configuration problems"
    "terminal history search navigation issues"
    "command line argument parsing shell script problems"
    "shell job control background process management"
    "terminal copy paste clipboard integration issues"
)

# Shuffle and pick 8 unique queries
SELECTED_QUERIES=$(printf "%s\n" "${QUERIES[@]}" | shuf | head -8)

echo "=== RESEARCH QUERIES ==="
echo "$SELECTED_QUERIES" | awk '{print NR ". " $0}'

# Log to file
LOG_FILE="/home/gene/.openclaw/workspace/dotfiles/logs/query-history.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date -Iseconds) | queries: $(echo "$SELECTED_QUERIES" | tr '\n' '; ')" >> "$LOG_FILE"

echo ""
echo "Use these queries with web_search to find NEW pain points."
echo "Focus on performance issues, configuration problems, and workflow friction."