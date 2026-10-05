# OpenClaw Runbook 2: Build an OpenClaw Setup You Can Understand and Repair

**Status:** Released, version 0.1.0.
**Scope:** Linux and WSL, single operator, self-hosted OpenClaw; commands checked against OpenClaw 2026.9.4.

OpenClaw Runbook 2 helps you build a working mental model of your OpenClaw installation: the gateway, configuration, workspace, plugins, service manager, and logs, and the boundaries between them. You gather read-only evidence, record a known-good baseline, and practice one safe change end to end. It is written for a technically comfortable self-hosted operator working with an OpenClaw agent. The procedure was technically validated in a clean, disposable WSL2 installation running OpenClaw 2026.9.4, and reviewed with a six-scenario beginner persona suite, before this package was assembled.

## Quick start

1. Give your agent the runbook first: [runbook/oc-runbook-2-understandable-repairable-setup.md](runbook/oc-runbook-2-understandable-repairable-setup.md). Your agent reads the whole runbook before acting.
2. Want the short version? Start with the quick-start card: [runbook/quick-start-card.md](runbook/quick-start-card.md).
3. Copy the seven prompts into your OpenClaw chat one at a time, in order, from the [prompts directory](prompts/) or all together in [prompts.txt](prompts.txt).
4. Finish with a recorded known-good baseline and one practiced safe change, then compare against the baseline after any future change.

## The seven prompts

Work through them in order:

1. [Map your system](prompts/01-map-my-openclaw-system.md)
2. [Read your config safely](prompts/02-read-my-config-safely.md)
3. [Check the gateway and service manager](prompts/03-check-the-gateway-and-service-manager.md)
4. [Understand and manage plugins](prompts/04-understand-and-manage-plugins.md)
5. [Run diagnostic checks and gather evidence](prompts/05-run-diagnostic-checks-and-gather-evidence.md)
6. [Record a known-good baseline](prompts/06-record-a-known-good-baseline.md)
7. [Practice one safe change end to end](prompts/07-practice-one-safe-change-end-to-end.md)

Prompts 01 through 06 are read-only. Prompt 07 practices one bounded plugin lifecycle, with your explicit approval required at both state-changing steps.

## Complete file map

| File | What it is |
| --- | --- |
| [README.md](README.md) | This overview: status, quick start, file map, and commands. |
| [CHANGELOG.md](CHANGELOG.md) | Package history and the 0.1.0 first release. |
| [LICENSE.md](LICENSE.md) | Bill Watson Limited-Use Content License 1.0, complete terms. |
| [.gitignore](.gitignore) | Ignores OS and editor artifacts for package maintainers. |
| [justfile](justfile) | Common commands for agents and maintainers. |
| [runbook/oc-runbook-2-understandable-repairable-setup.md](runbook/oc-runbook-2-understandable-repairable-setup.md) | The canonical agent-facing runbook. |
| [runbook/quick-start-card.md](runbook/quick-start-card.md) | One-page summary: prompt order and the first message to send your agent. |
| [runbook/glossary.md](runbook/glossary.md) | Plain definitions for the terms the runbook uses. |
| [tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md](tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md) | Reader-facing explanation of the concepts and how to use the prompts. |
| [prompts/01-map-my-openclaw-system.md](prompts/01-map-my-openclaw-system.md) | Prompt 1: map your system. |
| [prompts/02-read-my-config-safely.md](prompts/02-read-my-config-safely.md) | Prompt 2: read your config safely. |
| [prompts/03-check-the-gateway-and-service-manager.md](prompts/03-check-the-gateway-and-service-manager.md) | Prompt 3: check the gateway and service manager. |
| [prompts/04-understand-and-manage-plugins.md](prompts/04-understand-and-manage-plugins.md) | Prompt 4: understand and manage plugins. |
| [prompts/05-run-diagnostic-checks-and-gather-evidence.md](prompts/05-run-diagnostic-checks-and-gather-evidence.md) | Prompt 5: run diagnostic checks and gather evidence. |
| [prompts/06-record-a-known-good-baseline.md](prompts/06-record-a-known-good-baseline.md) | Prompt 6: record a known-good baseline. |
| [prompts/07-practice-one-safe-change-end-to-end.md](prompts/07-practice-one-safe-change-end-to-end.md) | Prompt 7: practice one safe change end to end. |
| [prompts.txt](prompts.txt) | All seven paste-ready prompts in order, in one plain text file. |
| [references/system-map.md](references/system-map.md) | The six components, where they live, and how to locate them. |
| [references/safe-change-checklist.md](references/safe-change-checklist.md) | The five-step safe-change loop as a checklist with stop conditions. |
| [references/known-good-baseline-template.md](references/known-good-baseline-template.md) | Blank baseline table to fill in before you change anything. |
| [references/plugin-quick-reference.md](references/plugin-quick-reference.md) | Read-only plugin commands and the safe lifecycle practice sequence. |
| [references/diagnostic-command-cheat-sheet.md](references/diagnostic-command-cheat-sheet.md) | The read-only diagnostic commands in one table. |
| [scripts/validate-package.sh](scripts/validate-package.sh) | Deterministic package validator used by the justfile. |
| [PUBLIC-MANIFEST.json](PUBLIC-MANIFEST.json) | Public-file allowlist used to build and verify the release ZIP. |
| [RIGHTS-MANIFEST.json](RIGHTS-MANIFEST.json) | Public rights and release-provenance sidecar. |
| [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) | Third-party notice registry; this release contains no third-party allowlist entries. |

## Release status

Version 0.1.0 was released on 2026-10-04. Every prompt carries the immutable tag-specific runbook address:

<https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.0/runbook/oc-runbook-2-understandable-repairable-setup.md>

## Commands for agents and maintainers

From the package root:

- `just help`: list all commands.
- `just menu`: open the interactive command menu.
- `just validate`: run the deterministic package validator.
- `just release-archive`: build the version 0.1.0 ZIP and checksum beside the package folder.
- `just agent-preflight`: preflight checks before working on the package.
- `just agent-verify`: verification after edits.
- `just agent-status`: current package state.

## License

Bill Watson Limited-Use Content License 1.0. Personal learning and internal operational use are permitted. Redistribution, resale, white-labeling, sublicensing, and using this protected material as the basis of an offering to others require prior written permission. The complete terms are in [LICENSE.md](LICENSE.md).

## Get the next guide

Agenthelpsite.com is growing one carefully tested guide at a time.

Get the next guide, tutorial or runbook the moment it's released.

Join the list to hear when the next one is ready: [https://agenthelpsite.com/subscribe](https://agenthelpsite.com/subscribe)
