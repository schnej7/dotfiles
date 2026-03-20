#!/usr/bin/env bash

# Example script with date command differences

# GNU date -d (fails on macOS)
date -d "yesterday"
date -d "2023-10-01" +%s
date --iso-8601

# macOS date syntax
date -v-1d
date -j -f "%Y-%m-%d" "2023-10-01" +%s

# Portable ISO 8601 format
date +%Y-%m-%dT%H:%M:%S