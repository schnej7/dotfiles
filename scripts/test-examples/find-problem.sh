#!/usr/bin/env bash

# Example script with find command syntax issues

# Incorrect: options before path (fails on macOS)
find -name "*.sh" .

# Correct: path before options
find . -name "*.sh"

# find -delete may have different behavior
find . -name "*.tmp" -delete

# More portable alternative
find . -name "*.tmp" -exec rm {} \;