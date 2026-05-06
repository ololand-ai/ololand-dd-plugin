#!/usr/bin/env bash
# Fails if any plugin's plugin.json version disagrees with the marketplace.json
# entry for that plugin. Source of truth: each plugin's plugin.json.
#
# Iterates every plugin listed in .claude-plugin/marketplace.json and compares
# against <pluginRoot>/<source>/.claude-plugin/plugin.json.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
marketplace_json="$repo_root/.claude-plugin/marketplace.json"

if [ ! -f "$marketplace_json" ]; then
  echo "fatal: marketplace.json not found at $marketplace_json" >&2
  exit 1
fi

drift=0
plugin_count=$(python3 -c "import json,sys; print(len(json.load(open(sys.argv[1]))['plugins']))" "$marketplace_json")

for i in $(seq 0 $((plugin_count - 1))); do
  read -r name source mp_version <<< "$(python3 -c '
import json, sys
mp = json.load(open(sys.argv[1]))
plugin_root = mp.get("metadata", {}).get("pluginRoot", ".")
entry = mp["plugins"][int(sys.argv[2])]
print(entry["name"], plugin_root.rstrip("/") + "/" + entry["source"], entry.get("version", ""))
' "$marketplace_json" "$i")"

  plugin_json="$repo_root/$source/.claude-plugin/plugin.json"
  if [ ! -f "$plugin_json" ]; then
    echo "fatal: $name lists source $source but $plugin_json does not exist" >&2
    drift=1
    continue
  fi

  pkg_version=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['version'])" "$plugin_json")

  if [ "$pkg_version" != "$mp_version" ]; then
    echo "version drift: $name plugin.json=$pkg_version marketplace.json=$mp_version" >&2
    drift=1
  fi
done

if [ "$drift" -ne 0 ]; then
  echo "update marketplace.json plugin entries to match each plugin's plugin.json before committing." >&2
  exit 1
fi
