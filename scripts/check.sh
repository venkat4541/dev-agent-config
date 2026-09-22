#!/usr/bin/env bash
set -uo pipefail

# Enforces what the repository claims: shell scripts lint clean, no secret ever
# lands in history, and the OpenCode config actually loads. The Brewfile already
# installed the linters; nothing ran them until this script existed.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root" || exit 1

failures=0
skipped=0

pass() { printf 'PASS  %s\n' "$1"; }
skip() { printf 'SKIP  %s\n' "$1"; skipped=$((skipped + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; failures=$((failures + 1)); }

echo "Configuration checks"
echo "Repository: $repo_root"

if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck bin/agentctl scripts/*.sh; then
    pass "shellcheck: bin/agentctl and scripts/*.sh are clean"
  else
    fail "shellcheck reported findings above"
  fi
else
  skip "shellcheck is not installed; run ./scripts/install-tools.sh"
fi

for script in bin/agentctl scripts/*.sh; do
  if [[ ! -x "$script" ]]; then
    fail "$script is not executable"
  fi
done

if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks detect --no-banner --redact --exit-code 1 >/dev/null 2>&1; then
    pass "gitleaks: no secret detected in history"
  else
    fail "gitleaks detected a possible secret; rerun 'gitleaks detect --redact' for detail"
  fi
else
  skip "gitleaks is not installed; run ./scripts/install-tools.sh"
fi

# The config is JSONC with comments, so OpenCode itself is the only authority
# on whether it parses and satisfies the schema.
#
# V1 accepts an isolated config home and fails on a file it cannot parse. V2
# dropped `opencode agent list`, resolves configuration through its background
# service (which ignores XDG_CONFIG_HOME), and starts even with a malformed
# file, so no isolated, non-interactive probe exists. On v2 this step reports
# SKIP rather than passing a check that proves nothing; the content checks
# below still assert agents, permissions, prompts, and skills from the file.
if command -v opencode >/dev/null 2>&1; then
  probe_home="$(mktemp -d)"
  mkdir -p "$probe_home/opencode"
  cp opencode/opencode.jsonc "$probe_home/opencode/opencode.jsonc"
  ln -s "$repo_root/opencode/agents" "$probe_home/opencode/agents"
  ln -s "$repo_root/opencode/commands" "$probe_home/opencode/commands"
  ln -s "$repo_root/opencode/skills" "$probe_home/opencode/skills"
  if XDG_CONFIG_HOME="$probe_home" opencode agent list >/dev/null 2>&1; then
    pass "OpenCode loads opencode/opencode.jsonc (v1, isolated copy)"
  elif [[ "$(opencode --version 2>/dev/null | grep -oE '[0-9]+' | head -1)" == "2" ]]; then
    skip "OpenCode v2 has no isolated config-load probe (service-resolved config); content checks below assert the file"
  else
    fail "OpenCode could not load opencode/opencode.jsonc"
  fi
  rm -rf "$probe_home"
else
  skip "opencode is not installed; config could not be validated"
fi

# Registration is asserted against the config itself rather than against
# `opencode agent list` output, which is a large stream that can arrive
# truncated and produce false "missing agent" failures.
missing=""
for agent in explorer architect implementer quick-fix frontend backend database tester reviewer security-reviewer; do
  grep -q "\"$agent\": {" opencode/opencode.jsonc || missing+=" $agent"
done
if [[ -n "$missing" ]]; then
  fail "Agent(s) not registered in opencode.jsonc:$missing"
else
  pass "All 10 agents are registered in opencode.jsonc"
fi

# Read-only agents must not be able to reach a mutating shell command. `edit:
# deny` does not cover bash, so each one needs its own bash rules.
for agent in explorer architect reviewer security-reviewer tester; do
  block="$(sed -n "/\"$agent\": {/,/^    }/p" opencode/opencode.jsonc)"
  if grep -q '"git push\*": "deny"' <<<"$block" && grep -q '"git commit\*": "deny"' <<<"$block"; then
    pass "$agent cannot commit or push"
  else
    fail "$agent lacks an explicit deny for git commit/push"
  fi
done

# A skill is discovered by directory name but selected by its description, so a
# name/directory mismatch or a missing description silently breaks triggering.
skill_problems=""
for skill_file in opencode/skills/*/SKILL.md; do
  skill_dir="$(basename "$(dirname "$skill_file")")"
  skill_name="$(sed -n 's/^name: //p' "$skill_file" | head -1)"
  skill_desc="$(sed -n 's/^description: //p' "$skill_file" | head -1)"
  [[ "$skill_name" == "$skill_dir" ]] || skill_problems+=" $skill_dir(name=$skill_name)"
  [[ -n "$skill_desc" ]] || skill_problems+=" $skill_dir(no-description)"
done
if [[ -n "$skill_problems" ]]; then
  fail "Skill frontmatter problems:$skill_problems"
else
  pass "All $(find opencode/skills -name SKILL.md | wc -l | tr -d ' ') skills have a matching name and a description"
fi

# AGENTS.md is injected into every session in every project, so its size is a
# recurring token cost. Fail if it regrows past the budget rather than letting
# always-on context creep back in unnoticed.
agents_chars="$(wc -c < opencode/AGENTS.md | tr -d ' ')"
if [[ "$agents_chars" -le 2600 ]]; then
  pass "AGENTS.md is within the always-on budget ($agents_chars <= 2600 chars)"
else
  fail "AGENTS.md exceeds the always-on budget ($agents_chars > 2600 chars); move workflow-specific detail into a skill or docs/"
fi

# Every agent registration must point at a prompt file that exists.
while IFS= read -r prompt_ref; do
  prompt_file="opencode/${prompt_ref#./}"
  if [[ ! -f "$prompt_file" ]]; then
    fail "Agent prompt referenced but missing: $prompt_file"
  fi
done < <(sed -n 's/.*"prompt": "{file:\([^}]*\)}".*/\1/p' opencode/opencode.jsonc)

if [[ $failures -gt 0 ]]; then
  printf 'Result: %d failure(s), %d skipped\n' "$failures" "$skipped" >&2
  exit 1
fi
printf 'Result: clean with %d skipped\n' "$skipped"
