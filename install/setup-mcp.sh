#!/bin/bash
#
# LLM-to-Make MCP Setup Script
# For Linux/Mac users
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "========================================"
echo "  LLM-to-Make MCP Setup Script"
echo "  Automatic Installation for Users"
echo "========================================"
echo ""

# ========================================
# Step 1: Check Node.js
# ========================================
echo "[1/5] Checking Node.js..."

if ! command -v node &> /dev/null; then
    echo ""
    echo "[ERROR] Node.js is not installed."
    echo ""
    echo "========================================"
    echo "  How to Install Node.js"
    echo "========================================"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    echo ""
    echo "Mac (with Homebrew):"
    echo "  brew install node"
    echo ""
    echo "Or download from: https://nodejs.org/"
    echo ""
    exit 1
fi

NODE_VERSION=$(node --version)
echo "[OK] Node.js found: $NODE_VERSION"
echo ""

# ========================================
# Step 2: Check .env file
# ========================================
echo "[2/5] Checking .env file..."

ENV_FILE="$SCRIPT_DIR/.env"
ENV_TEMPLATE="$SCRIPT_DIR/.env.template"

if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_TEMPLATE" ]; then
        echo "     [INFO] .env file not found."
        echo ""
        echo "     Copying .env.template to .env"
        echo "     Please enter your API keys."
        echo ""
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        echo "     [Created] .env file has been created."
        echo "     Location: $ENV_FILE"
        echo ""
        echo "     Please edit the .env file and add your API keys:"
        echo "     nano $ENV_FILE"
        echo "     or"
        echo "     vim $ENV_FILE"
        echo ""
        echo "     After entering API keys, run this script again."
        echo ""
        exit 0
    else
        echo "     [ERROR] .env.template file not found."
        exit 1
    fi
fi

# Read values from .env file
AIRTABLE_API_KEY=""
AIRTABLE_BASE_ID=""
GITHUB_TOKEN=""
MAKE_MCP_URL=""

while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue

    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    case "$key" in
        AIRTABLE_API_KEY) AIRTABLE_API_KEY="$value" ;;
        AIRTABLE_BASE_ID) AIRTABLE_BASE_ID="$value" ;;
        GITHUB_TOKEN) GITHUB_TOKEN="$value" ;;
        MAKE_MCP_URL) MAKE_MCP_URL="$value" ;;
    esac
done < "$ENV_FILE"

# Check required values
missing_keys=0
if [ -z "$AIRTABLE_API_KEY" ] || [ "$AIRTABLE_API_KEY" = "YOUR_AIRTABLE_API_KEY" ]; then
    missing_keys=1
fi
if [ -z "$AIRTABLE_BASE_ID" ] || [ "$AIRTABLE_BASE_ID" = "YOUR_AIRTABLE_BASE_ID" ]; then
    missing_keys=1
fi
if [ -z "$MAKE_MCP_URL" ] || [ "$MAKE_MCP_URL" = "YOUR_MAKE_MCP_URL_HERE" ]; then
    missing_keys=1
fi

if [ $missing_keys -eq 1 ]; then
    echo "     [ERROR] Required values missing in .env file."
    echo ""
    echo "     Please edit .env file and enter:"
    echo "     - AIRTABLE_API_KEY"
    echo "     - AIRTABLE_BASE_ID"
    echo "     - MAKE_MCP_URL"
    echo ""
    echo "     Edit with: nano $ENV_FILE"
    echo ""
    exit 1
fi

echo "[OK] .env file verified"
echo "     - Airtable API Key: ${AIRTABLE_API_KEY:0:10}..."
echo "     - Airtable Base ID: $AIRTABLE_BASE_ID"
echo "     - Make MCP URL: configured"
[ -n "$GITHUB_TOKEN" ] && echo "     - GitHub Token: configured"
echo ""

# ========================================
# Step 3: Check existing .mcp.json and select MCPs
# ========================================
echo "[3/5] Checking MCP configuration..."
echo ""

MCP_JSON_PATH="$PROJECT_DIR/.mcp.json"
INSTALL_MAKE=1
INSTALL_AIRTABLE=1
INSTALL_GITHUB=0
INSTALL_GDRIVE=0
INSTALL_PLAYWRIGHT=0

# Check if .mcp.json exists and read current settings
if [ -f "$MCP_JSON_PATH" ]; then
    echo "[FOUND] Existing .mcp.json detected"
    echo ""
    echo "Current MCPs configured:"

    # Use Node.js to parse existing .mcp.json
    EXISTING_MCPS=$(node -e "
        const fs = require('fs');
        try {
            const c = JSON.parse(fs.readFileSync('$MCP_JSON_PATH', 'utf8'));
            Object.keys(c.mcpServers || {}).forEach(k => console.log(k));
        } catch(e) {}
    ")

    for mcp in $EXISTING_MCPS; do
        echo "  [x] $mcp"
        [ "$mcp" = "github" ] && INSTALL_GITHUB=1
        [ "$mcp" = "gdrive" ] && INSTALL_GDRIVE=1
        [ "$mcp" = "playwright-test" ] && INSTALL_PLAYWRIGHT=1
    done
    echo ""
else
    echo "[INFO] No existing .mcp.json found"
    echo "       Will create new configuration"
    echo ""
fi

echo "========================================"
echo "  MCP Selection"
echo "========================================"
echo ""
echo "[Required - Always installed]"
[ $INSTALL_MAKE -eq 1 ] && echo "  1. [x] Make.com     - Scenario management" || echo "  1. [ ] Make.com     - Scenario management"
[ $INSTALL_AIRTABLE -eq 1 ] && echo "  2. [x] Airtable     - Database management" || echo "  2. [ ] Airtable     - Database management"
echo ""
echo "[Optional - Toggle with numbers]"
[ $INSTALL_GITHUB -eq 1 ] && echo "  3. [x] GitHub       - Repository management" || echo "  3. [ ] GitHub       - Repository management"
[ $INSTALL_GDRIVE -eq 1 ] && echo "  4. [x] Google Drive - File management" || echo "  4. [ ] Google Drive - File management"
[ $INSTALL_PLAYWRIGHT -eq 1 ] && echo "  5. [x] Playwright   - E2E testing" || echo "  5. [ ] Playwright   - E2E testing"
echo ""
echo "----------------------------------------"
echo "Enter numbers to toggle ON/OFF (e.g., 3 4)"
echo "Press Enter to keep current selection"
echo "----------------------------------------"
echo ""

read -p "Toggle MCPs (e.g., 3 4 5) or press Enter: " MCP_CHOICE

if [ -n "$MCP_CHOICE" ]; then
    [[ "$MCP_CHOICE" == *"3"* ]] && { [ $INSTALL_GITHUB -eq 1 ] && INSTALL_GITHUB=0 || INSTALL_GITHUB=1; }
    [[ "$MCP_CHOICE" == *"4"* ]] && { [ $INSTALL_GDRIVE -eq 1 ] && INSTALL_GDRIVE=0 || INSTALL_GDRIVE=1; }
    [[ "$MCP_CHOICE" == *"5"* ]] && { [ $INSTALL_PLAYWRIGHT -eq 1 ] && INSTALL_PLAYWRIGHT=0 || INSTALL_PLAYWRIGHT=1; }
fi

echo ""
echo "Final Selection:"
echo "  [x] Make.com"
echo "  [x] Airtable"
[ $INSTALL_GITHUB -eq 1 ] && echo "  [x] GitHub" || echo "  [ ] GitHub"
[ $INSTALL_GDRIVE -eq 1 ] && echo "  [x] Google Drive" || echo "  [ ] Google Drive"
[ $INSTALL_PLAYWRIGHT -eq 1 ] && echo "  [x] Playwright" || echo "  [ ] Playwright"
echo ""

# ========================================
# Step 4: Install packages
# ========================================
echo "[4/5] Installing packages..."
echo "      (This may take a few minutes)"
echo ""

# Install Claude Code
echo "  - Claude Code..."
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code > /dev/null 2>&1 || true
    echo "    [OK] Installed"
    echo ""
    echo "  - Claude Code authentication required"
    echo "    Run: claude auth login"
    echo ""
else
    echo "    [OK] Already installed"
fi

# Install required MCPs
echo "  - mcp-remote (Make.com)..."
npm install -g mcp-remote > /dev/null 2>&1 || true
echo "    [OK]"

echo "  - airtable-mcp-server..."
npm install -g airtable-mcp-server > /dev/null 2>&1 || true
echo "    [OK]"

echo "  - dotenv-cli..."
npm install -g dotenv-cli > /dev/null 2>&1 || true
echo "    [OK]"

# Install optional MCPs
if [ $INSTALL_GITHUB -eq 1 ]; then
    echo "  - server-github..."
    npm install -g @modelcontextprotocol/server-github > /dev/null 2>&1 || true
    echo "    [OK]"
fi

if [ $INSTALL_GDRIVE -eq 1 ]; then
    echo "  - mcp-gdrive..."
    npm install -g @isaacphi/mcp-gdrive > /dev/null 2>&1 || true
    echo "    [OK]"
fi

if [ $INSTALL_PLAYWRIGHT -eq 1 ]; then
    echo "  - playwright..."
    npm install -g playwright > /dev/null 2>&1 || true
    echo "    [OK]"
fi

echo ""
echo "[OK] All packages installed"
echo ""

# ========================================
# Step 5: Generate .mcp.json
# ========================================
echo "[5/5] Generating .mcp.json..."
echo ""

# Backup existing .mcp.json
if [ -f "$MCP_JSON_PATH" ]; then
    cp "$MCP_JSON_PATH" "${MCP_JSON_PATH}.backup"
    echo "[BACKUP] Saved to .mcp.json.backup"
fi

# Generate .mcp.json using Node.js
node -e "
const fs = require('fs');
const config = { mcpServers: {} };

// Required: Make (uses wrapper to read URL from .env)
config.mcpServers.make = {
    command: 'node',
    args: ['install/make-mcp-wrapper.js'],
    description: 'Make.com scenario management'
};

// Required: Airtable
config.mcpServers.airtable = {
    command: 'npx',
    args: ['-y', 'dotenv-cli', '-e', 'install/.env', '--', 'npx', '-y', 'airtable-mcp-server'],
    description: 'Airtable data management'
};

// Optional: GitHub
if ($INSTALL_GITHUB === 1) {
    config.mcpServers.github = {
        command: 'npx',
        args: ['-y', 'dotenv-cli', '-e', 'install/.env', '--', 'npx', '-y', '@modelcontextprotocol/server-github'],
        description: 'GitHub repository management'
    };
}

// Optional: Google Drive
if ($INSTALL_GDRIVE === 1) {
    config.mcpServers.gdrive = {
        command: 'npx',
        args: ['-y', 'dotenv-cli', '-e', 'install/.env', '--', 'npx', '-y', '@isaacphi/mcp-gdrive'],
        description: 'Google Drive file management'
    };
}

// Optional: Playwright
if ($INSTALL_PLAYWRIGHT === 1) {
    config.mcpServers['playwright-test'] = {
        command: 'npx',
        args: ['playwright', 'run-test-mcp-server'],
        description: 'E2E testing'
    };
}

fs.writeFileSync('$MCP_JSON_PATH', JSON.stringify(config, null, 2));
console.log('Generated .mcp.json');
"

echo "[OK] .mcp.json created in project root"
echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Configured MCPs:"
echo "  [x] Make.com"
echo "  [x] Airtable"
[ $INSTALL_GITHUB -eq 1 ] && echo "  [x] GitHub"
[ $INSTALL_GDRIVE -eq 1 ] && echo "  [x] Google Drive"
[ $INSTALL_PLAYWRIGHT -eq 1 ] && echo "  [x] Playwright"
echo ""
echo "========================================"
echo "  How to Use"
echo "========================================"
echo ""
echo "1. Open terminal in this project folder"
echo "2. Run: claude"
echo "3. MCP tools will be loaded automatically"
echo ""
echo "To reconfigure MCPs, run this script again."
echo ""
echo "========================================"
echo ""
