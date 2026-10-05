#!/usr/bin/env bash
# Deterministic validator for the OpenClaw Runbook 2 public package.
# Released package, version 0.1.1.
#
# Checks the package manifest, license integrity, product naming, privacy
# hygiene, Markdown link resolution, prompts.txt integrity, immutable URL
# coverage, no placeholder/fallback language, whitespace, and excluded
# internal artifacts. Runs offline. This script never references private
# data, private paths, or credentials.

set -u

PKG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PKG_ROOT" || exit 1

issues=0
pass() { printf 'ok: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; issues=$((issues + 1)); }
note() { printf 'note: %s\n' "$1"; }

PROMPT_FILES=(
  prompts/01-map-my-openclaw-system.md
  prompts/02-read-my-config-safely.md
  prompts/03-check-the-gateway-and-service-manager.md
  prompts/04-understand-and-manage-plugins.md
  prompts/05-run-diagnostic-checks-and-gather-evidence.md
  prompts/06-record-a-known-good-baseline.md
  prompts/07-practice-one-safe-change-end-to-end.md
)

EXPECTED_FILES=(
  .gitignore
  CHANGELOG.md
  LICENSE.md
  README.md
  justfile
  prompts.txt
  runbook/glossary.md
  runbook/oc-runbook-2-understandable-repairable-setup.md
  runbook/quick-start-card.md
  tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md
  references/system-map.md
  references/safe-change-checklist.md
  references/known-good-baseline-template.md
  references/plugin-quick-reference.md
  references/diagnostic-command-cheat-sheet.md
  scripts/validate-package.sh
  "${PROMPT_FILES[@]}"
)

PROSE_FILES=(
  .gitignore
  CHANGELOG.md
  README.md
  justfile
  prompts.txt
  runbook/glossary.md
  runbook/oc-runbook-2-understandable-repairable-setup.md
  runbook/quick-start-card.md
  tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md
  references/system-map.md
  references/safe-change-checklist.md
  references/known-good-baseline-template.md
  references/plugin-quick-reference.md
  references/diagnostic-command-cheat-sheet.md
  "${PROMPT_FILES[@]}"
)

RELEASE_URL="https://raw.githubusercontent.com/xbillwatsonx/openclaw-runbook-2-understandable-repairable-setup/v0.1.1/runbook/oc-runbook-2-understandable-repairable-setup.md"
LICENSE_SHA256="4a115f5800376ea76d3b45b269779c9b1b4fa1a77425c584df7326fa66c3371a"

# Repository-only rights metadata is intentionally absent from the release ZIP.
# Validate it when running from a repository checkout without requiring it in
# the downloaded artifact.
if [ -f PUBLIC-MANIFEST.json ] || [ -f RIGHTS-MANIFEST.json ] || [ -f THIRD-PARTY-NOTICES.md ]; then
  EXPECTED_FILES+=(PUBLIC-MANIFEST.json RIGHTS-MANIFEST.json THIRD-PARTY-NOTICES.md)
fi

# 1. Required files exist.
missing=0
for f in "${EXPECTED_FILES[@]}"; do
  if [ ! -f "$f" ]; then
    fail "missing required file: $f"
    missing=1
  fi
done
if [ "$missing" -eq 0 ]; then pass "all required files present"; fi

# 2. Exact file set: nothing missing, nothing unexpected.
actual="$(find . -type f -not -path './.git/*' | sed 's|^\./||' | sort)"
expected="$(printf '%s\n' "${EXPECTED_FILES[@]}" | sort)"
if [ "$actual" = "$expected" ]; then
  pass "file set matches the package manifest exactly"
else
  fail "file set mismatch (unexpected or missing files)"
  diff <(printf '%s\n' "${EXPECTED_FILES[@]}" | sort) <(printf '%s\n' "$actual") | sed 's/^/    /' || true
fi

# 3. License integrity: exact canonical Bill Watson Limited-Use Content License 1.0 text.
if command -v sha256sum >/dev/null 2>&1; then
  actual_hash="$(sha256sum LICENSE.md | awk '{print $1}')"
  if [ "$actual_hash" = "$LICENSE_SHA256" ]; then
    pass "LICENSE.md matches the canonical Bill Watson Limited-Use Content License 1.0 text (sha256)"
  else
    fail "LICENSE.md sha256 mismatch: $actual_hash"
  fi
else
  if head -n 1 LICENSE.md | grep -q 'Bill Watson Limited-Use Content License 1.0'; then
    note "sha256sum unavailable; only the LICENSE header line was checked"
  else
    fail "LICENSE.md first line is not the Bill Watson Limited-Use Content License 1.0 header"
  fi
fi

# 4. Package-level naming consistency. In-document reader prose may use the
# series shorthand "Runbook 2" under the approved series voice.
bad=0
for f in README.md CHANGELOG.md prompts.txt justfile; do
  total="$(grep -o 'Runbook 2' "$f" | wc -l)"
  qualified="$(grep -o 'OpenClaw Runbook 2' "$f" | wc -l)"
  if [ "$total" -ne "$qualified" ]; then
    fail "$f: $((total - qualified)) unqualified package-level 'Runbook 2' occurrence(s)"
    bad=1
  fi
done
[ "$bad" -eq 0 ] && pass "package-level product name is consistently qualified as OpenClaw Runbook 2"

# 5. Privacy: reject operator-specific absolute home paths while allowing the
# documented generic /home/user examples.
bad=0
for f in "${PROSE_FILES[@]}"; do
  n="$(grep -Pc '/home/(?!user(?:/|$))[A-Za-z0-9._-]+' "$f" || true)"
  n="${n:-0}"
  if [ "$n" -gt 0 ]; then
    fail "$f: $n operator-specific absolute /home/ path reference(s)"
    bad=1
  fi
done
[ "$bad" -eq 0 ] && pass "no operator-specific absolute /home/ paths in package prose"

# 6. No em or en dash characters anywhere in the package.
em_dash="$(printf '\xe2\x80\x94')"
en_dash="$(printf '\xe2\x80\x93')"
bad=0
for f in "${EXPECTED_FILES[@]}"; do
  if grep -qF "$em_dash" "$f" || grep -qF "$en_dash" "$f"; then
    fail "$f: contains em or en dash characters"
    bad=1
  fi
done
[ "$bad" -eq 0 ] && pass "no em or en dashes in any package file"

# 7. All relative Markdown links resolve.
broken=0
while IFS= read -r f; do
  dir="$(dirname "$f")"
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    case "$target" in
      http://*|https://*|mailto:*) continue ;;
      '#'*) continue ;;
    esac
    path_part="${target%%#*}"
    [ -z "$path_part" ] && continue
    if [ ! -e "$dir/$path_part" ]; then
      fail "$f: broken Markdown link -> $target"
      broken=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$f" | cut -c3- | sed 's/)$//' || true)
done < <(find . -name '*.md' -not -path './.git/*' | sort)
[ "$broken" -eq 0 ] && pass "all relative Markdown links resolve"

# 8. Known relative file references resolve.
ref_fail=0
check_ref() {
  if grep -qF "$2" "$1"; then
    if [ ! -e "$3/$2" ]; then
      fail "$1: referenced path $2 does not resolve from $3"
      ref_fail=1
    fi
  else
    fail "$1: expected reference to $2 is missing"
    ref_fail=1
  fi
}
check_ref runbook/oc-runbook-2-understandable-repairable-setup.md '../LICENSE.md' runbook
check_ref runbook/oc-runbook-2-understandable-repairable-setup.md '../tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md' runbook
check_ref runbook/oc-runbook-2-understandable-repairable-setup.md '../prompts.txt' runbook
check_ref tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md '../runbook/oc-runbook-2-understandable-repairable-setup.md' tutorial
check_ref tutorial/build-an-openclaw-setup-you-can-understand-and-repair.md '../LICENSE.md' tutorial
check_ref runbook/quick-start-card.md 'oc-runbook-2-understandable-repairable-setup.md' runbook
check_ref prompts.txt 'runbook/oc-runbook-2-understandable-repairable-setup.md' .
for pf in "${PROMPT_FILES[@]}"; do
  check_ref runbook/quick-start-card.md "../$pf" runbook
done
[ "$ref_fail" -eq 0 ] && pass "known relative file references resolve"

# 9. prompts.txt integrity: header, seven complete bodies in order, end marker.
txt="$(cat prompts.txt)"
order_ok=1
if [ "$(head -n 1 prompts.txt)" = "OpenClaw Runbook 2: paste-ready prompts" ]; then
  :
else
  fail "prompts.txt first line must be the OpenClaw Runbook 2 header"
  order_ok=0
fi
grep -q '^Released, version 0\.1\.1\.$' prompts.txt || { fail "prompts.txt is missing the released version line"; order_ok=0; }
delim_count="$(grep -c '^=== Prompt ' prompts.txt || true)"
delim_count="${delim_count:-0}"
if [ "$delim_count" -ne 7 ]; then
  fail "prompts.txt has $delim_count prompt delimiters, expected 7"
  order_ok=0
fi
grep -q '^=== End of prompts ===' prompts.txt || { fail "prompts.txt: missing end marker"; order_ok=0; }
prev_pos=0
i=1
for pf in "${PROMPT_FILES[@]}"; do
  title="$(sed -n 's/^# Prompt: //p' "$pf")"
  body="$(sed -n '/^---$/,$p' "$pf" | tail -n +2)"
  if [ -z "$title" ] || [ -z "$body" ]; then
    fail "$pf: could not extract title or body"
    order_ok=0
    i=$((i + 1))
    continue
  fi
  grep -qF "=== Prompt ${i} of 7: ${title} ===" prompts.txt || { fail "prompts.txt: missing delimiter for prompt $i ($title)"; order_ok=0; }
  rest="${txt:prev_pos}"
  case "$rest" in
    *"$body"*) ;;
    *) fail "prompts.txt: body of prompt $i is missing or out of order"; order_ok=0 ;;
  esac
  prefix="${rest%%"$body"*}"
  prev_pos=$(( prev_pos + ${#prefix} + 1 ))
  i=$((i + 1))
done
[ "$order_ok" -eq 1 ] && pass "prompts.txt contains all seven prompts, complete and in order"

# 10. README requirements.
readme_ok=1
if [ "$(head -n 1 README.md)" = "# OpenClaw Runbook 2: Build an OpenClaw Setup You Can Understand and Repair" ]; then
  :
else
  fail "README first line must be '# OpenClaw Runbook 2: Build an OpenClaw Setup You Can Understand and Repair'"
  readme_ok=0
fi
grep -q '\*\*Status:\*\* Released, version 0\.1\.1\.' README.md || { fail "README must state the released 0.1.1 status"; readme_ok=0; }
grep -q '0\.1\.1' README.md || { fail "README must mention release 0.1.1"; readme_ok=0; }
grep -qi '^## Quick start' README.md || { fail "README must have a Quick start section"; readme_ok=0; }
map_ok=1
for f in "${EXPECTED_FILES[@]}"; do
  case "$f" in PUBLIC-MANIFEST.json|RIGHTS-MANIFEST.json|THIRD-PARTY-NOTICES.md) continue ;; esac
  grep -qF "](${f})" README.md || { fail "README file map is missing a link to $f"; map_ok=0; }
done
[ "$map_ok" -eq 1 ] || readme_ok=0
grep -qF "$RELEASE_URL" README.md || { fail "README must contain the immutable release URL"; readme_ok=0; }
[ "$readme_ok" -eq 1 ] && pass "README title, status, quick start, file map, and release URL verified"

# 11. CHANGELOG requirements.
cl_ok=1
grep -q 'OpenClaw Runbook 2' CHANGELOG.md || { fail "CHANGELOG must name the product as OpenClaw Runbook 2"; cl_ok=0; }
grep -q '^## 0\.1\.1 - 2026-10-04$' CHANGELOG.md || { fail "CHANGELOG must record the 0.1.1 release date"; cl_ok=0; }
[ "$cl_ok" -eq 1 ] && pass "CHANGELOG requirements verified"

# 12. No stale draft/placeholder status strings.
stale=0
for f in "${PROSE_FILES[@]}"; do
  for s in 'not yet technically validated' 'Approved build draft' 'Draft companion' 'still a draft' 'Review-ready' 'not yet released' 'placeholder; not released' 'Before release' 'RUNBOOK_RELEASE_URL_PENDING' '[RELEASE_URL]'; do
    if grep -qF "$s" "$f"; then
      fail "$f: stale status string '$s'"
      stale=1
    fi
  done
done
[ "$stale" -eq 0 ] && pass "no stale draft or placeholder status strings"

# 13. No references to excluded internal material.
internal=0
for f in "${PROSE_FILES[@]}"; do
  if grep -qE 'BRIEF\.md|SPEC-DRAFT|EVIDENCE|REVIEW-PACKAGE|HERMES-REVIEW|FLASH-REVIEW|PERSONA-VALIDATION|TECHNICAL-VALIDATION-PLAN|FINAL-RELEASE-READINESS|validation/2026|validation/fixtures|AUDIENCE-DEFINITIONS|GITHUB-WORKFLOW|MASTER-PLAN|MONETIZATION|PRODUCTION-PIPELINE|PUBLIC-READY-DEFINITION|RELEASE-CALENDAR|RUNBOOK-UPDATE-PLAN|SERIES-TRACKER|SITE-FIX|SITE-NAVIGATION|TAILSCALE-CONTROL|video-strategy|companion-content|audience-feedback' "$f"; then
    fail "$f: references excluded internal material"
    internal=1
  fi
done
[ "$internal" -eq 0 ] && pass "no references to excluded internal material"

# 14. No credential-like patterns.
cred=0
for f in "${EXPECTED_FILES[@]}"; do
  if grep -qE 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|xox[baprs]-|sk-[A-Za-z0-9_-]{20,}' "$f"; then
    fail "$f: contains a credential-like pattern"
    cred=1
  fi
done
[ "$cred" -eq 0 ] && pass "no credential-like patterns"

# 15. Whitespace: no trailing whitespace, every file ends with a newline.
ws=0
for f in "${EXPECTED_FILES[@]}"; do
  if grep -qnE '[[:blank:]]+$' "$f"; then
    fail "$f: trailing whitespace"
    ws=1
  fi
  if [ -n "$(tail -c 1 "$f")" ]; then
    fail "$f: missing final newline"
    ws=1
  fi
done
[ "$ws" -eq 0 ] && pass "no trailing whitespace; all files end with a newline"

# 16. Immutable URL coverage: every prompt and prompts.txt carries the release URL.
url_ok=1
for pf in "${PROMPT_FILES[@]}"; do
  grep -qF "$RELEASE_URL" "$pf" || { fail "$pf: missing the immutable v0.1.1 runbook URL"; url_ok=0; }
done
grep -qF "$RELEASE_URL" prompts.txt || { fail "prompts.txt: missing the immutable v0.1.1 runbook URL"; url_ok=0; }
[ "$url_ok" -eq 1 ] && pass "immutable v0.1.1 runbook URL present in all prompts and prompts.txt"

# 17. Version/date consistency across README and CHANGELOG.
ver_ok=1
grep -q '2026-10-04' README.md || { fail "README must mention the 2026-10-04 release date"; ver_ok=0; }
grep -q '2026-10-04' CHANGELOG.md || { fail "CHANGELOG must mention the 2026-10-04 release date"; ver_ok=0; }
grep -q 'version 0\.1\.1' README.md || { fail "README must mention version 0.1.1"; ver_ok=0; }
grep -q '0\.1\.1' CHANGELOG.md || { fail "CHANGELOG must mention version 0.1.1"; ver_ok=0; }
[ "$ver_ok" -eq 1 ] && pass "version and date consistency verified"

# 18. No person names beyond Bill Watson (the author).
names=0
for f in "${PROSE_FILES[@]}"; do
  if grep -qiE '\balex\b' "$f"; then
    fail "$f: contains person name 'alex'"
    names=1
  fi
done
[ "$names" -eq 0 ] && pass "no unauthorized person names"

# Summary.
printf '\n'
if [ "$issues" -eq 0 ]; then
  printf 'OpenClaw Runbook 2 package validation: PASS\n'
  exit 0
else
  printf 'OpenClaw Runbook 2 package validation: FAIL (%s issue(s))\n' "$issues"
  exit 1
fi
