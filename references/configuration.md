# Configuration

## Settings Command

```bash
fossil settings                          # list all settings
fossil settings autosync                 # show one setting
fossil set autosync 1                    # set (local)
fossil setting --global autosync 0       # set global
fossil setting --global --value autosync # show global value
fossil unset autosync                    # remove local setting
fossil settings --changedOnly            # only non-default values
fossil settings --exact autosync         # exact name match
```

Settings marked as **versionable** are overridden by `.fossil-settings/PROPERTY` files in the checkout root.

## Common Settings

### Behavior Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `autosync` | 1 | Auto-sync on commit (set 0 for Git-like manual push) |
| `mv-rm-files` | 0 | Make `mv`/`rm` hard (actually delete/rename on disk) |
| `editor` | (system) | Commit message editor |
| `gpg` | (none) | GPG signing command |
| `crnl-glob` | (none) | Files to normalize line endings (e.g., `*.txt`) |
| `empty-dirs` | (none) | Allow tracking empty directories (e.g., `node_modules`) |
| `large-file-size` | 10485760 | Warn on files > 10MB (v2.18+) |
| `max-loadavg` | (none) | Skip HTTP requests if load average exceeds this |
| `binary-glob` | (none) | Files to treat as binary (no diff) |
| `forbid-delta-manifest` | 0 | Forbid delta manifests (v2.22+) |
| `ticket-table` | (none) | Custom ticket table schema |
| `ticket-common` | (none) | Common fields for all ticket types |
| `ticket-changeview` | 0 | Show ticket changes in timeline |
| `timeline-utc` | 0 | Show timeline in UTC instead of local time |

### Display Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `timeline-max-comment` | 0 | Truncate timeline comments (0 = no limit) |
| `timeline-plaintext` | 0 | Show plaintext instead of formatted comments |
| `timeline-truncate-at-blank` | 0 | Truncate at first blank line |
| `timeline-hard-newlines` | 0 | Preserve hard newlines |
| `timeline-non-wiki` | 0 | Allow non-wiki markup in comments |
| `timeline-date-format` | (none) | Custom date format string |
| `timeline-block-markup` | 0 | Allow block markup in comments |
| `timeline-dwelltime` | 500 | Hover dwell time for timeline (ms) |
| `timeline-minor-interval` | 10 | Minor tick interval (seconds) |

### Email Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `email-url` | (none) | URL of the Fossil instance (for email links) |
| `email-from` | (none) | From address for outgoing email |
| `email-admin` | (none) | Admin email address |
| `smtp-server` | (none) | SMTP server for outgoing email |
| `smtp-port` | 25 | SMTP port |
| `smtp-login` | (none) | SMTP username |
| `smtp-password` | (none) | SMTP password |
| `smtp-mimetype` | text/plain | MIME type for email notifications |
| `email-send-command` | (none) | External command to send email |
| `email-self` | 0 | Send email to self |

### Skin & CSS

| Setting | Default | Description |
|---------|---------|-------------|
| `skin` | (none) | Default skin label |
| `css` | (none) | Custom CSS to inject |
| `header` | (none) | Custom header template |
| `footer` | (none) | Custom footer template |
| `logo-mimetype` | (none) | Logo image MIME type |
| `logo-image` | (none) | Logo image (base64) |
| `icon-mimetype` | (none) | Favicon MIME type |
| `icon-image` | (none) | Favicon image (base64) |
| `background-mimetype` | (none) | Background image MIME type |
| `background-image` | (none) | Background image (base64) |

### Project Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `project-name` | (none) | Project name |
| `project-code` | (auto) | Project code UUID |
| `project-description` | (none) | Project description |
| `index-page` | (none) | Custom index page (e.g., `/wiki?name=home`) |
| `manifest` | 0 | Include manifest in repository |
| `short-project-name` | (none) | Short project name |

### Security Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `localauth` | 0 | Enable auto-login for localhost |
| `redirect-to-https` | 0 | Redirect HTTP to HTTPS |
| `ssl-cert` | (none) | TLS certificate path |
| `ssl-key` | (none) | TLS private key path |
| `th1-docs` | 0 | Enable TH1 embedded documents (security risk!) |
| `user-capabilities` | (none) | Default capabilities for new users |
| `web-browser` | (none) | Path to web browser for `fossil ui` |

### Wiki & Tickets

| Setting | Default | Description |
|---------|---------|-------------|
| `wiki-about-page-status` | 0 | Show wiki page in timeline "About" |
| `wiki-max-upload` | (none) | Max wiki upload size (bytes) |
| `ticket-default-report` | (none) | Default ticket report ID |
| `ticket-default-table` | (none) | Default ticket table view |
| `ticket-nl-after` | 0 | Newlines after ticket comments |
| `ticket-login` | 0 | Require login to view tickets |
| `ticket-mimetype` | (none) | Default ticket comment MIME type |

### Forum Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `forum-close-days` | (none) | Auto-close forum after N days |
| `forum-keep-days` | (none) | Keep forum posts for N days |
| `forum-keep-count` | (none) | Keep at most N forum posts |
| `forum-no-approve` | 0 | Don't require moderation for forum posts |
| `forum-title` | (none) | Forum title |

### Chat Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `chat-initial-history` | 0 | Number of chat messages to show initially |
| `chat-keep-count` | (none) | Max chat messages to keep |
| `chat-keep-days` | (none) | Days to keep chat messages |
| `chat-delete-days` | (none) | Days before auto-deleting chat |
| `chat-mimetype` | (none) | Chat message MIME type |

### Search Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `search-max-results` | (none) | Max search results to return |
| `fts-content` | (none) | FTS content table name |

### Versionable Settings

These are stored in the repository and propagate on sync. Can be overridden by `.fossil-settings/PROPERTY` files:

- `autosync`
- `editor`
- `large-file-size`
- `empty-dirs`
- `crnl-glob`
- `binary-glob`
- `max-loadavg`
- `ticket-table`
- `ticket-common`
- `ticket-changeview`
- `timeline-utc`
- `timeline-max-comment`
- `timeline-plaintext`
- `timeline-truncate-at-blank`
- `timeline-hard-newlines`
- `timeline-non-wiki`
- `timeline-date-format`
- `timeline-block-markup`
- `timeline-dwelltime`
- `timeline-minor-interval`
- `wiki-about-page-status`
- `wiki-max-upload`
- `ticket-default-report`
- `ticket-default-table`
- `ticket-nl-after`
- `ticket-login`
- `ticket-mimetype`
- `forum-close-days`
- `forum-keep-days`
- `forum-keep-count`
- `forum-no-approve`
- `forum-title`
- `chat-initial-history`
- `chat-keep-count`
- `chat-keep-days`
- `chat-delete-days`
- `chat-mimetype`
- `search-max-results`
- `fts-content`

## Per-Repo vs Global

- `fossil set KEY VALUE` — applies to current repository only (stored in `.fossil` DB)
- `fossil setting --global KEY VALUE` — applies to all repositories (stored in `~/.fossil` or `%LOCALAPPDATA%\_fossil`)
- `fossil unset KEY` — remove a local setting
- `fossil settings` — list all current settings (local overrides global)

Local values take precedence over global values.

## Configuration Import/Export

```bash
# Export configuration areas
fossil configuration export all config.txt
fossil configuration export email email.txt
fossil configuration export skin skin.txt
fossil configuration export ticket ticket.txt
fossil configuration export user users.txt
fossil configuration export interwiki interwiki.txt
fossil configuration export project project.txt
fossil configuration export shun shun.txt
fossil configuration export alias alias.txt
fossil configuration export subscriber sub.txt

# Import (overwrite)
fossil configuration import config.txt

# Import (merge, existing values win)
fossil configuration merge config.txt

# Pull from remote
fossil configuration pull all https://remote.example.com/repo

# Push to remote (requires admin on remote)
fossil configuration push all https://remote.example.com/repo

# Sync with remote
fossil configuration sync all https://remote.example.com/repo

# Reset to defaults
fossil configuration reset all
```

## User Configuration

```bash
fossil user default NAME               # Set default user for commits
fossil user default -v                 # Show how default user is computed
fossil user default ""                 # Unset default user
fossil user list                       # List all users
fossil user ls                         # Alias for list
fossil user new NAME [CONTACT] [PASS]  # Create user (never deletable!)
fossil user password NAME [PASS]       # Change password
fossil user capabilities USER [STRING] # Get/set capabilities
fossil user contact USER [INFO]        # Get/set contact info
```

Default user resolution order:
1. `fossil user default` setting
2. `-U` command-line option
3. `FOSSIL_USER` environment variable
4. `USER` environment variable
5. `LOGNAME` environment variable
6. `USERNAME` environment variable
7. OS user account name

## Access Control (Capabilities)

Fossil uses capability letters for access control. Caps are **case-sensitive** (`A` ≠ `a`).

### User Categories

Four fixed categories with hierarchical capability inheritance:

```
Setup ≥ Admin ≥ Moderator ≥ (Developer or Reader) ≥ Subscriber ≥ Anonymous ≥ Nobody
```

| Category | Default Caps | Description |
|----------|-------------|-------------|
| **Nobody** | `gjorz` | Unauthenticated visitors (better named "everybody") |
| **Anonymous** | `+hmnc` | Logged-in as anonymous (better named "user") |
| **Reader** | `+kptw` | Identified users, passive role (better named "participant") |
| **Developer** | `+ei` | Can check in changes, view PII |
| **Setup** | (all) | All-powerful superuser |
| **Admin** | (all except s) | Administrative access |

### Individual Capability Letters

| Letter | Name | Description |
|--------|------|-------------|
| `a` | Admin | All capabilities except Setup, Private, WrUnver |
| `b` | Attach | Add attachments to wiki/technotes/tickets |
| `c` | ApndTkt | Append comments to existing tickets |
| `d` | (legacy) | **Remove this** — CVSTrac legacy, no meaning in Fossil |
| `e` | RdAddr | View PII (email addresses) of other users |
| `f` | NewWiki | Create new wiki articles |
| `g` | Clone | Clone the repository (distinct from Read) |
| `h` | Hyperlink | Get hyperlinks in generated HTML (deny to prevent bot crawling) |
| `i` | Write | Check in changes (also grants Read) |
| `j` | RdWiki | View wiki articles |
| `k` | WrWiki | Edit wiki articles (grants RdWiki + ApndWiki, but NOT NewWiki) |
| `l` | ModWiki | Moderate wiki appends |
| `m` | ApndWiki | Append to existing wiki articles |
| `n` | NewTkt | File new tickets |
| `o` | Read | Read file content/history over HTTP (distinct from Clone) |
| `p` | Password | Change own password |
| `q` | ModTkt | Moderate tickets (delete comments) |
| `r` | RdTkt | View existing tickets |
| `s` | Setup | All-powerful superuser |
| `t` | TktFmt | Create new ticket report formats (read-only SQL) |
| `u` | (category) | Inherit Reader category caps |
| `v` | (category) | Inherit Developer category caps |
| `w` | WrTkt | Edit tickets (grants RdTkt + ApndTkt + NewTkt) |
| `x` | Private | Push/pull private branches |
| `y` | WrUnver | Push unversioned content |
| `z` | Zip | Pull zip/tarball/sqlar archives (expensive!) |
| `2` | RdForum | Read forum posts |
| `3` | WrForum | Create forum posts (held for moderation) |
| `4` | WrTForum | Create forum posts (bypass moderation) |
| `5` | ModForum | Moderate forum posts (grants WrTForum + RdForum) |
| `6` | AdminForum | Trust users to bypass moderation |
| `7` | EmailAlert | Sign up for email alerts |
| `A` | Announce | Send email announcements |
| `B` | Attach (Forum) | Add attachments to forum posts |
| `C` | Chat | Access chat room |
| `D` | Debug | Enable debugging features |
| `L` | Is-logged-in | Not a real cap; used in capexpr checks |

### Key Capability Relationships

- `i` (Write) grants `o` (Read) automatically
- `k` (WrWiki) grants `j` (RdWiki) + `m` (ApndWiki)
- `w` (WrTkt) grants `r` (RdTkt) + `c` (ApndTkt) + `n` (NewTkt)
- `5` (ModForum) grants `4` (WrTForum) + `2` (RdForum)
- `6` (AdminForum) grants `5` (ModForum) + everything it grants
- `a` (Admin) grants everything except `s`, `x`, `y`

### Important Notes

- **Caps affect web interfaces only** — local operations are governed by OS file permissions
- **Users can never be deleted** — only denied all access
- **Taking a repo private** clears Nobody and Anonymous caps — reassign to other categories first!
- **Read ≠ Clone** — Read prevents web browsing of files/history; Clone prevents downloading the repo
- **New repos** create one user (OS username) with Setup capability
- **Anonymous login** gives the "anonymous" category caps (hmnc added to nobody's gjorz)

## Login Groups

Login groups share user credentials across multiple repositories.

```bash
fossil login-group                      # Show current login group
fossil login-group join other-repo.fossil  # Join existing group
fossil login-group join --name mygroup other-repo.fossil  # Create new group
fossil login-group leave                 # Leave current group
```

When a user changes their password in one member, it changes in all members. Users must exist in each member's USER table.

## Interwiki Configuration

Define interwiki prefixes in Admin → Wiki (or via `fossil configuration`):

```
fossil configuration export interwiki prefixes.txt
# Edit prefixes.txt, then:
fossil configuration import prefixes.txt
```

Built-in prefixes: `forum:`, `wikipedia:`

## Custom TH1 Configuration

For advanced users, Fossil's TH1 scripting language can extend functionality:

```bash
# Check if TH1 docs are enabled
fossil settings th1-docs

# Enable (requires --with-th1-docs build)
fossil set th1-docs 1
```

**Warning**: TH1 docs grant server-side code execution to anyone with check-in privilege.
