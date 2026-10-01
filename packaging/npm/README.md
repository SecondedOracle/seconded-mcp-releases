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
