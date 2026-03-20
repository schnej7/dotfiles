# External Insights - Community Pain Points

This file captures pain points, friction, and issues reported by the community related to bash, terminal workflows, Vim, Git helpers, shell bootstrap/install failures, and related tooling. Entries are sorted newest first.

Format for each entry:
- **Date**: YYYY-MM-DD
- **Source**: URL
- **Community**: GitHub, Reddit, Stack Overflow, etc.
- **Pain Point**: Focus on the problem, not someone else's fix
- **Idea/Tool** (optional): Shorthand for potential exploration
- **Tags**: Performance, Onboarding, Cross-platform, Reliability, etc.

---

## 2026-03-19
*Research cycle started*

### Entry 1: Bash prompt slowdown with git status integration
- **Date**: 2026-03-19
- **Source**: https://unix.stackexchange.com/questions/642812/why-is-git-bash-so-slow-to-give-me-a-command-prompt-and-how-can-i-fix-it
- **Community**: Unix & Linux Stack Exchange
- **Pain Point**: Git-aware bash prompts can become extremely slow, especially when PATH includes network locations (like OneDrive) or when git status operations are heavy. Users experience noticeable delays before getting a command prompt.
- **Tags**: Performance, Git integration, Bash prompt

### Entry 2: Git LFS causes severe bash prompt slowdown
- **Date**: 2026-03-19
- **Source**: https://askubuntu.com/questions/1533926/bash-git-prompt-being-really-slow-with-git-lfs
- **Community**: Ask Ubuntu
- **Pain Point**: Git Large File Storage (LFS) operations in bash prompts cause significant performance degradation, making the terminal feel unresponsive.
- **Tags**: Performance, Git LFS, Bash prompt

### Entry 3: Readline inputrc configuration breaks Ctrl+arrow navigation
- **Date**: 2026-03-19
- **Source**: https://superuser.com/questions/589313/inputrc-causes-ctrlarrows-not-to-work
- **Community**: Super User
- **Pain Point**: Simply having a ~/.inputrc file (even empty) can cause Ctrl+arrow key combinations to print escape sequences instead of moving cursor by words, breaking expected navigation behavior.
- **Tags**: Readline, Inputrc, Navigation, Configuration

### Entry 4: fzf performance issues with large directories
- **Date**: 2026-03-19
- **Source**: https://github.com/junegunn/fzf/issues/1419
- **Community**: GitHub
- **Pain Point**: fzf becomes extremely slow (over 1 minute) when searching through large directories with many files, making it unusable for certain workflows.
- **Tags**: Performance, fzf, File navigation

### Entry 5: Cross-platform bash script differences (Linux vs macOS)
- **Date**: 2026-03-19
- **Source**: https://unix.stackexchange.com/questions/82244/bash-in-linux-v-s-mac-os
- **Community**: Unix & Linux Stack Exchange
- **Pain Point**: Core utilities differ between Linux (GNU) and macOS (FreeBSD), causing scripts that work on one platform to fail on another due to flag differences, output formatting, and behavior variations.
- **Tags**: Cross-platform, Compatibility, Bash scripts

### Entry 6: Vim/LSP slow startup times in WSL
- **Date**: 2026-03-19
- **Source**: https://github.com/neovim/nvim-lspconfig/issues/3704
- **Community**: GitHub
- **Pain Point**: Language Server Protocol (LSP) configuration in Vim/Neovim takes significantly longer to load in WSL environments (2+ seconds) compared to native Linux, affecting developer workflow.
- **Tags**: Performance, Vim, LSP, WSL, Startup time

### Entry 7: Shell bootstrap/install script failures due to bash version
- **Date**: 2026-03-19
- **Source**: https://github.com/ohmybash/oh-my-bash/issues/27
- **Community**: GitHub
- **Pain Point**: Installation scripts fail on macOS because it ships with an older version of bash (3.2) while scripts require bash 4.0+, creating onboarding friction for new users.
- **Tags**: Onboarding, Bootstrap, macOS, Bash version

### Entry 8: CI/CD pipeline bash script failures due to shell differences
- **Date**: 2026-03-19
- **Source**: https://stackoverflow.com/questions/70866389/bash-script-getting-syntax-error-in-cd-ci-pipeline
- **Community**: Stack Overflow
- **Pain Point**: Bash scripts that work locally fail in CI/CD pipelines because the pipeline uses a different shell (sh vs bash) that doesn't support arrays or other bash-specific features.
- **Tags**: CI/CD, Compatibility, Shell differences, Reliability

