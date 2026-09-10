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
- Added configurable timeout (default: 1.0s) via `GIT_PROMPT_TIMEOUT_SECONDS`
- Shows timeout indicator `!` when git status takes too long
- Maintains backward compatibility - all existing behavior preserved
- Uses `timeout` command if available, falls back gracefully if not

### [x] Enhance git branch switching workflow
**Problem**: Switching between git branches could be faster and more intuitive in my workflow

**Source**: My existing `branch` function uses fzf but could be improved

**Idea**: Add branch preview, recent branches list, or smarter sorting

**Implementation Rules**:
- Enhance existing `branch` function
- Add useful features without complexity
- MAX 1 file changed

**Implementation Details**:
- Enhanced `branch()` function in `bash/aliases.bash` with:
  1. **Recent branches list**: Shows most frequently used branches from last 30 days
  2. **Better preview**: Shows last commit time, author, and recent commits
  3. **Keyboard shortcuts**: Ctrl-R for recent branches, Ctrl-A for all branches
  4. **Better feedback**: Clear messages when switching branches
  5. **History integration**: Failed commands added to bash history for easy retry
- Maintains backward compatibility while adding useful features
- Single file changed as required

### [ ] Add vim key mapping conflict detection
**Problem**: Vim/Neovim users struggle to identify and resolve key mapping conflicts between plugins, with overlapping keybindings causing unexpected behavior

**Source**: External-insights.md shows this is a common pain point for vim/LSP workflow

**Idea**: Create simple script to detect conflicting key mappings in vim configuration

**Implementation Rules**:
- Create single script file
- Parse vimrc and plugin mappings
- Report conflicts clearly
- MAX 1 file changed