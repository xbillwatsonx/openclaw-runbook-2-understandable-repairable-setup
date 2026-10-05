# OpenClaw Runbook 2 public package.
# Status: released, version 0.1.1.

# Show all commands
help:
    @just --list

# Open command menu
menu:
    @justx

# Run the deterministic package validator
validate:
    bash scripts/validate-package.sh

# Build the version 0.1.1 ZIP and checksum beside the package folder
release-archive:
    @cd ..; rm -f "openclaw-runbook-2-understandable-repairable-setup-v0.1.1.zip" "openclaw-runbook-2-understandable-repairable-setup-v0.1.1.zip.sha256"; zip -rq "openclaw-runbook-2-understandable-repairable-setup-v0.1.1.zip" "openclaw-runbook-2-understandable-repairable-setup" -x "openclaw-runbook-2-understandable-repairable-setup/.git/*"; sha256sum "openclaw-runbook-2-understandable-repairable-setup-v0.1.1.zip" > "openclaw-runbook-2-understandable-repairable-setup-v0.1.1.zip.sha256"

# Agent preflight checks
agent-preflight:
    git status
    just --list
    just validate

# Agent verification after edits
agent-verify:
    git status
    git diff --stat
    git diff --check
    just validate

# Show current package state
agent-status:
    git status
    git log --oneline -5
