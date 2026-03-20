# Micro Improvements Backlog

These are bite-sized tasks for the daily automation. Always pick the first unchecked item (FIFO queue), implement it in a single PR, and update this file afterward (move completed items to the "Done" section with a short note).

## Todo

- [ ] Harden the bootstrap/install path so config+dependency drift is caught during provisioning (make the "doctor" script unnecessary).
- [ ] `cdf` cache/depth flag: add optional `cdf --depth N` and cache the directory list per session using `mapfile` + background `find` so repeated calls are instant.
- [ ] `git-sync-fork` helper: automate the common workflow of syncing a forked repository with upstream (fetch upstream, rebase onto upstream/main, push to origin). Many developers manually run these commands when keeping forks updated.

## Done

- [x] `gstash` helper in `bash/aliases.bash`: fzf over `git stash list` with preview (`git stash show -p {}`), Enter = apply & drop, Alt-Enter = apply without dropping. Implemented in PR #6 (https://github.com/schnej7/dotfiles/pull/6).
- [x] `sync` helper in `bash/aliases.bash`: fetch/prune + rebase current branch onto default (`main`/`master`), using `git rev-parse --abbrev-ref` and `git config --get init.defaultBranch` as fallbacks. Implemented in PR #7.