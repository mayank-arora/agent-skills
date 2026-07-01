#!/usr/bin/env bash
# Gathers recent git + PR activity to seed devlog talking-point nudges.
# Usage: devlog-context.sh [--since "<iso-date-or-git-approxidate>"]
# If --since is omitted, defaults to the last 7 days.
# Output is plain text grouped into sections; the skill turns it into nudges.
# This script only READS git/gh state. It never writes anything.

set -uo pipefail

SINCE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --since)
      SINCE="${2:-}"
      shift 2 || shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ -z "$SINCE" ]; then
  SINCE="7 days ago"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "(not inside a git repository - no git activity to report)"
  exit 0
fi

ME_EMAIL="$(git config user.email 2>/dev/null || true)"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
DIRTY_COUNT="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"

echo "## Current"
if [ "$DIRTY_COUNT" = "0" ]; then
  echo "branch: $BRANCH (clean working tree)"
else
  echo "branch: $BRANCH ($DIRTY_COUNT uncommitted file change(s))"
fi
echo

echo "## Your commits since $SINCE"
COMMITS="$(git log --all --no-merges --since="$SINCE" \
  ${ME_EMAIL:+--author="$ME_EMAIL"} \
  --pretty='- %h %s (%cr, %D)' 2>/dev/null | head -n 25)"
if [ -n "$COMMITS" ]; then
  echo "$COMMITS"
else
  echo "(none)"
fi
echo

echo "## Recently active branches"
git for-each-ref --sort=-committerdate refs/heads/ \
  --format='- %(refname:short) (%(committerdate:relative))' 2>/dev/null | head -n 8
echo

echo "## Your PRs (recent)"
if command -v gh >/dev/null 2>&1; then
  PRS="$(gh pr list --author "@me" --state all --limit 10 \
    --json number,title,state,headRefName \
    --template '{{range .}}- #{{.number}} {{.state}}  {{.title}}  [{{.headRefName}}]{{"\n"}}{{end}}' 2>/dev/null)"
  if [ -n "$PRS" ]; then
    echo "$PRS"
  else
    echo "(no PRs found, or gh is not authenticated for this repo)"
  fi
else
  echo "(gh CLI not installed - skipping PR lookup)"
fi
