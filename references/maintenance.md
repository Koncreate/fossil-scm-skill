# Repository Maintenance

## Rebuild

Reconstruct the database from core records. Required after upgrading Fossil versions that change the database schema.

```bash
fossil rebuild                             # rebuild current repository
fossil rebuild repo.fossil                 # rebuild specific repository
fossil all rebuild                          # rebuild all tracked repos
```

### Rebuild Options

- `--analyze` — Run ANALYZE after rebuilding (updates query planner statistics)
- `--cluster` — Compute clusters for unclustered artifacts
- `--compress` — Make database as small as possible
- `--compress-only` — Skip rebuild, only compress (same as `fossil repack`)
- `--force` — Complete rebuild even if errors are seen
- `--ifneeded` — Only rebuild if schema version would change
- `--index` — Always add full-text search index
- `--noverify` — Skip verification of BLOB table changes
- `--noindex` — Always omit full-text search index
- `--pagesize N` — Set database page size (512..65536, power of 2)
- `--quiet` — Only show output if there are errors
- `--stats` — Show artifact statistics after rebuilding
- `--vacuum` — Run VACUUM after rebuilding
- `--wal` — Enable Write-Ahead-Log journal mode

## Repack

Optimize storage by recompressing artifacts:

```bash
fossil repack                              # compress current repo
fossil repack repo.fossil                  # compress specific repo
fossil all repack                           # compress all repos
```

Equivalent to `fossil rebuild --compress-only`. Performs extra delta-compression to minimize repository size.

## Verify

Check repository integrity:

```bash
fossil verify                              # verify database integrity
fossil dbstat --db-check                   # run PRAGMA quick_check
fossil dbstat --db-verify                  # full verification (decode + reparse all artifacts)
```

Full verification decodes and reparses every artifact. This can take significant time on large repositories.

## Scrub

Remove sensitive data from a repository (e.g., before sharing with untrusted parties):

```bash
fossil scrub                               # interactive scrub (prompts for confirmation)
fossil scrub --force                        # non-interactive
fossil scrub --private                      # only remove private branches
fossil scrub --verily                       # thorough scrub (passwords + private branches + concealed email/IP addresses)
fossil scrub repo.fossil                    # scrub specific repository
fossil all scrub                            # scrub all tracked repos
```

**WARNING**: This command permanently deletes scrubbed information. Effects are IRREVERSIBLE.

## Database Statistics

```bash
fossil dbstat                              # show database statistics
fossil dbstat -b                           # brief (essential elements only)
fossil dbstat --db-check                   # quick_check only
fossil dbstat --db-verify                  # full verification
fossil dbstat --omit-version-info          # omit version headers
fossil all dbstat                           # stats for all repos
```

## FTS Index (Full-Text Search)

```bash
fossil fts-config                          # show current settings
fossil fts-config index on                 # enable search index
fossil fts-config index off                # disable search index
fossil fts-config reindex                  # rebuild search index
fossil fts-config enable all               # enable all search types
fossil fts-config enable check-in ticket   # enable specific types
fossil fts-config disable forum            # disable forum search
fossil fts-config tokenizer porter         # set tokenizer (porter, trigram, unicode61, off)
```

Search types: `check-in`, `document`, `ticket`, `wiki`, `technote`, `forum`, `help`, `all`

Tokenizers:
- `porter` (default) — English stemming
- `on` — same as porter
- `trigram` — good for CJK text and code
- `unicode61` — Unicode-aware, no stemming
- `off` — no tokenization (exact match only)

## Clean (Remove Unmanaged Files)

```bash
fossil clean                               # remove unmanaged files (with prompts)
fossil clean --dry-run                      # preview what would be removed
fossil clean --force                        # remove without prompting
fossil clean --verily                       # remove EVERYTHING unmanaged
fossil clean --temp                         # remove only Fossil temp files
fossil clean --keep "*.log"                 # keep files matching pattern
fossil clean --ignore "*.tmp"               # ignore files matching pattern
fossil clean --dotfiles                     # include dotfiles
fossil clean --emptydirs                    # remove empty directories
fossil clean --dirsonly                     # only remove empty directories
fossil clean --no-prompt                    # answer 'no' to all prompts
fossil clean --disable-undo                 # disable undo for this operation
fossil clean -v                             # verbose
fossil all clean                            # clean all tracked repos
```

Default glob patterns controlled by versionable settings: `clean-glob`, `ignore-glob`, `keep-glob`.

**Note**: `fossil clean` only saves undo state for files < 10MiB.

## Extras (List Unmanaged Files)

```bash
fossil extras                               # list unmanaged files
fossil extras --abs-paths                   # absolute paths
fossil extras --rel-paths                   # relative paths
fossil extras --dotfiles                    # include dotfiles
fossil extras --header                      # identify the repository
fossil extras --tree                        # tree format
fossil extras --ignore "*.tmp"              # override ignore patterns
fossil extras src/                          # only check specific directory
fossil all extras                           # extras for all repos
```

## Changes (Modified File Status)

```bash
fossil changes                              # list modified files (what would be committed)
fossil changes --abs-paths                  # absolute paths
fossil changes --rel-paths                  # relative paths
fossil changes --by-type                    # group by change type
fossil changes --by-zone                    # group by directory
fossil changes --merge                      # show merge contributors
fossil changes --no-merge                   # hide merge contributors
fossil changes ADDED                        # show only added files
fossil changes DELETED                      # show only deleted files
fossil changes EDITED                       # show only edited files
fossil changes RENAMED                      # show only renamed files
fossil changes MISSING                      # show only missing files
fossil changes CONFLICT                     # show only conflicting files
fossil changes EXTRA                        # show only extra files
fossil changes EXECUTABLE                   # show only permission changes
fossil changes PRIVATE                      # show only private files
fossil changes UNPUSHED                     # show only unpushed files
fossil changes UNVERSIONED                  # show only unversioned files
```

## Status

```bash
fossil status                               # concise status with header/footer
fossil status --abs-paths                   # absolute paths
fossil status --rel-paths                   # relative paths
```

Unlike `changes`, `status` includes header info (branch, commit) and footer (fork detection, autosync status).

## Multi-Repo Operations (`fossil all`)

```bash
fossil all sync                            # sync all tracked repos
fossil all push                            # push all repos
fossil all pull                            # pull all repos
fossil all changes                         # modified files in all checkouts
fossil all extras                          # extras in all checkouts
fossil all clean                           # clean all checkouts
fossil all rebuild                         # rebuild all repos
fossil all repack                          # repack all repos
fossil all info                            # info for all repos
fossil all remote                          # show remote hosts for all repos
fossil all settings                        # run settings command on all repos
fossil all fts-config                      # FTS config for all repos
fossil all dbstat                          # stats for all repos
fossil all git status                      # Git mirror status for all repos
fossil all git export                      # Git export for all repos
fossil all backup /path/to/dir             # backup all repos to directory
fossil all server                          # serve all repos (root URI lists them)
fossil all ui                              # UI for all repos (local only, auto-login)
fossil all set autosync 0                  # set on all repos
fossil all unset autosync                  # unset on all repos
```

Repositories are tracked in `~/.fossil` (or `%LOCALAPPDATA%\_fossil` on Windows).
