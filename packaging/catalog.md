# SECONDED catalog

Generated from a local offline API catalog capture; see ops/release/catalog/capture-provenance.json. Prepared metadata only; no signed or published 0.3.1 release.

| Check | MCP tool | USD price by input tier |
| --- | --- | --- |
| Trade Check | `seconded_trade_check` | small: $0.25, medium: $1.50 |
| Stock Token Check | `seconded_stock_token_check` | small: $0.25 |
| Token Check | `seconded_token_check` | small: $0.25 |
| Agent Registry Check | `seconded_agent_registry_check` | small: $0.25 |
| Counterparty Address Check | `seconded_counterparty_check` | small: $0.25 |
| Cross-Chain Compare | `seconded_cross_chain_compare` | small: $0.25 |
| Scam Check | `seconded_scam_check` | small: $0.25, medium: $1.50, large: $2.50 |

| Payment network | Asset | Selection |
| --- | --- | --- |
| Base (`eip155:8453`) | USDC | `base` |
| Arc (`eip155:5042`) | USDC | `arc` |
| Robinhood Chain (`eip155:4663`) | USDG | `robinhood` |

New wallets: $2.50 per check, $25/day. Chat may only tighten or freeze; raising limits, unfreezing and switching wallets require the owner terminal. Legacy nil or above-$25/day policies freeze pending owner review. Automatic private-file fallback is UNENCRYPTED; fund a dedicated wallet with only a few dollars. Native binaries have no Apple notarization or Windows Authenticode; verify the SSH-signed SHA-256 manifest.
