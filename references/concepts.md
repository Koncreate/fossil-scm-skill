# Core Concepts & Architecture

## Project

A collection of one or more computer files serving a unified purpose that evolves over time, with history being a valuable record. Fossil requires all files for a project be in a single directory hierarchy owned by a single user.

**Good uses**: Software projects, fiction books, documentation, Vim configuration (`~/.vim`).

**Bad uses**: OS configuration files (scattered across filesystem, complex permissions), whole-system backups.

## Repository

A single file (`.fossil`) containing all historical versions of all files in a project. Repositories can be cloned and synced between machines.

- Repository files are just files — move, rename, copy them anywhere
- `.fossil` extension is traditional but only required for `fossil server DIRECTORY`
- Cloned repos redundantly store all available project information
- If one repo is lost, all cloned historical content is preserved in surviving repos
- Repositories don't track their source trees — free to delete/move source trees without consequence
- But if you move/rename/delete a repository, associated source trees lose their connection

## Check-in (Version / Revision / Hash)

A snapshot of the project at an instant in time, committed to the repository. Check-ins are **immutable** — once created, they cannot be changed (only hidden/closed via amendments).

- Each check-in has a unique SHA1/SHA3-256 hash (the "artifact ID" of its manifest)
- You can reference any check-in by a unique prefix of its hash (4+ characters)
- Fossil typically displays the first 10 digits
- Check-ins exist only inside the repository
- A check-in may have multiple names (tags, branches), but only the hash is globally unique

**Terminology**: "Version," "revision," "hash," and "UUID" are all used interchangeably in Fossil, though "UUID" is deprecated (Fossil hashes don't follow UUID standards).

## Check-out

A set of files extracted from a repository representing a particular check-in. Unlike a check-ins, check-outs are **mutable**.

- You can modify files in a check-out, then commit to create a new immutable check-in
- Switch between check-ins with `fossil update`
- One repository can have multiple check-out directories (e.g., `trunk/`, `release/`, `scratch/`)
- Check-outs are associated with repos via `.fslckout` file (POSIX) or `_FOSSIL_` file (Windows)
- Repository must be on the same machine as the check-out (SQLite requirement)

## Artifact

A particular version of a particular file, identified by its SHA1/SHA3-256 hash (artifact ID).

- Changing a single byte creates a completely different artifact ID
- Artifacts are immutable — the foundation of Fossil's integrity
- A repository is an unordered collection of artifacts
- New artifacts can be added; existing ones can never be removed (except via shunning)
- Fossil can reconstruct complete project history from artifacts in any order

## Manifest

A special file associated with every check-in that lists all other files in that source tree.

- Contains artifact IDs and disk names for every file in the check-in
- The artifact ID of the manifest IS the identifier for the entire check-in
- Also contains: check-in comment, timestamp, author, parent links, checksums
- May be PGP clearsign
- Not normally a materialized file on disk (computed in memory)
- Can be materialized with `fossil setting manifest 1` (useful for embedding version info in builds)

## Autosync

Fossil automatically syncs (push + pull) on every commit. This is the default behavior.

- **Enabled by default** — every `fossil commit` triggers a sync
- Disable with `fossil set autosync 0` for Git-like manual push behavior
- **Intransitive** — if A syncs with B, and B syncs with C, changes don't automatically flow A→C
- This is an "AP mode" system (eventual consistency), not strongly consistent
- Push = local → remote, Pull = remote → local, Sync = both directions

## Unversioned Files (UV Files)

Artifacts that sync across repositories but don't preserve history. Only the most recent version is retained.

```bash
fossil uv add FILE                   # add/update unversioned file
fossil uv add FILE --as UVFILE       # add with different name in repo
fossil uv cat FILE                   # print content to stdout
fossil uv export FILE OUTPUT         # write content to disk
fossil uv list                       # list all unversioned files
fossil uv list --glob "*.pdf"        # filter by pattern
fossil uv edit FILE                  # edit in text editor
fossil uv remove FILE                # remove from repository
fossil uv sync                       # sync with remote (requires 'y' capability)
fossil uv revert                     # restore to match remote state
fossil uv touch FILE                 # update timestamp
```

**Use cases**: Binary assets, build outputs, large files that don't need versioning.

**Caveat**: Changes are permanent and cannot be undone. Use with caution.

## Shunning

The mechanism for removing artifacts from a repository. Discouraged except for spam or inappropriate content.

- Shunned artifacts don't sync to clones
- Requires `fossil rebuild` to fully remove from local database
- Used internally for rejecting moderated forum posts

## Private Branches

Branches that stay local and don't sync to remotes.

```bash
fossil commit --branch my-tests --private   # create private branch
fossil merge --private VERSION              # merge private branch
fossil sync --private                       # sync private branches
```

- Require `x` (Private) capability to push
- Useful for experimental work, personal notes, WIP features
- Not included in normal clones (only Setup users get full clones)

## Hash Policy

Fossil supports two hash algorithms:

- **SHA1** (legacy, 160-bit, 40 hex chars) — pre-Fossil 2.0 default
- **SHA3-256** (current default, 256-bit, 64 hex chars) — Fossil 2.0+

The hash policy determines which algorithm is used for new repositories. Existing repos keep their original algorithm.

## Backup Strategies

### Method 1: Sync-Based Backup (Setup user required)

```bash
fossil sync --unversioned
fossil configuration pull all
fossil rebuild
```

Gets nearly everything but misses private branches and SQL-level customizations.

### Method 2: SQL-Level Backup (SSH access required)

```bash
# On remote server
fossil backup -R repo.fossil backups/repo-$(date +%Y-%m-%d).fossil

# Or via SSH
ssh example.com "cd museum ; fossil backup -R repo.fossil backups/repo.fossil"
```

Gets everything including private branches. Safe to run on in-use repositories.

### Encrypted Off-Site Backups

```bash
iter=152830
pass="YOUR_ENCRYPTION_PASSWORD_HERE"  # ⚠️ Use env var or prompt — never hardcode real passwords
fossil sql -R repo.fossil .dump | xz -9 |
    openssl enc -e -aes-256-cbc -pbkdf2 -iter $iter -pass pass:"$pass" -out backup.enc
```
```

### What Doesn't Sync by Default

- **User table** (except for Setup users — privacy/security)
- **Skin configuration** (intentional — local customization)
- **Email alert settings** (prevents duplicate notifications)
- **Project configuration** (prevents accidental repo merging)
- **URL aliases, interwiki, ticket customizations**
- **Private branches** (by design)
- **Shunned artifacts** (by design)
- **Unversioned files** (requires `--unversioned` flag)

## Fossil Is a Single Executable

- Self-contained — no dependencies required
- No need for CVS, gzip, diff, rsync, Python, Perl, Tcl, Java, Apache, PostgreSQL, MySQL, etc.
- Optional: text editor (VISUAL/EDITOR env var), GPG (for signing), Tcl/Tk (for GUI diff)
- Install: put `fossil` binary on $PATH
- Uninstall: delete the binary
- Upgrade: replace binary, then `fossil all rebuild`
