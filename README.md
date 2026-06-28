# Fossil SCM Agent Skill

A comprehensive agent skill for [Fossil SCM](https://fossil-scm.org) — the distributed version control system that bundles source control, ticketing, wiki, forum, chat, and a built-in web interface into a single SQLite database.

## Install

### Via npx skills add

```bash
# Install from GitHub
npx skills add koncreate/fossil-scm-skill@1.0.0

# Or install from a local path
npx skills add ./fossil-scm-skill

# Global install (available across all projects)
npx skills add koncreate/fossil-scm-skill@1.0.0 -g

# Install to a specific agent
npx skills add koncreate/fossil-scm-skill@1.0.0 -a claude-code

# List what would be installed without installing
npx skills add koncreate/fossil-scm-skill@1.0.0 --list
```

### Manual Install

Copy this directory to your agent's skills folder:

| Agent | Path |
|-------|------|
| Claude Code | `~/.claude/skills/fossil-scm/` |
| Codex | `~/.agents/skills/fossil-scm/` |
| Cursor | `~/.cursor/skills/fossil-scm/` |
| OpenCode | `~/.agents/skills/fossil-scm/` |
| Pi | `~/.agents/skills/fossil-scm/` |
| Cline / Zed / Warp | `~/.agents/skills/fossil-scm/` |
| Gemini CLI | `~/.gemini/skills/fossil-scm/` |
| Continue | `~/.continue/skills/fossil-scm/` |

## What It Covers

- **Core Concepts** — repository, check-out, artifacts, manifests, autosync
- **Git to Fossil Translation** — side-by-side command comparison
- **Wiki** — standalone pages, embedded docs, technotes, markup
- **Tickets** — lifecycle, fields, reports, cross-linking to commits
- **Forum & Chat** — setup, moderation, capabilities, configuration
- **Server Deployment** — CGI, SSH, standalone, reverse proxy, SSL, Chiselapp
- **Configuration** — settings, capabilities/ACL, login groups, skins
- **Advanced** — amend, bisect, diff variants, Pikchr, git interop
- **Maintenance** — rebuild, repack, verify, scrub, FTS, clean
- **Sync Protocol** — autosync behavior, wire protocol, what doesn't sync
- **Skins & Customization** — CSS, TH1, headers/footers, per-page styling

## Structure

```
fossil-scm/
├── SKILL.md              # Main skill entry point (lean hub)
├── references/           # Detailed reference files (loaded on demand)
│   ├── commands.md       # Full command syntax reference
│   ├── concepts.md       # Core architecture & terminology
│   ├── configuration.md  # Settings, capabilities, ACL, login groups
│   ├── forum-chat.md     # Forum setup, moderation, chat commands
│   ├── maintenance.md    # Rebuild, repack, verify, scrub, FTS, clean
│   ├── server.md         # CGI, SSH, standalone, reverse proxy, Chiselapp
│   ├── skins-customization.md  # CSS, TH1, headers/footers
│   ├── sync-protocol.md  # Autosync, wire protocol, transports
│   ├── tickets.md        # Lifecycle, fields, reports, cross-linking
│   └── wiki.md           # Pages, embedded docs, technotes, markup
├── scripts/              # Helper scripts
│   ├── fossil-wiki.sh
│   ├── fossil-ticket.sh
│   ├── fossil-search.sh
│   └── fossil-chiselapp.sh
└── assets/               # Static assets (if any)
```

## Design

This skill follows the hub-and-spoke pattern:
- `SKILL.md` stays lean (~270 lines) with quick-reference tables and gotchas
- Detailed content lives in `references/` files, loaded on demand
- The `description` frontmatter uses "Load when..." routing for agent discovery

## Official Fossil Documentation

- [Fossil Book](https://fossil-scm.org/schimpf-book)
- [Git to Fossil Guide](https://fossil-scm.org/home/doc/tip/www/gitusers.md)
- [Fossil vs Git](https://fossil-scm.org/home/doc/tip/www/fossil-v-git.wiki)
- [Glossary](https://fossil-scm.org/home/doc/tip/www/glossary.md)
- [Concepts](https://fossil-scm.org/home/doc/tip/www/concepts.wiki)
- [Forum](https://fossil-scm.org/forum)

## License

Apache-2.0
