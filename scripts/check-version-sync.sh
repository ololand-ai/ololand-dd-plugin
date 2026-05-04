#!/usr/bin/env bash
# Fails if .claude-plugin/plugin.json and .claude-plugin/marketplace.json
# disagree on the plugin version. Source of truth: plugin.json.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
plugin_json="$repo_root/.claude-plugin/plugin.json"
marketplace_json="$repo_root/.claude-plugin/marketplace.json"

plugin_version=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['version'])" "$plugin_json")
marketplace_version=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['plugins'][0]['version'])" "$marketplace_json")

if [ "$plugin_version" != "$marketplace_version" ]; then
  echo "version drift: plugin.json=$plugin_version marketplace.json=$marketplace_version" >&2
  echo "update .claude-plugin/marketplace.json plugins[0].version to match plugin.json before committing." >&2
  exit 1
fi
