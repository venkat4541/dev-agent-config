#!/usr/bin/env bash
set -euo pipefail

profile="$HOME/.zprofile"
marker="# dev-agent-config: Homebrew tools before legacy shims"

if [[ -f "$profile" ]] && grep -Fq "$marker" "$profile"; then
  echo "PATH configuration already present in $profile"
  exit 0
fi

{
  printf '\n%s\n' "$marker"
  printf 'if [[ -d /opt/homebrew/bin ]]; then\n'
  printf "  export PATH=\"/opt/homebrew/bin:\$HOME/.local/bin:\$PATH\"\n"
  printf 'fi\n'
} >> "$profile"

echo "Added a managed PATH entry to $profile. Open a new terminal before using pnpm."
