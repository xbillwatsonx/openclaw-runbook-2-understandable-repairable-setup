# Build an OpenClaw Setup You Can Understand and Repair

> **The teaching guide.** This tutorial explains the concepts and the "why." When you are ready to actually do the work, use the copy-paste prompts in `prompts/` and let your OpenClaw agent execute them.

**Edition:** Linux and WSL only (first edition)
**Audience:** Technically comfortable people who know terminals and config files, but are new to OpenClaw internals.

---

## Table of Contents

1. [Why understanding beats memorizing](#1-why-understanding-beats-memorizing)
2. [The system map: six components, clear boundaries](#2-the-system-map-six-components-clear-boundaries)
3. [Configuration: read before you write](#3-configuration-read-before-you-write)
4. [The gateway and the service manager](#4-the-gateway-and-the-service-manager)
5. [Plugins: what they are and how to manage them](#5-plugins-what-they-are-and-how-to-manage-them)
6. [Gather evidence before you change anything](#6-gather-evidence-before-you-change-anything)
7. [The known-good baseline](#7-the-known-good-baseline)
8. [The safe-change workflow](#8-the-safe-change-workflow)
9. [What good looks like](#9-what-good-looks-like)

---

## 1. Why understanding beats memorizing

OpenClaw Runbook 1 gave you the safety foundation: backups, access, and a recovery plan. OpenClaw Runbook 2 is about something different but related: understanding how OpenClaw is actually put together, so that when something breaks or needs changing, you can find the right component and act without guessing.

There are two ways to run a tool like OpenClaw:

- **Memorize commands**: remember a list of magic incantations and hope they still work when the version changes.
- **Understand the structure**: know what the pieces are, where they live, and how they connect, so you can reason about any problem.

This runbook teaches the second way. It is not a reference manual of every config key. It is a working mental model. Once you have the model, the specific commands are easy to look up, because you know where to look.

The goal is simple: **you should be able to locate each major component and gather useful evidence before changing anything.**

---

## 2. The system map: six components, clear boundaries

OpenClaw is made of a small number of components with clear boundaries. Here is the map.

| Component | What it is | Where it lives (Linux/WSL) |
|-----------|------------|----------------------------|
| **Gateway** | The process that runs OpenClaw, manages sessions, and connects channels | Runs as a systemd user service |
| **Configuration** | How the gateway behaves, who can talk to it, what it can do | `~/.openclaw/openclaw.json` (JSON5) |
| **Workspace** | Your files, notes, projects, and memory | `~/.openclaw/workspace` |
| **Plugins** | Extensions that add providers, tools, and capabilities | Stock plugins bundled with OpenClaw, plus installed plugins |
| **Service manager** | How the gateway is started and kept running | systemd user unit `openclaw-gateway.service` |
| **Logs** | What the gateway and service have been doing | `journalctl --user -u openclaw-gateway.service` |

The boundaries are the important part. Here is how to think about them:

- The **gateway** is the running process. It is the thing that is "on."
- The **config** tells the gateway how to behave. It is a file, not a process.
- The **workspace** is your data. It is separate from the config.
- The **plugins** extend what the gateway can do. They are separate from the config and the workspace.
- The **service manager** keeps the gateway running. It is the thing that restarts the gateway if it stops.
- The **logs** record what happened. They are your first stop when something goes wrong.

A few consequences of these boundaries:

- Changing the config does not change the workspace, and vice versa. They are separate.
- The gateway reads the config at startup (and on reload). A config change does not take effect until the gateway reloads or restarts.
- A plugin problem is a plugin problem, not a config problem. Knowing which component is misbehaving tells you where to look.

---

## 3. Configuration: read before you write

The config file is `~/.openclaw/openclaw.json`, in JSON5 format. JSON5 is a superset of JSON that allows comments and trailing commas, which makes it friendlier to edit by hand.

OpenClaw gives you non-interactive config helpers, so you do not have to edit the file blindly. The most important ones:

| Command | What it does | Read-only or state-changing |
|---------|--------------|------------------------------|
| `openclaw config file` | Print the active config file path | Read-only |
| `openclaw config get <path>` | Get a value by dot path | Read-only |
| `openclaw config set <path> <value>` | Set a value by dot path | State-changing |
| `openclaw config patch` | Patch config from a JSON5 object in one validated write | State-changing |
| `openclaw config unset <path>` | Remove a value by dot path | State-changing |
| `openclaw config validate` | Validate config against the schema | Read-only |
| `openclaw config schema` | Print the JSON schema | Read-only |

The **dot path** is how you address a value. For example, `gateway.port` addresses the port, and `channels.discord.token` addresses the Discord token. This is the key concept: you can read and change individual values without touching the whole file.

The safe habit is: **read before you write.** Use `openclaw config get` to see the current value, `openclaw config validate` to confirm the file is valid, and only then make a change. And after any change, validate again.

---

## 4. The gateway and the service manager

The gateway runs as a **systemd user service** named `openclaw-gateway.service`. "User service" means it is managed per-user (with `systemctl --user`), not system-wide, and it lives under your home directory.

On WSL, these commands require a distribution running systemd. If `systemctl --user` reports that systemd is not running or cannot connect to the user bus, stop the service steps. Check the current Microsoft WSL documentation or ask an administrator rather than changing the service setup by guesswork.

The commands you need:

| Command | What it does | Read-only or state-changing |
|---------|--------------|------------------------------|
| `systemctl --user status openclaw-gateway.service` | Check service state | Read-only |
| `systemctl --user restart openclaw-gateway.service` | Restart the gateway | State-changing |
| `systemctl --user stop openclaw-gateway.service` | Stop the gateway | State-changing |
| `systemctl --user start openclaw-gateway.service` | Start the gateway | State-changing |
| `journalctl --user -u openclaw-gateway.service -n 50` | Read recent logs | Read-only |

On a default local install, the gateway binds to **loopback only** (`ws://127.0.0.1:18789`). That means it is reachable from the local machine and not exposed to the network. That is the default, and it is a good default.

The key habit: when something goes wrong, check the service state first (`systemctl --user status`), then read the logs (`journalctl`). The logs almost always tell you what actually happened.

---

## 5. Plugins: what they are and how to manage them

Plugins extend OpenClaw with providers, tools, and capabilities. There are two kinds:

- **Stock plugins**: bundled with OpenClaw itself. They are already there, and you enable or disable them.
- **Installed plugins**: added by you, from a path, an archive (`.zip`, `.tgz`, or `.tar.gz`), an npm package, a git repo, a `clawhub:` package, or a marketplace entry.

The commands you need:

| Command | What it does | Read-only or state-changing |
|---------|--------------|------------------------------|
| `openclaw plugins list` | List discovered plugins and their state | Read-only |
| `openclaw plugins install <spec>` | Install a plugin | State-changing |
| `openclaw plugins uninstall <plugin>` | Uninstall a plugin | State-changing |
| `openclaw plugins enable <plugin>` | Enable a plugin | State-changing |
| `openclaw plugins disable <plugin>` | Disable a plugin | State-changing |
| `openclaw plugins doctor` | Report plugin load issues | Read-only |
| `openclaw plugins inspect <plugin>` | Inspect plugin details | Read-only |
| `openclaw plugins update` | Update installed plugins | State-changing |

Flags worth knowing:

- `--pin` records an npm install as an exact resolved `<name>@<version>`, so you can reproduce the exact version later. This is good practice for reproducibility.
- `--link` links a local path instead of copying it, which is useful when you are developing a plugin.
- `--force` both confirms a non-ClawHub source and permits overwrite of an existing plugin or hook pack. Those are separate safety effects, so do not use it as a routine shortcut.

Installation may ask you to accept the plugin's declared capabilities or acknowledge an install-policy warning. In 2026.9.4, the corresponding non-interactive flags are `--accept-capabilities` and `--acknowledge-install-policy-warning`; the latter does not bypass policy blocks or failures. Treat both as decisions, not convenience flags: inspect the source and read the capability/policy details before approving them.

The safe practice is a controlled lifecycle: you select a trusted spec, make a verified backup, review source/capabilities/policy warnings and the uninstall plan, then approve one install. Installation writes executable plugin code plus tracked records and may update config; depending on required configuration, the resulting plugin can be enabled or disabled. Confirm the actual state with `plugins doctor`, `plugins inspect`, and `plugins list`. Preview removal with `plugins uninstall <id> --dry-run`, because uninstall removes the applicable settings, records, allow/deny entries, exact load paths, and managed files shown in the preview. Multi-entry packages can also affect sibling policy and slot/channel references, and uninstall leaves an `enabled: false` marker for each removed plugin ID. Approve the interactive uninstall only when the preview is expected, then verify removal. Installing or removing plugin code requires a gateway restart before the running gateway reflects it. Record the installer's restart/config-reload message: a running-Gateway install can request an automatic restart when config reload is enabled, while a separate-shell install requires a later manual restart; config reload can also restart connected channels. Prompt 07 does not run a restart command or claim runtime-capability testing. If an automatic restart or channel reload occurs, stop and record that the no-restart boundary changed. Stop if trust, capabilities, warnings, installed state, uninstall scope, rollback, or approval is unclear.

---

## 6. Gather evidence before you change anything

Before you change anything, gather evidence. This is the habit that separates a careful operator from someone who guesses.

The read-only diagnostics:

| Command | What it reports | Read-only or state-changing |
|---------|-----------------|------------------------------|
| `openclaw status` | Gateway, channel, and session summary | Read-only |
| `openclaw status --all` | Full diagnosis (pasteable) | Read-only |
| `openclaw status --deep` | Channel probes (WhatsApp, Telegram, Discord, Slack, Signal) | Read-only |
| `openclaw doctor --lint` | Read-only health checks | Read-only |
| `openclaw security audit` | Security findings (footguns, exposure, perms) | Read-only |
| `openclaw plugins doctor` | Plugin load issues | Read-only |

The rule is simple: **evidence first, change second.** Run the read-only diagnostics, understand what they tell you, and only then make a change. Do not run the `--fix` or `--repair` variants until you understand exactly what they change.

---

## 7. The known-good baseline

A baseline is a snapshot of "what working looks like." You record it before you change anything, so you can detect drift afterward.

A baseline should capture:

- **Version**: `openclaw --version`
- **Gateway state**: `openclaw status`
- **Config path and validity**: `openclaw config file`, `openclaw config validate`
- **Plugin count**: `openclaw plugins list`
- **Service state**: `systemctl --user status openclaw-gateway.service`
- **Disk space**: `df -h ~`
- **Backup freshness**: last backup date

Save it as a dated markdown file (for example, `openclaw-baseline-YYYY-MM-DD.md`). After any change, compare against the baseline to see what drifted.

The baseline is your "before" picture. Without it, you cannot tell whether a change actually changed anything, or whether a problem existed before you touched it.

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

The most important rule: **change one thing at a time.** If you change three things and something breaks, you do not know which one caused it. If you change one thing and something breaks, you know exactly what to revert.

This is the same discipline as Runbook 1's backup-first rule, applied to every change, not just updates.

---

## 9. What good looks like

You are done with this runbook when all of these are true:

- You can name the six components (gateway, config, workspace, plugins, service manager, logs) and their boundaries.
- You can locate each component on your machine with a real command.
- You can read your config safely and validate it.
- You can check and restart the gateway service.
- You can install, verify, and uninstall a plugin.
- You ran the read-only diagnostics and understood the output.
- You recorded a known-good baseline.
- You practiced one safe change end to end.

And the stop conditions, the things that mean "stop and think before you keep going":

- You are about to change config without a backup.
- You are about to change multiple things at once.
- You are about to run `--fix` or `--repair` without understanding what it changes.
- You are about to change credentials, tokens, or security settings.
- You are about to run `openclaw reset` or `openclaw uninstall`.
- On WSL, `systemctl --user` says systemd is not running or cannot connect to the user bus.
- A plugin source, requested capability, policy warning, installed ID, or uninstall plan is unclear.

---

## Next step

When you are ready to actually do the work, give your agent the [runbook](../runbook/oc-runbook-2-understandable-repairable-setup.md) first, then open [`prompts/`](../prompts/) and work through the prompts in order, pasting each one into your OpenClaw chat. Your agent will do the work, and you will have a setup you understand and can repair.

---

## License

Copyright © 2026 Bill Watson. All rights reserved.

Personal learning and internal operational use are permitted. Redistribution, resale, white-labeling, sublicensing, and using this protected material as the basis of an offering to others require prior written permission. The complete terms are in [LICENSE.md](../LICENSE.md).

## Get the next guide

Agenthelpsite.com is growing one carefully tested guide at a time.

Get the next guide, tutorial or runbook the moment it's released.

Join the list to hear when the next one is ready: [https://agenthelpsite.com/subscribe](https://agenthelpsite.com/subscribe)
