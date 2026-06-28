# Tickets

Fossil's built-in ticket system tracks bugs, features, and tasks with full history and cross-linking to commits. Tickets are stored as **ticket change artifacts** in the repository's block chain — each modification creates a new artifact with the same ticket ID. The current state is determined by replaying all artifacts in timestamp order.

## Ticket Lifecycle

1. **Create** — via web UI (Tickets → New Ticket) or CLI
2. **Assign** — set status, priority, severity, subsystem
3. **Work** — link related commits using `[ticket-hash]` syntax
4. **Resolve** — mark as fixed/tested/closed
5. **Close** — record the resolving commit hash

## Ticket Fields

Default fields (customizable in Admin → Ticket Configuration):

| Field | Description |
|-------|-------------|
| `type` — bug, feature request, etc.
| `status` — open, closed, fixed, tested
| `subsystem` — component area
| `priority` — importance level
| `severity` — impact level
| `foundin` — version where discovered
| `resolution` — how it was fixed
| `title` — short summary
| `comment` — full description

Custom fields can be added via Admin → Ticket Configuration. The TICKET table schema is **local state** (not synced between repositories), but ticket change artifacts are **global state** (synced).

## CLI Ticket Commands

```bash
# Create a ticket
fossil ticket add "Title" type=bug priority=high
fossil ticket add "Title" type=bug subsystem=auth severity=high "comment=Full description here"

# Update fields
fossil ticket set <uuid> status=closed
fossil ticket set <uuid> status=fixed resolution=done
fossil ticket change <uuid> status=fixed resolution=done  # alias for set

# Append to a field (use + prefix)
fossil ticket set <uuid> +comment="Additional info"

# Run a report (by title or number)
fossil ticket show "Report Title"
fossil ticket show "Report Title" status='open'
fossil ticket show "Report Title" status='open' type='bug'
fossil ticket show 0  # list all columns defined in the ticket table

# List available fields and reports
fossil ticket list fields
fossil ticket list reports
fossil ticket ls fields   # alias
fossil ticket ls reports  # alias

# Full change history
fossil ticket history <uuid>
```

### Ticket Command Options

- `-l|--limit LIMITCHAR` — Change output separator (default: TAB)
- `--quote` — Encode special chars (space→`\s`, tab→`\t`, newline→`\n`, etc.)
- `-R|--repository REPO` — Operate on a specific repository

### Filter Syntax for Reports

```bash
# Filter by field value
fossil ticket show "Open Bugs" status='open'
fossil ticket show "My Tickets" status!='open'
fossil ticket show "Report" [#]='uuid-prefix'
```

## Cross-Linking Tickets ↔ Commits

Put the 10-digit ticket hash in commit comments surrounded by brackets:
```
fossil commit -m "Fix login bug [a1b2c3d4e5]"
```
This creates a clickable link from the commit to the ticket. When closing the ticket, add the resolving commit hash to create a reverse link.

## Ticket Reports

Reports are defined by TH1 scripts in Admin → Ticket Configuration. They produce tab-separated output for CLI use and HTML tables for the web UI.

```bash
# List all saved reports
fossil ticket list reports

# Run report #0 to see all available columns
fossil ticket show 0
```

### Report Filter Syntax

Filters use SQL WHERE clause syntax:
- `field='value'` — exact match
- `field!='value'` — exclusion
- `[#]='uuid'` — match by ticket UUID prefix

## Ticket Internals

- **Ticket ID**: 40-character random hex string (UUID)
- **Storage**: Each change is a separate "ticket change artifact" in the block chain
- **Merge behavior**: Independent changes to the same ticket are automatically merged on sync (no branching)
- **Timestamp sensitivity**: System clocks must be approximately correct. Artifacts with timestamps off by months/years can confuse the replay algorithm
- **Immutability**: Ticket history is permanent. "Deletion" is actually an edit with blank content

## Customizing Tickets

Admin → Ticket Configuration allows:
- Adding custom fields (text, boolean, select, textarea)
- Defining field types and validation
- Configuring ticket display templates (TH1 scripts)
- Setting up email notifications for ticket changes

The ticket table schema and screen templates are **local state** — they don't sync between repositories. Only ticket change artifacts sync.

## Email Notifications

Configure in Admin → Notification:
- Subscribe to ticket changes by type/subsystem
- Set up SMTP server in Admin → Notification
- Use `fossil ticket show` in scripts for automated reporting
