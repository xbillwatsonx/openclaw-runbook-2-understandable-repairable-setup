# OpenClaw 2026.9.4 - Known-Good Baseline Template

Record this before you change anything, so you can detect drift afterward.

| Field | What to record | How to record (command) | Example |
|-------|---------------|------------------------|---------|
| **Version** | OpenClaw version | `openclaw --version` | `OpenClaw 2026.9.4` |
| **Gateway state** | Gateway running? status summary | `openclaw status` | (output table) |
| **Config path** | Active config file path | `openclaw config file` | `~/.openclaw/openclaw.json` |
| **Config validity** | Schema-valid? | `openclaw config validate` | `pass` or `fail` + notes |
| **Plugin count** | How many installed plugins | `openclaw plugins list` | `3 stock + 2 installed` |
| **Service state** | systemd user service up? | If Prompt 03 confirmed systemd: `systemctl --user status openclaw-gateway.service`; otherwise record the read-only error and `not available in this environment` | `active (running)` or `not available in this environment` |
| **Disk space** | Available space in workspace | `df -h ~` | `Filesystem Size Used Avail Use% <home>` |
| **Backup freshness** | Last backup date | (date of your last backup) | `2026-09-28` |

Save this file as a dated markdown file:
```
openclaw-baseline-2026-10-02.md
```
or your preferred date format under the actual workspace path discovered in Prompt 01. Do not assume the default workspace when an agent-specific override exists.

After any change, compare the current output against this baseline to detect drift.
