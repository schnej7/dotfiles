#!/usr/bin/env bash

# Example of a portable shell script that avoids common cross-platform issues

set -euo pipefail

# Platform detection for when platform-specific code is necessary
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        *)          echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

# Portable file size function
get_file_size() {
    local file="$1"
    case "$PLATFORM" in
        linux)
            stat -c %s "$file" 2>/dev/null || wc -c < "$file"
            ;;
        macos)
            stat -f %z "$file" 2>/dev/null || wc -c < "$file"
            ;;
        *)
            wc -c < "$file"
            ;;
    esac
}

# Portable date parsing (simplified example)
get_timestamp() {
    local date_str="$1"
    case "$PLATFORM" in
        linux)
            date -d "$date_str" +%s 2>/dev/null || return 1
            ;;
        macos)
            # Try common formats
            for fmt in "%Y-%m-%d" "%Y/%m/%d" "%m/%d/%Y"; do
                date -j -f "$fmt" "$date_str" +%s 2>/dev/null && return 0
            done
            return 1
            ;;
        *)
            echo "Unsupported platform" >&2
            return 1
            ;;
    esac
}

# Portable sed in-place editing
sed_inplace() {
    local file="$1"
    local pattern="$2"
    
    case "$PLATFORM" in
        linux)
            sed -i "$pattern" "$file"
            ;;
        macos)
            sed -i '' "$pattern" "$file"
            ;;
        *)
            # Most portable: create backup
            sed -i.bak "$pattern" "$file" && rm -f "${file}.bak"
            ;;
    esac
}

# Use printf instead of echo -e
log_message() {
    printf "%s: %s\n" "$(date +%Y-%m-%dT%H:%M:%S)" "$1"
}

# Portable find usage
find_sh_files() {
    local dir="${1:-.}"
    find "$dir" -name "*.sh" -type f
}

# Portable xargs (avoid -r flag)
safe_xargs_rm() {
    local pattern="$1"
    find . -name "$pattern" -print0 | xargs -0 rm -f 2>/dev/null || true
}

# Main script logic
main() {
    log_message "Starting portable script example"
    
    # Example: Get size of this script
    local script_size
    script_size=$(get_file_size "$0")
    log_message "Script size: $script_size bytes"
    
    # Example: Find and list shell scripts
    log_message "Looking for shell scripts..."
    find_sh_files | while read -r script; do
        local size
        size=$(get_file_size "$script")
        printf "  %s (%d bytes)\n" "$script" "$size"
    done
    
    log_message "Example complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi