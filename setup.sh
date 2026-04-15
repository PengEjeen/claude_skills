#!/bin/bash
# Claude Code Skills - Automated Setup Script (Linux/macOS)
# This script creates symbolic links for skills, agents, and rules

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}  Claude Code Skills - Automated Setup${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_DIR="$HOME/.claude"

echo -e "${GREEN}Repository: $SCRIPT_DIR${NC}"
echo -e "${GREEN}Claude Code: $CLAUDE_DIR${NC}"
echo ""

# Create Claude directories if not exist
for dir in skills agents rules hooks; do
    if [ ! -d "$CLAUDE_DIR/$dir" ]; then
        echo -e "${YELLOW}Creating directory: $CLAUDE_DIR/$dir${NC}"
        mkdir -p "$CLAUDE_DIR/$dir"
    fi
done

# Function to create symbolic link
create_symlink() {
    local target=$1
    local link=$2
    local name=$(basename "$link")
    
    # Remove existing symlink; warn if real file/directory
    if [ -L "$link" ]; then
        rm -f "$link"
    elif [ -e "$link" ]; then
        echo -e "  ${YELLOW}!${NC} $name - 기존 파일/디렉토리 존재 (심볼릭 링크 아님). 백업 후 진행하세요."
        return 1
    fi
    
    if ln -sf "$target" "$link" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name - Failed to create symlink"
        return 1
    fi
}

# Install skills
echo -e "${CYAN}Installing Skills...${NC}"
success_count=0
fail_count=0

for skill_dir in "$SCRIPT_DIR/skills"/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        if create_symlink "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    fi
done

echo ""

# Install agents
echo -e "${CYAN}Installing Agents...${NC}"

for agent_file in "$SCRIPT_DIR/agents"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file")
        if create_symlink "$agent_file" "$CLAUDE_DIR/agents/$agent_name"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    fi
done

echo ""

# Install rules
echo -e "${CYAN}Installing Rules...${NC}"

for rule_file in "$SCRIPT_DIR/rules"/*.md; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file")
        if create_symlink "$rule_file" "$CLAUDE_DIR/rules/$rule_name"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    fi
done

echo ""

# Install hooks
echo -e "${CYAN}Installing Hooks...${NC}"

for hook_file in "$SCRIPT_DIR/hooks"/*.sh; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        if create_symlink "$hook_file" "$CLAUDE_DIR/hooks/$hook_name"; then
            chmod +x "$CLAUDE_DIR/hooks/$hook_name" 2>/dev/null
            ((success_count++))
        else
            ((fail_count++))
        fi
    fi
done

echo ""
echo -e "${CYAN}==================================================${NC}"
if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}Installation Complete!${NC}"
else
    echo -e "${YELLOW}Installation Complete with warnings${NC}"
fi
echo -e "Success: $success_count | Failed: $fail_count"
echo -e "${CYAN}==================================================${NC}"
echo ""

# Install MCP Research Server dependencies
echo -e "${CYAN}Installing MCP Research Server...${NC}"
MCP_REQ="$SCRIPT_DIR/requirements-mcp.txt"
if [ -f "$MCP_REQ" ]; then
    if command -v pip3 &> /dev/null; then
        pip3 install -q -r "$MCP_REQ" 2>/dev/null && \
            echo -e "  ${GREEN}✓${NC} MCP dependencies installed" || \
            echo -e "  ${YELLOW}!${NC} pip install failed — run manually: pip install -r requirements-mcp.txt"
    elif command -v pip &> /dev/null; then
        pip install -q -r "$MCP_REQ" 2>/dev/null && \
            echo -e "  ${GREEN}✓${NC} MCP dependencies installed" || \
            echo -e "  ${YELLOW}!${NC} pip install failed — run manually: pip install -r requirements-mcp.txt"
    else
        echo -e "  ${YELLOW}!${NC} pip not found — install manually: pip install -r requirements-mcp.txt"
    fi
else
    echo -e "  ${YELLOW}!${NC} requirements-mcp.txt not found"
fi

# Copy .mcp.json to project if not present
if [ -f "$SCRIPT_DIR/.mcp.json" ]; then
    echo -e "  ${GREEN}✓${NC} .mcp.json ready (MCP server config)"
fi

echo ""

# Check Python dependencies for skills
if command -v python3 &> /dev/null || command -v python &> /dev/null; then
    echo -e "${CYAN}Checking skill Python dependencies...${NC}"

    for skill in product-planner llm-app-planner; do
        req_file="$SCRIPT_DIR/skills/$skill/requirements.txt"
        if [ -f "$req_file" ]; then
            echo -e "  ${YELLOW}- $skill: Found requirements.txt${NC}"
        fi
    done
    echo ""
else
    echo -e "${YELLOW}Python not found. Skipping dependency check.${NC}"
    echo ""
fi

# Verify installation
echo -e "${CYAN}Verifying installation...${NC}"
skill_count=$(ls -1 "$CLAUDE_DIR/skills" 2>/dev/null | wc -l)
agent_count=$(ls -1 "$CLAUDE_DIR/agents" 2>/dev/null | wc -l)
rule_count=$(ls -1 "$CLAUDE_DIR/rules" 2>/dev/null | wc -l)

echo -e "  ${GREEN}✓${NC} $skill_count skills installed"
echo -e "  ${GREEN}✓${NC} $agent_count agents installed"
echo -e "  ${GREEN}✓${NC} $rule_count rules installed"
hook_count=$(ls -1 "$CLAUDE_DIR/hooks" 2>/dev/null | wc -l)
echo -e "  ${GREEN}✓${NC} $hook_count hooks installed"

echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo -e "${NC}1. Restart Claude Code CLI${NC}"
echo -e "${NC}2. Test a skill: /product-planner \"AI education platform\"${NC}"
echo -e "${NC}3. See all skills: ls ~/.claude/skills${NC}"
echo ""
echo -e "${BLUE}Documentation: https://github.com/hyunseung1119/My_ClaudeCode_Skill${NC}"
echo ""
