# Sync Protocol & Autosync

## Autosync Setting

The `autosync` setting controls when automatic synchronization occurs. It's a comma-separated list of `VALUE` and `COMMAND=VALUE` entries.

### Values

| Value | Behavior |
|-------|----------|
| `on` | Always autosync for commands where it makes sense (commit, merge, open, update) |
| `off` | Never autosync |
| `pullonly` | Only do pull autosyncs (not push) |
| `all` | Sync with all remotes (not just default) |

### Command-Specific Overrides

```bash
fossil set autosync on                    # default: sync on commit/merge/open/update
fossil set autosync off                   # never autosync (Git-like manual push)
fossil set autosync pullonly              # only pull, never auto-push
fossil set autosync all                   # sync with ALL remotes
fossil set autosync "on,open=off"         # sync on most commands, but not on open
fossil set autosync "off,commit=pullonly" # no autosync except pull before commit
```

### When Autosync Triggers

- **`fossil commit`** — syncs after committing
- **`fossil merge`** — syncs before merging (to get latest)
- **`fossil open`** — syncs after opening
- **`fossil update`** — syncs before updating

### Intransitive Sync

Autosync is **not transitive**. If A syncs with B, and B syncs with C:
- Changes flow A → B automatically
- Changes do NOT flow A → C automatically
- C must sync with B to get A's changes

This is an "AP mode" system (eventual consistency). For failover servers, set up explicit bidirectional sync.

## Sync Commands

```bash
fossil sync                               # push + pull with default remote
fossil sync --unversioned                 # also sync unversioned files
fossil sync --private                     # also sync private branches
fossil sync --all                         # sync with all remotes
fossil sync --once                        # don't remember URL
fossil sync --ping                        # just verify server is alive
fossil sync --verbose                     # debug output
fossil sync -v -v                         # network debug output
fossil sync --verily                      # extra verification
fossil sync --no-http-compression         # disable compression
fossil sync -B user:pass                  # ⚠️ HTTP Basic Auth — prefer interactive prompt to avoid exposing credentials in process list
fossil sync --proxy PROXY                 # HTTP proxy
fossil sync --ssh-command "ssh -i key"   # custom SSH command
fossil sync --transport-command CMD       # external transport
fossil sync --ssl-identity FILE           # SSL client cert
fossil sync -R repo.fossil                # sync specific repository
```

### Push

```bash
fossil push                               # push to default remote
fossil push --private                     # also push private branches
fossil push --all                         # push to all remotes
fossil push --once                        # don't remember URL
```

### Pull

```bash
fossil pull                               # pull from default remote
fossil pull --force                       # pull even with local changes
fossil pull --integrate                   # merge pulled changes immediately
```

## Sync Protocol (Wire Protocol)

Fossil synchronization uses HTTP-based protocol between client and server.

### Transport Methods

1. **HTTPS** — Standard HTTP requests with TLS encryption
2. **HTTP** — Unencrypted (not recommended for production)
3. **SSH** — HTTP tunneled through SSH (uses `test-http` on remote)
4. **FILE** — Local file-based transport (for `file:` URLs)
5. **SCGI** — SCGI protocol (for nginx/apache integration)
6. **CGI** — CGI mode (for any web server)

### SSH Transport Details

```bash
# Standard SSH sync
fossil clone ssh://user@host//path/to/repo.fossil

# With custom fossil path on remote
fossil clone ssh://host//repo.fossil?fossil=/usr/local/bin/fossil

# With custom SSH command
fossil clone -c "ssh -i ~/.ssh/key -p 2222" ssh://host//repo.fossil
```

SSH sync works by running `fossil test-http` on the remote machine and tunneling HTTP requests through the SSH connection.

**Common issue**: SSH daemon's PATH may differ from interactive shell PATH. If `fossil` isn't found on remote, use the `?fossil=` URL parameter.

### FILE Transport Details

For `file:` URLs, Fossil writes HTTP requests to temp files and runs `fossil http` in a subprocess. This avoids network overhead for local repositories.

### Protocol Flow

1. **Login** — Client sends login card with userid, nonce, signature
2. **Artifact Exchange** — Share hash lists, then transfer missing artifacts
3. **Completion** — Verify integrity, update local state

Content type: `application/x-fossil` (compressed) or `application/x-fossil-debug` (uncompressed).

### Server URL

The sync endpoint is the repository URL + `/xfer`:
```
https://example.com/repo → https://example.com/repo/xfer
```

## What Syncs (Global State)

- Check-ins (code)
- Wiki pages
- Tickets
- Forum posts
- Technotes
- Tags
- Branches

## What Doesn't Sync by Default (Local State)

| Item | Why |
|------|-----|
| User table (full) | Privacy/security (only Setup users get full copy) |
| Skin configuration | Intentional local customization |
| Email alert settings | Prevents duplicate notifications |
| Project configuration | Prevents accidental repo merging |
| URL aliases | Local configuration |
| Interwiki configuration | Local configuration |
| Ticket customizations (schema) | Local configuration |
| Private branches | By design (use `--private`) |
| Shunned artifacts | By design |
| Unversioned files | Use `--unversioned` flag |

## Configuration Sync

```bash
# Pull specific config areas from remote
fossil configuration pull all
fossil configuration pull skin
fossil configuration pull ticket
fossil configuration pull user
fossil configuration pull email
fossil configuration pull interwiki
fossil configuration pull project
fossil configuration pull shun
fossil configuration pull alias
fossil configuration pull subscriber

# Push config to remote (requires admin on remote)
fossil configuration push skin
fossil configuration push ticket

# Export/import config (between different projects)
fossil configuration export skin skin.txt
fossil configuration import skin.txt
fossil configuration merge skin.txt  # merge, existing values win

# Reset to defaults
fossil configuration reset all
```

## Unversioned Files (UV) Sync

```bash
# Clone with unversioned files
fossil clone --unversioned URL repo.fossil

# Sync unversioned files
fossil sync --unversioned

# Push unversioned files (requires 'y' capability)
fossil uv sync
```

## Private Branch Sync

```bash
# Create private branch
fossil commit --branch my-wip --private

# Sync private branches
fossil sync --private

# Push private branches (requires 'x' capability)
fossil push --private
```

## Debugging Sync

```bash
# HTTP trace
fossil sync --httptrace

# SSH trace
fossil sync --sshtrace

# Verbose output
fossil sync -v
fossil sync -v -v  # network-level debug

# Dry run (ping)
fossil sync --ping

# Extra verification
fossil sync --verily
```
