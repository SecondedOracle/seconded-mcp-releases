# Wallet storage and backup

Setup and the first MCP tool call prefer the OS credential store. If the store is
unavailable, SECONDED automatically saves `wallet.key` inside the selected profile.
No flag, password or interactive approval is needed. The funding message says:
“stored in <path>, private to your user account; back it up”. This replaces older guidance
that required `--advanced --allow-file-key`; that flag remains compatible.

On macOS, missing or locked Keychain access and writes that cannot be read back
trigger fallback. Linux uses Secret Service; an absent session bus, absent service
or a failed credential operation triggers fallback. Windows uses Credential
Manager (the platform-protected credential API); failures to read or persist a new
credential trigger fallback. A readable existing wallet without profile metadata requires recovery and is never
replaced. Malformed credential encoding, oversized writes and mismatched read-back
return `keystore_data_invalid`, with guidance to preserve and restore the credential;
changing profile permissions does not repair these data errors.

On macOS, SECONDED disables in-process Security.framework interaction before
opening or inspecting a keychain. It checks `SecKeychainGetStatus` before each
credential read or write. A locked keychain returns unavailable immediately,
without launching a credential subprocess. An unlocked keychain is accessed
through `/usr/bin/security`, the stable trusted application that created legacy
wallet items and now creates new ones. This keeps item access working across
client rebuilds and retains go-keyring hex/base64 compatibility. The default
keychain is resolved to a concrete path; the check and CLI operation target that
same path. An explicit `SECONDED_KEYCHAIN_PATH` is checked and used directly.

There is a residual lock race: the keychain can lock after the status check but
before the CLI operation. The subprocess has its own UI policy, so it could then
show a dialog; its three-second deadline bounds waiting but cannot guarantee
absence of UI. Custom item ACLs that do not trust `security` can also require
approval. Items created by the short-lived in-process backend may need owner-managed
access repair; this fix does not rewrite their ACLs. SECONDED never unlocks a
keychain or grants itself access. Only a credential-read item-not-found result
means no wallet; lock, authentication, missing-keychain and metadata failures mean
unavailable. Linux rejects Secret Service prompt objects without
calling `Prompt`. Windows uses `CredReadW`/`CredWriteW`, with no credential-UI call.
The native Linux and Windows desktop behavior still requires platform testing.

On Unix, the profile must be owned by the effective user and have private
permissions (0700); files are created with mode 0600. Symlinks, foreign ownership
and group/world-accessible paths are rejected. Windows checks ownership and the
ACL and creates a private directory with a protected ACL. The file is written to
a private temporary file, flushed and atomically renamed. The client does not
encrypt the fallback file. The same OS user, administrators and backups may have
access; private permissions do not isolate it from other processes running as you.
Keep the profile and its backups in private storage.

If storage cannot be written safely, setup reports the profile path and asks for
a writable, private directory owned by you. Use the same absolute `--profile`
path on subsequent commands. Existing wallets retain their recorded backend,
address, settings and executable binding, even if OS store availability changes.
If the profile metadata is present and its OS wallet becomes inaccessible, restore
access to that store; SECONDED will not create a replacement wallet. Keep the original executable:
a different binary still requires the existing recovery process.

Run `seconded-mcp [--profile /absolute/profile] export-key` yourself in your own
terminal. This works for either backend. Read the displayed wallet address, type
its last six characters (case-insensitive), and press Enter to confirm. Empty,
incorrect or incomplete confirmation cancels the export. The warning reminds you
that anyone with the key can spend the wallet.

Both confirmation and output use the controlling terminal (`/dev/tty` on Unix;
`CONIN$` and `CONOUT$` on Windows). There is no `--output` file option or environment
override. Piped stdin cannot confirm, and redirected stdout/stderr never receives
the key. Without a terminal the command refuses before accessing the profile and
asks you to run it in your own terminal. MCP never offers key export.

Terminal confirmation prevents unattended export but does not authenticate a
human: software controlling a PTY can enter text too. Other processes running as
you may also access the wallet store. Do not ask an agent to run export or copy
the key into chat. Terminal scrollback or recording may retain the displayed key;
manage those copies yourself. Automatic private-file fallback remains unchanged.

The private key comes from the OS random generator, is retained in the selected
local store, and is loaded into memory for signing and explicit CLI export.
macOS keychain writes pass base64-encoded credential data to `security` through
stdin, never process arguments; reads return it through a captured stdout pipe.
Base64 is encoding, not encryption. CLI diagnostics are not exposed to callers,
and writes still require an exact read-back match before setup succeeds.
Network operations receive signatures and the public address, not the private
key. MCP receives the public address, funding instructions and the fallback
storage path. The path may disclose your OS username to the connected host.
Wallet state is retained until the owner removes it; no automatic deletion,
migration or remote backup occurs. Fund only what checks need.

## Earlier wallet discovery and switching

If profile metadata is missing and the OS store cannot be read, setup still creates
a new file wallet, records a pending check, and adds this warning:

> Couldn't check for an earlier SECONDED wallet on this computer. If you had one, don't fund this address yet - ask me to check again once your computer is unlocked.

Later starts, setup reruns and tool calls retry while the check is pending. Once
the OS store can be read, a different earlier wallet is reported once in a tool
result, with its public address and balances from the configured two-reader path.
Unavailable networks say “balance unknown”; this is never treated as zero.
The profile retains discovery metadata so restarting does not lose the notice.
An absent entry or the same address clears the check without reporting a discovery.
Invalid credential data keeps the check pending and gives repair guidance.

Ask the agent to show the owner terminal instructions for switching wallets.
Chat cannot switch back or select a newer wallet. The owner must use the release's
human CLI, inspect the old and destination addresses and policy, and confirm in
their own controlling terminal. The agent must not automate the confirmation.
Both keys and separate payment histories are retained; switching never deletes
either wallet. Recovery of an earlier key uses a private unencrypted file and a
separate wallet-specific ledger, leaving the original OS credential intact.
Already-running clients follow the persisted selection. Back up the whole profile.
A missing old profile means its old local payment history cannot be reconstructed;
recovery starts a separate empty ledger for that key, not a claim that it never paid.
Receipt lookup and background reconciliation use the currently selected ledger.

Setup reruns and reopened sessions say “SECONDED check wallet”, without claiming
creation. MCP reports only public addresses, balances and storage guidance. The
recovery copy has the same unencrypted, user-account file boundary described above.
Balance reads send the public earlier address to the configured RPC readers over
their HTTPS connections. Keys remain local; no automatic backup or deletion occurs.

For isolated macOS acceptance testing, `SECONDED_KEYCHAIN_PATH` selects an absolute,
existing keychain file. Keep that setting consistent across setup and later commands.
Every credential operation specifies that file; it does not change the default
keychain or search list. The opt-in native harness is
`python3 tests/client/wallet-gap-verification/verify_native.py`. It builds and signs
a test executable, uses fresh HOME directories and an explicitly named throwaway
keychain, and deletes only that keychain. It requires a macOS session where
`security create-keychain` can succeed; a failed creation is not a passed native test.
The harness builds with CGO disabled, checks an unlocked read/write positive
control, then requires each locked read and write to return unavailable in under
one second and the first locked MCP wallet call in under five seconds. A test
process deadline catches hangs. Unit tests also query the native no-interaction
setting; a timeout alone would not prove that a short-lived dialog never appeared.
It also creates a legacy fixture through `security`, verifies it from two
ad-hoc-signed builds with different `-X` strings and binary hashes, and requires
build B to read an item created by build A. An absent-item control must return
not found. Every harness `security` command is checked for the throwaway path;
no login-keychain or search-list command is used. Locked-state unit tests assert
that no subprocess launches; native timing alone is not a GUI observation.

## Policy changes and wallet selection

Chat can only TIGHTEN a policy, FREEZE payments and enable safety switches.
Raising any limit, removing a limit, unfreezing, weakening a safety switch and
switching wallets are owner terminal actions. The $25/day default is non-loosenable
by chat; even a raise below $25 requires owner confirmation. For policy changes,
run the exact `seconded-mcp --profile PROFILE limits --human --patch 'JSON'`
command returned by the client yourself and type the wallet address's last six
characters. The agent must never run it or type the answer for you.
Approval binds the exact change and selected wallet, expires after two minutes,
and is consumed once. Terminal confirmation is not OS-backed proof of a human:
software controlling a PTY can enter text too.

On v1 upgrade, legacy nil or above-$25/day policies freeze pending owner review.
The wallet key, ledger and retained settings remain available. Review the current
policy in your terminal before choosing to unfreeze; chat cannot unfreeze it.
All policy mutations are recorded in private policy-audit.json across wallet
selections, with public addresses, old/new settings, timestamps and change source.
It contains no keys, check text or typed answers. Notices announce committed
changes, including terminal changes, on the next tool result. Records persist
without automatic rotation or deletion. Switching keeps both keys and ledgers.

## Dedicated-wallet funding and release trust

**The automatic private-file fallback is UNENCRYPTED.** Private permissions are
not encryption and do not isolate the key from processes running as your user.
Administrators and backups may access it too. Setup discloses the backend before
funding. Use the preferred OS credential store when available; fallback keeps
zero-touch setup usable when it is not. Keep profile and backups private.

Fund a dedicated check wallet with only a few dollars, only after verifying the
address, storage backend and selected network. Base and Arc use USDC; Robinhood
Chain uses USDG. Do not fund an unreviewed newly discovered wallet or send mainnet
assets for testnet checks. Defaults are $2.50/check and $25/day across networks.
Chat can lower these limits or freeze payments. The policy does not stop someone
who steals the key from spending the wallet balance outside the client.

Base mainnet and Base Sepolia funding normally becomes usable after about a
minute. The client reads 30 blocks behind the lower of its two independent
readers' latest heads (about 60 seconds at two seconds per block), or the agreed
finalized block if that is newer. Both readers must agree on the block, token
identity and balance. The wallet labels this `recent_agreement`, as it does for
Robinhood Chain, rather than claiming the balance is finalized. Base latest
heads must be at most 15 seconds old and the selected state at most 90 seconds
old, including request latency. This depth rule does not claim OP-Stack `safe`
or L1 finality; recent state can still be reorganized.

Final payment certification, reservation release and spending-limit time still
use finalized evidence. The existing Base finalized-anchor age limit of 1,800
seconds remains: excessive finality lag, stale state, disagreement or an
unavailable reader blocks checks instead of guessing. The one-minute funding
timing therefore depends on healthy readers and a valid finalized anchor.

The v1 native executables ship without Apple notarization or Windows Authenticode.
An SSH-signed release manifest and SHA-256 prove the publisher's bytes, not OS
acceptance. Authenticate the publisher key on secondedoracle.xyz and @SecondedOracle.
The publisher is SecondedOracle and support is support@secondedoracle.xyz.
Use the verified installer or wrapper described in [the release runbook](release/mcp-v1.md).
Keep the previous signed release and the complete private profile for rollback.

Paid checks use POST /v1/x402/checks. A pending payment retains the exact request
and credential for same-credential recovery; never sign a replacement to retry.
The original /v1/checks door is operator rollback only until later separately
approved mainnet canaries pass. Installation and wallet setup do not pay for checks.

## Owner review checklist

- Verify the independently announced publisher fingerprint before running new bytes.
- Verify the signed manifest version and binary checksum before first execution.
- Review setup's actual backend and public address before funding.
- Keep the balance small and use the asset on the selected payment network.
- Review any legacy-policy freeze notice in your own terminal.
- Keep both the old executable and complete profile for a tested rollback.
- Keep keys, payment headers and recovery records out of chat and public logs.
- Restore an inaccessible OS store rather than creating a replacement wallet.
- Decline any request to automate a terminal confirmation.
