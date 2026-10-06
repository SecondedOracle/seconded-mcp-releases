class SecondedMcp < Formula
  desc "SECONDED local stdio MCP client"
  homepage "https://secondedoracle.xyz"
  version "0.4.0"

  on_macos do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.0/seconded-mcp_darwin_arm64", using: :nounzip
      sha256 "eb6d3a843537e80dac9b8be9f730ee977ac4894797711ab8a07f3cd0adaa2ca3"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.0/seconded-mcp_darwin_amd64", using: :nounzip
      sha256 "59203b26e3519f7880f17d3cdf288a12e82a041e33c15d21369daffce2f55e93"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.0/seconded-mcp_linux_arm64", using: :nounzip
      sha256 "8b0a7e87d5941264e8808933db79b7d74d7222d46454bc5826a28e08fa85f253"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.0/seconded-mcp_linux_amd64", using: :nounzip
      sha256 "8d9fe1fda1e67eb663d8efe8880821d0b1245b37d68d40c0f21b1154ae6ed738"
    end
  end

  depends_on "openssh"
  resource "release-manifest" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.0/SHA-256SUMS", using: :nounzip
    sha256 "ee1d57df4960ba19ab2a2845abd048e955610048ac5ba500a6fb6116193e4db9"
  end
  resource "release-signature" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.0/SHA-256SUMS.sig", using: :nounzip
    sha256 "1a99441dc45b08c73a24109b8c142bb7ceae9ae1eb3b38fe76c2ea23b40c36c0"
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
