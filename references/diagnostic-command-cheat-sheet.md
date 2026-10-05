# OpenClaw 2026.9.4 - Diagnostic Command Cheat Sheet (Read-Only)

These commands inspect the system without changing anything.

| Command | What it reports | Version |
|---------|----------------|---------|
| `openclaw status` | Gateway, channel, and session summary table | 2026.9.4 |
| `openclaw status --all` | Full diagnosis (pasteable into reports) | 2026.9.4 |
| `openclaw status --deep` | Channel probes: WhatsApp, Telegram, Discord, Slack, Signal status | 2026.9.4 |
| `openclaw doctor --lint` | Read-only health checks | 2026.9.4 |
| `openclaw security audit` | Security findings: footguns, exposure, permissions | 2026.9.4 |
| `openclaw plugins doctor` | Plugin load issues and warnings | 2026.9.4 |

**Do not run** `--fix` or `--repair` variants until you understand what they change. These are state-changing and not part of the read-only diagnostic set.

All commands are read-only. No operator-specific paths, usernames, hosts, session IDs, credentials, tokens, or personal data appear in this file.
