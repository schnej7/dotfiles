#!/usr/bin/env bash
# Cursor MCP (and other macOS GUI parents) often run with a stripped PATH.
# Use this as the MCP "command" and pass the real program + args in "args".
set -euo pipefail

# Homebrew (Apple Silicon / Intel) and common install locations
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:${PATH}"

# Optional: machine-specific extras (nvm, pyenv shims, custom tools, etc.)
# Create ~/.cursor-mcp-env with lines like: export PATH="$HOME/.local/bin:$PATH"
if [[ -f "${HOME}/.cursor-mcp-env" ]]; then
  # shellcheck disable=SC1090
  source "${HOME}/.cursor-mcp-env"
fi

exec "$@"
