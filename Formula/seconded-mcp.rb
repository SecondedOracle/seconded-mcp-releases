class SecondedMcp < Formula
  desc "SECONDED local stdio MCP client"
  homepage "https://secondedoracle.xyz"
  version "0.4.5"

  on_macos do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.5/seconded-mcp_darwin_arm64", using: :nounzip
      sha256 "e6484cd221f71b4a70f449ae70a653d16aa71be4f5badb3d668568a60f681427"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.5/seconded-mcp_darwin_amd64", using: :nounzip
      sha256 "d68d0070e37341c259095b120212f06d0399a319188bc888c9572dc84bba43d2"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.5/seconded-mcp_linux_arm64", using: :nounzip
      sha256 "b07fd35bff9bf4b6943a838fc890071f5cac52ef08b48f66c0025335dbe0063b"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.5/seconded-mcp_linux_amd64", using: :nounzip
      sha256 "c6bb4e6a6e2fac7f54bd18ea3a41c1938a418d62ae0011ad492ebf650bea2f2b"
    end
  end

  depends_on "openssh"
  resource "release-manifest" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.5/SHA-256SUMS", using: :nounzip
    sha256 "ef7aef7d9130389f658da3975a2c7d9cad1fc1cb4d0a1c424fbff66e38e05e93"
  end
  resource "release-signature" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.5/SHA-256SUMS.sig", using: :nounzip
    sha256 "7d12d17fc535726936833c850fed71ca7fe3fe667b400e6fc83c13690cc4b14f"
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
