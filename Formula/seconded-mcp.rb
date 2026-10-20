class SecondedMcp < Formula
  desc "SECONDED local stdio MCP client"
  homepage "https://secondedoracle.xyz"
  version "0.4.4"

  on_macos do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.4/seconded-mcp_darwin_arm64", using: :nounzip
      sha256 "e9a0e42155bc3b37a631349e2603e99138efeccd1a00959e54cb524e2ba35824"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.4/seconded-mcp_darwin_amd64", using: :nounzip
      sha256 "d6049ea4d852023f8df59a6c8650f7cdcc8533ef658a3e5c3c2181b783c84f52"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.4/seconded-mcp_linux_arm64", using: :nounzip
      sha256 "8586af7b9b8ec8ecc9b042794898f6a8eb0e990ae4e618d4330b03026a5fe267"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.4/seconded-mcp_linux_amd64", using: :nounzip
      sha256 "29f55d3ad3c708b253fca512f70e1e2274abe7fb066d5f496719c73eaccb6b41"
    end
  end

  depends_on "openssh"
  resource "release-manifest" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.4/SHA-256SUMS", using: :nounzip
    sha256 "cce5dfd5041e01455bb597787232e891035c4592a75616ac885b5fb4b93c9587"
  end
  resource "release-signature" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.4/SHA-256SUMS.sig", using: :nounzip
    sha256 "7ff8737fe7ae5a38d219226c17b44433506cfafcea03503706f5ed5ad612bbf4"
  end

  def install
    resource("release-manifest").stage { (buildpath/"SHA-256SUMS").write((Pathname.pwd/"SHA-256SUMS").read) }
    resource("release-signature").stage { (buildpath/"SHA-256SUMS.sig").write((Pathname.pwd/"SHA-256SUMS.sig").read) }
    (buildpath/"allowed_signers").write('release@seconded namespaces="seconded-release" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8LZZnzivB2s/CPAeLBE7Mt8PuDGlQg5mgyy4kaxCDf' + "\n")
    Utils.safe_popen_write(Formula["openssh"].opt_bin/"ssh-keygen", "-Y", "verify",
                          "-f", buildpath/"allowed_signers", "-I", "release@seconded",
                          "-n", "seconded-release", "-s", buildpath/"SHA-256SUMS.sig") do |pipe|
      pipe.write((buildpath/"SHA-256SUMS").read)
    end
    manifest = (buildpath/"SHA-256SUMS").read
    raise "Manifest version mismatch" unless manifest.lines.first == "# seconded-release-version: #{version}\n"
    asset = Dir["seconded-mcp_*"].select { |name| File.file?(name) }.fetch(0)
    expected = "#{Digest::SHA256.file(asset).hexdigest}  #{asset}\n"
    raise "Binary absent from signed manifest" unless manifest.lines.count(expected) == 1
    # Preserve basename for the native client's signed-sidecar verification.
    libexec.install asset, "SHA-256SUMS", "SHA-256SUMS.sig"
    chmod 0755, libexec/asset
    (bin/"seconded-mcp").write_env_script libexec/asset
  end

  def caveats
    <<~EOS
      Native binaries have no Apple notarization. Verify the publisher key announcement.
      Setup can use an UNENCRYPTED private key file. Fund a dedicated wallet with only a few dollars.
      Default $25/day; chat only tightens/freezes. Raising, unfreezing and wallet switching require your terminal.
      Keep old formula versions and the complete private profile for owner-confirmed rollback.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/seconded-mcp")
  end
end
