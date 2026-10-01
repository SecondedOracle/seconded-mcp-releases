# SECONDED MCP v1 unsigned release runbook

Prepared locally; nothing in this task publishes, funds a wallet or pays for a check.
Publisher: **SecondedOracle**. Support: **support@secondedoracle.xyz**.
The native build has no Apple Developer ID/notarization or Windows Authenticode.
An SSH Ed25519 signed release manifest authenticates bytes; it is not a platform certificate.

## Operator accounts and trust

Provision GitHub identity SecondedOracle with 2FA and repositories
`seconded-mcp-releases` and `homebrew-tap`; npm organization `secondedoracle`
with package permission for `@seconded/mcp`; Smithery namespace
`seconded`; and official MCP Registry GitHub device authentication for
`io.github.SecondedOracle/seconded-mcp`. Confirm support@secondedoracle.xyz is
monitored. Account login and publication are operator actions, never worker steps.
No Apple or Microsoft signing account is required for this UNSIGNED release.

Use an operator-controlled SSH Ed25519 release key. Keep its private half outside
source, logs, package bundles and public repositories. Announce the public key and
SHA256 fingerprint independently on **@SecondedOracle** and **secondedoracle.xyz**
before distributing bytes. Record the exact key and fingerprint in the release
announcement. Require agreement between those channels. A downloaded key next to
a downloaded binary does not establish independent trust. A key rotation requires
separate credential authorization and privacy-steward follow-up before deployment.

## Local preparation and gates

1. Integrate the parallel client changes: standard `POST /v1/x402/checks`, durable
   same-credential recovery, chat only tightens/freezes, terminal-only raises,
   unfreezes and wallet switching, and legacy nil/above-$25/day freeze. Keep the
   original `/v1/checks` as operator rollback until all three mainnet canaries pass.
   Do not publish a release assembled from the old client behavior.
2. Capture the live catalog without payment and regenerate metadata:

   ```sh
   curl -fsS --proto '=https' --max-time 30 https://api.secondedoracle.xyz/v1/products -o ops/release/catalog/live-products.json
   python3 ops/release/metadata.py
   python3 ops/release/metadata.py --check --check-client
   ```

   The capture supplies tools, price tiers and networks. All five small checks
   are $0.25. Trade medium is $1.50; Scam medium/large are $1.50/$2.50. Base and Arc
   settle USDC; Robinhood Chain settles USDG. Metadata drift and client-schema
   drift must be resolved before building. Do not copy legacy catalog usage prose
   as v1 instructions: the standard door is the binding operator decision.
3. Commit reviewed release inputs. Choose a strictly newer SemVer for an upgrade;
   the 0.3.0 source templates are not approval to replace an enrolled 0.3.0 wallet.
   Retain the complete private profile and previous signed release. Set the shell
   variables below to reviewed values; RELEASE_PUBLIC_KEY names the public key file,
   SIGNING_KEY names the operator-held private key and GOVULNDB an approved local
   file:// database. Signing is a separate operator action. No key is created here.
4. Build twice from the same clean commit using the pinned Go toolchain and approved
   vulnerability database. Source and vendor dependencies are archived locally:

   ```sh
   python3 ops/release/release.py build "$VERSION" --ref "$COMMIT" --output candidate-a --release-public-key "$RELEASE_PUBLIC_KEY"
   python3 ops/release/release.py build "$VERSION" --ref "$COMMIT" --output candidate-b --release-public-key "$RELEASE_PUBLIC_KEY"
   ```

   Compare every native binary and build-info.json byte for byte. Do not add Apple
   or Microsoft signing after checksums: this task's selected release is unsigned.
5. Sign each build's pre-package checksum manifest in namespace seconded-release:

   ```sh
   ssh-keygen -Y sign -f "$SIGNING_KEY" -n seconded-release ops/release/dist/candidate-a/SHA-256SUMS
   python3 ops/release/release.py package candidate-a --setup-signature ops/release/dist/candidate-a/SHA-256SUMS.sig
   ssh-keygen -Y sign -f "$SIGNING_KEY" -n seconded-release ops/release/dist/candidate-b/SHA-256SUMS
   python3 ops/release/release.py package candidate-b --setup-signature ops/release/dist/candidate-b/SHA-256SUMS.sig
   ```

   Compare the final MCPB bytes. The bundle contains signed per-binary setup
   sidecars and license notices. The aggregate bundle hash is different from any
   contained executable hash. Never execute an unverified launcher.
6. Run the focused release suite, final client/interop qualification in the owning
   lane, and candidate verification. A fresh-host install/upgrade/owner rollback
   must retain the wallet address, ledger and limits and pass self-check. Test
   lost-response recovery using the same credential, never a new payment.
7. Sign the final asset list and stage the exact distribution:

   ```sh
   python3 ops/release/release.py assets-checksums candidate-a > ops/release/dist/candidate-a-assets-sums
   ssh-keygen -Y sign -f "$SIGNING_KEY" -n seconded-release ops/release/dist/candidate-a-assets-sums
   python3 ops/release/release.py stage candidate-a --owner SecondedOracle --repo seconded-mcp-releases --smithery-namespace seconded --assets-signature ops/release/dist/candidate-a-assets-sums.sig
   python3 ops/release/verify.py candidate-a-public --staged --release-public-key "$RELEASE_PUBLIC_KEY"
   ssh-keygen -Y sign -f "$SIGNING_KEY" -n seconded-release ops/release/dist/candidate-a-public/DISTRIBUTION-SHA256SUMS
   ```

   Stage renders the npm publisher pin, version and URL, and a Homebrew formula
   with exact native-binary/manifest/signature hashes. It renders registry MCPB
   hashes from final bytes. Never publish the source key/hash placeholders.
8. Run both leak scanners over the entire staged directory and an explicit final
   npm tarball. Include the tap formula, installer, user docs, manifest/sidecars,
   binaries and extracted MCPB. Keep private reports outside the staged tree:

   ```sh
   python3 ops/release/scan_release_leaks.py ops/release/dist/candidate-a-public
   LEAK_REPORT_ROOT=ops/release/.work/final-leak-reports RELEASE_PY=python3 bash ops/release/scan_release_surface.sh final-public ops/release/dist/candidate-a-public
   ```

   Run the scanner positive controls too. A missing/erroring scanner is degraded
   coverage, not a clean result. Only support@secondedoracle.xyz may occur as an
   email. Preserve evidence privately; never upload the source archive, action
   logs, task envelopes, fixture keys or private report directories.

## Install choices and unsigned OS behavior

Authenticate the publisher key first. After publication, the terminal path is:

```sh
curl -fsSL --proto '=https' https://raw.githubusercontent.com/SecondedOracle/seconded-mcp-releases/vVERSION/packaging/install.sh | sh -s -- VERSION 'ssh-ed25519 ANNOUNCED_PUBLIC_KEY'
```

Replace VERSION in both positions and supply the independently announced key.
The HTTPS bootstrap script runs before artifact verification; inspect it first,
or verify its separately signed DISTRIBUTION-SHA256SUMS hash, when fully verified
bootstrap is required. The script authenticates SHA-256SUMS.sig, checks the signed
version and binary SHA-256, then installs into a new version directory with its
sidecars. It does not execute the downloaded binary or overwrite an enrolled one.
Run the printed absolute binary path with setup --host HOST, then self-check.

Node 20+ path: `npx --yes @seconded/mcp@VERSION serve --host generic`.
The wrapper pins the publisher key and re-verifies downloaded/cached native bytes
on every launch. It retains the platform filename and signed sidecars for setup.
Use the same version-pinned command in host settings. Windows x64 is supported by
the wrapper; it does not require OpenSSH for its own cryptographic verification,
though the native client's setup still requires OpenSSH -Y verify support.

Homebrew: `brew install SecondedOracle/tap/seconded-mcp`. The formula pins all hashes
and verifies the manifest signature. The PATH launcher calls a stable libexec
binary beside its sidecars. Keep previous formula versions available for rollback;
a brew upgrade must not silently repoint a funded profile without owner review.

Direct curl/npm downloads can avoid browser-added com.apple.quarantine in the
measured macOS environment. They do not certify all macOS versions, download
agents, MCP hosts, existing filesystem attributes or enterprise policies. None
of these installers clears quarantine or disables Gatekeeper/SmartScreen.

Browser downloads may carry quarantine. After verifying the publisher and bytes,
the owner may attempt launch, then choose macOS System Settings → Privacy & Security
→ Open Anyway and confirm the one-time exception. Windows may show SmartScreen
“Windows protected your PC”; the owner reviews More info → Run anyway after
verification. The displayed unknown publisher is expected for unsigned binaries.
Managed policy can prohibit either override. Stop if the key/hash differs.
Claude Desktop MCPB import is a distinct route: a successful curl test does not
prove it works. Measure the final MCPB import, extracted binary attributes and
host launch in a clean desktop session before announcing that route as supported.

Setup prefers the OS credential store. If unavailable it automatically writes an
**UNENCRYPTED** private key file; disclose the backend before funding. Same-user
processes, administrators and backups may read it. Fund a dedicated wallet with
only a few dollars. $25/day is non-loosenable by chat; chat only tightens/freezes.
Raises, unfreezes and wallet switching require the owner terminal. Upgrade freezes
legacy nil/above-$25/day policies until that review. Limits cannot stop direct key theft.

## Operator publication order

1. Complete independent key announcements, final private-host trials and tested
   owner rollback. Obtain a separate canary spend authorization; run exactly one
   $0.25 small check from the final MCP bytes on Base, Arc and Robinhood sequentially,
   at most $0.75 service spend plus separately approved gas. Stop on an unexpected
   status and recover the same credential. This task performs none of those payments.
2. Under explicit public_release approval, create the release-only GitHub repo and
   a version tag. Upload exactly the staged assets, installer/wrapper/docs, rendered
   registry drafts, distribution checksums/signature and reviewed release notes.
   Download anew from GitHub and re-verify the independently trusted key, version,
   manifest signature and every asset hash. Public source archive upload is prohibited.
3. Pack the rendered npm directory using `npm pack --ignore-scripts`, scan/extract
   the tarball, then operator-publish `@seconded/mcp` at the exact VERSION.
   Re-download the package and compare the four launcher/config bytes and pinned key.
4. Commit the rendered Formula/seconded-mcp.rb to SecondedOracle/homebrew-tap.
   Test both architectures on the relevant Mac/Linux hosts; verify resource hashes,
   signature verification, setup, upgrade and rollback. Do not claim native testing
   from Ruby syntax checks or a local dummy download alone.
5. From the staged `registry` directory, operator-run `mcp-publisher validate`,
   `mcp-publisher login github`, then `mcp-publisher publish`. Authenticate an account
   authorized for SecondedOracle; verify the namespace authorization before publish.
   These commands use the pinned publisher CLI and final server.json. Read the
   registry entry back and compare identity, version, stdio transport, MCPB URL/hash.
6. From the staged public tree, operator-run `smithery auth login`, then
   `smithery mcp publish "assets/seconded-mcp_VERSION.mcpb" -n "seconded/seconded-mcp"`.
   Replace VERSION with the final version; the command uploads the exact local MCPB.
   smithery.yaml supplies name/target only when the name flag is omitted. The rendered
   smithery.json is an operator provenance/listing record, not a CLI input. Read back the listing and compare the exact MCPB hash, tools,
   prices and networks. Do not describe local JSON as remote registry acceptance.
7. The site owner publishes install/wallet/catalog pages under secondedoracle.xyz,
   checks the public read-back, then announces the tested channels on @SecondedOracle.
   Keep the original door available only as rollback until all canary evidence passes.

No account, credential, DNS, live-traffic or public action is performed by this
preparation task. Publication, site work, paid canaries and platform trials remain
explicit later operator steps. Schema/CLI acceptance must be rechecked against
then-current official sources before account login or publication.
