# Dotfiles Micro-Improvements

*Todo list for small, focused improvements DIRECTLY RELATED TO MY WORKFLOWS: bash prompt with git integration, git workflows, vim with LSP, screen session management, development tools.*

## Todo (FIFO - take first unchecked entry)

### [x] Improve git prompt performance in large repositories
**Problem**: Git-aware bash prompts become slow (100ms+) in large repositories, causing noticeable delays before command prompt appears. This affects my workflow when working with large codebases.

**Source**: Multiple sources in external-insights.md show this is a common pain point

**Idea**: Add configurable timeout or caching to git status checks in prompt functions

**Implementation Rules**:
- Modify existing bash prompt files only
- Add timeout mechanism with fallback
- Maintain backward compatibility
- MAX 2 files changed

**Implementation Details**:
- Modified `bash/bashrc` to add timeout protection for `git status` calls
- Added configurable timeout (default: 500ms) via `GIT_PROMPT_TIMEOUT_MS`
- Added result caching (default: 2 seconds) via `GIT_PROMPT_CACHE_SEC`
- Shows timeout indicator `!` when git status takes too long
- Maintains backward compatibility - all existing behavior preserved
- Uses `timeout` command if available, falls back gracefully if not

### [x] Optimize fzf performance for file searches in large directories  
**Problem**: fzf becomes slow when searching directories with 10k+ files, affecting my file navigation workflow

**Source**: Known fzf performance issue with large directories (external-insights.md shows fd v8.1.0+ DFS algorithm causes slowdowns)

**Idea**: Add directory size detection and limit search scope for large directories

**Implementation Rules**:
- Modify existing fzf configuration
- Add performance optimization
- MAX 2 files changed

**Implementation Details**:
- Enhanced `browse()` function in `bash/aliases.bash` with directory size detection
- Added automatic depth limiting for directories with >5000 or >10000 items
- Added `fzf-smart()` helper function that adjusts behavior based on directory size
- Set FZF environment variables for better default performance
- Maintains backward compatibility while improving large directory performance

### [ ] Enhance git branch switching workflow
**Problem**: Switching between git branches could be faster and more intuitive in my workflow

**Source**: My existing `branch` function uses fzf but could be improved

**Idea**: Add branch preview, recent branches list, or smarter sorting

**Implementation Rules**:
- Enhance existing `branch` function
- Add useful features without complexity
- MAX 1 file changed
