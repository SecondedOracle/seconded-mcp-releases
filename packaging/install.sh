#!/bin/sh
# Usage: sh install.sh VERSION 'ssh-ed25519 INDEPENDENTLY_TRUSTED_PUBLIC_KEY'
set -eu
umask 077
version=${1:?Supply the reviewed release version}
publisher_key=${2:?Supply the publisher key authenticated on the website and @SecondedOracle}
case "$version" in *[!0-9A-Za-z.+-]*|'') echo 'Invalid version' >&2; exit 64;; esac
case "$publisher_key" in 'ssh-ed25519 '*) ;; *) echo 'Expected SSH Ed25519 public key' >&2; exit 64;; esac
case "$publisher_key" in *'
'*) echo 'Multiline key refused' >&2; exit 64;; esac
base=${SECONDED_DOWNLOAD_BASE:-https://github.com/SecondedOracle/seconded-mcp-releases/releases/download/v$version}
case "$base" in https://*) protocols='=https';; http://127.0.0.1:*) protocols='=http';; *) echo 'HTTPS required (loopback HTTP allowed for local tests)' >&2; exit 64;; esac
install_dir=${SECONDED_INSTALL_DIR:-${HOME:?}/.local/share/seconded-mcp/$version}
if [ -e "$install_dir" ] || [ -L "$install_dir" ]; then echo 'Use a new versioned install directory; existing install refused' >&2; exit 73; fi
case "$(uname -s)/$(uname -m)" in
 Darwin/arm64) target=darwin_arm64;; Darwin/x86_64) target=darwin_amd64;;
 Linux/aarch64|Linux/arm64) target=linux_arm64;; Linux/x86_64) target=linux_amd64;;
 *) echo 'Unsupported OS/CPU; use the reviewed platform download' >&2; exit 69;;
esac
binary=seconded-mcp_$target
for executable in curl ssh-keygen awk shasum; do command -v "$executable" >/dev/null || exit 69; done
scratch=$(mktemp -d "${TMPDIR:-/tmp}/seconded-install.XXXXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
fetch() { curl --fail --silent --show-error --location --proto "$protocols" --proto-redir "$protocols" --max-time 60 "$base/$1" -o "$scratch/$1"; }
fetch SHA-256SUMS
fetch SHA-256SUMS.sig
printf 'release@seconded namespaces="seconded-release" %s\n' "$publisher_key" > "$scratch/allowed_signers"
ssh-keygen -Y verify -f "$scratch/allowed_signers" -I release@seconded -n seconded-release -s "$scratch/SHA-256SUMS.sig" < "$scratch/SHA-256SUMS"
expected=$(awk -v version="$version" -v binary="$binary" '
 NR==1 {if ($0 != "# seconded-release-version: " version) exit 1; next}
 {if (length($1)!=64 || $1 ~ /[^0-9a-f]/ || $0 != $1 "  " $2 || $2 ~ /[^A-Za-z0-9._-]/ || seen[$2]++) exit 1;
 if ($2==binary) {hash=$1; count++}}
 END {if (count!=1) exit 1; print hash}' "$scratch/SHA-256SUMS")
fetch "$binary"
actual=$(shasum -a 256 "$scratch/$binary" | awk '{print $1}')
[ "$actual" = "$expected" ] || { echo 'Binary SHA-256 mismatch' >&2; exit 1; }
# Keep original asset basename and sidecars: the client binds setup to this file.
mkdir -p "$(dirname "$install_dir")"
mkdir "$install_dir"
cp "$scratch/$binary" "$scratch/SHA-256SUMS" "$scratch/SHA-256SUMS.sig" "$install_dir/"
chmod 755 "$install_dir/$binary"
printf 'Verified installation: %s/%s\nRun this path with setup --host HOST, then self-check. Fund small.\n' "$install_dir" "$binary"
