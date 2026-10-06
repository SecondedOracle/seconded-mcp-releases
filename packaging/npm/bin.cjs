#!/usr/bin/env node
'use strict';
const path = require('node:path');
const os = require('node:os');
const {spawn} = require('node:child_process');
const {install} = require('./download.cjs');
const config = require('./release-config.json');
(async () => {
  const root = process.env.LOCALAPPDATA || process.env.XDG_DATA_HOME || path.join(os.homedir(), '.local', 'share');
  const binary = await install(config, path.join(root, 'seconded-mcp', 'npm-' + config.version));
  const child = spawn(binary, process.argv.slice(2), {stdio:'inherit', windowsHide:true});
  for (const signal of ['SIGINT','SIGTERM']) process.on(signal, () => child.kill(signal));
  child.on('error', error => { console.error(error.message); process.exitCode = 1; });
  child.on('exit', (code, signal) => { process.exitCode = code ?? (signal ? 1 : 0); });
})().catch(error => { console.error('SECONDED install failed: ' + error.message); process.exitCode = 1; });
