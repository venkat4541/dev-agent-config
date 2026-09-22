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

# Required: the core workflow cannot run without it.
check_required_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool: $("$tool" --version 2>&1 | head -1)"
  else
    fail "$tool is not on PATH"
  fi
}

# Optional: useful, but its absence does not break a task worktree.
check_optional_tool() {
  local tool="$1" reason="$2"
  if command -v "$tool" >/dev/null 2>&1; then
    pass "$tool: $("$tool" --version 2>&1 | head -1)"
  else
    warn "$tool is not on PATH ($reason)"
  fi
}

echo "Agent environment doctor"
echo "Repository: $repo_root"
check_required_tool git
check_required_tool node
check_required_tool pnpm
check_required_tool opencode
check_required_tool superset
check_required_tool gh
# jq is a hard dependency of `agentctl start-task`.
check_required_tool jq
check_optional_tool supabase "needed only for Supabase projects"
# The tailscale-app cask does not reliably put a CLI on PATH, so a missing
# binary is not evidence of a broken install.
check_optional_tool tailscale "private cross-Mac networking; the app may be installed without a CLI"
check_optional_tool shellcheck "used by agentctl check"
check_optional_tool gitleaks "used by agentctl check"

if command -v agentctl >/dev/null 2>&1; then
  pass "agentctl is on PATH"
else
  warn "agentctl is linked under ~/.local/bin but is not on this shell's PATH; open a new terminal"
fi

if [[ -d "/Applications/Visual Studio Code.app" ]]; then
  pass "Visual Studio Code application installed"
else
  warn "Visual Studio Code is not installed; run ./scripts/install-tools.sh if you want it"
fi

if [[ -d "/Applications/Warp.app" ]]; then
  pass "Warp application installed"
else
  warn "Warp application is not installed; run ./scripts/install-tools.sh"
fi

# Checking only that a link exists is not enough. A second checkout of this
# repository will satisfy that check while serving entirely different config,
# so verify each link actually resolves into *this* repository.
check_link() {
  local target="$1" expected="$2" actual
  if [[ ! -L "$target" ]]; then
    if [[ -e "$target" ]]; then
      fail "$(basename "$target") exists but is not a symlink; run agentctl sync"
    else
      fail "$(basename "$target") is not linked; run agentctl sync"
    fi
    return
  fi
  actual="$(readlink "$target")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$(basename "$target") is linked to this repository"
  else
    fail "$(basename "$target") points at a different checkout: $actual (expected $expected); run agentctl sync from $repo_root"
  fi
}

for item in AGENTS.md opencode.jsonc agents commands skills; do
  check_link "$config_home/$item" "$repo_root/opencode/$item"
done
check_link "$HOME/.local/bin/agentctl" "$repo_root/bin/agentctl"

if [[ -L "$HOME/.warp/tab_configs/agent_cockpit.toml" ]]; then
  if [[ "$(readlink "$HOME/.warp/tab_configs/agent_cockpit.toml")" == "$repo_root/warp/tab_configs/agent_cockpit.toml" ]]; then
    pass "Warp Agent Cockpit tab config is linked to this repository"
  else
    warn "Warp Agent Cockpit tab config points at a different checkout; run agentctl sync"
  fi
else
  warn "Warp Agent Cockpit tab config is not symlinked; run agentctl sync"
fi

if command -v opencode >/dev/null 2>&1; then
  if opencode agent list >/dev/null 2>&1; then
    pass "OpenCode can load the configured agents"
  else
    warn "OpenCode agent loading could not be verified; run 'opencode agent list' interactively"
  fi
fi

if command -v opencode >/dev/null 2>&1; then
  provider_status="$(opencode providers list 2>/dev/null || true)"
  if grep -Fq "0 credentials" <<<"$provider_status"; then
    warn "OpenCode has no connected provider; open OpenCode and use /connect to authenticate a provider"
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
