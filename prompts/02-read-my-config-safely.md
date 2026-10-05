# Prompt: Read My Config Safely

Copy this prompt into your OpenClaw chat.

---

**Runbook bridge:** Read the released runbook at <https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.1/runbook/oc-runbook-2-understandable-repairable-setup.md> before acting. Relevant section: **§3, Configuration: read and change safely**. This prompt helps the reader understand config without exposing secrets; the agent should inspect and explain only, redact sensitive values, and make no changes.

I want to understand my OpenClaw config file without changing it. Do not modify the config.

Please:

1. Run `openclaw config file` and tell me the exact path to the active config file.
2. Run `openclaw config get` on a few safe, non-secret values so I can see how the dot-path syntax works. For example, show me the gateway bind address and port, and the default model, if those are readable.
3. Explain the difference between `openclaw config get`, `openclaw config set`, `openclaw config patch`, and `openclaw config validate`. For each, tell me whether it is read-only or state-changing.
4. Run `openclaw config validate` and report whether the current config is valid against the schema.

Important:
- Do not print any credentials, tokens, API keys, or secret values. Redact them.
- Do not run `openclaw config set` or `openclaw config patch` yet. This is read-only.

After this, tell me the safest way to make a single small config change and verify it, so I understand the workflow before I actually do it.
