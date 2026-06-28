#!/usr/bin/env bash
# fossil-chiselapp.sh — Chiselapp hosting setup and sync
# Usage: fossil-chiselapp.sh <command> [args]

set -euo pipefail

REPO="${REPO:-}"

repo_flag() {
  if [[ -n "$REPO" ]]; then echo "-R $REPO"; fi
}

case "${1:-help}" in  init)
    REPOFILE="${2:?Usage: fossil-chiselapp.sh init <repo.fossil> <account> <project>}"
    ACCOUNT="${3:?Missing Chiselapp account name}"
    PROJECT="${4:?Missing Chiselapp project name}"
    URL="https://${ACCOUNT}:${PROJECT}@chiselapp.com/user/${ACCOUNT}/repository/${PROJECT}"

    echo "=== Chiselapp Repository Setup ==="
    echo ""
    echo "1. Get project code from local repo:"
    echo "   fossil info -R $REPOFILE"
    echo "   Look for 'Project Code' UUID — you'll need it for the Chiselapp form."
    echo ""
    echo "2. Create repository on Chiselapp:"
    echo "   https://chiselapp.com"
    echo "   - Log in → Create New Repository"
    echo "   - Name: $PROJECT"
    echo "   - Project Code: (from step 1)"
    echo ""
    echo "3. Push your repository:"
    echo "   fossil push $URL -R $REPOFILE --once"
    echo ""
    echo "4. After push, fix up:"
    echo "   - Shun the initial empty check-in (Timeline → Shun)"
    echo "   - Admin → Configuration → set Index Page to your wiki home"
    echo "   - Fix doc links: /doc/trunk/... → /doc/tip/..."
    ;;
  push|sync)
    REPOFILE="${2:?Usage: fossil-chiselapp.sh push <repo.fossil> <account> <project>}"
    ACCOUNT="${3:?Missing Chiselapp account name}"
    PROJECT="${4:?Missing Chiselapp project name}"
    ONCE_FLAG="${5:-}"
    URL="https://${ACCOUNT}:${PROJECT}@chiselapp.com/user/${ACCOUNT}/repository/${PROJECT}"

    if [[ -n "$ONCE_FLAG" && "$ONCE_FLAG" == "--once" ]]; then
      echo "Pushing (one-time, no sync back)..."
      fossil push "$URL" -R "$REPOFILE" --once
    else
      echo "Syncing (bidirectional)..."
      fossil push "$URL" -R "$REPOFILE"
    fi
    ;;
  url)
    ACCOUNT="${2:?Usage: fossil-chiselapp.sh url <account> <project>}"
    PROJECT="${3:?Missing project name}"
    echo "https://chiselapp.com/user/${ACCOUNT}/repository/${PROJECT}/"
    ;;
  help|*)
    echo "Fossil Chiselapp hosting helpers"
    echo ""
    echo "Usage: fossil-chiselapp.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  init <repo.fossil> <account> <project>   Show setup instructions"
    echo "  push <repo.fossil> <account> <project> [--once]  Push/sync to Chiselapp"
    echo "  url <account> <project>                  Print repository URL"
    echo ""
    echo "Environment:"
    echo "  REPO=-R path/to/repo.fossil  Operate on a specific repository"
    ;;
esac
