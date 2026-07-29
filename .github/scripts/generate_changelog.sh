#!/usr/bin/env bash
# FILE_NAME: generate_changelog.sh
# DESCRIPTION: Regenerate CHANGELOG.md with git-cliff for a release tag/version
# VERSION: 1.0.0
# AUTHORS: ravichandrapatel
#
# INTENT: Produce Keep a Changelog from conventional commits
# INPUT: $1 = version without leading v (e.g. 1.0.0-rc.4)
# OUTPUT: Writes CHANGELOG.md at repo root
# ROLE: release helper
# SIDE_EFFECTS: overwrites CHANGELOG.md

set -euo pipefail

# _log("[T-01] validate args")
VERSION="${1:?version required (no leading v)}"
TAG="v${VERSION}"
CLIFF_VERSION="${GIT_CLIFF_VERSION:-2.8.0}"
CLIFF_BIN="$(command -v git-cliff || true)"

# _log("[T-02] ensure git-cliff")
if [[ -z "${CLIFF_BIN}" ]]; then
  DEST="${RUNNER_TEMP:-/tmp}/git-cliff-bin"
  mkdir -p "${DEST}"
  curl -sL "https://github.com/orhun/git-cliff/releases/download/v${CLIFF_VERSION}/git-cliff-${CLIFF_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
    | tar xz -C /tmp
  install -m 0755 "/tmp/git-cliff-${CLIFF_VERSION}/git-cliff" "${DEST}/git-cliff"
  CLIFF_BIN="${DEST}/git-cliff"
fi

# _log("[T-03] generate changelog for this version (including untagged commits)")
"${CLIFF_BIN}" --config cliff.toml --tag "${TAG}" -o CHANGELOG.md

echo "Generated CHANGELOG.md for ${TAG}"
