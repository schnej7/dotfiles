# dotfiles
A comprehensive development environment configuration featuring an intelligent bash prompt, advanced git workflows, powerful vim setup with LSP support, and seamless screen session management.

# Features

## Bash Prompt

<img width="517" alt="image" src="https://github.com/user-attachments/assets/59b25b27-d96d-4775-9715-dd118a05004b" />

```
[<screen-id>](<user>@<host>)<working-dir>(<git-branchname> <git-branch-status>)
$
```
`git-branch-status`:
* `+` = Unstaged changes
* `×` = Staged changes not yet committed

## Git & Development Workflow

### Branch Management
- `branch` - Interactive branch selector with preview using fzf
- `master` - Quick switch to master branch
- `push` - Push current branch to origin with upstream tracking
- `giff <commit>` - Interactive diff viewer for specific commit

### Staging & Commits
- `add` - Interactive staging with fzf: select files to stage (conflicts, new, removed, modified) with diff/preview; useful during rebase and day-to-day staging
- `commit` - Interactive commit with conventional commit type (feat, fix, docs, etc.), optional ticket from branch name, and COMMIT_SUBJECT; opens editor for message

### Code Analysis
- `kill-count` - Show line count contributions by author
- `replace <old> <new> <dir>` - Recursive find and replace with preview
- `sack <pattern>` - Search code excluding common directories (node_modules, dist, etc.)
- `osack <pattern>` - Open files containing pattern in vim
- `portkill` - Interactive kill by port: fzf over listening ports (port, PID, command) with multi-select; uses lsof

### File Management
- `f <pattern>` - Find files by name (excludes node_modules/dist)
- `fa <pattern>` - Find files by name (includes all directories)
- `o <pattern>` - Open matching files in vim with fzf selection
- `cdf [query]` - Interactive directory navigation using fzf to browse subdirectories within CDPATH
- `dirspace <dir>` - Show disk usage for directory

## Screen Session Management

- `s` - Attach to first detached session or create new one
- `ns` - Create new screen session
- `rs` - Resume first detached screen session
- `x <name>` - Attach to named session
- `sl` - List all screen sessions
- `dsl` - List detached sessions
- `ksl` - Kill all screen sessions
- `kdsl` - Kill all detached sessions

**Screen Features:**
- 10,000 line scrollback buffer
- Multi-user support enabled
- Auto-detach functionality

## Docker Utilities

- `docker-select` - Interactive container selector with preview and shell access

## Cursor Integration

When running inside Cursor (when `CURSOR_TRACE_ID` is set), bash sources `~/.cursor_bashrc.sh`, which in turn sources `~/.cursor_bashrc_private.sh` for work-specific configuration (both are symlinked from the repo by `make`). The GitHub MCP server can be run via the wrapper script `bash/github-mcp.sh`, which starts the official GitHub MCP server in Docker using `gh auth token`.

## Vim Configuration

### LSP Features (Language Server Protocol)
- `Ctrl+h` - Show hover documentation
- `-` - Show code actions/quick fixes
- `0` - Find all references
- `3` - Rename symbol
- `gi` - Go to implementation (when LSP enabled)
- `gd` - Go to declaration (when LSP enabled)
- `gr` - Find references (when LSP enabled)
- `gl` - Show diagnostics (when LSP enabled)

### Navigation & Management
- `Enter` - Toggle line numbers on/off
- `Ctrl+n` - Toggle relative line numbers
- `1` - Close all tabs except current
- `2` - Buffer selector
- `8` - Open quickfix window
- `9` - Close quickfix window

### Plugins Included
- **vim-lsp** - Language Server Protocol support
- **vim-lsp-settings** - Automatic LSP server installation
- **vim-fugitive** - Git integration
- **JavaScript/TypeScript/JSX** - Full syntax highlighting and support

### Key Features
- Vi command line mode enabled
- Automatic plugin installation via vim-plug
- LSP disabled by default (call `:StartLsp()` when needed)
- Smart indentation for multiple file types
- Enhanced quickfix window navigation

## Bash Environment Features

### Vi Mode & Readline
- Vi command line editing mode
- Custom readline shortcuts:
  - `Ctrl+f` - Interactive file explorer
  - `Ctrl+s` - Source ~/.bashrc
  - `Ctrl+l` - Clear screen
  - `Ctrl+a` - Beginning of line
  - `Ctrl+e` - End of line

### History & Session Recording
- **Bash history** is written per session (PID) and per day to `~/.history/bash_history.$PID.$date`; history is appended progressively so each terminal has its own file
- **Script sessions**: if `script` is available, each new terminal session (and each new `bash` subshell) starts a `script` recording to `~/.script/script.$PID.$date`, capturing full input and output for that session

### Enhanced Tools Integration
- **fzf** configured with bat preview and reverse layout
- **git completion** for branch names and commands
- **Optimized git status** parsing for faster prompt updates
- **CDPATH** includes home directory for easier navigation

### Interactive Directory Navigation (`cdf`)
The `cdf` function provides fuzzy directory navigation for all subdirectories within your CDPATH:

- **What it does**: Shows all immediate subdirectories within each CDPATH location for fzf selection
- **Live preview**: Displays `ls` output of each directory as you navigate
- **Smart navigation**: Uses `cd -P` to properly handle symbolic links
- **Query support**: `cdf myproject` starts with "myproject" pre-filled in fzf
- **Ergonomic design**: Navigate directly to project folders rather than parent directories
- **Auto-startup**: Automatically launches when starting a new bash session (can be customized with `CDF_DEFAULT` environment variable)

**Example**: If CDPATH includes `~/projects` and `~/work`, `cdf` shows:
```
~/projects/dotfiles
~/projects/myapp
~/projects/website
~/work/client1
~/work/client2
```

**Customization**: Set `CDF_DEFAULT` environment variable to change startup behavior:
- `export CDF_DEFAULT=""` - Default, shows all directories on startup
- `export CDF_DEFAULT="myproject"` - Pre-filters to directories matching "myproject"
- Comment out the `cdf "$CDF_DEFAULT"` line in `bashrc` to disable auto-startup

## Legacy Aliases

These are the most commonly used aliases (more available in [aliases.bash](https://github.com/schnej7/dotfiles/blob/main/bash/aliases.bash)):

- `f <filename>` - Case insensitive find
- `o <filename>` - Open all files matching `<filename>` in vim
- `ns` - New screen session
- `sl` - List all screen sessions
- `kill-count` - Get line count in git repo by author

# Installation

## Quick Start
```bash
git clone --recursive https://github.com/schnej7/dotfiles.git
cd ~/.dotfiles
make        # Basic installation
```

## Installation Profiles

| Command | Includes | Best For |
|---------|----------|----------|
| `make` | Bash, Vim, Screen, SSH | Linux/Basic setup |
| `make osx` | Base + macOS features | macOS users |
| `make work` | macOS + Private configs | Work environment |

## What Gets Installed

Each profile creates symbolic links:
- `~/.bashrc` → `bash/bashrc`
- `~/.vimrc` → `vim/vimrc`
- `~/.screenrc` → `screen/screenrc`
- `~/.bash_aliases` → `bash/aliases.bash`
- `~/.bash_colors` → `bash/bash_colors.bash`
- `~/.inputrc` → `bash/inputrc`
- `~/.cursor_bashrc.sh` → `cursor_bashrc.sh`

## First Time Setup
After installation:
1. Restart your terminal or run `source ~/.bashrc`
2. Open vim and run `:PlugInstall` to install plugins
3. For LSP features in vim, run `:call StartLsp()`

## Prerequisites

### Required Tools
- **Git** - For cloning and managing the repository
- **Make** - For running installation commands
- **Bash** - Shell environment
- **Vim** - Text editor (configured with plugins)

### macOS Specific Requirements
- **Homebrew** - Package manager (installed automatically with `make osx`)
- **bash-completion** - Enhanced tab completion

### Optional Enhancements
- **fzf** - Fuzzy finder for enhanced file/branch selection
- **bat** - Better `cat` with syntax highlighting
- **ack** - Advanced text search tool
- **screen** - Terminal multiplexer

# Repository Structure

```
dotfiles/
├── bash/                  # Bash configuration
│   ├── bashrc            # Main bash configuration
│   ├── aliases.bash      # Command aliases and functions
│   ├── bash_colors.bash  # Color definitions for prompt
│   ├── profile.bash      # Bash profile loader
│   ├── inputrc          # Readline configuration (vi mode)
│   ├── github-mcp.sh    # GitHub MCP server wrapper (Docker + gh auth)
│   └── osx/             # macOS-specific configurations
├── vim/                  # Vim configuration
│   ├── vimrc            # Main vim configuration
│   └── pack/            # Vim plugin packages (git submodules)
├── screen/              # GNU Screen configuration
│   └── screenrc         # Screen settings
└── private/             # Private/sensitive configurations
    ├── ssh/             # SSH configuration
    └── bash/            # Work-specific bash settings
```

## How It Works

The dotfiles use symbolic links to connect configuration files to their expected locations in your home directory. The Makefile system provides different installation profiles:

- **Base** (`make`): Core bash, vim, screen, and SSH configurations
- **macOS** (`make osx`): Base + macOS-specific enhancements
- **Work** (`make work`): macOS + private work configurations

## Contributing

This repository follows the [forking workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow), which allows contributors to propose changes without requiring direct write access to the main repository.

### How to Contribute

1. **Fork the repository** - Create your own server-side copy of this repository using GitHub's fork button

2. **Clone your fork** - Download your fork to your local machine:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

3. **Add upstream remote** - Connect to the original repository to stay updated:
   ```bash
   git remote add upstream https://github.com/schnej7/dotfiles.git
   ```

4. **Create a feature branch** - Work on changes in a dedicated branch:
   ```bash
   git checkout -b feature/your-improvement
   ```

5. **Make your changes** - Edit files, test your modifications, and commit:
   ```bash
   git commit -am "Add your descriptive commit message"
   ```

6. **Push to your fork** - Upload your changes to your server-side repository:
   ```bash
   git push origin feature/your-improvement
   ```

7. **Open a pull request** - Use GitHub to propose merging your changes into the main repository

### Staying Updated

Keep your fork synchronized with the main repository:
```bash
git pull upstream main
git push origin main
```

### Customization

While contributing, you can customize your local setup:
- Add personal aliases to `bash/aliases.bash`
- Modify `vim/vimrc` for editor preferences
- Use the `private/` directory for sensitive configurations
- Adjust colors in `bash/bash_colors.bash`

