# Prompt: Run Diagnostic Checks and Gather Evidence

Copy this prompt into your OpenClaw chat.

---

**Runbook bridge:** Read the released runbook at <https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.0/runbook/oc-runbook-2-understandable-repairable-setup.md> before acting. Relevant section: **§6, Diagnostic checks and evidence**. This prompt helps the reader gather evidence before a change; the agent should run only read-only checks, explain results plainly, redact secrets, and perform no repair.

I want to learn how to gather useful evidence about my OpenClaw setup before I change anything. Do not change anything. Just run read-only diagnostics and report.

Please run and explain each of the following:

1. `openclaw status`: what does it tell me about the gateway, channels, and sessions?
2. `openclaw status --all`: what extra detail does the full diagnosis add?
3. `openclaw doctor --lint`: what health checks does it run, and what does it report? (This is read-only.)
4. `openclaw security audit`: what does it flag, and is it read-only? (Do not run `--fix`.)
5. `openclaw plugins doctor`: what plugin load issues does it report?

For each command, tell me:
- Whether it is read-only or state-changing.
- What success looks like.
- What a warning or failure would look like.

Do not run any `--fix`, `--repair`, or state-changing variant. This is evidence gathering only.

After running these, summarize the current health of my setup in plain language, and flag anything I should look at before making changes.
