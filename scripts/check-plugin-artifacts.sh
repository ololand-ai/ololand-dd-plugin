#!/usr/bin/env bash
# Fails if generated Claude/Codex plugin artifacts are missing or stale.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$repo_root/scripts/generate-plugin-artifacts.py" --check
