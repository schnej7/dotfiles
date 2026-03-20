# Cross-Platform Shell Script Compatibility Checker

A tool to detect GNU vs BSD utility differences in shell scripts and suggest fixes for common incompatibilities between Linux and macOS.

## Overview

Shell scripts written on Linux often fail on macOS (and vice versa) due to differences between GNU Coreutils (Linux) and BSD Coreutils (macOS). This tool scans shell scripts for common compatibility issues and provides actionable suggestions for making them more portable.

## Features

- **Detects 12+ common compatibility issues** including:
  - `sed` in-place editing (`-i` vs `-i ''`)
  - `grep -P` (Perl regex) availability
  - `date` command differences (`-d` vs `-j -f`)
  - `find` command syntax variations
  - `stat` command format differences (`-c` vs `-f`)
  - `head`/`tail` flag differences
  - `xargs` variations (`-r` flag)
  - `awk`/`gawk` compatibility
  - Shebang portability
  - `echo -e` vs `printf`
  - `ps` command output format

- **Color-coded output** for easy issue identification
- **Recursive directory scanning** option
- **Comprehensive test suite** with example problematic scripts
- **Pre-commit hook integration** for automated checking

## Installation

```bash
# Make the script executable
chmod +x scripts/cross-platform-check.sh

# Optional: Add to PATH or create alias
sudo ln -s $(pwd)/scripts/cross-platform-check.sh /usr/local/bin/cross-platform-check
```

## Usage

### Basic Usage

```bash
# Check a single script
./scripts/cross-platform-check.sh script.sh

# Check multiple scripts
./scripts/cross-platform-check.sh *.sh

# Recursively check all .sh files in current directory
./scripts/cross-platform-check.sh -r

# Check specific directory
./scripts/cross-platform-check.sh scripts/*.sh
```

### Options

```
-h, --help     Show help message
-v, --version  Show version information
-r, --recursive Check all .sh files in current directory
```

### Examples

```bash
# Check all scripts in project
./scripts/cross-platform-check.sh -r

# Check specific problematic examples
./scripts/cross-platform-check.sh test-examples/*.sh

# Get version info
./scripts/cross-platform-check.sh -v
```

## Test Suite

The tool includes example scripts demonstrating common issues:

- `test-examples/gnu-sed-problem.sh` - `sed -i` differences
- `test-examples/grep-p-problem.sh` - `grep -P` (Perl regex)
- `test-examples/date-problem.sh` - `date` command variations
- `test-examples/find-problem.sh` - `find` syntax issues
- `test-examples/stat-problem.sh` - `stat` format differences
- `test-examples/mixed-problems.sh` - Multiple issues in one script

Run the test suite:
```bash
./scripts/cross-platform-check.sh test-examples/*.sh
```

## Common Issues Detected

### 1. sed In-place Editing
- **GNU/Linux**: `sed -i 's/foo/bar/g' file.txt`
- **macOS/BSD**: `sed -i '' 's/foo/bar/g' file.txt`
- **Portable**: `sed -i.bak 's/foo/bar/g' file.txt` (creates backup)

### 2. grep Perl Regex (-P)
- **Issue**: `grep -P '\d+'` (macOS grep doesn't support `-P`)
- **Fix**: `grep -E '[0-9]+'` or rewrite without PCRE features

### 3. Date Command
- **GNU**: `date -d "yesterday"`, `date -d "2023-10-01" +%s`
- **BSD/macOS**: `date -v-1d`, `date -j -f "%Y-%m-%d" "2023-10-01" +%s`
- **Portable ISO 8601**: `date +%Y-%m-%dT%H:%M:%S`

### 4. Find Command Syntax
- **Incorrect**: `find -name "*.sh" .` (options before path)
- **Correct**: `find . -name "*.sh"` (path before options)

### 5. Stat Command
- **GNU**: `stat -c %s file.txt` (file size)
- **BSD/macOS**: `stat -f %z file.txt`
- **Portable**: `wc -c < file.txt`

### 6. Shebang Lines
- **Problematic**: `#!/bin/bash` (hardcoded path, different versions)
- **Better**: `#!/usr/bin/env bash` (uses PATH lookup)

## Pre-commit Hook Integration

Add automated checking to your Git workflow:

### Option 1: Simple pre-commit script

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "Running cross-platform compatibility check..."
./scripts/cross-platform-check.sh -r
if [ $? -ne 0 ]; then
    echo "❌ Cross-platform issues found. Commit aborted."
    exit 1
fi
echo "✅ No cross-platform issues found."
exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Option 2: Add to existing bash configuration

Add to `~/.bashrc` or `~/.bash_profile`:
```bash
# Cross-platform checker alias
alias shell-check='~/path/to/scripts/cross-platform-check.sh'

# Function to check changed scripts before commit
git-precommit-check() {
    git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' | while read file; do
        if [ -f "$file" ]; then
            echo "Checking $file..."
            ~/path/to/scripts/cross-platform-check.sh "$file"
        fi
    done
}
```

## Best Practices for Cross-Platform Scripts

1. **Use `#!/usr/bin/env bash`** instead of `#!/bin/bash`
2. **Prefer `printf` over `echo -e`** for escape sequences
3. **Test with target system's `/bin/sh`** if using POSIX shell
4. **Use feature detection** instead of OS detection when possible
5. **Avoid GNU/BSD extensions** unless necessary
6. **Consider containerization** (Docker) for complex scripts

## Platform Detection in Scripts

If you need platform-specific code, here's a reliable pattern:

```bash
#!/usr/bin/env bash

case "$(uname -s)" in
    Darwin*)
        # macOS/BSD
        STAT_CMD="stat -f %z"
        DATE_CMD="date -j -f"
        ;;
    Linux*)
        # GNU/Linux
        STAT_CMD="stat -c %s"
        DATE_CMD="date -d"
        ;;
    *)
        echo "Unsupported OS" >&2
        exit 1
        ;;
esac

# Use the platform-specific commands
file_size=$($STAT_CMD "file.txt")
```

## Integration with ShellCheck

This tool complements [ShellCheck](https://www.shellcheck.net/). Use both for comprehensive script validation:

```bash
# Run both tools
shellcheck script.sh
./scripts/cross-platform-check.sh script.sh
```

## Limitations

- Only checks shell scripts (`.sh` files by default)
- Cannot detect all possible compatibility issues
- Some suggestions may require manual review
- Doesn't execute scripts (static analysis only)

## Contributing

Found an issue or have a suggestion? The tool is designed to be extensible. Common patterns to check can be added to the `check_*` functions in the script.

## License

This tool is provided as-is for educational and practical use. Feel free to modify and adapt for your needs.

## References

Based on research from: [Write Cross-Platform Shell: Linux vs macOS Differences That Break Production](https://tech-champion.com/programming/write-cross-platform-shell-linux-vs-macos-differences-that-break-production/)

Additional resources:
- [GNU vs BSD Coreutils Differences](https://www.gnu.org/software/coreutils/)
- [ShellCheck - shell script analysis tool](https://www.shellcheck.net/)
- [POSIX Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)