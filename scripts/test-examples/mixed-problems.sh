#!/bin/bash  # Hardcoded shebang

# Script with multiple cross-platform issues

# 1. Hardcoded shebang (line 1)

# 2. echo -e (behavior differs)
echo -e "Line 1\nLine 2"

# 3. xargs -r (GNU extension)
find . -name "*.txt" | xargs -r rm

# 4. head with negative numbers
head -n -5 file.txt

# 5. Using gawk
gawk '{print $1, $3}' file.txt

# 6. ps with Linux-specific format
ps -eo pid,comm

# Better alternatives:
printf "Line 1\nLine 2\n"
find . -name "*.txt" -print0 | xargs -0 rm  # Null-delimited, more portable
tail -n +6 file.txt  # Skip first 5 lines
awk '{print $1, $3}' file.txt
ps aux  # More portable, though column order may vary