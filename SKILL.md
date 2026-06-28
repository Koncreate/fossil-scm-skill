---
name: fossil-scm
description: "Expert guide for Fossil SCM. Load when: (1) user asks about Fossil or compares it to Git, (2) initializing/managing Fossil repositories, (3) branching/merging in Fossil, (4) working with Fossil wiki/tickets/forum/chat, (5) setting up Fossil servers or Chiselapp, (6) migrating Git↔Fossil, (7) user says 'fossil' or 'fossil-scm'."
license: Apache-2.0
---

# Fossil SCM

Fossil is a distributed version control system that bundles source control, ticketing, wiki, forum, chat, and a built-in web interface into a single SQLite database file (`.fossil`).
## Core Concepts

- **Repository ≠ Checkout** — The `.fossil` DB is separate from your working directory. The `.fslckout` file tracks local state.
- **No staging area** — `fossil commit` commits all changes. Specify files to commit selectively: `fossil commit src/ doc/`
- **No auto-commit** — Merge/cherry-pick/backout only modify the working tree. You must `fossil commit` separately.
- **No detached HEAD** — Impossible by design.
- **No rebase** — Commits are durable. Use `fossil amend` to hide/close/retarget.
- **Autosync** — Auto-syncs on commit. Disable with `fossil set autosync 0`.
- **Sync is all-or-nothing** — Pushes/pulls branches, tags, wiki, tickets, forum, technotes.
- **Anonymous users default to `hz`** (read + zip) in new repos.

## Git → Fossil Quick Translation

| Git | Fossil |
|-----|--------|
| `git init` | `fossil init project.fossil` |
| `git clone URL` | `fossil clone URL project.fossil && fossil open project.fossil` |
| `git clone URL` (one-step) | `fossil open URL` | Clone + open in one command |
| `git checkout branch` | `fossil update branch` | `checkout` exists but `update` is preferred |
| `git pull` | `fossil update` | Pull + update working dir |
| `git push` | `fossil push` |
| `git add file` | `fossil add file` |
| `git commit -m "msg"` | `fossil commit -m "msg"` |
| `git status` | `fossil status` | Does NOT show unmanaged files; use `extras` |
| `git log` | `fossil timeline` | Shows all branches by default |
| `git diff` | `fossil diff` | No color by default |
| `git stash` | `fossil stash save` | Also has `snapshot`, `goto`, `rename` |
| `git cherry-pick C` | `fossil merge --cherrypick C` |
| `git revert C` | `fossil merge --backout C` |
| `git reset --hard` | `fossil up -f VERSION` |
| `git worktree add` | `fossil open repo.fossil branch` | Into empty dir |
| `git tag` | `fossil tag add NAME TAG` | Tags need not be unique |

## Workflows

### Single-User Setup
```bash
cd my-project
fossil init ~/museum/my-project.fossil
fossil open ~/museum/my-project.fossil
fossil add .
fossil commit -m "Initial commit"
fossil ui   # web UI at http://localhost:8080
```

### In-Place Init (like `git init`)
```bash
cd existing-project
fossil init .fsl
fossil open --force .fsl
fossil add .
fossil ci -m "Initial commit of project."
```

### Multi-User / Remote
```bash
fossil clone https://example.com/repo repo.fossil
fossil open repo.fossil

# Or one-step clone+open:
fossil open https://example.com/repo

# Daily workflow (autosync handles push/pull)
fossil up          # pull + update working dir
# ... edit ...
fossil ci -m "msg" # commit + auto-sync

# Manual sync (if autosync disabled)
fossil pull
fossil push
# or combined:
fossil sync

# Switch remote
fossil remote other-server.example.com/repo
# or named:
fossil remote add work https://dev-server.example.com/repo
fossil remote work
```

### Branching
```bash
# Preferred: create branch at point of need
fossil commit --branch feature-x --branchcolor 0xC0F0FF
# Alternative (discouraged): create ahead of need
fossil branch new feature-x
fossil up feature-x

# Merging
fossil merge          # merge fork (no auto-commit!)
fossil merge --cherrypick abc123
fossil merge --backout abc123
fossil merge --integrate --dry-run   # preview, close branch on commit

# Switching branches
fossil update trunk       # default main branch is 'trunk'
fossil checkout branch-name   # exists but update is preferred

# Branch management
fossil branch list --merged     # show merged branches
fossil branch close old-branch
fossil branch hide old-branch
fossil branch current           # print current branch name

# Private branches
fossil commit --branch my-tests --private   # stays local
```

### Fixing Mistakes (no `git reset`)
```bash
fossil amend --branch MISTAKE --hide --close -m "mea culpa" tip
fossil update trunk
```

### Stash (replaces Git index for partial commits)
```bash
fossil stash save -m "WIP feature"     # save and revert
fossil stash snapshot -m "WIP"        # save but keep working (no revert)
fossil stash list -v                     # list with file details
fossil stash diff                        # show as patch
fossil stash apply                       # apply, keep in stash
fossil stash pop                         # apply and remove
fossil stash goto ID                    # update to stash baseline + apply
fossil stash rename ID "new name"       # rename stash description
fossil stash drop ID                    # delete specific stash
fossil stash drop --a                    # delete ALL (not undoable!)

# Commit splitting (Git's `git add -p` equivalent)
fossil stash save -m 'big changes'
fossil stash diff > my-changes.patch
# ... edit the patch file ...
fossil stash apply
```

## Key Commands

```bash
# Repository
fossil init [FILE]          # create
fossil clone URL [FILE]      # clone
fossil open REPO [VER]       # open checkout (REPO can be URI for clone+open)
fossil open --empty            # empty checkout (new initial commit)
fossil open --keep             # only update manifest, leave files
fossil close [--force]        # dissociate checkout (--force if uncommitted)
fossil status / extras       # changed / unmanaged files

# Commit & History
fossil commit -m "msg" / fossil ci
fossil timeline [-b BRANCH] [-n N]
fossil time -v                # verbose (like git log --raw)
fossil info VERSION
fossil diff [--from A --to B] [--checkin V]
fossil describe HASH           # detailed artifact info
fossil amend V --branch NAME --hide --close --tag TAG
```

# Branching & Merging
fossil branch new NAME [V]    # create ahead of need (discouraged)
fossil branch list [--merged] [--unmerged] [-a] [-c]
fossil branch close NAME
fossil branch hide NAME
fossil branch current
fossil merge [--cherrypick V] [--backout V] [--integrate] [--dry-run]
fossil cherry-pick V           # alias for merge --cherrypick
fossil tag add NAME TAG        # tags need not be unique
fossil tag cancel NAME TAG
fossil tag find NAME
fossil checkout VERSION       # switch version (no remote pull; use `update` instead)
fossil checkout --latest       # checkout latest
```

# Sync & Remote
fossil remote [URL | NAME]    # show, switch, or add (URL switches to it)
fossil remote add NAME URL
fossil sync / push / pull / update
fossil up -n                   # dry run
```

# Stash
fossil stash save / snapshot / list / apply / pop / goto / drop / diff / rename
```

# Wiki
fossil wiki create|commit|export|list PAGENAME
fossil wiki create -t "Release notes"   # technote
```

# Tickets
fossil ticket add "Title" [FIELD VALUE]...
fossil ticket set <UUID> FIELD VALUE
fossil ticket show "Report" [FILTER]
```
fossil ticket add "Title" [FIELD VALUE]...
fossil ticket set <UUID> FIELD VALUE
fossil ticket show "Report" [FILTER]

# Search
fossil search -a "query"        # all content
fossil search --wiki --tickets "query"
fossil search -n 20 "query"    # limit results
```

# Chat
fossil chat send -m "msg"
fossil chat pull / purge / reindex / url
```

# File Management
fossil add FILE
fossil rm FILE [--hard]
fossil mv OLD NEW [--hard]
fossil addremove           # add unmanaged, remove missing
fossil clean [--dry-run]   # remove unmanaged (destructive!)
```

# Multi-repo
fossil all sync / push / pull / list / changes / rebuild / repack
fossil all add repo.fossil / ignore repo.fossil
fossil all server / ui / git status
```

# Maintenance
fossil rebuild / repack / verify / scrub / dbstat / fts-config
```

## Gotchas

- **`fossil sync` syncs ALL artifacts**, wiki, tickets, forum, technotes, not just code. There is no push only commits.
- **No `git reset --hard`** — use `fossil up -f VERSION` or `fossil amend --hide --close`.
- **Tags and branch names need not be unique** — Fossil resolves ambiguity by newest match (e.g., `fossil up release` gets the latest release tag).
- **Default main branch is `trunk`**, not `master` or `main`. `fossil git export` maps trunk to master by default; use `--mainbranch` to change.
- **`fossil open URL` clones+opens in one step**, e.g., `fossil open https://example.com/repo`
- **`fossil checkout` exists but `fossil update` is preferred** — `checkout` does not pull from remote; `update` does.
- **`fossil close` refuses with uncommitted changes or non-empty stash** — requires `--force`.
- **`fossil amend` does not modify the commit** — it inserts metadata records to change how the commit displays. The hash is unchanged. Amendments do not autosync.
- **`fossil stash drop --a` is NOT undoable** — individual drops are undoable, but `--all` is permanent.
- **`fossil merge` can take multiple VERSION arguments** — each is merged in order. Use `-n` for dry-run first.
- **`fossil mv`/`fossil rm` are soft by default** — add `--hard` to actually rename/delete on disk. Set `mv-rm-files 1` to change default.
- **`fossil status` does NOT show unmanaged files** — use `fossil extras` for that.
- **`fossil push` without `--once` to Chiselapp does bidirectional sync** — initial push should use `--once`.
- **Check-in comments only support Fossil wiki markup** (not Markdown). Wiki pages and tickets support both.

## When to Load What

- **Need a command syntax?** → Read `references/commands.md`
- **Working with wiki/tickets/forum?** → Read `references/wiki.md`, `references/tickets.md`, `references/forum-chat.md`
- **Setting up a server or Chiselapp?** → Read `references/server.md`
- **Configuring Fossil?** → Read `references/configuration.md`
- **Advanced operations?** → Read `references/advanced.md`
- **Repository maintenance?** → Read `references/maintenance.md`
- **Understanding Fossil concepts/architecture?** → Read `references/concepts.md` (check-ins, artifacts, manifests, autosync, backups)
- **Customizing the web UI?** → Read `references/skins-customization.md` (skins, CSS, TH1, headers/footers)
- **Understanding sync behavior?** → Read `references/sync-protocol.md` (autosync, wire protocol, what doesn't sync)

## Official Docs

- **Fossil Book**: https://fossil-scm.org/schimpf-book
- **Git to Fossil**: https://fossil-scm.org/home/doc/tip/www/gitusers.md
- **Command Reference**: https://fossil-scm.org/schimpf-book/uv/FossilBook.html#fossil-commands
- **Chiselapp Hosting**: https://fossil-scm.org/schimpf-book/uv/FossilBook.html#chiselapp
- **Glossary**: https://fossil-scm.org/home/doc/tip/www/glossary.md
- **Fossil vs Git**: https://fossil-scm.org/home/doc/tip/www/fossil-v-git.wiki
- **Concepts**: https://fossil-scm.org/home/doc/tip/www/concepts.wiki
- **Forum**: https://fossil-scm.org/forum
