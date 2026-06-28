#!/usr/bin/env bash
# fossil-wiki.sh — Fossil wiki helpers
# Usage: fossil-wiki.sh <command> [args]

set -euo pipefail

REPO="${REPO:-}"

repo_flag() {
  if [[ -n "$REPO" ]]; then echo "-R $REPO"; fi
}

case "${1:-help}" in
  create)
    PAGE="${2:?Usage: fossil-wiki.sh create <page> [mimetype]}"
    MT="${3:-text/x-fossil-wiki}"
    echo "Creating wiki page: $PAGE (mimetype: $MT)"
    echo "Enter content (Ctrl+D to end):"
    fossil wiki create "$PAGE" --mimetype "$MT" "$(cat)" $(repo_flag)
    ;;
  edit|commit)
    PAGE="${2:?Usage: fossil-wiki.sh edit <page>}"
    if [[ -z "${EDITOR:-}" ]]; then
      export EDITOR="${VISUAL:-${EDITOR:-vim}}"
    fi
    TMPFILE=$(mktemp /tmp/fossil-wiki-XXXXXX.wiki)
    # Export current content if page exists
    fossil wiki list --all "$PAGE" $(repo_flag) 2>/dev/null && \
      fossil wiki export "$PAGE" "$TMPFILE" $(repo_flag) 2>/dev/null || true
    "$EDITOR" "$TMPFILE"
    fossil wiki commit "$PAGE" "$TMPFILE" $(repo_flag)
    rm -f "$TMPFILE"
    echo "Updated: $PAGE"
    ;;
  export)
    PAGE="${2:?Usage: fossil-wiki.sh export <page> [file]}"
    OUT="${3:-}"
    if [[ -n "$OUT" ]]; then
      fossil wiki export "$PAGE" "$OUT" $(repo_flag)
      echo "Exported to: $OUT"
    else
      fossil wiki export "$PAGE" $(repo_flag)
    fi
    ;;
  list)
    if [[ "${2:-}" == "--all" ]]; then
      fossil wiki list --all $(repo_flag)
    elif [[ "${2:-}" == "--technotes" || "${2:-}" == "-t" ]]; then
      fossil wiki list -t $(repo_flag)
    else
      fossil wiki list $(repo_flag)
    fi
    ;;
  technote)
    shift
    TAG=false
    if [[ "${1:-}" == "-t" || "${1:-}" == "--technote" ]]; then
      TAG=true
      shift
    fi
    if [[ "$TAG" == true ]]; then
      NAME="${1:?Usage: fossil-wiki.sh technote -t <name>}"
      EXTRA_ARGS=""
      [[ -n "${TECHNOTE_TAGS:-}" ]] && EXTRA_ARGS="--technote-tags $TECHNOTE_TAGS"
      [[ -n "${TECHNOTE_BGCOLOR:-}" ]] && EXTRA_ARGS="$EXTRA_ARGS --technote-bgcolor $TECHNOTE_BGCOLOR"
      echo "Creating technote: $NAME"
      echo "Enter content (Ctrl+D to end):"
      fossil wiki create -t "$NAME" $EXTRA_ARGS "$(cat)" $(repo_flag)
    else
      echo "For technotes, use: fossil-wiki.sh technote -t <name>"
      exit 1
    fi
    ;;
  help|*)
    echo "Fossil wiki helpers"
    echo ""
    echo "Usage: fossil-wiki.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  create <page> [mimetype]   Create a new wiki page (stdin content)"
    echo "  edit <page>                Edit in \$EDITOR (exports, opens, commits)"
    echo "  export <page> [file]       Export to stdout or file"
    echo "  list [--all]               List wiki pages"
    echo "  list --technotes           List technotes"
    echo "  technote -t <name>         Create a technote (stdin content)"
    echo ""
    echo "Environment:"
    echo "  REPO=-R path/to/repo.fossil  Operate on a specific repository"
    echo ""
    echo "Examples:"
    echo "  echo 'Hello World' | fossil-wiki.sh create Intro"
    echo "  fossil-wiki.sh edit Documentation"
    echo "  fossil-wiki.sh export Intro docs/intro.wiki"
    ;;
esac
