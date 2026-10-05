# OpenClaw 2026.9.4 - Safe Change Checklist

Every change follows this loop. Do not skip or reorder.

## 1. Back up
`openclaw backup create --verify --output ~/Backups`
- Confirm the destination directory exists; ask before creating it if it does not.
- Verify the backup was created and is readable before proceeding.
- If backup fails, resolve before any change.

## 2. Change one thing
Make a single, small, reversible change only.
- Never change multiple things at once.
- If the change is config: `openclaw config get <dot-path>` first to see current value.
- If the change is a plugin: use one trusted, user-selected plugin spec; inspect its source, requested capabilities, and policy warnings before approving installation; then install/remove one at a time.

## 3. Validate
- For config changes: `openclaw config validate`
- For plugin changes: `openclaw plugins doctor`
- For service changes: `systemctl --user status openclaw-gateway.service`
- For plugin changes, confirm the actual enabled/disabled state with doctor, inspect, and list. Before uninstall, run `openclaw plugins uninstall <id> --dry-run` and stop if its applicable settings, record, allow/deny, exact-load-path, managed-file, sibling-policy, slot/channel, or `enabled: false` marker effects are unexpected.
- Installing or removing plugin code requires a Gateway restart before the running Gateway reflects it. Record the CLI's restart/config-reload message: a running-Gateway install can request an automatic restart when config reload is enabled, while a separate-shell install requires a later manual restart; config reload can also restart connected channels. Treat any restart/runtime verification as a separate service-impacting change with its own approval and rollback plan.
- If plugin installation or validation fails, stop and preserve the output. Use the reviewed uninstall plan only after the exact installed ID and ownership are confirmed; otherwise report the blocker instead of guessing or using `--force`. Use the verified backup only if residual changes remain and the restore procedure is understood.
- If another validation fails, stop and use the reviewed rollback plan; do not improvise a restore.

## 4. Test
Run the diagnostic that confirms everything still works:
- `openclaw status`: check gateway and channel health
- `openclaw status --all`: full diagnosis
- Any command relevant to the change made.
- For plugin lifecycle practice: inspect/list/doctor the installed state without invoking capabilities, preview uninstall with `--dry-run`, then after approved interactive uninstall compare list/doctor/inspect with the pre-change output. Do not claim runtime verification without a separately approved Gateway restart.

## 5. Record
Log what changed, when it changed, the before/after result, and the exact rollback command. Compare the result with the dated baseline created from `known-good-baseline-template.md`; update that baseline only after the system is confirmed healthy.

**Stop conditions** (do not proceed if any are true):
- About to change config without a backup. Back up first.
- About to change multiple things at once. Change one thing at a time.
- About to run `--fix` or `--repair` without understanding what it changes.
- About to change credentials, tokens, or security settings. Proceed with extra care.
- On WSL, `systemctl --user` says systemd is not running or cannot connect to the user bus. Stop the service steps and verify the WSL/systemd prerequisite first.

All steps are generic. No operator-specific paths, usernames, or data.
