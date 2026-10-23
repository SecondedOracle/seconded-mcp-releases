# SECONDED npm launcher

Release identity: SecondedOracle. Support: support@secondedoracle.xyz.

After the operator publishes the rendered package, use `npx --yes @seconded/mcp@VERSION serve --host generic`.
Node 20 or newer is required. No install lifecycle script executes a binary.
The launcher verifies the SSH Ed25519 signed manifest using Node's built-in crypto,
checks its exact release version and binary SHA-256, and verifies cached bytes on every launch.
It downloads directly over HTTPS and does not clear quarantine attributes.
The publisher key is pinned in the rendered package; authenticate its fingerprint on
secondedoracle.xyz and @SecondedOracle before trusting the package or installer.
The source template fails closed until the operator renders a real reviewed key.

Native executables are unsigned by Apple/Microsoft. Signature verification does not
certify notarization, SmartScreen reputation, or host acceptance. See the release runbook.
Setup prefers the OS store and automatically falls back to an UNENCRYPTED private key file.
Use a dedicated wallet with a few dollars. Defaults: $2.50/check and $25/day.
Chat can only tighten or freeze; terminal owner confirmation is required to raise,
unfreeze or switch wallets. Installation never funds a wallet or pays for a check.

The bundled client also exposes optional burn-credit tools:
`seconded_credits_quote`, `seconded_credits_redeem`, and `seconded_credits_buy`.
For paid checks, opt in with `payment_preference: "seconded_discount"`,
`network: "robinhood"`, and `agent_id`. Buying requires explicit USDG, slippage,
and gas caps plus a stable `pack_id` for recovery. Pack face value is $5–$10,
with a separate $10 maximum USDG input per pack. Ordinary checks retain their
$2.50 cap; packs still obey aggregate spending limits and freezes. See `client/README-v1.md` in the
source repository for the arguments and recovery behavior.

To export a saved purchase receipt for independent signature verification:

```sh
npx --yes @seconded/mcp@VERSION export-receipt CHECK_ID > RECEIPT.json
seconded-verify RECEIPT.json
```

Use the local check ID from `seconded_receipt` or `recover`, and the same profile
used for the purchase (`--profile /absolute/directory` before the command).
MCP callers can use `seconded_receipt` with `{"check_id":"CHECK_ID","export":true}`;
the tool's text and structured content contain the same standalone JSON document.
Export verifies the saved receipt and returns only `envelope`, `sig`, and `key_id`,
including the original signed billing and server admission ID. It makes no recovery
or network request and needs no wallet key. A missing or invalid receipt fails;
use normal receipt recovery first if no signed receipt has been saved yet.

Receipts contain public billing addresses and any signed findings. Local request
bodies, payment credentials and commitment salts are excluded. Signature verification
authenticates the signer’s assertions; it does not independently prove chain finality.

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
