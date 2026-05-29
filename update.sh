#!/usr/bin/env bash
#
# Sync the AMC Group Setting Guide from the private vault into this public
# Quartz site. The vault is the single source of truth; this script copies its
# body and re-attaches the frontmatter the site needs (title + publish: true).
#
# Usage:
#   ./update.sh            # sync, then show git status
#   ./update.sh --push     # sync, commit, and push (triggers the live deploy)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/../Asteria/Asteria Vault/Campaigns/Asteria - AMC Group/Setting Guide.md"
DEST="$SCRIPT_DIR/content/index.md"

if [[ ! -f "$SRC" ]]; then
  echo "✗ Source not found: $SRC" >&2
  exit 1
fi

# Take the source body, dropping (a) any leading YAML frontmatter block and
# (b) the first H1 heading + the blank lines right after it — the page title is
# supplied by the frontmatter below, so we don't want it rendered twice.
body="$(awk '
  NR==1 && $0=="---" { infm=1; next }       # enter frontmatter
  infm && $0=="---"  { infm=0; next }        # leave frontmatter
  infm               { next }                # skip frontmatter lines
  !seenh1 && /^# /    { seenh1=1; next }      # drop first H1
  seenh1==1 && /^[[:space:]]*$/ { next }     # drop blank lines right after it
  { seenh1=2; print }                        # emit the rest verbatim
' "$SRC")"

{
  printf -- '---\ntitle: Setting Guide\npublish: true\n---\n\n'
  printf '%s\n' "$body"
} > "$DEST"

echo "✓ Synced vault Setting Guide -> content/index.md"

if [[ "${1:-}" == "--push" ]]; then
  cd "$SCRIPT_DIR"
  git add -A
  if git diff --cached --quiet; then
    echo "Nothing changed; site already up to date."
  else
    git commit -m "Update Setting Guide"
    git push
    echo "✓ Pushed. GitHub Pages will redeploy in ~1-2 min."
  fi
else
  echo "Preview:  npx quartz build --serve   (http://localhost:8080)"
  echo "Publish:  ./update.sh --push          (or: git add -A && git commit && git push)"
fi
