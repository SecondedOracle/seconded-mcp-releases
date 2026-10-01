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
