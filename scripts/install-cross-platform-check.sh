#!/bin/bash

# Installation script for cross-platform shell script checker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/cross-platform-check.sh"
CONFIG_SNIPPET="$SCRIPT_DIR/bash-config-snippet.sh"
PRE_COMMIT_EXAMPLE="$SCRIPT_DIR/pre-commit-example.sh"
README="$SCRIPT_DIR/README-cross-platform-check.md"

echo "Installing cross-platform shell script compatibility checker..."
echo ""

# Check if checker script exists
if [ ! -f "$CHECK_SCRIPT" ]; then
    echo "Error: cross-platform-check.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Make scripts executable
echo "Making scripts executable..."
chmod +x "$CHECK_SCRIPT" 2>/dev/null || true
chmod +x "$PRE_COMMIT_EXAMPLE" 2>/dev/null || true
chmod +x "$0" 2>/dev/null || true

echo ""
echo "✅ Scripts are now executable."

# Create symlink in /usr/local/bin if user wants
read -p "Create symlink in /usr/local/bin? (requires sudo) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v sudo >/dev/null 2>&1; then
        sudo ln -sf "$CHECK_SCRIPT" /usr/local/bin/cross-platform-check
        echo "✅ Symlink created: /usr/local/bin/cross-platform-check"
    else
        echo "⚠  sudo not available. Creating symlink in ~/.local/bin instead..."
        mkdir -p ~/.local/bin
        ln -sf "$CHECK_SCRIPT" ~/.local/bin/cross-platform-check
        echo "✅ Symlink created: ~/.local/bin/cross-platform-check"
        echo "   Add ~/.local/bin to your PATH if not already there."
    fi
fi

echo ""
echo "📋 Installation options:"
echo ""
echo "1. Add to bash configuration:"
echo "   Add the following to your ~/.bashrc or ~/.bash_profile:"
echo ""
echo "   # Cross-platform checker"
echo "   source \"$CONFIG_SNIPPET\""
echo ""
echo "2. Set up pre-commit hook:"
echo "   Copy the example pre-commit hook to your git repository:"
echo "   cp \"$PRE_COMMIT_EXAMPLE\" /path/to/your/repo/.git/hooks/pre-commit"
echo "   chmod +x /path/to/your/repo/.git/hooks/pre-commit"
echo ""
echo "3. Test the checker:"
echo "   $CHECK_SCRIPT --help"
echo "   $CHECK_SCRIPT test-examples/*.sh"
echo ""
echo "📚 Documentation: $README"
echo ""
echo "Installation complete! 🎉"