# Dotfiles Micro-Improvements

This file tracks small, focused improvements to dotfiles. Each entry should solve ONE specific problem with MAX 3 files changed.

## Todo (FIFO - take first unchecked entry)

### [x] OpenClaw completion causing shell startup delays
**Problem**: OpenClaw's bash completion command takes over 3 seconds to execute, causing significant shell startup delays when sourced in .bashrc. The completion command eagerly loads all subcommands and dependencies, creating performance bottlenecks that affect shell responsiveness.

**Source**: 2026-03-20 | https://github.com/openclaw/openclaw/issues/6177 | GitHub/openclaw | completion command takes 3+ seconds due to eager loading of all subcommands - OpenClaw completion causes shell startup delays

**Idea**: Create a lazy-loading wrapper for OpenClaw completion that defers loading until first use, or implement a cached completion approach to avoid blocking shell startup.

**Implementation Rules**:
- Create 1-3 files maximum
- Focus on core functionality: lazy loading or caching of OpenClaw completion
- No documentation frameworks, no test suites unless absolutely necessary
- Provide immediate value: faster shell startup for OpenClaw users

### [ ] Clangd LSP memory leaks in Neovim
**Problem**: Clangd language server in Neovim has massive memory leaks that can consume 100+ GB of memory and OOM systems if not monitored. The leaks occur during extended editing sessions with C/C++ codebases and require manual intervention to resolve.

**Source**: 2026-03-20 | https://www.reddit.com/r/neovim/comments/1oja5h8/neovim_is_eating_100_gb_of_memory/ | Reddit/neovim | Neovim Is Eating 100+ GB of Memory - clangd sometimes has massive memory leaks and OOMs systems

**Idea**: Create a memory monitoring script for clangd LSP that automatically restarts it when memory usage exceeds thresholds, or implement configuration optimizations to reduce memory consumption.

**Implementation Rules**:
- Create 1-3 files maximum
- Focus on core functionality: memory monitoring and automatic restart for clangd
- No documentation frameworks, no test suites unless absolutely necessary
- Provide immediate value: prevent system OOM from clangd memory leaks

---

## In Progress

## Done

### [x] OpenClaw completion causing shell startup delays
**Problem**: OpenClaw's bash completion command takes over 3 seconds to execute, causing significant shell startup delays when sourced in .bashrc. The completion command eagerly loads all subcommands and dependencies, creating performance bottlenecks that affect shell responsiveness.

**Source**: 2026-03-20 | https://github.com/openclaw/openclaw/issues/6177 | GitHub/openclaw | completion command takes 3+ seconds due to eager loading of all subcommands - OpenClaw completion causes shell startup delays

**Solution**: Created lazy-loading wrapper with caching that defers OpenClaw completion loading until first use, eliminating shell startup delays while maintaining full functionality.

**Files Changed**:
1. `bash/openclaw-completion.sh` - Main lazy-loading implementation with caching
2. `bash/bashrc` - Integration point
3. `bash/README-openclaw-completion.md` - Documentation

**Status**: Implemented, committed, and PR ready

## Todo (FIFO - take first unchecked entry)

### [ ] Bash startup performance degradation with NVM and tool loading
**Problem**: Bash shell startup suffers 10+ second delays when loading tools like NVM (Node Version Manager) in .bashrc, particularly severe in WSL environments. The cumulative latency across terminal sessions significantly impacts developer productivity and workflow efficiency.

**Source**: 2026-03-21 | https://github.com/microsoft/WSL/issues/776 | GitHub/microsoft/WSL | startup bash too slow with nvm loading in .bashrc config - 10+ second delays reported

**Idea**: Implement lazy loading or deferred initialization for NVM and similar environment tools, with intelligent caching and on-demand loading to eliminate shell startup delays while maintaining tool functionality.

**Implementation Rules**:
- Create 1-3 files maximum
- Focus on core functionality: lazy loading of NVM and environment tools
- No documentation frameworks, no test suites unless absolutely necessary
- Provide immediate value: faster shell startup for developers using NVM and similar tools

### [x] Terminal emulator shell integration conflicts with readline vi mode
**Problem**: Terminal emulator shell integration features conflict with readline vi mode configuration, causing broken mode indicators, cursor shape issues, or complete failure of vi mode visual feedback. Ghostty's shell-integration doesn't work with readline mode indicator on macOS, and PowerShell PSReadLine has limitations on simultaneous cursor and prompt indicators.

**Source**: 2026-03-20 | https://github.com/ghostty-org/ghostty/issues/10953 | GitHub/ghostty | bash: ghostty shell-integration doesn't work with readline mode indicator on OSX - vi mode configuration in .inputrc conflicts with shell integration

**Solution**: Created cross-terminal compatible vi mode indicator script that detects terminal capabilities and provides appropriate visual feedback without breaking shell integration.

**Files Changed**:
1. `bash/vi-mode-indicator.sh` - Main implementation with terminal detection
2. `bash/bashrc` - Integration point
3. `bash/README-vi-mode.md` - Documentation

**Status**: Implemented and ready for testing

