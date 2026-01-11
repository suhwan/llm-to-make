#!/usr/bin/env node
/**
 * Make MCP Wrapper
 * Reads MAKE_MCP_URL from .env and launches mcp-remote
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// Find .env file (check current dir and parent dirs)
function findEnvFile() {
    let dir = process.cwd();
    for (let i = 0; i < 5; i++) {
        const envPath = path.join(dir, '.env');
        if (fs.existsSync(envPath)) {
            return envPath;
        }
        const parent = path.dirname(dir);
        if (parent === dir) break;
        dir = parent;
    }
    return null;
}

// Parse .env file
function parseEnv(filePath) {
    const env = {};
    const content = fs.readFileSync(filePath, 'utf8');
    content.split('\n').forEach(line => {
        line = line.trim();
        if (line && !line.startsWith('#')) {
            const [key, ...valueParts] = line.split('=');
            if (key && valueParts.length > 0) {
                env[key.trim()] = valueParts.join('=').trim();
            }
        }
    });
    return env;
}

// Main
const envFile = findEnvFile();
if (!envFile) {
    console.error('[ERROR] .env file not found');
    process.exit(1);
}

const env = parseEnv(envFile);
const makeUrl = env.MAKE_MCP_URL;

if (!makeUrl || makeUrl === 'YOUR_MAKE_MCP_URL_HERE') {
    console.error('[ERROR] MAKE_MCP_URL not set in .env');
    console.error('Please add your Make MCP URL to .env file');
    process.exit(1);
}

// Launch mcp-remote with the URL
const child = spawn('npx', ['-y', 'mcp-remote', makeUrl], {
    stdio: 'inherit',
    shell: true
});

child.on('error', (err) => {
    console.error('[ERROR] Failed to start mcp-remote:', err.message);
    process.exit(1);
});

child.on('exit', (code) => {
    process.exit(code || 0);
});
