# Plugin Publishing

This repository is a dual-target plugin marketplace. Maintainers edit canonical
YAML metadata and plugin implementation files, then generate Claude and Codex
artifacts from the same source of truth.

## Source Of Truth

Edit these files by hand:

- `marketplace.yaml`
- `plugins/*/plugin.yaml`
- `plugins/*/skills/**`
- `plugins/*/commands/**`
- `plugins/*/agents/**`
- `plugins/*/hooks/**`
- `plugins/*/.mcp.json`

Do not hand-edit generated artifacts:

- `.claude-plugin/marketplace.json`
- `.agents/plugins/marketplace.json`
- `plugins/*/.claude-plugin/plugin.json`
- `plugins/*/.codex-plugin/plugin.json`
- `plugins/*/skills/cmd-<command-name>/SKILL.md` files whose body says they were
  generated from Claude slash commands

## Generate Artifacts

Install the generator dependency once:

```bash
python3 -m pip install -r scripts/requirements.txt
```

Regenerate all plugin artifacts:

```bash
python3 scripts/generate-plugin-artifacts.py
```

Check that generated artifacts are current:

```bash
./scripts/check-plugin-artifacts.sh
```

## Release Process

1. Create a release branch from `main`.
2. Update the relevant `plugins/<plugin>/plugin.yaml` version and metadata.
3. Update skills, commands, agents, hooks, or MCP config as needed.
4. Run `python3 scripts/generate-plugin-artifacts.py`.
5. Run `./scripts/check-plugin-artifacts.sh` and `./scripts/check-version-sync.sh`.
6. Open a PR including both source changes and generated artifacts.
7. Merge after GitHub Actions passes.
8. Tag the release, using either a plugin tag or marketplace tag:

```bash
git tag ololand-dd-v1.6.2
git push origin ololand-dd-v1.6.2
```

or:

```bash
git tag marketplace-v2026.05.12
git push origin marketplace-v2026.05.12
```

Pushing either tag pattern runs `.github/workflows/release.yml`, verifies the
generated artifacts again, and creates a GitHub Release with generated notes.

## Codex Compatibility

The generator writes Codex-compatible manifests at
`plugins/*/.codex-plugin/plugin.json` and a Codex marketplace at
`.agents/plugins/marketplace.json`.

Codex-specific plugin presentation metadata comes from each plugin's
`plugin.yaml` fields:

- `displayName`
- `shortDescription`
- `capabilities`
- `defaultPrompt`
- `interface`

The generator automatically includes Codex component paths when they exist:

- `skills` when `skills/*/SKILL.md` exists
- `hooks` when `hooks/hooks.json` exists
- `mcpServers` when `.mcp.json` exists
- `apps` when `.app.json` exists

Claude slash commands under `commands/*.md` are converted into generated Codex
skill wrappers under `skills/cmd-<command-name>/SKILL.md`. If a hand-written
skill already exists at that path, the generator fails instead of overwriting
it. Set `codex.generateCommandSkills: false` in a plugin's `plugin.yaml` to opt
out.

Claude sub-agent definitions remain in their existing folders. If Codex needs
equivalent behavior, add native Codex skills under `skills/` and regenerate
artifacts.
