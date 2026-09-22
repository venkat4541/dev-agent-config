# Orca remote harness on a miniPC VM

Goal: one always-on Orca runtime on a miniPC VM. The macOS Orca app and the Orca mobile app pair to that same runtime, so both drive the same worktrees, terminals, agents, skills, and Linear flow. This replaces the Mac-local Superset harness and makes the harness reachable from anywhere.

## Why this works

Orca splits into a **runtime** — it owns worktrees, terminals, repos, agents, skills, and ticket state — and **clients** — the desktop and mobile apps. `orca serve` runs the runtime headless on a Linux or macOS host and prints a pairing link; clients pair to it. The miniPC therefore holds the harness, and the MacBook and phone become thin clients.

Two connection modes matter here:

- **Orca-server mode** (this design). `orca serve` runs on the VM and emits a `pairingCode`. Clients dial the runtime over the network. `--mobile-pairing` prints a mobile-scoped QR/link instead of the desktop pairing link.
- **SSH mode**. Orca dials the VM over SSH; no server runs there. Good for a per-workspace host, but it gives the mobile app nothing to pair with, so it is not the model for this goal.

## Target architecture

```
miniPC (Linux)
└── VM  ── the harness host ─────────────────────────────┐
    ├── Orca runtime:  orca serve --mobile-pairing       │
    ├── repos, worktrees, terminals, agents, skills      │
    ├── agent CLIs + gh, authenticated on this host      │
    └── Tailscale (private reachability, no public port) │
                                                         │
macOS Orca app ──pair over Tailscale─────────────────────┤
Orca mobile app ──pair over Tailscale────────────────────┘
```

The runtime's user data lives at `${XDG_CONFIG_HOME:-$HOME/.config}/orca` on Linux. It holds the pairing keypair and device-token registry (`orca-e2ee-keypair.json`, `orca-devices.json`). Treat that directory as a secret; never commit it, and never bake it into a VM image (see Security).

## Superset is retired

Superset is removed from this repository — Brewfile, `doctor`, `agentctl start-task`, templates, and docs. Orca tracked the existing Superset worktrees under `~/.superset/worktrees/...` as external worktrees, so nothing was lost in the switch. The mapping that guided it:

| Superset role | Orca replacement |
| --- | --- |
| Worktree creation (`agentctl start-task` → `superset ws create`) | `orca worktree create` against a repo registered with `orca repo add` |
| Live terminal view across worktrees | Orca desktop app, and the same runtime from the mobile app |
| Cross-Mac view | Orca remote environments: pair each client to the runtime |
| `superset.config.json` setup/run scripts | Orca repo hook settings (`setup` / `archive`), already present per repo |
| Auth (`superset auth login`) | `orca account add` / runtime pairing; agent CLIs log in on the host |
| Ticket flow | `orca-linear` skill over `orca linear …` |

The migration was a re-registration, not a rewrite: each repo is registered once with `orca repo add`, setup/run commands live in the repo's Orca hook settings, and `agentctl start-task` creates Orca worktrees.

## Setup on the miniPC VM

Steps marked **[you]** are human-only (provisioning, interactive logins); the rest can be scripted. Exact host names, ports, and hypervisor are captured in the setup wizard — see Open decisions.

1. **[you] Provision the VM** on the miniPC with a Linux distribution Orca supports, enough RAM for the agent CLIs and builds, and a persistent disk.
2. **Install Orca for Linux** on the VM, plus the toolchain this repo expects (`git`, `node`, `pnpm`, `gh`, the agent CLIs).
3. **[you] Authenticate on the VM.** Agent logins use the device-auth flow (for example `codex login --device-auth`) because the VM is headless and a loopback OAuth callback is unreachable. Run `gh auth login` on the VM too. Accounts are per host — the Mac's logins do not carry over.
4. **Install Tailscale** on the VM and on each client, then `tailscale up` and note the VM's MagicDNS name. Tailscale is the private transport; do not publish the runtime port.
5. **Start the runtime** (foreground to observe, then a service unit):
   ```bash
   orca serve \
     --port 6768 \
     --pairing-address ws://<vm-magicdns-name>:6768 \
     --mobile-pairing
   ```
   `--pairing-address` only changes the address advertised to clients; pass the Tailscale-reachable endpoint. Tailscale already encrypts the transport, so `ws://` is enough; use `wss://` only if you terminate TLS with `tailscale serve`. The command prints the mobile pairing QR/link, and a browser URL when the web client bundle is present.
6. **Pair the clients.**
   - macOS app: `orca environment add --name miniPC --pairing-code 'orca://pair?code=…'`
   - Mobile app: scan the QR from step 5.
   Both then see one runtime and the same worktrees.
7. **Register repos** on the runtime. Clone each project on the VM (the harness is independent of the Mac), then `orca repo add --path <abs/path>` and `orca repo set-base-ref --repo id:<id> --ref origin/main`.

## Security

- The pairing link is access. Treat it as a credential; rotate by restarting the runtime, which reissues pairing material.
- Keep the runtime bound to the Tailscale interface or loopback. Never expose it on the public Internet.
- Back up `${XDG_CONFIG_HOME:-$HOME/.config}/orca` as a secret (pairing keypair + device tokens), and never commit it.
- **Never snapshot a VM on which `orca serve` has already run.** The first run creates the runtime user data, and everything in it — pairing keypair, device-token registry, agent-session authority key — is baked into the snapshot and shared by every VM booted from it. Snapshot before the first run, or delete the verified user-data directory first.
- Agent and `gh` credentials live on the VM, not the Mac. Do not forward a desktop token over SSH.

## Decisions

- **Hypervisor:** Proxmox, with Orca running inside a Linux VM guest.
- **Transport:** Tailscale. Port `6768` (the port the local runtime already uses); pairing address `ws://<vm-magicdns-name>:6768`.
- **Repos:** cloned on the VM, so the harness runs independently of the Mac. The Mac keeps its own checkouts for editing; the VM's checkouts are authoritative for agent work.
- **Superset:** removed from the repository.

[`scripts/setup-orca-vm.sh`](../scripts/setup-orca-vm.sh) walks the human-only steps: Proxmox VM creation, toolchain install, interactive logins, Tailscale join, and pairing.
