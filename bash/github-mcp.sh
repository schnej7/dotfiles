# #!/usr/bin/env bash
# set -euo pipefail
# 
# TOKEN="$(gh auth token)"
# 
# exec docker run -i --rm \
#   -e GITHUB_PERSONAL_ACCESS_TOKEN="$TOKEN" \
#   ghcr.io/github/github-mcp-server

#!/usr/bin/env bash
set -euo pipefail
export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)"
exec github-mcp-server stdio
Make sure it's executable: chmod +x ~/cmt/dotfiles/bash/github-mcp.sh
