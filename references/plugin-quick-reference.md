# OpenClaw 2026.9.4 - Plugin Quick Reference

These commands inspect plugin state without changing anything.

| Command | What it reports | Usage (generic) |
|---------|----------------|-----------------|
| `openclaw plugins list` | List all discovered plugins and their enabled/disabled state | Run alone; no arguments needed. |
| `openclaw plugins doctor` | Report plugin load issues, failures, or warnings | Run alone; no arguments needed. |
| `openclaw plugins inspect <plugin>` | Inspect details of a specific plugin (name only; no operator data) | Replace `<plugin>` with the plugin name as reported by `openclaw plugins list`. Read-only; no changes. |

## Safe lifecycle practice

Use only a trusted plugin spec selected by the user; this reference deliberately does not name or endorse one. Discover candidates with the read-only `openclaw plugins search <query>` command, browse ClawHub, or use a local plugin path you already trust. A spec may be a local path, archive (`.zip`, `.tgz`, or `.tar.gz`), npm package, git repository, `clawhub:` package, or marketplace entry.

1. Back up and verify the backup.
2. Review the source, declared capabilities, install-policy warnings, version/pinning choice, and uninstall plan.
3. Ask for explicit approval before `openclaw plugins install <trusted-user-selected-spec>`. Treat it as executable-code installation that writes tracked files/records and may update config.
4. Verify the actual enabled/disabled state with `openclaw plugins doctor`, `openclaw plugins inspect <installed-plugin-id>`, and `openclaw plugins list`; do not invoke capabilities.
5. Preview removal with `openclaw plugins uninstall <installed-plugin-id> --dry-run`. Review the applicable plugin settings, install/index records, allow/deny entries, exact load paths, managed files, sibling policy, slot/channel references, and `enabled: false` markers shown for that installation.
6. Ask for explicit approval before the interactive `openclaw plugins uninstall <installed-plugin-id>`. Do not add `--force` or `--keep-files` without separate approval.
7. Verify removal with `openclaw plugins list`, `openclaw plugins doctor`, and `openclaw plugins inspect <installed-plugin-id>`.

In 2026.9.4, `--accept-capabilities` records acceptance of declared capabilities, while `--acknowledge-install-policy-warning` acknowledges policy warnings without prompting; blocks and failures still stop installation. Do not add either flag until the user has reviewed and explicitly accepted what it covers. `--force` both confirms a non-ClawHub source and permits overwrite of an existing plugin or hook pack, so it is not a routine shortcut.

Installing or removing plugin code requires a Gateway restart before the running Gateway reflects that code change. Record the installer's restart/config-reload message: a running-Gateway install can request an automatic restart when config reload is enabled, while a separate-shell install requires a later manual restart; config reload can also restart connected channels. The bounded practice does not run a restart command or claim runtime verification. If an automatic restart or channel reload occurs, stop and record that the no-restart boundary changed.

Stop before installation if the source is untrusted, capabilities or policy warnings are unclear, the plugin ID or uninstall plan is unknown, the backup fails, or approval is absent. Stop if install state or the uninstall dry-run preview is unexpected, ownership is ambiguous, or verification fails.

All paths and names are generic. No operator-specific plugin names or paths appear in this file.
