# SECONDED distribution templates

These files prepare an unsigned native release under SecondedOracle; they publish nothing.
Support: support@secondedoracle.xyz. The SSH release manifest authenticates exact bytes;
it does not confer Apple notarization or Windows Authenticode trust.

After final staging, the release directory includes `packaging/install.sh`, a rendered
`packaging/npm` package and `Formula/seconded-mcp.rb`. Only the rendered files are ready
for operator publication. Never publish the unconfigured publisher-key template.
The Homebrew formula pins each platform binary, manifest and signature checksum,
and verifies the SSH signature before installing. Brew uses a stable libexec basename
with sidecars and a PATH launcher. A formula template by itself is not an installed tap.

Terminal installation after publication (replace VERSION and the independently announced key):

```sh
curl -fsSL --proto '=https' https://raw.githubusercontent.com/SecondedOracle/seconded-mcp-releases/vVERSION/packaging/install.sh | sh -s -- VERSION 'ssh-ed25519 ANNOUNCED_PUBLIC_KEY'
```

Authenticate the script's repository/tag through the independent publisher announcement;
the bootstrap script executes before artifact verification. For a fully verified bootstrap,
download and inspect the script first using its separately published SHA-256.
The script verifies the signed manifest and binary before installation and does not execute
the binary. It retains the original platform filename and sidecars in a new version directory.
`SECONDED_INSTALL_DIR` selects a new directory; existing installs are refused.
The binary's setup verifies sidecars again against its compiled publisher-key pin.
No installer removes quarantine attributes or disables OS checks.

npm: `npx --yes @seconded/mcp@VERSION serve --host generic` (Node 20+).
Homebrew: `brew install SecondedOracle/tap/seconded-mcp` after the operator creates the tap.
A browser download can carry quarantine; see the runbook for owner-controlled macOS/Windows approval.
Local HTTP is accepted only on 127.0.0.1 for the explicit local test harness. Public distribution uses HTTPS.

Pricing and payment networks are generated in [catalog.md](catalog.md).
Installation is free and performs no check. Fund a dedicated wallet with only a few dollars.
Automatic fallback stores a private key file UNENCRYPTED. Default spending is $25/day;
chat only tightens or freezes. Owner terminal confirmation governs raises, unfreezes and switches.

## Client 0.4.5 candidate

This local candidate adds burn-credit buying, quoting and redemption to the MCP
catalog (21 tools). Repeat the same `pack_id` and arguments to recover a buy;
`seconded_receipt` recovers a check, and authenticated credit status is queried
when an older server omits a balance snapshot. There is no separate credit-status
MCP tool. Use `payment_preference: "seconded_discount"`, `network: "robinhood"`
and `agent_id` to opt in.

Credit-paid check results and CLI `recover` output show the dollar balance
**after this check**, its observation time, and `credit_balance_trust: "unsigned"`.
The spendable balance excludes reserved, expired and frozen credits. It is a
transport-authenticated account snapshot outside the signed receipt; it cannot
prove a balance later or change signed billing. Older replies without the new
fields remain supported; a separate status lookup is labelled accordingly.

Saved receipt export is available through `export-receipt CHECK_ID` and MCP
`seconded_receipt` with `export: true`. Export preserves only the original signed
receipt. The release carries forward 0.4.4 Asset Check, quote-network selection,
billing guidance, unsigned service diagnostics and certified-nonpayment recovery
fixes, plus the receipt-export and paid-run regression fixes.

Version 0.4.5 is prepared locally only. Publication, publisher signatures and paid
candidate end-to-end qualification remain separate steps.
