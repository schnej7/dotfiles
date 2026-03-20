#!/bin/bash

# Example script with GNU sed syntax that fails on macOS

# GNU sed -i without backup extension (fails on macOS)
sed -i 's/foo/bar/g' file.txt

# GNU sed with backup extension (works on both)
sed -i.bak 's/foo/bar/g' file.txt

# What macOS expects
sed -i '' 's/foo/bar/g' file.txt