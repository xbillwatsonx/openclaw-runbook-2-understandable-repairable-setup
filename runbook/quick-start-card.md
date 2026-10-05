# Quick Start Card

Use this when you want to understand and repair your OpenClaw setup without becoming a sysadmin.

## The Simple Setup

Work through these three things:

1. Map your system (gateway, config, workspace, plugins, service manager, logs).
2. Record a known-good baseline.
3. Practice one safe change end to end.

## Prompt Order

### Do Today

1. [`01-map-my-openclaw-system.md`](../prompts/01-map-my-openclaw-system.md): build your mental map
2. [`02-read-my-config-safely.md`](../prompts/02-read-my-config-safely.md): understand your config
3. [`03-check-the-gateway-and-service-manager.md`](../prompts/03-check-the-gateway-and-service-manager.md): understand the gateway
4. [`04-understand-and-manage-plugins.md`](../prompts/04-understand-and-manage-plugins.md): understand plugins
5. [`05-run-diagnostic-checks-and-gather-evidence.md`](../prompts/05-run-diagnostic-checks-and-gather-evidence.md): gather evidence
6. [`06-record-a-known-good-baseline.md`](../prompts/06-record-a-known-good-baseline.md): record your baseline

### Complete the Runbook

7. [`07-practice-one-safe-change-end-to-end.md`](../prompts/07-practice-one-safe-change-end-to-end.md): practice the bounded plugin install → inspect → uninstall-preview → uninstall → verify workflow with a trusted plugin spec you select; Gateway restart/runtime testing requires separate approval

## What To Tell The Agent First

Give your agent the [runbook](oc-runbook-2-understandable-repairable-setup.md) first. Your agent reads the whole runbook before acting.

```text
Please use this runbook to help me understand and repair my OpenClaw setup. Start by mapping my system: what the gateway is, where my config and workspace live, what plugins are installed, and how the service runs. Do not change files yet. First explain what you found and what I should understand before changing anything.
```

## What Good Looks Like

- you can name the six components and their boundaries
- you can locate each component with a real command
- you can read and validate your config safely
- you can check and restart the gateway
- you can install, verify, and uninstall a plugin while distinguishing disk/config checks from separately approved runtime verification
- you have a known-good baseline
- you practiced one safe change end to end

## Safety Boundary

Do not ask the agent to run `openclaw reset`, uninstall OpenClaw itself, or change credentials, tokens, or security settings. Back up before any change. Change one thing at a time. For plugin practice, select a trusted spec yourself, review capabilities and policy warnings, require approval before install, review `plugins uninstall <id> --dry-run`, and require approval before interactive uninstall. Installing/removing plugin code needs a Gateway restart to affect the running process. Record whether the installer says a running-Gateway path requested an automatic restart or a separate-shell path requires a later manual restart; keep any restart/runtime testing separate unless explicitly approved. On WSL, stop service steps if `systemctl --user` reports that systemd is unavailable.
