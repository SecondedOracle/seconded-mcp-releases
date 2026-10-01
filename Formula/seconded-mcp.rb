class SecondedMcp < Formula
  desc "SECONDED local stdio MCP client"
  homepage "https://secondedoracle.xyz"
  version "0.3.2"

  on_macos do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/seconded-mcp_darwin_arm64", using: :nounzip
      sha256 "0e1d18c4812814c5d94f2152cdd934823bf1e71567f8bb4506721a00d04ef6cc"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/seconded-mcp_darwin_amd64", using: :nounzip
      sha256 "e78a4a4959a7664605e0a0b876c2bc9f0e7c470bf2a6af08d43296f227d8e9ba"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/seconded-mcp_linux_arm64", using: :nounzip
      sha256 "61677bff512d66f24c527084fa6586de44e132e9e81c915ab31c57d75d465618"
    end
    on_intel do
      url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/seconded-mcp_linux_amd64", using: :nounzip
      sha256 "fe0f810d32200d83daf0356226b5e4472fb2ef05b5664a9f2c985775bf1f7b5a"
    end
  end

  depends_on "openssh"
  resource "release-manifest" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/SHA-256SUMS", using: :nounzip
    sha256 "0dee951c4995131cb71e145f62380f01ba4d2706951b52bf8524496f8296c182"
  end
  resource "release-signature" do
    url "https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v0.3.2/SHA-256SUMS.sig", using: :nounzip
    sha256 "acbff111e03ee721e25869fd90729e7067897e77c3e04778d259db359c9d7419"
  end

  def install
    resource("release-manifest").stage { (buildpath/"SHA-256SUMS").write((Pathname.pwd/"SHA-256SUMS").read) }
    resource("release-signature").stage { (buildpath/"SHA-256SUMS.sig").write((Pathname.pwd/"SHA-256SUMS.sig").read) }
    (buildpath/"allowed_signers").write('release@seconded namespaces="seconded-release" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8fWrnJvaLIX4obwzm/CnbVDdQKoQZ2ExqGeVzkgaxD' + "\n")
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
