#!/usr/bin/env bash
# fossil-ticket.sh — Fossil ticket lifecycle helpers
# Usage: fossil-ticket.sh <command> [args]

set -euo pipefail

REPO="${REPO:-}"

repo_flag() {
  if [[ -n "$REPO" ]]; then echo "-R $REPO"; fi
}

case "${1:-help}" in
  add|create)
    shift
    TITLE="${1:?Usage: fossil-ticket.sh add \"Title\" [field=value ...]}"
    shift
    ARGS=()
    for kv in "$@"; do
      ARGS+=("$kv")
    done
    echo "Creating ticket: $TITLE"
    fossil ticket add "$TITLE" "${ARGS[@]}" $(repo_flag)
    ;;
  show)
    UUID="${2:?Usage: fossil-ticket.sh show <uuid>}"
    fossil ticket history "$UUID" $(repo_flag)
    ;;
  set|update)
    UUID="${2:?Usage: fossil-ticket.sh set <uuid> <field> <value>}"
    FIELD="${3:?Missing field name}"
    VALUE="${4:?Missing value}"
    shift 4
    EXTRA=()
    while [[ $# -gt 0 ]]; do
      EXTRA+=("$1" "$2")
      shift 2
    done
    fossil ticket set "$UUID" "$FIELD" "$VALUE" "${EXTRA[@]}" $(repo_flag)
    ;;
  close)
    UUID="${2:?Usage: fossil-ticket.sh close <uuid> [resolution]}"
    RESOLUTION="${3:-closed}"
    fossil ticket set "$UUID" status closed resolution "$RESOLUTION" $(repo_flag)
    echo "Ticket $UUID closed (resolution: $RESOLUTION)"
    ;;
  list)
    if [[ "${2:-}" == "fields" ]]; then
      fossil ticket list fields $(repo_flag)
    elif [[ "${2:-}" == "reports" ]]; then
      fossil ticket list reports $(repo_flag)
    else
      REPORT="${2:-All Tickets}"
      fossil ticket show "$REPORT" $(repo_flag)
    fi
    ;;
  link-commit)
    UUID="${2:?Usage: fossil-ticket.sh link-commit <uuid> <hash>}"
    HASH="${3:?Missing commit hash}"
    echo "To link ticket $UUID to commit $HASH:"
    echo "  1. In commit message, include: [$HASH]"
    echo "  2. When closing ticket, set 'resolution' to the commit hash"
    echo ""
    echo "Example commit:"
    echo "  fossil commit -m \"Fix issue [$HASH]\""
    ;;
  help|*)
    echo "Fossil ticket lifecycle helpers"
    echo ""
    echo "Usage: fossil-ticket.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  add \"Title\" [field=value ...]   Create a new ticket"
    echo "  show <uuid>                     Show ticket history"
    echo "  set <uuid> <field> <value>      Update a ticket field"
    echo "  close <uuid> [resolution]       Close a ticket"
    echo "  list                            Show all tickets (default: \"All Tickets\")"
    echo "  list fields                     List available ticket fields"
    echo "  list reports                    List saved ticket reports"
    echo "  link-commit <uuid> <hash>       Show how to link ticket ↔ commit"
    echo ""
    echo "Common fields: type, status, subsystem, priority, severity, foundin, resolution, title, comment"
    echo ""
    echo "Environment:"
    echo "  REPO=-R path/to/repo.fossil  Operate on a specific repository"
    ;;
esac
