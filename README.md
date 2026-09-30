# SECONDED MCP client 0.3.0

The oracle for agents. Verify trades, tokens and messages before your agent acts.

SECONDED is the oracle for agents. Before your agent acts, it checks the real cost, the real contract and the real risk, read live and confirmed by two rival AIs, one from OpenAI and one from Anthropic. If they don't agree, you don't pay. Every answer comes with a signed receipt.

Release-only repository for `seconded-mcp`, the local stdio MCP client for SECONDED checks.
It holds no source code. Every file here was produced by `ops/release/release.py stage` from
the archived inputs of source commit `1496bde2ce21ce87bad697ec3258f5ce3b78efbc`, with the selected release version,
public publisher identity and signatures. `build-info.json` records one SHA-256 for the complete
source/input archive and individual SHA-256 hashes for the fixed release templates; packaging
and staging use that snapshot. To reconstruct the full input set, recreate the archive from the
recorded source commit with `ops/release/release.py` and its `INPUT_PATHS`, or obtain the retained
private archive, then verify the archive digest and the template hashes.

## Downloads

Assets are attached to the [v0.3.0 release](https://github.com/SecondedOracle/seconded-mcp-releases/releases/tag/v0.3.0).
Base URL: `https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/`

| File | SHA-256 |
| --- | --- |
| [`seconded-mcp_darwin_arm64`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/seconded-mcp_darwin_arm64) | `e1b1ad63f003b70dbfa3aff315ba7d8267f8c22a12cb2fd65801ec0721cb4ded` |
| [`seconded-mcp_darwin_amd64`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/seconded-mcp_darwin_amd64) | `689e2c78a1847b64f264ffa758a6d59677d6dc3d86d1801750181b9861e00923` |
| [`seconded-mcp_linux_amd64`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/seconded-mcp_linux_amd64) | `c100e25db33ce59666e640f74b23d68a6353440e752a089483301e137a0bf3d5` |
| [`seconded-mcp_linux_arm64`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/seconded-mcp_linux_arm64) | `4cc80f753981bb9d41b31479fc9b7c678ea2983a0cafe5258c3829b863c307d2` |
| [`seconded-mcp_windows_amd64.exe`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/seconded-mcp_windows_amd64.exe) | `103040444a97ee5fb22dbe36edfd1a75cb96e7227f1cf2e5b4d3c98b97c98e0c` |
| [`seconded-mcp_0.3.0.mcpb`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/seconded-mcp_0.3.0.mcpb) | `b356b76850d495ab7986c9281216a77a93715dfd39a59b4650e5c8400efec087` |
| [`build-info.json`](https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/build-info.json) | `a001ecea789769a79891a8f1dd9b9329f652f97ceaef3ff1da01b1e73655cc32` |

`SHA-256SUMS` lists the same hashes. `SHA-256SUMS.sig` is the publisher's SSH
signature over that file. The publisher key fingerprint is `SHA256:wV2gkz0HE+pcwQtkI0qwT/XGA7h+D0+sNa9ClqjCTKA`
(identity `release@seconded`, namespace `seconded-release`). Create your
own `allowed_signers` with `release@seconded namespaces="seconded-release" ssh-ed25519 KEY_BLOB`.
Never learn the trusted key from this download or a signer file delivered alongside it.
The signed manifest's version comment must match the release you selected.

```sh
ssh-keygen -Y verify -f allowed_signers -I release@seconded -n seconded-release \
  -s SHA-256SUMS.sig < SHA-256SUMS
shasum -a 256 -c SHA-256SUMS        # macOS
sha256sum -c SHA-256SUMS            # Linux
Get-FileHash -Algorithm SHA256 .\seconded-mcp_windows_amd64.exe   # Windows
```

The `.mcpb` bundle hash differs from each binary hash. Normal agent-compatible setup verifies
signed binary checksums automatically; no hash is pasted. Keep SHA-256SUMS and
SHA-256SUMS.sig beside raw binaries. MCPB bundles carry signed sidecars in server/.
System OpenSSH ssh-keygen with -Y verify support is required at setup.

## Install with one prompt

The same prompt is available in [INSTALL_PROMPT.md](INSTALL_PROMPT.md).
This build has no Apple Developer ID signature or notarization. SSH-signed checksums
authenticate the release; they do not bypass native platform security prompts.

Pick your platform's binary URL and the signed checksum URLs above, then paste this into Claude Code,
Cursor, Codex or Hermes:

```text
Install the SECONDED stdio MCP client for me.
Release binary URL for my OS/architecture: <RELEASE_BINARY_HTTPS_URL>
Signed checksums URL: https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/SHA-256SUMS
Signature URL: https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.0/SHA-256SUMS.sig
Independently trusted publisher SSH Ed25519 public key: <RELEASE_PUBLIC_KEY>
Version: 0.3.0
Host: <claude-desktop|claude-code|cursor|codex|generic> (use generic for Hermes)
Network I will pay on: base (Base mainnet) unless I name arc or robinhood. Use a testnet (base_sepolia, arc_testnet or robinhood_testnet) only if I ask for one.
Optional isolated profile: <ABSOLUTE_PRIVATE_PROFILE_DIRECTORY>

1. Confirm my OS and architecture and download that binary over HTTPS into a
   new versioned directory owned by me. Never overwrite an installed binary.
   Do not execute a downloaded installer script or pipe a download into a shell.
2. Download SHA-256SUMS and SHA-256SUMS.sig beside the binary. Verify the SSH
   signature with the independently trusted publisher key, identity
   release@seconded and namespace seconded-release; then compare the binary's
   computed SHA-256 to its platform entry. Do this automatically, without asking
   me to copy the digest. Stop on missing metadata, unresolved placeholders,
   bad signatures or mismatches; do not execute unverified bytes. Never learn
   the trusted key from the same unverified download. System OpenSSH ssh-keygen
   with -Y verify support is required (including on Windows).
   Use the publisher key supplied above from the independently
   trusted announcement channel. Check the signed version comment matches my
   selected release; a valid old signature alone does not prevent rollback.
   This is an unsigned platform build: no Apple Developer ID or notarization.
   If macOS blocks it, stop for the owner to review the release and Privacy &
   Security approval; never remove quarantine or disable Gatekeeper.
3. Make the verified binary executable where needed. Add this MCP to my user-level
   host settings using host-snippet --host <host> from its absolute path.
   For an isolated profile, prefix every command with
   --profile <ABSOLUTE_PRIVATE_PROFILE_DIRECTORY> before its command name.
   Omit the optional profile when not requested; never pass a placeholder.
   Preserve existing host settings and use the emitted host-specific configuration.
   For Claude Code, run the printed claude mcp add --scope user seconded -- ...
   command; do not edit ~/.claude.json. MCPB users use the bundle manifest without
   also adding a duplicate raw-binary snippet.
4. Run setup --host <host> yourself with the same verified binary and profile.
   Default setup is non-interactive and needs no terminal, yes or OS password.
   New defaults: $2.50 max per check, $25 a day; chat can only tighten or freeze.
   Hourly and outstanding limits are unset; value gate is off. Dedupe, loop brake
   and alerts stay on, with 30 signed checks per rolling 60 seconds.
   It prefers the OS credential store and verifies signed release metadata automatically.
   If a wallet already exists, report its stored policy; setup never changes it.
   After installation, change limits or safety switches when I ask in ordinary
   language, using seconded_get_limits and seconded_set_limits. For example,
   "set my daily limit to $20" means daily_usd=20; "remove my hourly limit"
   means hourly_usd=null. "Turn on the value gate" means value_gate=true.
   With it off, max_price_usd is optional and the per-check limit still applies.
   Chat can always tighten limits, freeze payments, or enable safety switches.
   Chat may only TIGHTEN limits, FREEZE payments and enable safety switches.
   Raising any limit, removing a limit, unfreezing, weakening safety switches,
   and switching wallets are terminal-only owner actions, even below $25/day.
   The agent must show the owner the exact command returned by the release,
   including its actual profile and patch, and must never run it or enter the
   wallet-bound confirmation. Ask the owner to run the command in their terminal.
   New wallets default to $25/day; chat cannot loosen that policy.
   On upgrade, a legacy nil or above-$25/day policy freezes pending owner review.
   Keep the wallet, history and existing switches; report the migration notice.
   Report each policy-change notice with its old and new values and time.
   Changes are also recorded locally in policy-audit.json, without private keys.
   The $2.50 compiled maximum per authorization always applies, including when
   a per-check policy limit is higher or removed.
   If the OS key store is unavailable, setup automatically uses private wallet.key.
   Report its location and ask me to back it up; SECONDED does not encrypt the file.
   Do not ask me for a password or seed, or automate owner authentication.
   Restart the host after adding the MCP: fully quit Claude Desktop (including
   its tray/menu-bar process) or Cursor and reopen; restart Claude Code, Codex
   or Hermes sessions. If the host starts before setup, its first tool call can
   create the safe wallet and return the funding address without running a check.
5. Run self-check on the same binary and profile. Verify fingerprint_matches and
   live_api_configured, then return the public wallet address and the dedicated-wallet notice below.
   Setup creates its own wallet; recovery can select a detected earlier SECONDED wallet. Do not initiate
   a paid check or fund the wallet.
   If live_api_configured is false, report that service integration still needs
   a release with reviewed public anchors. Never ask for wallet/provider secrets.
6. Tell me: "SECONDED created a check wallet: <address>. Fund it with a few dollars
   of USDC on Base or Arc, or USDG on Robinhood Chain to use SECONDED checks.
   SECONDED requires a dedicated funded wallet for security: keep only what
   checks need in it. New defaults: $2.50 max per check, $25 a day; chat can only tighten or freeze."
   For an existing profile, say "SECONDED check wallet" without claiming creation,
   and report its actual stored limits instead, in dollars as seconded_get_limits
   shows them: daily_usd "25.00" means $25 a day and null means no limit.
   Preserve any warning that an earlier wallet could not be checked; do not recommend funding the new address until it
   is resolved. Once the computer is unlocked, call a tool again to retry the check.
   If an earlier wallet is found, report its address and balances (or "balance
   unknown"). If I say "switch back", explain the terminal-only owner action.
   Never call a wallet-switch MCP action; the owner must confirm in their terminal.
   Report the loosening-class notice, both addresses, policy differences and time.
   File storage is "private to your user account" and is not encrypted by SECONDED.
   Tell me which asset funds my chosen network: USDC on base or arc (testnet USDC
   on base_sepolia or arc_testnet), USDG on robinhood (testnet USDG on
   robinhood_testnet). Robinhood never takes USDC. A check with no network runs on
   base (Base mainnet); to pay anywhere else, every paid check must pass network=arc,
   robinhood, base_sepolia, arc_testnet or robinhood_testnet explicitly. Never send
   mainnet funds to pay a testnet check, and never guess a network for me.
7. If I want my private key, tell me how to run seconded-mcp export-key myself.
   Never run it for me, capture its terminal output, or put a private key in chat.
   It has no file-output option: it displays the key only on my controlling terminal
   after I type the wallet address's last 6 characters.
   Remind me: store this safely; anyone with it can spend this wallet.
```

## Networks

Checks default to Base mainnet. Arc and Robinhood mainnet, and the Base Sepolia, Arc and
Robinhood testnets, are used only when a check names that network. Base and Arc settle in USDC; Robinhood
settles in USDG. Outputs are AI-generated checks of the input you send, not guarantees or
financial advice.

Default setup creates a wallet non-interactively and prints its funding address.
$2.50 max per check, $25 a day; change by asking your agent. No hourly or outstanding
cap; value gate off, dedupe and alerts on, loop brake on at 30 signed checks per
rolling 60 seconds. Existing profiles keep their stored policy. Setup prefers the
OS credential store and uses a private file when unavailable. Inspect or change limits with
seconded_get_limits and seconded_set_limits; no owner password is required. Fund the printed address after setup; installation sends no payment.

## Distribution

Publisher: SecondedOracle. Support: support@secondedoracle.xyz.
The npm launcher (`npx --yes @seconded/mcp@0.3.0 serve --host <host>`) pins the publisher key and verifies the
signed checksums and binary hash automatically on every launch.
Native binaries have no Apple notarization or Windows Authenticode.
Automatic private-file fallback is UNENCRYPTED. Fund only a few dollars in a dedicated
wallet. Defaults are $2.50/check and $25/day; chat can only tighten or freeze.
Raises, unfreezes and wallet switching require the owner terminal.
Pricing and networks: https://secondedoracle.xyz/pricing
