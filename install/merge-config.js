#!/usr/bin/env node
/**
 * Claude Desktop MCP 설정 병합 스크립트
 *
 * 기존 설정을 유지하면서 Make/Airtable MCP만 추가합니다.
 */

const fs = require('fs');
const path = require('path');

// 환경변수에서 값 읽기
const AIRTABLE_API_KEY = process.env.AIRTABLE_API_KEY;
const AIRTABLE_BASE_ID = process.env.AIRTABLE_BASE_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const MAKE_MCP_URL = process.env.MAKE_MCP_URL || 'https://eu2.make.com/mcp/u/24d0c939-f69a-4c68-8ea9-8314e72d4dd0/sse';

// Claude Desktop 설정 파일 경로
const CLAUDE_DIR = path.join(process.env.APPDATA || '', 'Claude');
const CONFIG_FILE = path.join(CLAUDE_DIR, 'claude_desktop_config.json');
const BACKUP_FILE = path.join(CLAUDE_DIR, 'claude_desktop_config.json.backup');

console.log('');
console.log('========================================');
console.log('  MCP 설정 병합 스크립트');
console.log('========================================');
console.log('');

// 필수 값 확인
if (!AIRTABLE_API_KEY || !AIRTABLE_BASE_ID) {
    console.error('[오류] 환경변수가 설정되지 않았습니다.');
    console.error('  - AIRTABLE_API_KEY');
    console.error('  - AIRTABLE_BASE_ID');
    process.exit(1);
}

// Claude 폴더 생성
if (!fs.existsSync(CLAUDE_DIR)) {
    fs.mkdirSync(CLAUDE_DIR, { recursive: true });
    console.log(`[생성됨] ${CLAUDE_DIR}`);
}

// 기존 설정 읽기
let existingConfig = { mcpServers: {} };
let hasExistingConfig = false;

if (fs.existsSync(CONFIG_FILE)) {
    hasExistingConfig = true;
    console.log('[발견됨] 기존 설정 파일');

    // 백업
    fs.copyFileSync(CONFIG_FILE, BACKUP_FILE);
    console.log(`[백업됨] ${BACKUP_FILE}`);

    try {
        const content = fs.readFileSync(CONFIG_FILE, 'utf8');
        existingConfig = JSON.parse(content);

        // mcpServers가 없으면 생성
        if (!existingConfig.mcpServers) {
            existingConfig.mcpServers = {};
        }

        // 기존 MCP 목록 출력
        const existingMcps = Object.keys(existingConfig.mcpServers);
        if (existingMcps.length > 0) {
            console.log('');
            console.log('[기존 MCP 목록]');
            existingMcps.forEach(name => {
                console.log(`  - ${name}`);
            });
        }
    } catch (e) {
        console.error('[경고] 기존 설정 파일 파싱 실패, 새로 생성합니다.');
        existingConfig = { mcpServers: {} };
    }
} else {
    console.log('[안내] 기존 설정 파일 없음, 새로 생성합니다.');
}

console.log('');

// 새 MCP 설정
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

// GitHub 토큰이 있으면 추가
if (GITHUB_TOKEN) {
    newMcpServers.github = {
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-github'],
        env: {
            GITHUB_TOKEN: GITHUB_TOKEN
        }
    };
}

// 병합 (새 설정이 기존 설정을 덮어씀)
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

// 결과 저장
fs.writeFileSync(CONFIG_FILE, JSON.stringify(existingConfig, null, 2), 'utf8');

// 결과 출력
console.log('[추가된 MCP]');
if (addedMcps.length > 0) {
    addedMcps.forEach(name => console.log(`  + ${name}`));
} else {
    console.log('  (없음)');
}

console.log('');
console.log('[업데이트된 MCP]');
if (updatedMcps.length > 0) {
    updatedMcps.forEach(name => console.log(`  ~ ${name}`));
} else {
    console.log('  (없음)');
}

console.log('');
console.log('[유지된 기존 MCP]');
const keptMcps = Object.keys(existingConfig.mcpServers).filter(
    name => !addedMcps.includes(name) && !updatedMcps.includes(name)
);
if (keptMcps.length > 0) {
    keptMcps.forEach(name => console.log(`  = ${name}`));
} else {
    console.log('  (없음)');
}

console.log('');
console.log('========================================');
console.log('  완료!');
console.log('========================================');
console.log('');
console.log(`설정 파일: ${CONFIG_FILE}`);
if (hasExistingConfig) {
    console.log(`백업 파일: ${BACKUP_FILE}`);
}
console.log('');
console.log('전체 MCP 목록:');
Object.keys(existingConfig.mcpServers).forEach(name => {
    console.log(`  - ${name}`);
});
console.log('');
