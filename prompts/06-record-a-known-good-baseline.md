# Prompt: Record a Known-Good Baseline

Copy this prompt into your OpenClaw chat.

---

**Runbook bridge:** Read the released runbook at <https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.1/runbook/oc-runbook-2-understandable-repairable-setup.md> before acting. Relevant section: **§7, Recording a known-good baseline**. This prompt helps the reader preserve a safe comparison point; the agent should gather read-only evidence, redact secrets, write only the approved baseline file, and report its path.

I want to record a known-good baseline of my OpenClaw setup, so I have a reference point to compare against after any change. Do not change anything. Just gather and record.

Please produce a baseline that captures:

1. **Version**: run `openclaw --version` and record it.
2. **Gateway state**: run `openclaw status` and record the gateway state, bind address, and service type.
3. **Config path and validity**: run `openclaw config file` and `openclaw config validate`, and record the path and whether it is valid.
4. **Plugins**: run `openclaw plugins list` and record the count of discovered and enabled plugins.
5. **Service state**: if Prompt 03 confirmed a working systemd user service, run `systemctl --user status openclaw-gateway.service` and record whether it is active. If systemd or the user bus is unavailable, record `not available in this environment` and the exact read-only error; do not reconfigure WSL or substitute another service manager.
6. **Disk space**: run `df -h ~` and record the free space on the home partition.
7. **Backup freshness**: is there a recent backup? When was the last one?

Save this baseline as a markdown file in the actual workspace path discovered in Prompt 01 (for example, `<discovered-workspace>/openclaw-baseline-YYYY-MM-DD.md`), with a clear date in the filename. If the workspace path was not confirmed, stop and ask me where to save it rather than assuming the default.

Do not print any credentials, tokens, or secret values. Redact them.

After saving, tell me the exact path to the baseline file, and explain how I would use it to detect drift after a future change.
