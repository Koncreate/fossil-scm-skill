# Fossil Command Reference

## Repository Management

- `fossil init [FILE]` — Create new repository
- `fossil init --project-name "Name" --project-desc "Desc"` — with metadata (v2.18+)
- `fossil clone URL [FILE]` — Clone remote repository
- `fossil clone --unversioned URL` — clone including unversioned files (UV)
- `fossil open REPO [VERSION]` — Open a checkout. REPO can be a URI (clone+open in one step)
- `fossil open --empty` — Initialize empty checkout (creates new initial commit on first commit)
- `fossil open --workdir DIR` — Put checkout in DIR instead of current directory
- `fossil close` — Dissociate checkout. Requires `--force` if uncommitted changes or non-empty stash
- `fossil close --force` — Force close, discarding stash/undo data
- `fossil checkout VERSION` — Switch version (exists but `update` is preferred; does not pull from remote)
- `fossil checkout --latest` — Checkout latest version in repository
- `fossil status` — Show changed files
- `fossil extras` — Show unmanaged files
- `fossil whatis HASH` — Identify any artifact type
- `fossil describe HASH` — Detailed artifact info (v2.19+)

## Commit & History

- `fossil commit -m "msg"` / `fossil ci` — Commit changes
- `fossil timeline` / `fossil time` — View history (all branches)
- `fossil timeline -b BRANCH` — Restrict to branch
- `fossil timeline -n N` — Limit to N entries
- `fossil info VERSION` — Show commit details
- `fossil diff` — Show uncommitted changes
- `fossil diff --from A --to B` — Diff between versions
- `fossil diff --checkin VERSION` — Show patch for a commit
- `fossil amend VERSION --branch NAME --hide --close` — Modify commit metadata

## Branching & Merging

- `fossil branch new NAME [VERSION]` — Create branch
- `fossil branch list` — List branches
- `fossil branch list --merged` — Show merged branches (v2.23+)
- `fossil branch close NAME` — Close a branch (v2.17+)
- `fossil branch hide NAME` — Hide a branch (v2.17+)
- `fossil branch new NAME [VERSION]` — Create branch ahead of need (discouraged; prefer `commit --branch`)
- `fossil branch list` — List branches
- `fossil branch list --merged` — Show merged branches (v2.23+)
- `fossil branch list --unmerged` — Show unmerged branches
- `fossil branch list -a` — List all branches (including closed)
- `fossil branch list -c` — List closed branches
- `fossil branch list -p` — List private branches
- `fossil branch list -t` — Show recently changed branches first
- `fossil branch close NAME` — Close branch (adds closed tag)
- `fossil branch reopen NAME` — Reopen closed branch
- `fossil branch hide NAME` — Hide branch from timeline
- `fossil branch unhide NAME` — Unhide branch
- `fossil branch current` — Print current branch name
- `fossil branch info BRANCH` — Print branch information
- `fossil branch lsh [LIMIT]` — List recently changed branches (default 5)
- `fossil merge [VERSION]` — Merge into current checkout. Without VERSION, merges recent fork
- `fossil merge --cherrypick VERSION` — Cherry-pick single commit
- `fossil merge --backout VERSION` — Revert a commit
- `fossil merge --integrate` — Merge and close branch on commit
- `fossil merge --baseline BASELINE` — Use custom merge pivot
- `fossil merge --binary GLOB` — Treat matching files as binary
- `fossil merge -n` — Dry run
- `fossil cherry-pick VERSION` — Alias for merge --cherrypick (v2.18+)
- `fossil tag add NAME ARTIFACT` — Add tag/propagate to descendants
- `fossil tag cancel NAME ARTIFACT` — Remove tag
- `fossil tag find NAME` — List objects with tag
- `fossil tag add --propagate NAME ARTIFACT` — Propagate tag to all descendants

## Sync & Remote

- `fossil remote` — Show current remote URL
- `fossil remote URL` — Switch to URL (replaces default, does NOT add named remote)
- `fossil remote add NAME URL` — Add a named remote
- `fossil remote NAME` — Switch to named remote
- `fossil remote-url` — Alias for `fossil remote`
- `fossil sync` — Push + Pull all artifacts
- `fossil push` — Push all branches
- `fossil pull` — Pull from remote
- `fossil update` / `fossil up` — Pull + update working dir
- `fossil up -n` — Dry run (show what would change)
- `fossil up -f VERSION` — Force update to version

## Stash & Undo

- `fossil stash save -m msg` — Stash changes and revert working dir
- `fossil stash snapshot -m msg` — Stash changes but keep working dir unchanged
- `fossil stash list` — List stashes
- `fossil stash list -v` — List with file details
- `fossil stash show [ID]` — Show stash contents as diff (alias: `cat`)
- `fossil stash gshow [ID]` — Show using external gdiff-command
- `fossil stash apply [ID]` — Apply stash (keeps it)
- `fossil stash pop [ID]` — Apply and remove stash
- `fossil stash goto ID` — Update to stash baseline + apply changes (undoable)
- `fossil stash diff [ID]` — Show diff of current dir vs applied stash
- `fossil stash gdiff [ID]` — Diff using external gdiff-command
- `fossil stash rename ID NAME` — Change stash description
- `fossil stash drop ID` — Delete specific stash (undoable)
- `fossil stash drop --all` — Delete ALL stashes (NOT undoable!)
- `fossil undo` — Undo last command

## Wiki

- `fossil wiki create PAGENAME` — Create wiki page
- `fossil wiki commit PAGENAME` — Update wiki page
- `fossil wiki export PAGENAME [FILE]` — Export to stdout/file
- `fossil wiki list` — List pages
- `fossil wiki list --all` — Include deleted pages
- `fossil wiki list -t` — List technotes

Export options: `-h|--html`, `-H|--HTML`, `-p|--pre`, `-M|--mimetype TYPE`

## Tickets

- `fossil ticket add "Title" [FIELD VALUE]...` — Create ticket
- `fossil ticket set <UUID> FIELD VALUE` — Update ticket
- `fossil ticket change <UUID> FIELD VALUE` — Alias for set
- `fossil ticket show "Report" [FILTER]` — Run a report
- `fossil ticket list fields` — List available fields
- `fossil ticket list reports` — List saved reports
- `fossil ticket history <UUID>` — Full change history

Use `--quote` for multiline values or special characters.

## Chat

- `fossil chat` — Open chat in browser
- `fossil chat send -m "msg"` — Send message
- `fossil chat send -f file.txt --as note.txt` — Attach a file
- `fossil chat pull` — Backup chat history (setup privilege required)
- `fossil chat purge` — Remove old messages (per chat-keep-days/chat-keep-count)
- `fossil chat reindex` — Rebuild full-text search index
- `fossil chat url` — Show chat server URL

## Search

- `fossil search "query"` — Search check-in comments (default)
- `fossil search -a "query"` — Search everything
- `fossil search --wiki "query"` — Search wiki pages
- `fossil search --tickets "query"` — Search tickets
- `fossil search --forum "query"` — Search forum posts
- `fossil search --technotes "query"` — Search technotes
- `fossil search --docs "query"` — Search embedded documentation
- `fossil search -n 20 "query"` — Limit results
- `fossil search --highlight 0 "query"` — Disable color output

## Web UI & Server

- `fossil ui` — Launch web UI in current checkout
- `fossil ui -port 9090` — Launch on specific port
- `fossil ui --ckout-alias NAME` — Preview uncommitted docs
- `fossil ui --localauth` — Local-only auth (no password)
- `fossil server` — Serve repository (standalone)
- `fossil server -P 9090` — Serve on port
- `fossil server --repolist DIR` — Serve multiple repos
- `fossil http` — CGI mode

## File Management

- `fossil add FILE` — Add file to tracking
- `fossil rm FILE` — Remove file (soft by default; use `--hard` to actually delete)
- `fossil mv OLD NEW` — Rename file (soft by default; use `--hard` to actually rename on disk)
- `fossil addremove` — Add all unmanaged files, remove all missing files
- `fossil clean` — Remove unmanaged files (destructive!)
- `fossil clean --dry-run` — Preview what would be removed
- `fossil clean --force` — Force clean
- `fossil clean --keep GLOB` — Keep files matching GLOB
- `fossil clean --whatif` — Show what would be removed (more verbose than --dry-run)

## Git Interop

- `fossil git export` — Export to Git
- `fossil git import` — Import from Git
- `fossil all git status` — Show Git mirror status for all repos

## Multi-Repo (`fossil all`)

- `fossil all list` — List tracked repos
- `fossil all sync` — Sync all repos
- `fossil all push` — Push all repos
- `fossil all pull` — Pull all repos
- `fossil all changes` — Show repos with uncommitted changes
- `fossil all extras` — Show unmanaged files across all repos
- `fossil all clean` — Clean all (use `--dry-run` first!)
- `fossil all rebuild` — Rebuild all databases
- `fossil all repack` — Optimize storage for all repos
- `fossil all info` — Run fossil info on all repos
- `fossil all remote` — Show remote URLs for all repos
- `fossil all settings` — Show settings for all repos
- `fossil all fts-config` — Show FTS config for all repos
- `fossil all add path/to/repo.fossil` — Register a repository
- `fossil all ignore path/to/repo.fossil` — Exclude from operations
- `fossil all ignore -c path/to/checkout` — Ignore a checkout directory

## Maintenance

- `fossil rebuild` — Rebuild database (required after version upgrade)
- `fossil repack` — Optimize storage by recompressing artifacts
- `fossil verify` — Check repository integrity
- `fossil scrub` — Remove sensitive data (interactive, use `--force` for non-interactive)
- `fossil dbstat` — Show database statistics
- `fossil fts-config` — Show FTS index info
