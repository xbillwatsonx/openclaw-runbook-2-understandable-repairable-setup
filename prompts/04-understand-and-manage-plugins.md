# Prompt: Understand and Manage Plugins

Copy this prompt into your OpenClaw chat.

---

**Runbook bridge:** Read the released runbook at <https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.1/runbook/oc-runbook-2-understandable-repairable-setup.md> before acting. Relevant section: **§5, Plugins: install, remove, verify**. This prompt helps the reader understand plugin choices before practice; the agent should inspect read-only, explain source/capability/policy risk, redact sensitive data, and make no changes.

I want to understand OpenClaw plugins and how to install, remove, and verify them. Do not install or remove anything yet. Just inspect and explain.

Please:

1. Run `openclaw plugins list` and report how many plugins are discovered and how many are enabled. Give me a few examples of enabled plugins and what they do.
2. Explain what a plugin is in OpenClaw, and the difference between a stock plugin (bundled with OpenClaw) and an installed plugin.
3. Show me the command to install a plugin: `openclaw plugins install <path-or-spec-or-plugin>`. Explain the different things I can install (a local path, an archive such as `.zip`, `.tgz`, or `.tar.gz`, an npm spec, a git repo, a `clawhub:` package, or a marketplace entry).
4. Show me the command to uninstall a plugin: `openclaw plugins uninstall <plugin>`. Explain what it changes.
5. Show me how to verify a plugin is healthy: `openclaw plugins doctor` and `openclaw plugins inspect <plugin>`. Explain what each reports.
6. Explain the `--pin` flag on install and why I might use it to record an exact version.
7. Explain that `--force` both confirms a non-ClawHub source and permits overwriting an existing plugin or hook pack. Also explain `--accept-capabilities` and `--acknowledge-install-policy-warning`, including that policy blocks and failures remain terminal.

Do not install, uninstall, enable, or disable any plugin. Just explain the commands and what each one does.

After this, explain that I can discover candidates with the read-only `openclaw plugins search <query>` command, browse ClawHub, or use a local plugin path I already trust. Do not recommend, invent, or select a plugin ID for me. Then tell me how to evaluate the spec I select for Prompt 07, covering source provenance, declared capabilities, policy warnings, version/pinning, installed ID, and uninstall plan.
