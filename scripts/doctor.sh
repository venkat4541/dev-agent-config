#!/usr/bin/env bash
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
failures=0
warnings=0

pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; failures=$((failures + 1)); }

check_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool: $("$tool" --version 2>&1 | head -1)"
  else
    fail "$tool is not on PATH"
  fi
}

echo "Agent environment doctor"
echo "Repository: $repo_root"
check_tool git
check_tool node
check_tool pnpm
check_tool opencode
check_tool superset
check_tool gh
check_tool supabase
check_tool tailscale
if command -v agentctl >/dev/null 2>&1; then
  pass "agentctl is on PATH"
else
  warn "agentctl is linked under ~/.local/bin but is not on this shell's PATH; open a new terminal"
fi

if [[ -d "/Applications/Visual Studio Code.app" ]]; then
  pass "Visual Studio Code application installed"
else
  fail "Visual Studio Code application is not installed"
fi

if [[ -d "/Applications/Warp.app" ]]; then
  pass "Warp application installed"
else
  warn "Warp application is not installed; run ./scripts/install-tools.sh"
fi

for item in AGENTS.md opencode.jsonc agents commands skills; do
  if [[ -L "$config_home/$item" ]]; then
    pass "OpenCode $item is symlinked"
  else
    fail "OpenCode $item is not symlinked; run agentctl sync"
  fi
done

if [[ -L "$HOME/.warp/tab_configs/agent_cockpit.toml" ]]; then
  pass "Warp Agent Cockpit tab config is symlinked"
else
  warn "Warp Agent Cockpit tab config is not symlinked; run agentctl sync"
fi

if command -v opencode >/dev/null 2>&1 && opencode agent list >/dev/null 2>&1; then
  pass "OpenCode can load configured agents"
else
  warn "OpenCode agent loading could not be verified; run 'opencode agent list' interactively"
fi

if command -v opencode >/dev/null 2>&1; then
  provider_status="$(opencode providers list 2>/dev/null || true)"
  if grep -Fq "0 credentials" <<<"$provider_status"; then
    warn "OpenCode has no connected provider; open OpenCode and use /connect → OpenCode Go"
  elif [[ -n "$provider_status" ]]; then
    pass "OpenCode has at least one connected provider"
  else
    warn "OpenCode provider authentication could not be checked"
  fi
fi

if command -v superset >/dev/null 2>&1; then
  if superset auth whoami >/dev/null 2>&1; then
    pass "Superset authentication is active"
  else
    warn "Superset is not authenticated; run 'superset auth login'"
  fi
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    pass "GitHub CLI authentication is active"
  else
    warn "GitHub CLI is not authenticated; run 'gh auth login'"
  fi
fi

if command -v tailscale >/dev/null 2>&1; then
  if tailscale status >/dev/null 2>&1; then
    pass "Tailscale is connected"
  else
    warn "Tailscale is installed but not connected; sign in with 'tailscale up'"
  fi
fi

if [[ $failures -gt 0 ]]; then
  printf 'Result: %d failure(s), %d warning(s)\n' "$failures" "$warnings" >&2
  exit 1
fi
printf 'Result: healthy with %d warning(s)\n' "$warnings"
