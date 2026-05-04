#!/usr/bin/env bash
# One-shot setup that points git at the in-tree hooks directory.
# Run once after cloning so the version-sync guard runs on every commit.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$repo_root" config core.hooksPath scripts/git-hooks
echo "core.hooksPath -> scripts/git-hooks"
echo "verifying guard runs:"
"$repo_root/scripts/check-version-sync.sh" && echo "  ok: plugin.json and marketplace.json versions match"
