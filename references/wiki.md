# Wiki System Deep-Dive

## Stand-alone Wiki Pages

Each wiki page has its own revision history independent of check-ins. Wiki pages can branch and merge like check-ins (the data format supports it, though the UI doesn't yet expose merge). On concurrent edits, the page forks; the most recent edit wins in the UI, but history preserves both branches.

Create via web UI (Wiki → New) or CLI:

```bash
fossil wiki create PAGENAME [FILE]       # create/read from FILE or stdin
fossil wiki commit PAGENAME [FILE]       # update existing page
fossil wiki export PAGENAME [FILE]       # print to stdout or save to file
fossil wiki list                         # list all pages
fossil wiki list --all                   # include deleted pages
fossil wiki list -a                      # show pages associated with checkins/branches
fossil wiki list -s                      # show technote IDs (with -t)
```

The `create` and `commit` subcommands accept content from FILE or stdin. The `Sandbox` pseudo-page is special — either `create` or `commit` can update it.

### Export Options

- `-h|--html` — render body as HTML (no header/footer)
- `-H|--HTML` — wrap in `<html><body>...</body></html>`
- `-p|--pre` — wrap plain text in `<pre>` tags (only with `-h`/`-H`)
- `-M|--mimetype TYPE` — set mimetype: `text/x-fossil-wiki`, `text/x-markdown`, `text/plain` (synonyms: `fossil`, `markdown`, `plain`)

Default mimetype for new pages is `text/x-fossil-wiki`.

### Wiki Page Lifecycle

- Pages can be **deleted** (shunned) — they remain in history but disappear from normal views
- `fossil wiki list --all` shows deleted pages
- There is no `fossil wiki delete` — deletion is done via the web UI (Admin → Shun) or by shunning the wiki artifact

## Special Wiki Pages

- `branch/<BRANCHNAME>` — associated with a branch, shown above its timeline
- `checkin/<HASH>` — associated with a commit, shown in the "About" section of `/info`

These special pages are useful for recording historical notes about branches or commits.

## Embedded Documentation

Files in the source tree with `.wiki`, `.md`, or `.markdown` extensions are rendered by Fossil's web server via the `/doc/` URL scheme:

```
<baseurl>/doc/<version>/<filename>       # specific checkin
<baseurl>/doc/ckout/<filename>             # preview uncommitted local file
<baseurl>/doc/tip/<filename>               # latest on current branch
```

`<version>` can be:
- A check-in hash (full or prefix)
- A branch name (e.g., `trunk`)
- A tag name
- A timestamp: `YYYY-MM-DD`, `YYYY-MM-DDTHH:MM`, or `YYYY-MM-DDTHH:MM:SS`
- `ckout` — local uncommitted file on disk
- `tip` — latest version on current branch

### Previewing Docs Before Commit

```bash
fossil ui --ckout-alias trunk
# Now /doc/trunk/... links point to your local uncommitted edits
```

This is essential for verifying how Fossil renders your markup before committing, since rendering varies between Markdown engines.

### Advantages of Embedded Docs

1. Versioned together with source code
2. Edited in your favorite text editor (not web UI)
3. Only committers can modify (access-controlled)
4. Can cross-reference source files and other docs

### Server-Side Text Substitution

- `$ROOT` in HTML and Markdown hyperlinks is replaced with the base URL. Wiki docs can just use `/`-relative URLs.
- `$CURRENT` in `/doc/` URLs is replaced with the current check-in hash being viewed. Only works for Markdown/HTML (not Wiki).

### HTML Rendering with Fossil Headers

Files with `.html`/`.htm` extensions are normally served as-is. But if the file begins with:
```html
<div class="fossil-doc" data-title="Title Text">
```
Fossil wraps it with the standard header/footer. The `data-title` attribute sets the page title.

### TH1 Documents (Advanced)

- Requires `--with-th1-docs` build flag and `th1-docs` setting enabled
- Files must have `.th1` extension
- Code embedded in `<th1>...</th1>` blocks
- **Security risk**: grants server-side code execution to anyone with check-in privilege
- Off by default

## Technotes

Technotes are dated, tagged annotations that appear on the timeline. Unlike wiki pages (named), technotes are identified by timestamp. Use for release notes, announcements, meeting minutes.

```bash
fossil wiki create -t "Release 2.0 notes"              # create technote "now"
fossil wiki create -t 2024-01-15T10:00:00 "Sprint review"
fossil wiki commit -t "Release 2.0 notes"              # update existing
fossil wiki commit -t 2024-01-15T10:00:00 "Updated"     # update by timestamp
fossil wiki export -t "Release 2.0 notes"
fossil wiki list -t                                    # list technotes
fossil wiki list -t -s                                 # list with technote IDs
```

DATETIME formats: `now`, `YYYY-MM-DDTHH:MM:SS.SSS`, or truncated forms. The `T` can be replaced by a space. Timezone offset: `-HH:MM` (west) or `+HH:MM` (east), or `Z` for UTC.

### Technote Options

- `-t|--technote DATETIME|ID|TAG` — target a technote
- `--technote-tags TAGS` — comma-separated tags
- `--technote-bgcolor COLOR` — timeline display color

## Wiki Markup Rules (Fossil Wiki Format)

| Syntax | Result |
|--------|--------|
| Blank line | Paragraph break |
| `* item` (with 2+ spaces or tab before) | Bullet list |
| `# item` or `1. item` | Numbered list |
| Tab or 2+ spaces at line start | Indented paragraph |
| `[https://example.com]` | Hyperlink |
| `[https://example.com\|Label]` | Hyperlink with custom text |
| `[artifact-hash]` | Link to checkin/ticket/wiki by hash |
| `[wikipage]` or `[wikipage\|Label]` | Link to wiki page |
| `[forum:post-id]` | Link to forum post |
| `[wikipedia:Fossil]` | Interwiki link |
| `<nowiki>...</nowiki>` | Disable all wiki/HTML formatting |
| `<verbatim>...</verbatim>` | Preformatted (like `<pre>`) |
| `<verbatim type="pikchr">...</verbatim>` | Pikchr diagram |
| Most HTML tags | Passed through (configurable) |

**Interwiki prefixes** can be defined in Admin → Wiki. Common built-in: `forum:`, `wikipedia:`.

## Markdown in Fossil

Fossil supports standard Markdown plus extensions:
- Same link syntax as wiki format for artifact/wiki/forum links
- Fenced code blocks with language hints
- `<verbatim type="pikchr">` for diagrams inside Markdown
- Footnotes (v2.19+)
- Tables, blockquotes, nested lists

## File Extension Determines Rendering

- `.wiki` → Fossil wiki markup
- `.md`/`.markdown` → Markdown
- `.txt` → plain text (rendered with Fossil header/footer)
- `.html`/`.htm` → served as-is (or with Fossil skin if wrapped in `<div class="fossil-doc">`)
- Other extensions → served directly as their MIME type

## Cross-Linking Tickets ↔ Commits

Put the 10-digit ticket hash in commit comments surrounded by brackets:
```
fossil commit -m "Fix login bug [a1b2c3d4e5]"
```
This creates a clickable link from the commit to the ticket. When closing the ticket, add the resolving commit hash to create a reverse link.

## Cross-Linking Wiki ↔ Commits

- `[artifact-hash]` in wiki text links to the commit/ticket
- Wiki pages named `checkin/<HASH>` or `branch/<NAME>` are auto-associated
- Technotes appear on the timeline at their specified date
