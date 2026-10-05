# OpenClaw 2026.9.4 - System Map (Linux/WSL first edition)

| Component | What it is | Where it lives (Linux/WSL) | How to locate it |
|-----------|------------|---------------------------|-----------------|
| **Gateway** | The OpenClaw process that runs the agent, manages sessions, and connects channels | Runs as a systemd user service | `systemctl --user status openclaw-gateway.service` |
| **Configuration** | The `openclaw.json` file that tells the gateway how to behave, who can talk to it, and what it can do | `~/.openclaw/openclaw.json` (JSON5 format) | `openclaw config file` prints the path; `openclaw config get <dot-path>` reads values |
| **Workspace** | `~/.openclaw/workspace`: your files, notes, projects, and memory | Defaults to `~/.openclaw/workspace`; an agent can use a configured override | Start with the default path, then inspect that agent's configuration if the directory was overridden |
| **Plugins** | Extensions that add providers, tools, or capabilities to OpenClaw | Stock plugins bundled with OpenClaw; installed plugins added by the user | `openclaw plugins list` reports installed and stock plugins |
| **Service manager** | The system (systemd) that starts and keeps the gateway running | systemd user unit `openclaw-gateway.service` | `systemctl --user status openclaw-gateway.service` |
| **Logs** | The record of what the gateway and service have been doing, read with `journalctl` | Read via `journalctl --user -u openclaw-gateway.service` | `journalctl --user -u openclaw-gateway.service -n 50` shows the last 50 entries |

**Key boundaries (2026.9.4):**
- The gateway is the running process. The config is a file that tells it how to behave at startup and on reload. The workspace is your data, separate from config. Plugins extend what the gateway can do. The service manager keeps the gateway running. The logs record what happened.
- Changing the config does not change the workspace, and vice versa. They are separate.
- The gateway reads the config at startup (and on reload). A config change does not take effect until the gateway reloads or restarts.
- A plugin problem is a plugin problem, not a config problem. Knowing which component is misbehaving tells you where to look.

**WSL prerequisite:** These service and log commands require a WSL distribution that is running systemd. If `systemctl --user` reports that systemd is not running or cannot connect to the user bus, stop this runbook's service steps. Confirm the WSL/systemd setup through the current Microsoft WSL documentation or ask an administrator; do not improvise a service-manager change from this runbook.
