# Forum & Chat

## Forum

Fossil's built-in discussion forum provides asynchronous team communication, designed as a replacement for mailing lists.

### Advantages

- **Easy to Administer** — same login/password as the rest of Fossil
- **Consistent Display** — Markdown, Fossil Wiki, or plain text rendered uniformly
- **Editable** — posts can be amended after sending; originals preserved in history
- **Full-Text Search** — forum posts included in Fossil's search index
- **Offline Access** — posts sync with clones; search and post while offline
- **Cross-Referenced** — links to/from check-ins, wiki, tickets auto-recognized
- **Spam Resistant** — posts only via web UI; anonymous posting with CAPTCHA
- **Distributed & Tamper-Proof** — same Merkle-tree design as check-ins

### Structure

- **Threads** — top-level posts that group related replies
- **Replies** — Markdown-formatted responses to threads
- **Closing** — administrators can close threads (v2.23+); only moderators can reply to closed threads
- **Statuses** — forum posts can be tagged with custom statuses (v2.29+, via `forum-statuses` setting)
- **Governance** — controlled via `forum-close-policy` setting and user capabilities

### Forum Markup

Forum messages use the same markup as wiki: Fossil wiki, Markdown, or HTML (depending on configuration). Default is Markdown.

### Forum Capabilities

| Capability | Letter | Description |
|------------|--------|-------------|
| RdForum | `2` | Read forum posts |
| WrForum | `3` | Create posts (held for moderation) |
| WrTForum | `4` | Create posts (bypass moderation) |
| ModForum | `5` | Moderate forum posts |
| AdminForum | `6` | Trust users to bypass moderation |
| Attach (Forum) | `B` | Add attachments to forum posts |

### Setting Up a Forum

1. **Enable capabilities** in Admin → Access:
   - Anonymous: `2` (RdForum) + `3` (WrForum) for public posting with CAPTCHA
   - Reader: `2` (RdForum) for read-only access
   - Developer: `4` (WrTForum) to bypass moderation
   - Add `5` (ModForum) to trusted users for moderation

2. **Skin setup** — Add to header:
   ```html
   if {anycap 23456 || anoncap 2 || anoncap 3} {
     menulink /forum Forum
   }
   ```

3. **Enable search** — Admin → Search → enable "Search Forum"

4. **Self-registration** — Admin → Access → "Allow users to register themselves" (optional)

### How Moderation Works

When a user with `WrForum` capability posts:
1. The post artifact is saved to the block chain
2. The artifact ID is added to a private table (prevents syncing)
3. A reference is added to the `modreq` table (backs moderation UI)
4. The post is NOT visible in the forum UI until approved

When a moderator approves:
- Private table entry is removed
- `modreq` entry is removed
- Post becomes visible and syncs to clones

When a moderator rejects:
- The artifact is removed from the tip of the block chain
- Safe because Fossil prevents replies to pending posts

Users with `WrTForum` capability bypass moderation entirely.

### Editing & Deleting Posts

- **Editing** creates a new artifact referencing the original as parent. Original remains in history.
- **Deleting** a post is actually an edit with blank replacement content.
- True deletion requires shunning the artifact.

### Closing Forum Posts (v2.23+)

- Only users with Setup/Admin caps (or Moderator if `forum-close-policy` is enabled) can close posts
- Closed posts: only authorized users can edit or respond (recursively through all responses)
- Closing is an "advisory lock" — can be bypassed by pushing artifact tags from a local copy

### Forum Statuses (v2.29+)

Enable via `forum-statuses` setting (JSON5 format):
```json
[
  {"label": "Open", "value": "open"},
  {"label": "Resolved", "value": "resolved"}
]
```
- Each thread root gets a status selector
- CSS can style statuses via `data-status` attributes
- All labels and values must be unique

### Forum Configuration Settings

| Setting | Description |
|---------|-------------|
| `forum-close-days` | Auto-close forum after N days |
| `forum-keep-days` | Keep forum posts for N days |
| `forum-keep-count` | Keep at most N forum posts |
| `forum-no-approve` | Don't require moderation |
| `forum-title` | Forum title |
| `forum-statuses` | JSON5 status definitions (v2.29+) |
| `forum-close-policy` | Allow moderators to close posts |

### Email Alerts

- Grant `EmailAlert` capability (`7`) to allow users to sign up
- Or handle signups manually via Admin → Notification
- Configure SMTP in Admin → Notification
- Email alerts also used by other Fossil features (ticket changes, etc.)

### Single Sign-On with Login Groups

Host the forum in a separate repository from your main project, then use login groups to share credentials:
```bash
fossil login-group join --name mygroup /path/to/forum-repo.fossil
```

## Chat

Fossil's chat provides a real-time team communication channel tied to a repository.

### Chat Commands

```bash
fossil chat                                    # open chat in browser
fossil chat send -m "Hello team"               # send a text message
fossil chat send -f file.txt --as note.txt     # attach a file with custom name
fossil chat send -m "Check this" -f image.png  # message + attachment
fossil chat pull                               # backup chat history (Setup required)
fossil chat pull --all                         # download all chat content
fossil chat pull --out backup.db               # store in separate database
fossil chat purge                              # remove old messages
fossil chat reindex                            # rebuild full-text search index
fossil chat url                                # show chat server URL
fossil chat --remote https://other.repo        # operate on different remote
fossil chat send --unsafe -m "msg"             # allow unencrypted HTTP
```

### Chat Features

- **Markdown-formatted messages** (full feature set, v2.17+)
- **File attachments** (images, documents) embedded via iframe
- **Message preview** before sending
- **Notification sounds** (customizable by admins)
- **Timeline integration**: `chat-timeline-user` setting announces timeline changes in chat
- **Full-text search**: chat messages indexed via FTS5
- **Offline access**: chat history synced with repository

### Chat Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `chat-initial-history` | 0 | Number of messages to show initially |
| `chat-keep-count` | (none) | Max chat messages to keep |
| `chat-keep-days` | (none) | Days to keep chat messages |
| `chat-delete-days` | (none) | Days before auto-deleting chat |
| `chat-mimetype` | (none) | Chat message MIME type |
| `chat-timeline-user` | (none) | User whose timeline changes are announced in chat |

### Chat Capabilities

| Capability | Letter | Description |
|------------|--------|-------------|
| Chat | `C` | Access chat room |

### Chat Retention

- `chat-keep-days` — Messages older than this are purged
- `chat-keep-count` — Only the most recent N messages are kept
- `chat-delete-days` — Hard delete after this many days
- Run `fossil chat purge` manually or via cron to enforce retention

### Chat URL

```
<baseurl>/chat
```

Access requires the `C` capability. The chat room is served by the same Fossil web server.
