#!/bin/sh
# Points Formula/tuneless.rb in nacholaciar/homebrew-tap at a release tag.
# Usage: Scripts/bump-homebrew-tap.sh vX.Y.Z
# Env:   GH_TOKEN  token with Contents: write on the tap (required to push)
#        DRY_RUN=1 show the change without committing or pushing
# Run by .github/workflows/release-please.yml after each release.
set -eu

TAG="${1:?usage: $0 vX.Y.Z}"
REPO="nacholaciar/tuneless"
TAP="nacholaciar/homebrew-tap"
FORMULA="Formula/tuneless.rb"
URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"

SHA=$(curl -fsSL "$URL" | shasum -a 256 | cut -d ' ' -f 1)
echo "$TAG -> sha256 $SHA"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
if [ -n "${GH_TOKEN:-}" ]; then
  git clone -q --depth 1 "https://x-access-token:$GH_TOKEN@github.com/$TAP.git" "$WORK"
else
  git clone -q --depth 1 "https://github.com/$TAP.git" "$WORK"
fi
cd "$WORK"

sed -i.bak -E \
  -e "s|^  url \".*\"|  url \"$URL\"|" \
  -e "s|^  sha256 \".*\"|  sha256 \"$SHA\"|" \
  "$FORMULA"
rm "$FORMULA.bak"

if git diff --quiet; then
  echo "$FORMULA already points at $TAG"
  exit 0
fi
git --no-pager diff

if [ -n "${DRY_RUN:-}" ]; then
  echo "DRY_RUN: not committing"
  exit 0
fi

git -c user.name="github-actions[bot]" \
    -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
    commit -q -am "feat: update tuneless to ${TAG#v}"
git push -q
echo "Pushed $FORMULA for $TAG to $TAP"
