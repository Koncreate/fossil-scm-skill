# Advanced Features

## `fossil amend`

Modify how a commit displays **without changing the commit itself** — Fossil inserts metadata records to override display behavior. The commit hash is unchanged. Amendments do not autosync.

```bash
fossil amend VERSION --branch new-branch       # retarget to a different branch
fossil amend VERSION --hide                    # hide from timeline
fossil amend VERSION --close                   # mark as closed
fossil amend VERSION --branchcolor auto        # auto-assign branch color (v2.17+)
fossil amend VERSION --bgcolor COLOR           # set check-in background color
fossil amend VERSION --branchcolor COLOR       # set + propagate color to branch
fossil amend VERSION --author USER             # change author
fossil amend VERSION --date DATETIME           # change check-in time
fossil amend VERSION --date-override DT        # set control artifact timestamp
fossil amend VERSION --tag TAG                 # add a tag
fossil amend VERSION --cancel TAG              # remove a tag
fossil amend VERSION --edit-comment            # launch editor for comment
fossil amend VERSION --comment MSG             # set comment text
fossil amend VERSION --message-file FILE       # read comment from FILE
fossil amend VERSION --user-override USER      # set user on control artifact
fossil amend VERSION --no-verify-comment       # skip comment validation
fossil amend VERSION -n                        # dry-run, print artifact
```

DATETIME format: `now`, `YYYY-MM-DDTHH:MM:SS.SSS`, or truncated forms. Timezone: `-HH:MM` (west), `+HH:MM` (east), or `Z` for UTC.

**Key insight**: `amend` doesn't modify the commit — it adds a "control artifact" that overrides how the commit displays. The original commit data is unchanged. This is fundamentally different from `git commit --amend`.

## `fossil bisect`

Binary search for the commit that introduced a bug:

```bash
fossil bisect start
fossil bisect good <version>
fossil bisect bad <version>
# Fossil checks out the midpoint commit
# Test it, then:
fossil bisect good    # or 'bad'
# Repeat until found
fossil bisect reset
```

### Bisect Subcommands

```bash
fossil bisect good ?VERSION?     # mark version as working (default: current)
fossil bisect bad ?VERSION?      # mark version as non-working (default: current)
fossil bisect skip ?VERSION?     # ignore version (e.g., doesn't compile)
fossil bisect next               # update to midpoint between good and bad
fossil bisect reset              # reinitialize bisect session
fossil bisect log                # show events in test order
fossil bisect chart              # show events in check-in order
fossil bisect status             # alias for vlist
fossil bisect vlist ?-a?         # list versions between innermost good/bad
fossil bisect undo               # undo most recent good/bad/skip
fossil bisect options ?NAME? ?VALUE?  # list/get/set bisect options
fossil bisect ui ?HOST@USER:PATH?    # launch UI showing only bisect check-ins
fossil bisect run [OPTIONS] COMMAND   # automated bisect (exit 0=good, 125=skip, else=bad)
```

### Automated Bisect

```bash
# Run a test script that exits 0 (good), 125 (skip), or other (bad)
fossil bisect run ./test-script.sh  # ⚠️ Only run trusted test scripts — arbitrary code execution
fossil bisect run ./test-script.sh

# Interactive mode (prompt for good/bad/skip instead of using exit code)
fossil bisect run -i ./test-script.sh  # ⚠️ Interactive mode — same trust requirement as above
```

v2.23+ adds `--start` to begin bisect from a specific commit.
v2.21+ added `merge-base` as an upgrade of `test-find-pivot`.

## `fossil diff` Variants

```bash
# Basic diffs
fossil diff                                    # all unsaved changes
fossil diff FILE1 FILE2                        # specific files
fossil diff --from VERSION --to VERSION        # between versions
fossil diff --checkin VERSION                  # changes in a specific check-in
fossil diff --branch BRANCHNAME                # all changes on a branch

# Output formats
fossil diff --by                                # side-by-side in browser
fossil diff --webpage                          # render as HTML page
fossil diff --json                             # JSON output
fossil diff --tcl                              # Tcl-friendly output
fossil diff -y                                 # text side-by-side
fossil diff --brief                            # filenames only
fossil diff --numstat                          # added/deleted line counts
fossil diff --tk                               # Tcl/Tk GUI

# Context and whitespace
fossil diff --context 10                       # 10 lines of context
fossil diff --context -1                       # infinite context (full file, v2.22+)
fossil diff --ignore-all-space                 # ignore whitespace
fossil diff --strip-trailing-cr                # strip trailing CR

# Binary and external diff
fossil diff --binary PATTERN                   # treat matching files as binary
fossil diff --diff-binary BOOL                 # include binary files with external diff
fossil diff --command PROG                     # external diff program
fossil diff -i                                 # force internal diff logic

# Other options
fossil diff --versions                         # show version details in header (v2.19+)
fossil diff --undo                             # use undo buffer as baseline
fossil diff --invert                           # invert the diff
fossil diff --linenum                          # show line numbers
fossil diff --verbose                          # output complete text of added/deleted files
fossil diff --dark                             # dark mode for GUI/HTML

# gdiff (GUI diff)
fossil gdiff FILE1 FILE2                       # open in GUI diff tool
fossil diff --by                               # shorthand for --browser -y

# xdiff (external files)
fossil xdiff FILE1 FILE2                       # diff unmanaged files on disk
```

## `fossil annotate` (blame/praise)

Show when each line of a file was last modified:

```bash
fossil annotate FILE                          # line numbers, no usernames
fossil blame FILE                             # show author for each line
fossil praise FILE                            # alias for blame
fossil blame -r VERSION FILE                  # annotate specific version
fossil blame -o trunk FILE                    # reverse annotation (toward trunk)
fossil blame -t FILE                          # latest check-in per file
fossil blame -T FILE                          # like -t with comment snippet
fossil blame --filevers FILE                  # show file version numbers
fossil blame -l FILE                          # list all versions analyzed
fossil blame -n 10 FILE                       # limit to 10 versions
fossil blame -n 30s FILE                      # analyze for max 30 seconds
fossil blame -w FILE                          # ignore whitespace
```

## `fossil describe`

Show detailed information about a repository artifact (v2.19+):

```bash
fossil describe <hash>                        # describe any artifact
fossil describe                               # describe current checkout
fossil describe --long                        # always show all components
fossil describe --digits 10                   # show 10 hex digits
fossil describe --dirty                       # show if uncommitted changes exist
fossil describe --match "v*"                  # only consider tags matching GLOB
```

Output format: `tagname-N-commithash` (e.g., `v2.23-15-abc12345`)

## `fossil finfo`

Print the complete change history for a single file:

```bash
fossil finfo FILE                             # log mode (default)
fossil finfo -b FILE                          # brief (one line per revision)
fossil finfo -i FILE                          # artifact ID and check-in info
fossil finfo -i -v FILE                       # all check-ins using the file
fossil finfo -s FILE                          # status mode (quick status)
fossil finfo -p FILE                          # print current version to stdout
fossil finfo -p -r VERSION FILE               # print specific version to stdout
fossil finfo -n 10 FILE                       # limit to 10 changes
fossil finfo --offset 5 FILE                  # skip first 5 changes
fossil finfo -W 80 FILE                       # wrap at 80 columns
```

## `fossil stash`

Save and restore working tree changes:

```bash
fossil stash                                  # save all changes (alias for save)
fossil stash save -m "WIP feature"           # save and revert
fossil stash save file.txt                    # stash specific files only
fossil stash snapshot -m "WIP"               # save but keep working dir unchanged
fossil stash list                             # list stashes
fossil stash list -v                          # list with file details
fossil stash show ID                          # show stash contents as diff
fossil stash cat ID                           # alias for show
fossil stash gshow ID                         # show using external diff command
fossil stash apply ID                         # apply stash (keeps it)
fossil stash apply ID                         # apply stash (keeps it) ⚠️ may overwrite uncommitted changes
fossil stash pop                              # apply and remove most recent ⚠️ overwrites uncommitted changes, then deletes stash
fossil stash pop ID                           # apply and remove specific stash ⚠️ same as pop default
fossil stash goto ID                          # update to baseline + apply (undoable) ⚠️ discards current working dir changes
fossil stash gdiff ID                         # diff using external diff command
fossil stash rename ID "new name"             # change stash description
fossil stash drop ID                          # delete specific stash (undoable)
fossil stash drop --all                       # delete ALL stashes (NOT undoable!)
```

**Note**: Stash is per-checkout (stored in `.fslckout`), not in the repository.

## `fossil undo` / `fossil redo`

Undo the previous command:

```bash
fossil undo                                   # revert last command
fossil undo FILE                              # restore specific file content
fossil redo                                   # undo the undo
fossil undo -n                                # dry-run (show what would happen)
```

Undoable commands: `update`, `merge`, `revert`, `stash pop`, `stash apply`, `stash drop`, `stash goto`, `clean` (files < 10MiB only).

## Pikchr Diagrams

Fossil supports inline Pikchr diagrams (v2.23+ renders client-side via WASM):

```
<verbatim type="pikchr">
box "Hello"
arrow
box "World"
</verbatim>
```

Works in wiki, technotes, embedded docs, and Markdown content.

## Git Export/Import

### Export (Fossil → Git)

```bash
fossil git export                             # create/update Git mirror
fossil git export /path/to/git-mirror         # specify mirror directory
fossil git export --autopush URL              # auto-push to remote after export
fossil git export --autopush off              # disable auto-push
fossil git export --mainbranch main           # map trunk to "main" (default: "master")
fossil git export --force                     # export even if nothing changed
fossil git export --if-mirrored               # no-op if mirror doesn't exist
fossil git export --limit N                   # add only N new check-ins
fossil git export --debug FILE                # write fast-export text to FILE
fossil git export -q                          # quiet
fossil git export -v                          # verbose
```

The mirror directory contains `.mirror_state` — do not edit these files manually.

### Import (Git → Fossil)

```bash
fossil git import /path/to/git-repo           # import from Git into Fossil
```

### Other Import Formats

```bash
# Import from git-fast-export format
fossil import new-repo.fossil < export.txt
fossil import --git new-repo.fossil export.txt
fossil import --rename-master trunk new-repo.fossil export.txt
fossil import --use-author new-repo.fossil export.txt
fossil import --attribute "email@example.com USER" new-repo.fossil export.txt
fossil import -i new-repo.fossil export.txt   # incremental (existing repo)

# Import from SVN dump
fossil import --svn new-repo.fossil svn-dump.txt
fossil import --svn --trunk trunk --branches branches --tags tags new-repo.fossil dump.txt
fossil import --svn --flat new-repo.fossil dump.txt  # single branch
```

### Git Mirror Status

```bash
fossil git status                             # show mirror status
fossil all git status                         # status for all repos with mirrors
```

## Checking Out by Date

```bash
fossil update 2020-03-17                      # reliable, consistent across clones
fossil up 2020-03-17T12:00:00                 # with time
fossil up 2020-03-17T12:00:00Z                # UTC
fossil up 2020-03-17T12:00:00-05:00           # with timezone
```

Git's `git checkout master@{date}` is unreliable (depends on local reflog, varies by machine). Fossil's date checkout is always consistent because it uses an indexed SQL query against cloned timestamps.

## `fossil checkout` vs `fossil update`

- `fossil update VERSION` — Pull from remote + update working dir (preferred)
- `fossil checkout VERSION` — Switch version locally, does NOT pull from remote
- `fossil checkout --latest` — Checkout latest version in repo

## `fossil open` Options

```bash
fossil open REPO --empty                      # empty checkout (new initial commit)
fossil open REPO --keep                       # only update manifest, leave files
fossil open REPO --workdir DIR                # put checkout in DIR
fossil open REPO --force                      # ⚠️ allow opening into non-empty directory — may overwrite existing files
fossil open REPO --nosync                     # skip auto-sync on open
fossil open REPO --nested                     # allow opening inside another checkout
fossil open REPO --reopen OTHER.fossil        # reconnect checkout to different file
fossil open REPO --repodir DIR                # store clone in DIR (when opening URI)
fossil open REPO --setmtime                   # set file timestamps to SCM times
fossil open REPO --proxy PROXY                # use HTTP proxy for sync
fossil open REPO --verbose                    # verbose clone output
```

## Multiple Remotes

```bash
fossil remote add work https://dev-server.example.com/repo
fossil remote add home ssh://nas.local//share/repo.fossil
fossil remote work                            # switch to work
fossil remote home                            # switch to home
fossil remote https://new-server.example.com/repo  # switch default (replaces, not named)
fossil remote list                            # list all remotes
fossil remote delete NAME                     # delete a named remote
fossil remote off                             # forget default URL (airplane mode)
fossil remote scrub                           # forget saved passwords
```

## `fossil tag` Management

```bash
fossil tag add NAME ARTIFACT                  # add tag
fossil tag add --propagate NAME ARTIFACT      # propagate to descendants
fossil tag add --root NAME ARTIFACT           # tag oldest parent + propagate
fossil tag add --date-override DATETIME NAME ARTIFACT  # custom timestamp
fossil tag add --user-override USER NAME ARTIFACT      # custom user
fossil tag add --raw NAME ARTIFACT            # raw tag name
fossil tag add -n NAME ARTIFACT               # dry-run
fossil tag cancel NAME ARTIFACT               # remove tag
fossil tag cancel --raw NAME ARTIFACT         # cancel raw tag
fossil tag find NAME                          # list objects with tag
```

**Note**: Fossil rejects tag prefixes `wiki-`, `tkt-`, `event-` (reserved internally).

## `fossil branch` Management

```bash
fossil branch new NAME [VERSION]              # create branch (discouraged)
fossil branch new --private NAME [VERSION]    # private branch
fossil branch new --bgcolor COLOR NAME        # custom background color
fossil branch new --nosign NAME               # don't sign manifest
fossil branch list                            # list open branches
fossil branch list -a                         # list all branches
fossil branch list -c                         # list closed branches
fossil branch list -m                         # list merged branches
fossil branch list -M                         # list unmerged branches
fossil branch list -p                         # list private branches
fossil branch list -r                         # reverse sort order
fossil branch list -t                         # recently changed first
fossil branch list --self                     # only branches you participate in
fossil branch list --username USER            # only branches USER participates in
fossil branch list GLOB                       # filter by pattern
fossil branch lsh [LIMIT]                     # recently changed (default 5)
fossil branch close NAME                      # close branch
fossil branch reopen NAME                     # reopen closed branch
fossil branch hide NAME                       # hide from timeline
fossil branch unhide NAME                     # unhide
fossil branch current                         # print current branch name
fossil branch info NAME                       # print branch information
```

## `fossil merge` Options

```bash
fossil merge                                  # merge recent fork on current branch
fossil merge VERSION                          # merge specific version
fossil merge VERSION1 VERSION2                # merge multiple versions in order
fossil merge --cherrypick VERSION             # cherry-pick single commit
fossil merge --backout VERSION                # revert a commit
fossil merge --integrate                      # merge and close branch on commit
fossil merge --baseline BASELINE              # custom merge pivot
fossil merge --binary GLOB                    # treat matching files as binary
fossil merge -f|--force                       # force merge even if no-op
fossil merge --force-missing                  # force even with missing content
fossil merge -K|--keep-merge-files            # retain *-baseline, *-original, *-merge files
fossil merge -n|--dry-run                     # preview without changing files
fossil merge --nosync                         # skip auto-sync before merge
fossil merge --noundo                         # don't record in undo log
fossil merge -v|--verbose                     # show additional details
```

**Note**: Merge never auto-commit. You must run `fossil commit` separately.
