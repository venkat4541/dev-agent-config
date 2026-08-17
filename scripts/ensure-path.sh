#!/usr/bin/env bash
set -euo pipefail

profile="$HOME/.zprofile"
marker="# dev-agent-config: Homebrew tools before legacy shims"

mkdir -p "$HOME/.local/bin"

if [[ -f "$profile" ]] && grep -Fq "$marker" "$profile"; then
  echo "PATH configuration already present in $profile"
  exit 0
fi

# Two independent guards. The Homebrew prefix is detected rather than assumed
# (Apple Silicon uses /opt/homebrew, Intel uses /usr/local), and ~/.local/bin --
# where agentctl is linked -- is added regardless. Previously it was nested
# inside the /opt/homebrew check, so agentctl never resolved on an Intel Mac.
#
# The quoted heredoc is deliberate: this block is literal text for the profile
# and must be expanded by the login shell, not by this script.
{
  printf '\n%s\n' "$marker"
  cat <<'PROFILE_BLOCK'
for brew_prefix in /opt/homebrew/bin /usr/local/bin; do
  if [[ -x "$brew_prefix/brew" ]]; then
    case ":$PATH:" in
      *":$brew_prefix:"*) ;;
      *) export PATH="$brew_prefix:$PATH" ;;
    esac
    break
  fi
done
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
PROFILE_BLOCK
} >> "$profile"

echo "Added a managed PATH entry to $profile. Open a new terminal before using pnpm or agentctl."
