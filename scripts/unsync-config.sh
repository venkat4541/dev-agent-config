#!/usr/bin/env bash
set -euo pipefail

# Removes only the symlinks this repository created, and only when they still
# point into this repository. Backups made by sync-config.sh are reported, never
# restored automatically -- which of several backups is wanted is a human call.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

targets=(
  "$config_home/AGENTS.md"
  "$config_home/opencode.jsonc"
  "$config_home/agents"
  "$config_home/commands"
  "$config_home/skills"
  "$HOME/.local/bin/agentctl"
  "$HOME/.warp/tab_configs/agent_cockpit.toml"
)

removed=0
for target in "${targets[@]}"; do
  if [[ ! -L "$target" ]]; then
    [[ -e "$target" ]] && echo "Left alone (not a symlink): $target"
    continue
  fi
  link_target="$(readlink "$target")"
  if [[ "$link_target" == "$repo_root"/* ]]; then
    rm "$target"
    echo "Removed: $target"
    removed=$((removed + 1))
  else
    echo "Left alone (points outside this repository): $target -> $link_target"
  fi
done

echo
echo "Removed $removed link(s)."

shopt -s nullglob
backups=("$config_home"/*.backup.* "$HOME/.warp/tab_configs"/*.backup.*)
shopt -u nullglob
if (( ${#backups[@]} )); then
  echo "Backups available to restore manually:"
  for backup in "${backups[@]}"; do
    printf '  %s\n' "$backup"
  done
  echo "Restore one with: mv <backup> <original-path>"
fi
