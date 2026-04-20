#!/bin/bash
# Claude Code Skills - Uninstall Script (Linux/macOS)

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}==================================================${NC}"
echo -e "${CYAN}  Claude Code Skills - Uninstall${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""

CLAUDE_DIR="$HOME/.claude"

echo -e "${YELLOW}WARNING: This will remove all symlinks to skills, agents, rules, hooks, and commands.${NC}"
echo -e "${YELLOW}The original repository files will NOT be deleted.${NC}"
echo ""

read -rp "Continue? (y/n) " -n 1
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Uninstall cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}Removing symlinks...${NC}"

removed_count=0

# Remove symlinks using process substitution (avoids subshell variable loss)
for dir in skills agents rules hooks commands; do
    if [ -d "$CLAUDE_DIR/$dir" ]; then
        while IFS= read -r link; do
            rm -f "$link"
            echo -e "  ${GREEN}OK${NC} Removed $dir: $(basename "$link")"
            ((removed_count+=1))
        done < <(find "$CLAUDE_DIR/$dir" -type l 2>/dev/null)
    fi
done

echo ""
echo -e "${CYAN}==================================================${NC}"
echo -e "${GREEN}Uninstall Complete! Removed $removed_count symlinks.${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""
echo -e "${BLUE}To reinstall, run: ./setup.sh${NC}"
