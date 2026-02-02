#!/bin/bash
# Cursor-specific bash configuration (top-level).
# Sources work-specific config from private so this file can stay in the repo.
if [ -f "$HOME/.cursor_bashrc_private.sh" ]; then
    source "$HOME/.cursor_bashrc_private.sh"
fi
