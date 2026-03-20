#!/usr/bin/env bash

# Example script with grep -P (Perl regex) that fails on macOS

# grep -P not available on macOS
grep -P '\d+' file.txt

# Portable alternative with grep -E
grep -E '[0-9]+' file.txt

# Another PCRE example
grep -P 'foo(?=bar)' file.txt