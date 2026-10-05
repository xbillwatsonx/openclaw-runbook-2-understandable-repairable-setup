# Prompt: Check the Gateway and Service Manager

Copy this prompt into your OpenClaw chat.

---

**Runbook bridge:** Read the released runbook at <https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.1/runbook/oc-runbook-2-understandable-repairable-setup.md> before acting. Relevant section: **§4, The gateway and service manager**. This prompt helps the reader understand gateway operation; the agent should inspect read-only, explain commands and the WSL/systemd prerequisite, and make no service changes.

I want to understand how my OpenClaw gateway runs and how to check and restart it safely. Do not restart anything yet. Just inspect and explain.

Please:

1. Run `openclaw status` and report the gateway state, bind address, and service type.
2. Tell me the systemd user unit name for the gateway (for example, `openclaw-gateway.service`).
3. Show me the read-only command to check the service state: `systemctl --user status openclaw-gateway.service`. Explain what "active (running)" means.
4. Show me the command to restart the service: `systemctl --user restart openclaw-gateway.service`. Explain what it changes and what success looks like.
5. Show me how to read recent logs: `journalctl --user -u openclaw-gateway.service -n 50`. Explain what to look for.
6. Explain the difference between restarting the gateway via `systemctl --user restart` versus using the `openclaw gateway restart` command, if both exist.

On WSL, first confirm that `systemctl --user` can reach a running systemd user service. If it cannot, stop and explain the prerequisite; do not try to reconfigure WSL or substitute another service manager.

Do not restart the service. Do not change anything. Just give me the commands and explain what each one does and when I would use it.
