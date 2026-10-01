'use strict';
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const crypto = require('node:crypto');
const https = require('node:https');
const http = require('node:http');
const MAX = 64 * 1024 * 1024;
const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
function sshString(bytes) {
  const length = Buffer.alloc(4); length.writeUInt32BE(bytes.length);
  return Buffer.concat([length, bytes]);
}
function reader(bytes) {
  let offset = 0;
  return { take() {
    if (offset + 4 > bytes.length) throw Error('Truncated SSH field');
    const size = bytes.readUInt32BE(offset); offset += 4;
    if (size > bytes.length - offset) throw Error('Invalid SSH field size');
    const value = bytes.subarray(offset, offset + size); offset += size; return value;
  }, end() { if (offset !== bytes.length) throw Error('Trailing SSH data'); } };
}
function verifySignature(manifest, armor, pinnedKey) {
  const keyMatch = /^ssh-ed25519 ([A-Za-z0-9+/]+={0,2})(?: [^\r\n]*)?$/.exec(pinnedKey);
  if (!keyMatch) throw Error('Publisher key is unconfigured or invalid');
  const pinned = Buffer.from(keyMatch[1], 'base64');
  const key = reader(pinned);
  if (key.take().toString() !== 'ssh-ed25519') throw Error('Unsupported key');
  const rawKey = key.take(); key.end();
  if (rawKey.length !== 32) throw Error('Invalid Ed25519 key');
  const match = /^-----BEGIN SSH SIGNATURE-----\r?\n([A-Za-z0-9+/=\r\n]+)-----END SSH SIGNATURE-----\r?\n?$/.exec(armor.toString());
  if (!match) throw Error('Invalid SSH signature armor');
  const sig = Buffer.from(match[1].replace(/\s/g, ''), 'base64');
  if (sig.subarray(0, 6).toString() !== 'SSHSIG' || sig.readUInt32BE(6) !== 1) throw Error('Invalid SSHSIG version');
  const fields = reader(sig.subarray(10));
  const embeddedKey = fields.take(), namespace = fields.take(), reserved = fields.take(), hashName = fields.take();
  const signature = reader(fields.take()); fields.end();
  if (!embeddedKey.equals(pinned) || namespace.toString() !== 'seconded-release' || reserved.length) throw Error('Publisher/namespace mismatch');
  if (!['sha256','sha512'].includes(hashName.toString())) throw Error('Unsupported SSHSIG hash');
  if (signature.take().toString() !== 'ssh-ed25519') throw Error('Unsupported signature');
  const signed = signature.take(); signature.end();
  const message = Buffer.concat([Buffer.from('SSHSIG'), sshString(namespace), sshString(reserved), sshString(hashName),
    sshString(crypto.createHash(hashName.toString()).update(manifest).digest())]);
  const publicKey = crypto.createPublicKey({key: Buffer.concat([Buffer.from('302a300506032b6570032100','hex'), rawKey]), format:'der', type:'spki'});
  if (!crypto.verify(null, message, publicKey, signed)) throw Error('Invalid manifest signature');
}
function parseManifest(bytes, version) {
  const lines = bytes.toString('utf8').split('\n');
  if (lines.shift() !== '# seconded-release-version: ' + version || lines.pop() !== '') throw Error('Manifest version/format mismatch');
  const files = new Map();
  for (const line of lines) {
    const item = /^([0-9a-f]{64})  ([A-Za-z0-9._-]+)$/.exec(line);
    if (!item || files.has(item[2])) throw Error('Malformed/duplicate manifest entry');
    files.set(item[2], item[1]);
  }
  if (!files.size) throw Error('Empty manifest');
  return files;
}
function fetchBytes(location, allowLoopback = false, redirects = 0) {
  const url = new URL(location);
  const local = allowLoopback && url.protocol === 'http:' && url.hostname === '127.0.0.1';
  if (url.username || url.password || (url.protocol !== 'https:' && !local)) return Promise.reject(Error('HTTPS required'));
  return new Promise((resolve, reject) => {
    const req = (local ? http : https).get(url, res => {
      if ([301,302,303,307,308].includes(res.statusCode)) {
        res.resume();
        if (!res.headers.location || redirects >= 5) return reject(Error('Invalid redirect'));
        return fetchBytes(new URL(res.headers.location, url).href, allowLoopback, redirects + 1).then(resolve, reject);
      }
      if (res.statusCode !== 200) { res.resume(); return reject(Error('Download HTTP ' + res.statusCode)); }
      let size = 0; const chunks = [];
      res.on('data', data => { size += data.length; if (size > MAX) res.destroy(Error('Download too large')); else chunks.push(data); });
      res.on('end', () => resolve(Buffer.concat(chunks))); res.on('error', reject);
    });
    req.setTimeout(30000, () => req.destroy(Error('Download timeout'))); req.on('error', reject);
  });
}
function targetName(platform = process.platform, arch = process.arch) {
  const target = {darwin: {arm64:'darwin_arm64',x64:'darwin_amd64'}, linux:{arm64:'linux_arm64',x64:'linux_amd64'},win32:{x64:'windows_amd64'}}[platform]?.[arch];
  if (!target) throw Error('Unsupported OS/CPU');
  return 'seconded-mcp_' + target + (platform === 'win32' ? '.exe' : '');
}
async function install(config, destination, options = {}) {
  if (!/^[0-9]+\.[0-9]+\.[0-9]+(?:[-+][A-Za-z0-9.-]+)?$/.test(config.version)) throw Error('Invalid release version');
  const name = targetName(options.platform, options.arch);
  const base = config.baseUrl.replace(/\/$/, '');
  const manifest = await fetchBytes(base + '/SHA-256SUMS', options.allowLoopback);
  const signature = await fetchBytes(base + '/SHA-256SUMS.sig', options.allowLoopback);
  verifySignature(manifest, signature, config.publisherKey);
  const expected = parseManifest(manifest, config.version).get(name);
  if (!expected) throw Error('Missing binary checksum');
  // Never trust a cached executable merely because it exists.
  const executable = path.join(destination, name);
  try {
    const stat = fs.lstatSync(executable);
    if (stat.isSymbolicLink() || !stat.isFile() || sha256(fs.readFileSync(executable)) !== expected) throw Error('Cached executable failed verification');
    // The freshly verified sidecars must also cover the setup-visible copy.
    fs.writeFileSync(path.join(destination,'SHA-256SUMS'), manifest, {mode:0o600});
    fs.writeFileSync(path.join(destination,'SHA-256SUMS.sig'), signature, {mode:0o600});
    return executable;
  } catch (error) { if (error.code !== 'ENOENT') throw error; }
  const binary = await fetchBytes(base + '/' + name, options.allowLoopback);
  if (sha256(binary) !== expected) throw Error('Binary SHA-256 mismatch');
  fs.mkdirSync(path.dirname(destination), {recursive:true, mode:0o700});
  fs.mkdirSync(destination, {mode:0o700});
  fs.writeFileSync(path.join(destination,'SHA-256SUMS'), manifest, {flag:'wx',mode:0o600});
  fs.writeFileSync(path.join(destination,'SHA-256SUMS.sig'), signature, {flag:'wx',mode:0o600});
  fs.writeFileSync(executable, binary, {flag:'wx',mode:0o755});
  return executable;
}
module.exports = {install, verifySignature, parseManifest, targetName, sha256};
