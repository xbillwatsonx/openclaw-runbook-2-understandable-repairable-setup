# Prompt: Map My OpenClaw System

Copy this prompt into your OpenClaw chat. Run it before you change anything.

---

**Runbook bridge:** Read the released runbook at <https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.0/runbook/oc-runbook-2-understandable-repairable-setup.md> before acting. Relevant section: **§2, The system map**. This prompt helps the reader understand the six components; the agent should inspect read-only, explain in plain language, redact secrets, and make no changes.

I want to build a mental map of how my OpenClaw setup is put together. Do not change any files, config, services, or plugins. Just inspect and report.

For each of the following, tell me what it is, where it lives on this machine, and what it does:

1. **Gateway**: the process that runs OpenClaw. How does it run (systemd user service, system service, or something else)? What is the service name and current state? Run `openclaw status` and report.
2. **Configuration**: the active config file. Run `openclaw config file` to find its path. What is the config file format (JSON5)?
3. **Workspace**: where my files, notes, projects, and memory live.
4. **Plugins**: run `openclaw plugins list` and report how many are discovered and how many are enabled. Do not list every plugin, just the count and a few examples of what is enabled.
5. **Service manager**: how the gateway is started and kept running. Is it systemd? What is the unit name?
6. **Logs**: where do the gateway and service logs live? How would I read recent logs (for example, `journalctl --user -u openclaw-gateway.service -n 50`)?
7. **Boundaries**: what is the relationship between the gateway, the config, the workspace, and the plugins? Which one controls which?

Do not print any credentials, tokens, or secret values. Redact them if they appear.

After the map, tell me the one or two boundaries that are most important to understand before I change anything.
