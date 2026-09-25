#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

"$repo_root/scripts/install-tools.sh"
"$repo_root/scripts/ensure-path.sh"
"$repo_root/scripts/sync-config.sh"
"$repo_root/bin/agentctl" doctor || true

echo
echo "Bootstrap complete. Complete separate logins for GitHub, OpenCode Go, Orca, Tailscale, and Supabase as needed."
