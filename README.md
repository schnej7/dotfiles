# dotfiles
Environment Configurations

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

## Installation

### Quick Start
```bash
git clone --recursive https://github.com/schnej7/dotfiles.git
cd ~/.dotfiles
make        # Basic installation
```

### Installation Profiles

| Command | Includes | Best For |
|---------|----------|----------|
| `make` | Bash, Vim, Screen, SSH | Linux/Basic setup |
| `make osx` | Base + macOS features | macOS users |  
| `make work` | macOS + Private configs | Work environment |

### What Gets Installed

Each profile creates symbolic links:
- `~/.bashrc` → `bash/bashrc`
- `~/.vimrc` → `vim/vimrc`
- `~/.screenrc` → `screen/screenrc`
- `~/.bash_aliases` → `bash/aliases.bash`
- `~/.bash_colors` → `bash/bash_colors.bash`
- `~/.inputrc` → `bash/inputrc`
- And more...

### First Time Setup
After installation:
1. Restart your terminal or run `source ~/.bashrc`
2. Open vim and run `:PlugInstall` to install plugins
3. For LSP features in vim, run `:call StartLsp()`

## Repository Structure

```
dotfiles/
├── bash/                  # Bash configuration
│   ├── bashrc            # Main bash configuration
│   ├── aliases.bash      # Command aliases and functions
│   ├── bash_colors.bash  # Color definitions for prompt
│   ├── profile.bash      # Bash profile loader
│   ├── inputrc          # Readline configuration (vi mode)
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

### Code Analysis
- `kill-count` - Show line count contributions by author
- `replace <old> <new> <dir>` - Recursive find and replace with preview
- `sack <pattern>` - Search code excluding common directories (node_modules, dist, etc.)
- `osack <pattern>` - Open files containing pattern in vim

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
  - `Ctrl+s` - Source ~/.bashrc
  - `Ctrl+l` - Clear screen
  - `Ctrl+a` - Beginning of line
  - `Ctrl+e` - End of line

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

## Customization

### Adding Personal Aliases
Add your custom aliases to `bash/aliases.bash` or create a local `~/.bash_local` file:

```bash
# In ~/.bash_local (sourced automatically if it exists)
alias myalias='echo "Hello World"'
```

### Vim Customization
- Edit `vim/vimrc` for vim settings
- Add plugins in the `InitPlugins()` function
- Custom keybindings can be added after the existing mappings

### Private Configurations
The `private/` directory is for sensitive configurations:
- `private/bash/work.bash` - Work-specific environment variables
- `private/ssh/config` - SSH host configurations
- This directory can be a separate git repository for security

### Color Customization
Bash prompt colors are defined in `bash/bash_colors.bash`:
- Regular colors: `txtred`, `txtgrn`, `txtblu`, etc.
- Bold colors: `bldred`, `bldgrn`, `bldblu`, etc.
- Script colors: `sh_red`, `sh_grn`, `sh_blu`, etc.

## Legacy Aliases

These are the most commonly used aliases (more available in [aliases.bash](https://github.com/schnej7/dotfiles/blob/main/bash/aliases.bash)):

- `f <filename>` - Case insensitive find
- `o <filename>` - Open all files matching `<filename>` in vim
- `ns` - New screen session
- `sl` - List all screen sessions
- `kill-count` - Get line count in git repo by author
