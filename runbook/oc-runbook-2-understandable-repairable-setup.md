# Build an OpenClaw Setup You Can Understand and Repair

**OpenClaw Runbook 2 of the AgentHelpSite OpenClaw Beginner Runbook Series**

This is the operational runbook. It pairs with the tutorial ([tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md](../tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md)) and the copy-paste prompts ([prompts/](../prompts/) or [prompts.txt](../prompts.txt)). Read the tutorial to understand the concepts, then use the prompts to have your OpenClaw agent do the work.

**Edition:** Linux and WSL only (first edition)
**Audience:** Technically comfortable people who know terminals and config files, but are new to OpenClaw internals.

---

## Table of Contents

1. [What this runbook is for](#1-what-this-runbook-is-for)
2. [The system map](#2-the-system-map)
3. [Configuration: read and change safely](#3-configuration-read-and-change-safely)
4. [The gateway and service manager](#4-the-gateway-and-service-manager)
5. [Plugins: install, remove, verify](#5-plugins-install-remove-verify)
6. [Diagnostic checks and evidence](#6-diagnostic-checks-and-evidence)
7. [Recording a known-good baseline](#7-recording-a-known-good-baseline)
8. [The safe-change workflow](#8-the-safe-change-workflow)
9. [Success checks and stop conditions](#9-success-checks-and-stop-conditions)
10. [Command-safety table](#10-command-safety-table)

---

## 1. What this runbook is for

OpenClaw Runbook 1 gave you the safety foundation: backups, access, and a recovery plan. OpenClaw Runbook 2 builds on that by giving you a working mental model of how OpenClaw is put together, so that when something breaks or needs changing, you can find the right component, gather evidence, and act without guessing.

By the end, you will be able to locate the gateway, config, workspace, plugins, service manager, and logs, and you will have practiced one safe change end to end.

**How to use it:** read the tutorial to understand the concepts. Then work through the prompts in order, pasting each one into your OpenClaw chat and letting your agent do the work.

---

## 2. The system map

OpenClaw is made of a small number of components with clear boundaries. Here is the map.

| Component | What it is | Where it lives (Linux/WSL) |
|-----------|------------|----------------------------|
| **Gateway** | The process that runs OpenClaw, manages sessions, and connects channels | Runs as a systemd user service |
| **Configuration** | How the gateway behaves, who can talk to it, what it can do | `~/.openclaw/openclaw.json` (JSON5) |
| **Workspace** | Your files, notes, projects, and memory | `~/.openclaw/workspace` |
| **Plugins** | Extensions that add providers, tools, and capabilities | Stock plugins bundled with OpenClaw, plus installed plugins |
| **Service manager** | How the gateway is started and kept running | systemd user unit `openclaw-gateway.service` |
| **Logs** | What the gateway and service have been doing | `journalctl --user -u openclaw-gateway.service` |

The key boundaries to understand:

- The **gateway** is the running process. The **config** tells it how to behave. The **workspace** is your data. The **plugins** extend what it can do. The **service manager** keeps it running. The **logs** record what happened.
- Changing the config does not change the workspace, and vice versa. They are separate.
- The gateway reads the config at startup (and on reload). A config change does not take effect until the gateway reloads or restarts.

---

## 3. Configuration: read and change safely

The config file is `~/.openclaw/openclaw.json`, in JSON5 format (a superset of JSON that allows comments and trailing commas).

OpenClaw provides non-interactive config helpers:

| Command | What it does | Read-only or state-changing |
|---------|--------------|------------------------------|
| `openclaw config file` | Print the active config file path | Read-only |
| `openclaw config get <path>` | Get a value by dot path | Read-only |
| `openclaw config set <path> <value>` | Set a value by dot path | State-changing |
| `openclaw config patch` | Patch config from a JSON5 object in one validated write | State-changing |
| `openclaw config unset <path>` | Remove a value by dot path | State-changing |
| `openclaw config validate` | Validate config against the schema without starting the gateway | Read-only |
| `openclaw config schema` | Print the JSON schema for `openclaw.json` | Read-only |

**The safe-change rule:** back up first, change one thing, validate, test, record. Never edit the config blindly. Use `openclaw config validate` after any change to confirm it is still valid.

---

## 4. The gateway and service manager

The gateway runs as a **systemd user service** named `openclaw-gateway.service`.

**WSL prerequisite:** the service commands below require a WSL distribution running systemd. If `systemctl --user` says systemd is not running or cannot connect to the user bus, stop the service steps. Verify the WSL/systemd setup against current Microsoft WSL documentation or ask an administrator; do not improvise a service-manager change from this runbook.

| Command | What it does | Read-only or state-changing |
|---------|--------------|------------------------------|
| `systemctl --user status openclaw-gateway.service` | Check service state | Read-only |
| `systemctl --user restart openclaw-gateway.service` | Restart the gateway | State-changing |
| `systemctl --user stop openclaw-gateway.service` | Stop the gateway | State-changing |
| `systemctl --user start openclaw-gateway.service` | Start the gateway | State-changing |
| `journalctl --user -u openclaw-gateway.service -n 50` | Read recent logs | Read-only |

On a default local install, the gateway binds to loopback only (`ws://127.0.0.1:18789`), reachable from the local machine and not exposed to the network.

---

## 5. Plugins: install, remove, verify

Plugins extend OpenClaw with providers, tools, and capabilities. There are **stock plugins** (bundled with OpenClaw) and **installed plugins** (added by you).

| Command | What it does | Read-only or state-changing |
|---------|--------------|------------------------------|
| `openclaw plugins list` | List discovered plugins and their enabled/disabled state | Read-only |
| `openclaw plugins install <spec>` | Install a plugin (path, archive, npm spec, git repo, `clawhub:` package, or marketplace entry) | State-changing |
| `openclaw plugins uninstall <plugin>` | Uninstall a plugin | State-changing |
| `openclaw plugins enable <plugin>` | Enable a plugin in config | State-changing |
| `openclaw plugins disable <plugin>` | Disable a plugin in config | State-changing |
| `openclaw plugins doctor` | Report plugin load issues | Read-only |
| `openclaw plugins inspect <plugin>` | Inspect plugin details | Read-only |
| `openclaw plugins update` | Update installed plugins | State-changing |

**Install flags worth knowing:**

- `--pin` records npm installs as exact resolved `<name>@<version>`, so you can reproduce the exact version later.
- `--link` links a local path instead of copying it (useful for developing a plugin).
- `--accept-capabilities` accepts the plugin's declared capabilities. Review them first; do not accept them automatically.
- `--acknowledge-install-policy-warning` acknowledges install-policy warnings without prompting; policy blocks and failures still stop installation. Read and understand each warning first.
- `--force` does two things: it confirms a non-ClawHub source and permits overwrite of an existing plugin or hook pack. Do not use it as a routine shortcut.

**The safe rule:** use a trusted plugin spec that you select; review its source, declared capabilities, policy warnings, version/pinning choice, and uninstall plan before approving installation. Treat install as executable-code installation: it writes tracked plugin files and records, may update plugin config, and can leave the plugin enabled or disabled depending on its configuration. Verify the resulting state with `openclaw plugins doctor`, `openclaw plugins inspect <plugin>`, and `openclaw plugins list`. Before removal, preview it with `openclaw plugins uninstall <plugin> --dry-run`; uninstall removes the applicable settings, records, allow/deny entries, exact load paths, and managed files shown in the preview. Multi-entry packages can also affect sibling policy and slot/channel references, and uninstall leaves an `enabled: false` marker for each removed plugin ID. Approve the interactive uninstall only when that preview is expected, then verify the result. Installing or removing plugin code requires a gateway restart before the running gateway reflects the code change. Record the installer's restart/config-reload message: a running-Gateway install can request an automatic restart when config reload is enabled, while a separate-shell install requires a later manual restart; config reload can also restart connected channels. Prompt 07 does not run a restart command or claim runtime testing. If an automatic restart or channel reload occurs, stop and record that the no-restart boundary changed.

---

## 6. Diagnostic checks and evidence

Before you change anything, gather evidence. These are the read-only diagnostics.

| Command | What it reports | Read-only or state-changing |
|---------|-----------------|------------------------------|
| `openclaw status` | Gateway, channel, and session summary | Read-only |
| `openclaw status --all` | Full diagnosis (pasteable) | Read-only |
| `openclaw status --deep` | Channel probes (WhatsApp, Telegram, Discord, Slack, Signal) | Read-only |
| `openclaw doctor --lint` | Read-only health checks | Read-only |
| `openclaw security audit` | Security findings (footguns, exposure, perms) | Read-only |
| `openclaw plugins doctor` | Plugin load issues | Read-only |

Do not run the `--fix` or `--repair` variants until you understand what they change. Evidence first, change second.

---

## 7. Recording a known-good baseline

A baseline is a snapshot of "what working looks like." Record it before you change anything, so you can detect drift afterward.

A baseline should capture:

- Version (`openclaw --version`)
- Gateway state (`openclaw status`)
- Config path and validity (`openclaw config file`, `openclaw config validate`)
- Plugin count (`openclaw plugins list`)
- Service state (`systemctl --user status openclaw-gateway.service`)
- Disk space (`df -h ~`)
- Backup freshness (last backup date)

Save it as a dated markdown file (for example, `openclaw-baseline-YYYY-MM-DD.md`). After any change, compare against the baseline to see what drifted.

---

## 8. The safe-change workflow

Every change follows the same loop:

```text
Back up → Change one thing → Validate → Test → Record
```

1. **Back up**: `openclaw backup create --verify --output ~/Backups`
2. **Change one thing**: make a single, small, reversible change.
3. **Validate**: `openclaw config validate` (for config changes) or the relevant check.
4. **Test**: run the diagnostic that confirms everything still works.
5. **Record**: note what changed, when, and how to revert it.

Never change multiple things at once. If something breaks, you want to know exactly which change caused it.

---

## 9. Success checks and stop conditions

### Success checks

- [ ] You can name the six components (gateway, config, workspace, plugins, service manager, logs) and their boundaries.
- [ ] You can locate each component on your machine with a real command.
- [ ] You can read your config safely and validate it.
- [ ] You can check and restart the gateway service.
- [ ] You can install, verify, and uninstall a plugin.
- [ ] You ran the read-only diagnostics and understood the output.
- [ ] You recorded a known-good baseline.
- [ ] You practiced one safe change end to end.

### Stop conditions

- **You are about to change config without a backup.** Back up first.
- **You are about to change multiple things at once.** Change one thing at a time.
- **You are about to run `--fix` or `--repair` without understanding what it changes.** Read the help first.
- **You are about to change credentials, tokens, or security settings.** These are high-risk; proceed with extra care.
- **You are about to run `openclaw reset` or `openclaw uninstall`.** These are destructive; do not run them casually.
- **On WSL, `systemctl --user` says systemd is not running or cannot connect to the user bus.** Stop the service steps and verify the prerequisite first.
- **A plugin source, capability request, policy warning, installed ID, or uninstall plan is unclear.** Do not install it.

---

## 10. Command-safety table

| Command | Where it runs | Read-only or state-changing | What it changes | Success looks like |
|---------|---------------|------------------------------|-----------------|--------------------|
| `openclaw status` | local | Read-only | Nothing | Overview table |
| `openclaw status --all` | local | Read-only | Nothing | Full diagnosis |
| `openclaw status --deep` | local | Read-only | Nothing | Channel probe results |
| `openclaw config file` | local | Read-only | Nothing | Config path printed |
| `openclaw config get <path>` | local | Read-only | Nothing | Value printed |
| `openclaw config validate` | local | Read-only | Nothing | "valid" or errors |
| `openclaw config schema` | local | Read-only | Nothing | JSON schema printed |
| `openclaw config set <path> <value>` | local | State-changing | Sets a config value | Value set |
| `openclaw config patch` | local | State-changing | Patches config | Config patched |
| `openclaw config unset <path>` | local | State-changing | Removes a config value | Value removed |
| `openclaw plugins list` | local | Read-only | Nothing | Plugin list |
| `openclaw plugins install <spec>` | local | State-changing | Installs a plugin | Plugin installed |
| `openclaw plugins uninstall <plugin>` | local | State-changing | Uninstalls a plugin | Plugin removed |
| `openclaw plugins enable <plugin>` | local | State-changing | Enables a plugin | Plugin enabled |
| `openclaw plugins disable <plugin>` | local | State-changing | Disables a plugin | Plugin disabled |
| `openclaw plugins doctor` | local | Read-only | Nothing | Load issues reported |
| `openclaw plugins inspect <plugin>` | local | Read-only | Nothing | Plugin details |
| `openclaw doctor --lint` | local | Read-only | Nothing | Health check report |
| `openclaw doctor --fix` | local | State-changing | Applies repairs | Repairs applied |
| `openclaw security audit` | local | Read-only | Nothing | Findings reported |
| `openclaw security audit --fix` | local | State-changing (narrow) | Tightens allowlists and perms | Findings resolved |
| `systemctl --user status openclaw-gateway.service` | local | Read-only | Nothing | "active (running)" |
| `systemctl --user restart openclaw-gateway.service` | local | State-changing | Restarts gateway | Service back to "active (running)" |
| `journalctl --user -u openclaw-gateway.service -n 50` | local | Read-only | Nothing | Recent logs |

For plugin installation, "Plugin installed" is only an intermediate result. Completion requires confirming the actual enabled/disabled state, successful doctor/inspect/list checks, review of `plugins uninstall <id> --dry-run`, a confirmed uninstall, and post-uninstall list/doctor/inspect checks. Because plugin code changes require a gateway restart to affect the running process, this exercise must state whether restart/runtime verification was separately approved or not performed.

For the plain-language teaching guide, see [the companion tutorial](../tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md). For all seven copyable prompts in one file, use [prompts.txt](../prompts.txt).

---

## License

Copyright © 2026 Bill Watson. All rights reserved.

Personal learning and internal operational use are permitted. Redistribution, resale, white-labeling, sublicensing, and using this protected material as the basis of an offering to others require prior written permission. The complete terms are in [LICENSE.md](../LICENSE.md).

## Get the next guide

Agenthelpsite.com is growing one carefully tested guide at a time.

Get the next guide, tutorial or runbook the moment it's released.

Join the list to hear when the next one is ready: [https://agenthelpsite.com/subscribe](https://agenthelpsite.com/subscribe)
