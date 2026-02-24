#!/bin/bash
# Install CLAUDE.md AI Templates for 4D Projects
# Usage: curl -fsSL https://raw.githubusercontent.com/KirkBrooks/AI_Project_Templates/main/install_claude_templates.sh | bash
#
# This script downloads all CLAUDE.md template files and places them
# in the correct folder structure relative to the current working directory.

set -e

REPO_BASE="https://raw.githubusercontent.com/KirkBrooks/AI_Project_Templates/main"

# Color output helpers
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing CLAUDE.md AI Templates for 4D Projects...${NC}"
echo ""

# Define the files to download and their target paths
declare -a FILES=(
    "CLAUDE.md"
    "Project/Sources/Classes/CLAUDE.md"
    "Project/Sources/DatabaseMethods/CLAUDE.md"
    "Project/Sources/Forms/CLAUDE.md"
    "Project/Sources/Methods/CLAUDE.md"
    "Project/Sources/TableForms/CLAUDE.md"
    "Project/Sources/Triggers/CLAUDE.md"
)

# Download each file
for file in "${FILES[@]}"; do
    # Create directory if needed
    dir=$(dirname "$file")
    if [ "$dir" != "." ]; then
        mkdir -p "$dir"
    fi
    
    echo -e "Downloading ${BLUE}$file${NC}..."
    
    # Download file using curl
    if curl -fsSL "${REPO_BASE}/${file}" -o "$file"; then
        echo -e "  ${GREEN}✓${NC} Installed $file"
    else
        echo "  ✗ Failed to download $file"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}✓ All CLAUDE.md templates installed successfully!${NC}"
echo ""
