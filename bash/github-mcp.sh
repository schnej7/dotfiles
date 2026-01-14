#!/usr/bin/env bash
set -euo pipefail

TOKEN="$(gh auth token)"

exec docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$TOKEN" \
  ghcr.io/github/github-mcp-server
