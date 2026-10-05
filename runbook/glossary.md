# Glossary

Plain definitions for the terms this runbook uses.

| Term | What it means |
|------|---------------|
| **Gateway** | The OpenClaw process that runs the agent, manages sessions, and connects channels. |
| **Configuration** | The `openclaw.json` file that tells the gateway how to behave, who can talk to it, and what it can do. |
| **Workspace** | `~/.openclaw/workspace`: your files, notes, projects, and memory. |
| **Plugin** | An extension that adds providers, tools, or capabilities to OpenClaw. |
| **Stock plugin** | A plugin bundled with OpenClaw itself. |
| **Installed plugin** | A plugin you added yourself. |
| **Service manager** | The system (systemd) that starts and keeps the gateway running. |
| **Service unit** | The systemd user unit (`openclaw-gateway.service`) that defines how the gateway runs. |
| **Logs** | The record of what the gateway and service have been doing, read with `journalctl`. |
| **JSON5** | A superset of JSON that allows comments and trailing commas. OpenClaw's config format. |
| **Dot path** | A way to address a config value, like `gateway.port` or `channels.discord.token`. |
| **Baseline** | A recorded snapshot of "what working looks like," used to detect drift after a change. |
| **Loopback** | A network address (`127.0.0.1`) reachable only from the local machine. |
| **systemd user service** | A service managed per-user (not system-wide), started with `systemctl --user`. |
| **Read-only** | A command that inspects but does not change anything. |
| **State-changing** | A command that modifies files, config, services, or plugins. |
| **Safe-change workflow** | Back up, change one thing, validate, test, record. |
