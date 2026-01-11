#!/usr/bin/env node
/**
 * Claude Desktop MCP Config Merge Script
 *
 * Preserves existing settings while adding Make/Airtable MCP.
 */

const fs = require('fs');
const path = require('path');

// Read from environment variables
const AIRTABLE_API_KEY = process.env.AIRTABLE_API_KEY;
const AIRTABLE_BASE_ID = process.env.AIRTABLE_BASE_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const MAKE_MCP_URL = process.env.MAKE_MCP_URL;

if (!MAKE_MCP_URL) {
    console.error('[ERROR] MAKE_MCP_URL environment variable not set.');
    console.error('  Please add MAKE_MCP_URL to your .env file.');
    process.exit(1);
}

// Claude Desktop config file path
const CLAUDE_DIR = path.join(process.env.APPDATA || '', 'Claude');
const CONFIG_FILE = path.join(CLAUDE_DIR, 'claude_desktop_config.json');
const BACKUP_FILE = path.join(CLAUDE_DIR, 'claude_desktop_config.json.backup');

console.log('');
console.log('========================================');
console.log('  MCP Config Merge Script');
console.log('========================================');
console.log('');

// Check required values
if (!AIRTABLE_API_KEY || !AIRTABLE_BASE_ID) {
    console.error('[ERROR] Environment variables not set.');
    console.error('  - AIRTABLE_API_KEY');
    console.error('  - AIRTABLE_BASE_ID');
    process.exit(1);
}

// Create Claude folder
if (!fs.existsSync(CLAUDE_DIR)) {
    fs.mkdirSync(CLAUDE_DIR, { recursive: true });
    console.log(`[CREATED] ${CLAUDE_DIR}`);
}

// Read existing config
let existingConfig = { mcpServers: {} };
let hasExistingConfig = false;

if (fs.existsSync(CONFIG_FILE)) {
    hasExistingConfig = true;
    console.log('[FOUND] Existing config file');

    // Backup
    fs.copyFileSync(CONFIG_FILE, BACKUP_FILE);
    console.log(`[BACKUP] ${BACKUP_FILE}`);

    try {
        const content = fs.readFileSync(CONFIG_FILE, 'utf8');
        existingConfig = JSON.parse(content);

        // Create mcpServers if not exists
        if (!existingConfig.mcpServers) {
            existingConfig.mcpServers = {};
        }

        // List existing MCPs
        const existingMcps = Object.keys(existingConfig.mcpServers);
        if (existingMcps.length > 0) {
            console.log('');
            console.log('[Existing MCP List]');
            existingMcps.forEach(name => {
                console.log(`  - ${name}`);
            });
        }
    } catch (e) {
        console.error('[WARNING] Failed to parse existing config, creating new one.');
        existingConfig = { mcpServers: {} };
    }
} else {
    console.log('[INFO] No existing config file, creating new one.');
}

console.log('');

// New MCP settings
const newMcpServers = {
    make: {
        command: 'npx',
        args: ['-y', 'mcp-remote', MAKE_MCP_URL]
    },
    airtable: {
        command: 'npx',
        args: ['-y', 'airtable-mcp-server'],
        env: {
            AIRTABLE_API_KEY: AIRTABLE_API_KEY,
            AIRTABLE_BASE_ID: AIRTABLE_BASE_ID
        }
    }
};

// Add GitHub if token exists
if (GITHUB_TOKEN) {
    newMcpServers.github = {
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-github'],
        env: {
            GITHUB_TOKEN: GITHUB_TOKEN
        }
    };
}

// Merge (new settings override existing)
const addedMcps = [];
const updatedMcps = [];

Object.keys(newMcpServers).forEach(name => {
    if (existingConfig.mcpServers[name]) {
        updatedMcps.push(name);
    } else {
        addedMcps.push(name);
    }
    existingConfig.mcpServers[name] = newMcpServers[name];
});

// Save result
fs.writeFileSync(CONFIG_FILE, JSON.stringify(existingConfig, null, 2), 'utf8');

// Print result
console.log('[Added MCP]');
if (addedMcps.length > 0) {
    addedMcps.forEach(name => console.log(`  + ${name}`));
} else {
    console.log('  (none)');
}

console.log('');
console.log('[Updated MCP]');
if (updatedMcps.length > 0) {
    updatedMcps.forEach(name => console.log(`  ~ ${name}`));
} else {
    console.log('  (none)');
}

console.log('');
console.log('[Preserved MCP]');
const keptMcps = Object.keys(existingConfig.mcpServers).filter(
    name => !addedMcps.includes(name) && !updatedMcps.includes(name)
);
if (keptMcps.length > 0) {
    keptMcps.forEach(name => console.log(`  = ${name}`));
} else {
    console.log('  (none)');
}

console.log('');
console.log('========================================');
console.log('  Complete!');
console.log('========================================');
console.log('');
console.log(`Config file: ${CONFIG_FILE}`);
if (hasExistingConfig) {
    console.log(`Backup file: ${BACKUP_FILE}`);
}
console.log('');
console.log('All MCP list:');
Object.keys(existingConfig.mcpServers).forEach(name => {
    console.log(`  - ${name}`);
});
console.log('');
