#!/bin/bash
# OpenClaw lazy-loading completion wrapper
# Solves: OpenClaw completion takes 3+ seconds to load, causing shell startup delays
# Solution: Defer completion loading until first use with intelligent caching

# Cache file location
OPENCLAW_COMPLETION_CACHE="${HOME}/.openclaw_completion.bash"
# How long to keep cache (seconds) - 24 hours
CACHE_MAX_AGE=86400

# Generate fresh completion if cache doesn't exist or is stale
_generate_openclaw_completion() {
    echo "Generating OpenClaw completion (first time or cache expired)..." >&2
    
    # Generate completion and save to cache
    if command -v openclaw >/dev/null 2>&1; then
        if openclaw completion --shell bash > "$OPENCLAW_COMPLETION_CACHE" 2>/dev/null; then
            echo "OpenClaw completion cached successfully" >&2
            return 0
        else
            echo "Failed to generate OpenClaw completion" >&2
            rm -f "$OPENCLAW_COMPLETION_CACHE"
            return 1
        fi
    else
        echo "openclaw command not found" >&2
        return 1
    fi
}

# Check if cache is valid
_cache_is_valid() {
    if [[ ! -f "$OPENCLAW_COMPLETION_CACHE" ]]; then
        return 1  # Cache doesn't exist
    fi
    
    # Check cache age
    local current_time=$(date +%s)
    local cache_mtime=$(stat -c %Y "$OPENCLAW_COMPLETION_CACHE" 2>/dev/null || stat -f %m "$OPENCLAW_COMPLETION_CACHE" 2>/dev/null)
    
    if [[ -z "$cache_mtime" ]]; then
        return 1  # Can't determine mtime
    fi
    
    local cache_age=$((current_time - cache_mtime))
    
    if [[ $cache_age -gt $CACHE_MAX_AGE ]]; then
        return 1  # Cache is too old
    fi
    
    return 0  # Cache is valid
}

# Lazy-load OpenClaw completion
_openclaw_completion_setup() {
    # Only set up completion if openclaw command exists
    if ! command -v openclaw >/dev/null 2>&1; then
        return 0
    fi
    
    # Check if we already have completion loaded
    if complete -p openclaw 2>/dev/null | grep -q "openclaw"; then
        return 0  # Completion already loaded
    fi
    
    # Ensure valid cache exists
    if ! _cache_is_valid; then
        _generate_openclaw_completion
    fi
    
    # Load completion from cache if it exists
    if [[ -f "$OPENCLAW_COMPLETION_CACHE" ]]; then
        # Source the cached completion
        source "$OPENCLAW_COMPLETION_CACHE" 2>/dev/null && return 0
    fi
    
    # Fallback: generate and load directly (slow, but works)
    echo "Loading OpenClaw completion directly (this may take a few seconds)..." >&2
    source <(openclaw completion --shell bash 2>/dev/null) 2>/dev/null
}

# Hook to trigger lazy loading when 'openclaw' command is typed
_openclaw_lazy_load() {
    # Remove this hook to avoid infinite recursion
    unset -f openclaw
    
    # Set up completion
    _openclaw_completion_setup
    
    # Execute the actual openclaw command
    command openclaw "$@"
}

# Only set up lazy loading if openclaw command exists
if command -v openclaw >/dev/null 2>&1; then
    # Create lazy-load wrapper function
    eval "openclaw() { _openclaw_lazy_load \"\$@\"; }"
    
    # Export function
    export -f openclaw 2>/dev/null || true
fi

# Optional: Pre-generate cache in background on shell startup
# (Uncomment if you want to generate cache immediately but non-blocking)
# if command -v openclaw >/dev/null 2>&1 && ! _cache_is_valid; then
#     (_generate_openclaw_completion &) 2>/dev/null
# fi