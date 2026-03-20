#!/usr/bin/env bash

# Example script with stat command differences

# GNU stat -c (fails on macOS)
stat -c %s file.txt
stat -c %Y file.txt

# macOS stat -f
stat -f %z file.txt
stat -f %m file.txt

# Portable alternatives
wc -c < file.txt  # File size
ls -l file.txt | awk '{print $5}'  # File size
date -r file.txt +%s  # Modification time (macOS/BSD)
stat -c %Y file.txt 2>/dev/null || stat -f %m file.txt  # Platform detection