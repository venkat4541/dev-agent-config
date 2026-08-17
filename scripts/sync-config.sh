#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
source_dir="$repo_root/opencode"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
local_bin="$HOME/.local/bin"

backup_existing() {
  local target="$1"
  local stamp
  stamp="$(date +%Y%m%d-%H%M%S)"
  local backup="${target}.backup.${stamp}"
  echo "Backing up existing $target to $backup"
  mv "$target" "$backup"
}

link_item() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "OK: $target"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup_existing "$target"
  fi
  ln -s "$source" "$target"
  echo "Linked: $target -> $source"
}

mkdir -p "$config_home"
mkdir -p "$local_bin"
link_item "$source_dir/AGENTS.md" "$config_home/AGENTS.md"
link_item "$source_dir/opencode.jsonc" "$config_home/opencode.jsonc"
link_item "$source_dir/agents" "$config_home/agents"
link_item "$source_dir/commands" "$config_home/commands"
link_item "$source_dir/skills" "$config_home/skills"
link_item "$repo_root/bin/agentctl" "$local_bin/agentctl"

echo "OpenCode configuration is linked. Credentials remain in OpenCode's local credential store."
