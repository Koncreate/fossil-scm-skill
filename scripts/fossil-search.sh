#!/usr/bin/env bash
# fossil-search.sh — Fossil full-text search helpers
# Usage: fossil-search.sh <command> [args]

set -euo pipefail

REPO="${REPO:-}"

repo_flag() {
  if [[ -n "$REPO" ]]; then echo "-R $REPO"; fi
}

case "${1:-help}" in  all)
    shift
    PATTERN="${1:?Usage: fossil-search.sh all \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search -a $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  wiki)
    shift
    PATTERN="${1:?Usage: fossil-search.sh wiki \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search --wiki $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  tickets)
    shift
    PATTERN="${1:?Usage: fossil-search.sh tickets \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search --tickets $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  forum)
    shift
    PATTERN="${1:?Usage: fossil-search.sh forum \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search --forum $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  technotes)
    shift
    PATTERN="${1:?Usage: fossil-search.sh technotes \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search --technotes $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  docs)
    shift
    PATTERN="${1:?Usage: fossil-search.sh docs \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search --docs $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  checkins)
    shift
    PATTERN="${1:?Usage: fossil-search.sh checkins \"query\" [limit]}"
    LIMIT="${2:-}"
    [[ -n "$LIMIT" ]] && LIMIT_ARGS="-n $LIMIT" || LIMIT_ARGS=""
    fossil search -c $LIMIT_ARGS "$PATTERN" $(repo_flag)
    ;;
  help|*)
    echo "Fossil full-text search helpers"
    echo ""
    echo "Usage: fossil-search.sh <command> \"query\" [limit]"
    echo ""
    echo "Commands:"
    echo "  all [limit]          Search all content types"
    echo "  wiki [limit]         Search wiki pages"
    echo "  tickets [limit]      Search tickets"
    echo "  forum [limit]        Search forum posts"
    echo "  technotes [limit]    Search technotes"
    echo "  docs [limit]         Search embedded documentation"
    echo "  checkins [limit]     Search check-in comments"
    echo ""
    echo "Environment:"
    echo "  REPO=-R path/to/repo.fossil  Operate on a specific repository"
    ;;
esac
