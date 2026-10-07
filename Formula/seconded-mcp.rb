class SecondedMcp < Formula
  desc "SECONDED local stdio MCP client"
  homepage "https://secondedoracle.xyz"
  version "0.4.2"

  on_macos do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.2/seconded-mcp_darwin_arm64", using: :nounzip
      sha256 "af81665b06f37d1b06b5c1465a118ff9c037c2d6c9f9eb9f0b95a830706fde4c"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.2/seconded-mcp_darwin_amd64", using: :nounzip
      sha256 "8932c473b6cea475e15c1c7da854e312c5a04d9d2a01f5d51637850b4e84d96b"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.2/seconded-mcp_linux_arm64", using: :nounzip
      sha256 "5271e57867d04b4b3c20756e3e39785e5256f7dc4ba99cf8ce1d9b61c750c527"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.2/seconded-mcp_linux_amd64", using: :nounzip
      sha256 "ec9dccb9b40f49c23a0238c697501492d0e1822e5bb0ec58ed0819b2dd00267e"
    end
  end

  depends_on "openssh"
  resource "release-manifest" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.2/SHA-256SUMS", using: :nounzip
    sha256 "eca5e1a3bedc697cb38c9dbe8f2753ace5166d9360143f19633d483d76913558"
  end
  resource "release-signature" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.4.2/SHA-256SUMS.sig", using: :nounzip
    sha256 "a2aa98d426b5cfeebe5f58b241b7fef4460f06fbbd72e512aea7eeed68f0ff92"
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
