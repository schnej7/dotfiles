#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

init_colors() {
  if command_exists tput && [ -n "${TERM:-}" ]; then
    local colors
    colors=$(tput colors 2>/dev/null || echo 0)
    if [ "$colors" -ge 8 ]; then
      COLOR_OK="$(tput setaf 2)"
      COLOR_WARN="$(tput setaf 3)"
      COLOR_ERR="$(tput setaf 1)"
      COLOR_INFO="$(tput setaf 4)"
      COLOR_RESET="$(tput sgr0)"
      return
    fi
  fi
  COLOR_OK=""; COLOR_WARN=""; COLOR_ERR=""; COLOR_INFO=""; COLOR_RESET=""
}

print_status() {
  local level message color icon
  level="$1"; message="$2"
  case "$level" in
    ok)    color="$COLOR_OK";   icon="✔" ;;
    warn)  color="$COLOR_WARN"; icon="⚠" ;;
    err)   color="$COLOR_ERR";  icon="✖" ;;
    info)  color="$COLOR_INFO"; icon="ℹ" ;;
    *)     color="";            icon="-" ;;
  esac
  printf "%s%s %s%s\n" "$color" "$icon" "$message" "$COLOR_RESET"
}

os_hint() {
  if [ "$OS_NAME" = "Darwin" ]; then
    printf "Install with: brew install %s" "$1"
  else
    printf "Install with: sudo apt-get install -y %s" "$1"
  fi
}

check_dependency() {
  local cmd pkg label
  cmd="$1"; pkg="$2"; label="$3"
  if command_exists "$cmd"; then
    print_status ok "$label ($cmd) found"
  else
    print_status err "$label ($cmd) missing. $(os_hint "$pkg")"
    missing_items=$((missing_items + 1))
  fi
}

resolve_path() {
  local target="$1"
  if command_exists python3; then
    python3 - <<'PY' "$target"
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
  elif command_exists realpath; then
    realpath "$target"
  elif [ -L "$target" ]; then
    readlink "$target"
  else
    printf "%s" "$target"
  fi
}

check_symlink() {
  local dest source expected actual
  dest="$1"; source="$2"; expected="$REPO_ROOT/$source"
  if [ -L "$dest" ]; then
    actual=$(resolve_path "$dest")
    if [ "$actual" = "$expected" ]; then
      print_status ok "Symlink OK: $dest -> $source"
      return
    fi
    print_status warn "Symlink mismatch: $dest -> $actual (expected $expected)"
    remediation_needed=$((remediation_needed + 1))
  elif [ -e "$dest" ]; then
    print_status warn "$dest exists but is not a symlink (expected link to $source)"
    remediation_needed=$((remediation_needed + 1))
  else
    print_status err "$dest missing. Run 'make' to install dotfiles."
    remediation_needed=$((remediation_needed + 1))
  fi
}

main() {
  init_colors
  OS_NAME="$(uname -s 2>/dev/null || echo Unknown)"
  print_status info "dotfiles doctor running on $OS_NAME"
  printf "Root: %s\n\n" "$REPO_ROOT"

  print_status info "Checking core dependencies"
  check_dependency git git "Git"
  check_dependency make make "GNU Make"
  check_dependency bash bash "Bash"
  check_dependency vim vim "Vim"
  check_dependency screen screen "GNU Screen"
  check_dependency fzf fzf "fzf"
  check_dependency bat bat "bat (use 'batcat' on Debian)"
  check_dependency ack ack-grep "ack"
  check_dependency docker docker "Docker"
  check_dependency gh gh "GitHub CLI"
  printf "\n"

  print_status info "Verifying dotfile symlinks"
  check_symlink "$HOME/.bashrc" "bash/bashrc"
  check_symlink "$HOME/.bash_aliases" "bash/aliases.bash"
  check_symlink "$HOME/.bash_colors" "bash/bash_colors.bash"
  check_symlink "$HOME/.inputrc" "bash/inputrc"
  check_symlink "$HOME/.vimrc" "vim/vimrc"
  check_symlink "$HOME/.screenrc" "screen/screenrc"
  check_symlink "$HOME/.cursor_bashrc.sh" "cursor_bashrc.sh"

  printf "\n"
  if [ "$missing_items" -eq 0 ] && [ "$remediation_needed" -eq 0 ]; then
    print_status ok "Environment looks good!"
    exit 0
  fi

  print_status warn "Found $missing_items missing dependency(ies) and $remediation_needed symlink issue(s)."
  print_status info "Re-run 'make' after addressing the issues above."
  exit 1
}

missing_items=0
remediation_needed=0
main
