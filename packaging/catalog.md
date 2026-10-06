# SECONDED catalog

Generated from a local offline API catalog capture; see ops/release/catalog/capture-provenance.json (historical capture catalog_sha256=9fd1e5238e17f95781d496439e78c242831a40962b78efb3afec911ae4841284 preserved; candidate manually revised). Prepared metadata only; no signed or published 0.3.1 release.

SECONDED exposes 12 paid verification checks and six MCP utility tools across five core job groups. It does not provide general transaction signing, trading execution, bridging, or automated portfolio actions. Payment signing for check fees is strictly bounded ($0.10 to $2.50) and never authorizes generic financial execution.

---

## Job Groups and Product Catalog

### 1. Before signing
Checks performed on unsigned transactions, permits, or cross-chain pool quotes before an agent or owner signs or routes funds.

| Product & MCP Tool | Display Alias | Purpose & Benefit | Input & Subject Chains | Output & Action Labels | Tiers & Prices (USD) |
| --- | --- | --- | --- | --- | --- |
| **Trade Check**<br>`seconded_trade_check`<br>(API: `trade_check`) | Transaction & Permit Check | Validates unsigned transactions or EIP-712 permits against two independent chain readers at a pinned block. Identifies approval scope, spender address, allowance amounts, nonce, expiry, and dangerous simulation reverts. | **Input**: Exactly one of `transaction` (required fields: `chainId`, `from`, `to`, `value`, `data` hex calldata ≤8,192 B; optional fee fields: `gas`, `gasPrice`, or paired `maxFeePerGas` + `maxPriorityFeePerGas`; max 20,000 canonical bytes) or `typed_data` (EIP-712 permit).<br>**Subject Chains**: Base (`eip155:8453`), Arc (`eip155:5042`), Robinhood (`eip155:4663`). Testnets excluded. | `proceed`: sign exact input.<br>`do_not_proceed`: STOP and show owner.<br>`NOT VERIFIED`: pause or ask human.<br>*(Withheld if evidence unbound or contradicts verified facts).* | Small (≤8,192 B): **$0.25**<br>Medium (≤65,536 B): **$1.50**<br>Large: *unavailable* |
| **Cross-Chain Compare**<br>`seconded_cross_chain_compare`<br>(API: `cross_chain_compare`) | Base–Arc USDC/EURC Comparison | Reads two independent readers at pinned blocks on Base (Uniswap V3) and Arc (Uniswap V4) to compare gross pool quote outputs for Circle USDC to EURC swaps. | **Input**: `mode`: "exact_in", `amount_in`: 1–10,000 USDC, `asset_in`: "circle:usdc", `asset_out`: "circle:eurc", `routes`: exactly 2 route objects (Base V3 and Arc V4).<br>**Subject Chains**: Base V3 and Arc V4 strictly. Requires standard x402 door (`POST /v1/x402/checks`) and client ≥0.3.1. | `comparison_available`: inspect quotes directly; check exact transaction separately before signing.<br>`comparison_invalid`: STOP and inspect invalid quote state.<br>`cannot_verify` / `NOT VERIFIED`: pause. | Small (≤8,192 B): **$0.10** ($0.15 on Robinhood)<br>Medium: *unavailable*<br>Large: *unavailable* |

> [!IMPORTANT]
> **Cross-Chain Compare is NOT Trade Execution or Total-Cost Ranking:** Cross-Chain Compare reports gross pool quote facts only, within a 30-second freshness window and 10-second skew. It does NOT execute trades, does NOT bridge assets, does NOT sign transactions, does NOT calculate destination gas or bridge fees, and does NOT rank total execution cost.

### 2. Assets
Pre-interaction analysis of smart contract tokens and official stock-token identities.

| Product & MCP Tool | Purpose & Benefit | Input & Subject Chains | Output & Action Labels | Tiers & Prices (USD) |
| --- | --- | --- | --- | --- |
| **Stock Token Check**<br>`seconded_stock_token_check`<br>(API: `stock_token_check`) | Verifies official Robinhood or Coinbase Base stock-token address against official issuer registries; returns optional signed parity (premium/discount bps vs reference USD price) and market calendar status. | **Input**: `network` (`eip155:4663` or `eip155:8453`), `address` (40-hex); optional `ticker` (e.g. `AAPLc` on Base, `AAPL` on Robinhood), optional `intended_price_usd`.<br>**Subject Chains**: Base (`eip155:8453`), Robinhood (`eip155:4663`). | `official_stock_token`: identity checked; not an endorsement.<br>`not_official_or_out_of_line`: STOP and show owner.<br>`NOT VERIFIED`: pause or ask human. | Small (≤8,192 B): **$0.10** ($0.15 on Robinhood)<br>Medium: *unavailable*<br>Large: *unavailable* |
| **Token Check**<br>`seconded_token_check`<br>(API: `token_check`) | Evaluates contract bytecode, impersonation warnings, administrative/owner control, honeypot sell reverts via state-override simulation, and excessive sell taxes (>1% soft, >10% HARD). | **Input**: `network`, `address` (40-hex); optional `context` (≤2,000 characters).<br>**Subject Chains**: Base (`eip155:8453`), Arc (`eip155:5042`), Robinhood (`eip155:4663`), Base Sepolia (`eip155:84532`). | `no_checked_warning_signs`: proceed with normal checks; not an endorsement.<br>`warning_no_contract`: STOP.<br>`warning_impersonation`: STOP.<br>`warning_owner_control`: STOP.<br>`NOT VERIFIED`: pause. | Small (≤8,192 B): **$0.10** ($0.15 on Robinhood)<br>Medium: *unavailable*<br>Large: *unavailable* |

### 3. Counterparties
Screening of on-chain agent identities and counterparty addresses before transacting.

| Product & MCP Tool | Purpose & Benefit | Input & Subject Chains | Output & Action Labels | Tiers & Prices (USD) |
| --- | --- | --- | --- | --- |
| **Agent Registry Check**<br>`seconded_agent_registry_check`<br>(API: `agent_registry_check`) | Reads ERC-8004 on-chain agent registration and bounded feedback records from two independent readers at a pinned block. Verifies claimed owner and payment-wallet addresses. | **Input**: `network`, `agent_id` (integer or numeric string up to uint256); optional `claimed_owner`, `claimed_wallet`, `context`.<br>**Subject Chains**: Base (`eip155:8453`), Arc (`eip155:5042`), Robinhood (`eip155:4663`). | `registered_with_feedback`: registration checked; feedback is not a trust score.<br>`registered_without_feedback`: registration checked.<br>`not_registered` / `owner_mismatch` / `wallet_mismatch` / `feedback_revocations_present`: STOP.<br>`NOT VERIFIED`: pause. | Small (≤8,192 B): **$0.25**<br>Medium: *unavailable*<br>Large: *unavailable* |
| **Address Screening Check**<br>`seconded_counterparty_check`<br>(API: `counterparty_check`) | Screens the address against sanctions, scam and phishing lists and known deployments using two readers at one block. A no-match is not proof of safety. | **Input**: `network`, `address` (40-hex only).<br>**Subject Chains**: Base (`eip155:8453`), Arc (`eip155:5042`), Robinhood (`eip155:4663`). | `listed_warning`: STOP and review exact list flag.<br>`deployment_mismatch`: STOP and review mismatch.<br>`configured_deployment_match` / `no_list_match`: continue other checks.<br>`cannot_verify` / `NOT VERIFIED`: pause. | Small (≤8,192 B): **$0.10** ($0.15 on Robinhood)<br>Medium: *unavailable*<br>Large: *unavailable* |

> [!NOTE]
> **No Trust Scores or Legal Guarantees:** Agent registration is not a trust score, credit rating, or endorsement. Counterparty address screening detects exact list presence and pin match only; it makes no legal, sanctions, audit, or safety conclusion.

### 4. Messages
Off-chain content and natural language message evaluation.

| Product & MCP Tool | Purpose & Benefit | Input & Subject Chains | Output & Action Labels | Tiers & Prices (USD) |
| --- | --- | --- | --- | --- |
| **Scam Check**<br>`seconded_scam_check`<br>(API: `scam_check`) | Dual-model evaluation of incoming messages, emails, chats, or agent instructions to detect deceptive intent, social engineering, fraudulent requests, and prompt injection attacks. | **Input**: `message` (required, 1–400,000 characters); optional `source` (`email`, `chat`, `social`, `web`, `agent`, `other`), optional `context` (1–100,000 characters).<br>**Subject Chains**: Chain-independent. | `benign`: proceed.<br>`suspicious`: pause; verify independently.<br>`malicious`: STOP and show owner.<br>`NOT VERIFIED`: pause or ask human. | Small (≤8,192 B): **$0.10** ($0.15 on Robinhood)<br>Medium (≤65,536 B): **$1.50**<br>Large (≤131,072 B): **$2.50** |

### 5. Wallet & receipts (Utility Tools)
Local MCP utilities and public API metadata routes for spending management and recovery.

| Tool / Route | Purpose & Benefit | Key Input | Cost |
| --- | --- | --- | --- |
| `seconded_wallet`<br>(local MCP) | Displays dedicated check wallet address, balances across all six networks, funding guidance, and freeze control. First call runs safe default setup without queuing a check. | `action`: `"status"` or `"freeze"` | Free (local) |
| `seconded_get_limits`<br>(local MCP) | Inspects active per-check, hourly, daily, and outstanding USD spending limits, along with safety switch states. | None | Free (local) |
| `seconded_set_limits`<br>(local MCP) | Allows chat to tighten spending limits, enable safety switches, or freeze authorizations. (Raising limits, unfreezing, or disabling switches requires owner terminal). | Policy patch JSON (e.g. `{"daily_usd": 20}`) | Free (local) |
| `seconded_products`<br>(GET `/v1/products`) | Returns the complete product guide, input schemas, prices, tiers, and enabled payment networks. | None | Free (public API) |
| `seconded_quote`<br>(POST `/v1/quote`) | Previews tier and price for a check input without payment authorization or challenge creation. *(Preview does not guarantee input acceptance).* | `product`, `input` | Free (public API) |
| `seconded_receipt`<br>(GET `/v1/checks/{check_id}` / POST `/v1/x402/checks`) | Recovers checks using the existing local handle in `check_id` without duplicate purchases; the handle can differ from the signed server admission ID. Standard x402 door replays the exact retained body and payment signature via POST; legacy original door and archives use GET with read-only ownership proof. Polling pending states retains the recovery lock until verified resolution. | `check_id` (optional; lists recent if omitted) | Free (public API / local ledger) |

---

## Production Payment Rails vs Subject Chains

Checks are paid in stablecoins on designated payment rails, completely independent of the chain being inspected:

| Payment Network | Chain ID | Asset | Client / API Selector | Rail Status |
| --- | --- | --- | --- | --- |
| **Base mainnet** | `eip155:8453` | USDC (`0x833589fcd6edb6e08f4c7c32d4f71b54bda02913`) | `base` | Default production rail |
| **Arc mainnet** | `eip155:5042` | USDC | `arc` | Production rail |
| **Robinhood Chain mainnet** | `eip155:4663` | Global Dollar (USDG) | `robinhood` | Production rail |

*Developer testnet rails (`base_sepolia`, `arc_testnet`, `robinhood_testnet`) are strictly segregated from production payment rails. Testnet funds cannot be used on mainnet deployments.*

---

## Wallet Boundaries and Spending Policy

1. **Dedicated Hot Wallet**: Setup creates an isolated EOA stored in the operating system credential store (macOS Keychain, Linux Secret Service, Windows Credential Manager) or falls back to private, unencrypted file storage (`~/.seconded/wallet.key`, mode 0600). Fund with only a few dollars of USDC/USDG.
2. **Spending Defaults**: New profiles enforce a **$2.50 per-check maximum** and a **$25.00 daily budget**. Hourly and outstanding limits are unset by default. Dedupe (300s) and loop brake (30 authorizations / 60s) are enabled.
3. **Owner Terminal Boundary**: Chat agents may **only tighten limits or freeze payments**. Raising limits, removing limits, unfreezing, disabling dedupe or loop brake, exporting private keys (`export-key`), and switching wallets require the human owner in a controlling terminal (`/dev/tty` / `CONIN$`) confirming with the wallet address's last six characters.
4. **Execution Authority Boundary**: The dedicated check wallet uses a standard secp256k1 EOA key whose operations within SECONDED are strictly limited by client policy to EIP-3009 check verification fee authorizations ($0.10–$2.50) to configured payees. The client exposes no arbitrary transaction signing, trade execution, or portfolio management commands. The key itself is a normal EOA and is not cryptographically restricted on-chain; to prevent exposure outside SECONDED, maintain a dedicated low-balance hot wallet ($5–$10) isolated from portfolio assets, backed by OS credential store protections.

---

## Unavailable and Retired Products

- **Unavailable / Not Offered**:
  - `portfolio_check` (Portfolio Check): Cut tool; unavailable, not offered (`422 product_in_testing`).
  - `hidden_prompt_check` (Hidden Prompt Check): Cut tool; unavailable, not offered (`422 product_in_testing`).
  - `owner_instruction_check` (Owner Instruction Check): Cut tool; unavailable, not offered (`422 product_in_testing`).
  - `code_review` (Code Review): In testing; not purchasable.
- **Retired Products**:
  - `transaction_check` (Free-text Transaction Check): Retired; input refused.
  - `full_stock_check` (Full Stock Check): Retired; input refused.

---

## Lending (0.4.0 Source Candidate — Morpho Blue)

| Product & MCP Tool | Purpose & Benefit | Input & Subject Chains | Output & Action Labels | Tiers & Prices (USD) |
| --- | --- | --- | --- | --- |
| **Lending Check**<br>`seconded_lending_check`<br>(API: `lending_check`) | Checks bounded Morpho Blue lending evidence. | Typed position on Base or Arc. | Inspect observations; pause if NOT VERIFIED. | Small (≤8,192 B): **$0.25**<br>Medium: *unavailable*<br>Large: *unavailable* |

> [!WARNING]
> **RELEASE HELD:** This offline 0.4.0 source candidate enables Lending through the normal registry and `seconded_lending_check`. It is not published or deployed. Root must qualify actual model, RPC, facilitator and settlement costs on every payment rail before merging or deploying this revision; independent review and a fresh execution grant remain required.
> Base/Arc paired subject checks passed at captured blocks 52062874/23822304. These historical facts are not current health evidence; Robinhood remains disabled as a Lending subject.

- **Exact Input**: `network`, `account`, and `market_id` only, with no extra fields. The account is a `0x`-prefixed 40-hex address and the market ID is `0x` plus 64 hex characters. Original input spelling binds the request; reader identities normalize lowercase.
- **Subject Chains**: Base (`eip155:8453`) and Arc (`eip155:5042`) only. Robinhood (`eip155:4663`) is disabled as a Lending subject.
- **Read-Only Scope**: Observes one existing account position in one Morpho Blue market at a pinned block. No proposed before/after simulation, approval analysis, borrowing, repayment, collateral movement, liquidation execution, staking, rebalancing, or yield optimization.
- **Observed States**: `no_debt`, `within_lltv_at_block`, and `liquidatable_at_block` describe the observed position. Unknown, unavailable, inconsistent, stale, or declined evidence yields no delivered answer or settlement intent (`cannot_verify` is the abstention option). These are distinct from API/MCP transport and recovery statuses.
- **Evidence Contract**: `receipt.envelope.answer.lending_observations` contains `sheet` and `evidence_sha256`. The sheet carries input, facts, source, and coverage; atomic quantities, shares, scales, and rates use exact decimal strings. Source block numbers/timestamps and token decimals remain bounded integers. Input, pinned block number/hash, evidence digest, and signed `outcome_at` bind the result; the complete sheet is capped at 8192 bytes.
- **Limits**: Oracle accuracy and independent feed age remain unknown. Evidence freshness is bounded to 120 seconds at the signed outcome time. An at-block relationship is conditional on the protocol oracle, not future safety, financial advice, or authority to take a loan action.
- **Fees & Wallets**: Subject chain and fee rail are independent. Existing Base USDC, Arc USDC, and Robinhood USDG fee rails and client check wallet policy remain unchanged; no new custody, key migration, or wallet provisioning.
- **Price**: Small $0.25 on all three existing fee rails; no Medium/Large tier.
- **Source Contract**: See [`LENDING` catalog/input schema](../server/checks/products.py), [`LendingInput` / `LendingObservations` / `Answer` OpenAPI components](../docs/openapi.json), and [`LendingCheck` evidence validation](../server/checks/lending_check.py). These are candidate source contracts. Keep published 0.3.2 install examples until 0.4.0 publication; do not execute paid examples before the release gates pass.

<!-- qualified040:start -->
## Qualified 0.4.0 checks

These four checks require stable client version 0.4.0 or newer.
Vault and Private Receive remain in testing and cannot be purchased.

| Product & MCP Tool | Scope | Tiers & Prices (USD) |
| --- | --- | --- |
| **Agent Work Payout Check**<br>`seconded_job_escrow_check`<br>(API: `job_escrow_check`) | Reviewed TermiX and Virtuals ACP V3 deployments on Base only. Two readers at one pinned block; typed facts, two blind judges and deterministic freshness/contradiction vetoes. Pooled balances do not prove order funding. Missing order terms, incomplete roles and unreviewed dependencies remain unknown. No refund or payout guarantee. | Small: **$0.25** |
| **x402 Payment Check**<br>`seconded_x402_payment_check`<br>(API: `x402_payment_check`) | Typed offer and budget checks with input-bound client signing evidence validated against the offer; missing authorization context withholds proceed and settlement verification. Seller delivery is not checked. Two agreeing readers and two independent judges; unknown is not a pass. | Small: **$0.10** ($0.15 on Robinhood) |
| **Shielded Route Check**<br>`seconded_shielded_route_check`<br>(API: `shielded_route_check`) | Public route quotes only; execution is never authorized. The existing seconded_privacy_shielded_route remains a client-local planning tool. Two agreeing readers and two independent judges; unknown is not a pass. | Small: **$0.25** |
| **Bridge Route Check**<br>`seconded_route_check`<br>(API: `route_check`) | Typed connected hops, reviewed contracts, public history and list screening; no privacy or compliance guarantee. Two agreeing readers and two independent judges; unknown is not a pass. | Small: **$0.10** ($0.15 on Robinhood) |

Prepared source and metadata only; this generation does not deploy or publish.
<!-- qualified040:end -->
