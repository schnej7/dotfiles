# OpenClaw Lazy-Loading Completion

## Problem Solved
OpenClaw's `completion --shell bash` command takes over 3 seconds to execute because it eagerly loads all subcommands and their heavy dependencies (AWS SDK, Playwright, Slack SDK, etc.). When sourced in `.bashrc`, this causes significant shell startup delays that affect every terminal session.

## Solution
A lazy-loading wrapper that:
1. **Defers completion loading** until the first time `openclaw` command is used
2. **Caches completion output** for 24 hours to avoid repeated generation
3. **Provides seamless integration** - users don't need to change their workflow

## Files Changed
1. `bash/openclaw-completion.sh` - Main implementation with lazy loading and caching
2. `bash/bashrc` - Integration point (sources the wrapper)
3. `bash/README-openclaw-completion.md` - This documentation

## How It Works

### Lazy Loading
- Instead of loading completion during shell startup, we create a wrapper function for `openclaw`
- When user first types `openclaw`, the wrapper:
  1. Loads completion from cache (if valid)
  2. Or generates fresh completion and caches it
  3. Then executes the actual command

### Caching
- Completion output is saved to `~/.openclaw_completion.bash`
- Cache is valid for 24 hours (configurable via `CACHE_MAX_AGE`)
- Stale cache is automatically regenerated

### Fallback
If caching fails, the script falls back to direct completion generation (the original 3-second delay, but only once).

## User Benefits
- **Faster shell startup**: No 3+ second delay when opening terminals
- **Transparent integration**: Works automatically, no manual steps needed
- **Maintains full functionality**: All OpenClaw subcommands and completions work as before
- **Self-healing**: Automatically regenerates cache if it becomes invalid

## Testing

### Verify Installation
```bash
# Check if wrapper is loaded
type openclaw | head -5

# Should show something like:
# openclaw is a function
# openclaw () {
#     _openclaw_lazy_load "$@"
# }
```

### Test Completion
```bash
# First use triggers lazy loading
openclaw <TAB><TAB>

# Should show available subcommands:
# acp      gateway  node     skill    ...
```

### Check Cache
```bash
# View cache file
ls -la ~/.openclaw_completion.bash

# Check cache age
stat -c %Y ~/.openclaw_completion.bash | xargs -I{} date -d @{}
```

### Performance Comparison
```bash
# Time shell startup without improvement
time bash -c 'source <(openclaw completion --shell bash)'

# Time first openclaw command with lazy loading
time openclaw --help
```

## Configuration

### Cache Location
```bash
# Default: ~/.openclaw_completion.bash
export OPENCLAW_COMPLETION_CACHE="$HOME/.custom_cache_path"
```

### Cache Duration
```bash
# Default: 86400 seconds (24 hours)
export CACHE_MAX_AGE=3600  # 1 hour
```

### Disable Caching
```bash
# In openclaw-completion.sh, comment out caching logic
# or set CACHE_MAX_AGE=0
```

## Troubleshooting

### Completion Not Working
```bash
# Regenerate cache manually
rm ~/.openclaw_completion.bash
openclaw --help  # Triggers regeneration
```

### Wrapper Not Loading
```bash
# Check if file exists and is sourced
ls -la ~/.bash/openclaw-completion.sh
grep "openclaw-completion" ~/.bashrc
```

### OpenClaw Command Not Found
```bash
# Ensure openclaw is in PATH
which openclaw
echo $PATH
```

## Implementation Details

The solution uses bash function wrapping and completion caching to avoid the performance bottleneck. The key insight is that completion only needs to be generated once (or once per day), not every shell startup.

## Source
Based on GitHub issue: https://github.com/openclaw/openclaw/issues/6177
"completion command takes 3+ seconds due to eager loading of all subcommands"