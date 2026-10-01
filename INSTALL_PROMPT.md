# Install SECONDED

```text
Install the SECONDED stdio MCP client for me.
Release binary URL for my OS/architecture: <RELEASE_BINARY_HTTPS_URL>
Signed checksums URL: https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/SHA-256SUMS
Signature URL: https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/SHA-256SUMS.sig
Independently trusted publisher SSH Ed25519 public key: <RELEASE_PUBLIC_KEY>
Version: 0.3.2
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
