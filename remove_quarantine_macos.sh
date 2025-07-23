#!/bin/bash
# macOS Quarantine Removal Script for WFC GDExtension
# Run this script if macOS blocks the WFC libraries after download

set -e

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍎 WFC GDExtension - macOS Quarantine Removal${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}❌ This script is only for macOS${NC}"
    exit 1
fi

# Find the current directory or ask user for path
if [[ -f "wfc.gdextension" ]]; then
    # We're in the WFC extension directory
    WFC_PATH="$(pwd)"
    echo -e "${GREEN}✅ Found WFC extension in current directory${NC}"
elif [[ -d "addons/wfc" ]]; then
    # We're in a Godot project with WFC installed
    WFC_PATH="$(pwd)/addons/wfc"
    echo -e "${GREEN}✅ Found WFC extension in addons/wfc${NC}"
else
    # Ask user for path
    echo -e "${YELLOW}🔍 Please enter the path to your WFC extension folder:${NC}"
    echo -e "${YELLOW}   (e.g., /Users/username/MyProject/addons/wfc)${NC}"
    read -p "Path: " WFC_PATH
    
    if [[ ! -d "$WFC_PATH" ]]; then
        echo -e "${RED}❌ Directory not found: $WFC_PATH${NC}"
        exit 1
    fi
    
    if [[ ! -f "$WFC_PATH/wfc.gdextension" ]]; then
        echo -e "${RED}❌ wfc.gdextension not found in: $WFC_PATH${NC}"
        echo -e "${RED}   Make sure this is the correct WFC extension directory${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}📍 Working with WFC extension at: $WFC_PATH${NC}"

# Check for quarantined files
QUARANTINED_FILES=()
MACOS_BIN_DIR="$WFC_PATH/bin/macos"

if [[ -d "$MACOS_BIN_DIR" ]]; then
    echo -e "${BLUE}🔍 Checking for quarantined files...${NC}"
    
    while IFS= read -r -d '' file; do
        if xattr -l "$file" 2>/dev/null | grep -q "com.apple.quarantine"; then
            QUARANTINED_FILES+=("$file")
        fi
    done < <(find "$MACOS_BIN_DIR" -name "*.dylib" -print0 2>/dev/null || true)
    
    if [[ ${#QUARANTINED_FILES[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ No quarantined files found - libraries should work fine!${NC}"
        echo ""
        echo -e "${BLUE}🎮 Your WFC extension is ready to use in Godot${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}⚠️  Found ${#QUARANTINED_FILES[@]} quarantined file(s):${NC}"
    for file in "${QUARANTINED_FILES[@]}"; do
        echo -e "${YELLOW}   - $(basename "$file")${NC}"
    done
    echo ""
    
    # Ask for confirmation
    echo -e "${BLUE}🔧 Remove quarantine attributes from these files? [y/N]${NC}"
    read -p "Choice: " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔓 Removing quarantine attributes...${NC}"
        
        for file in "${QUARANTINED_FILES[@]}"; do
            echo -e "${BLUE}   Processing: $(basename "$file")${NC}"
            if xattr -d com.apple.quarantine "$file" 2>/dev/null; then
                echo -e "${GREEN}   ✅ Quarantine removed from $(basename "$file")${NC}"
            else
                echo -e "${RED}   ❌ Failed to remove quarantine from $(basename "$file")${NC}"
            fi
        done
        
        echo ""
        echo -e "${GREEN}🎉 Quarantine removal complete!${NC}"
        echo -e "${GREEN}🎮 Your WFC extension should now work in Godot${NC}"
    else
        echo -e "${YELLOW}⏸️  Quarantine removal cancelled${NC}"
        echo -e "${YELLOW}   Libraries may still be blocked by macOS${NC}"
        echo ""
        echo -e "${BLUE}💡 Manual removal command:${NC}"
        echo -e "${BLUE}   xattr -dr com.apple.quarantine \"$MACOS_BIN_DIR\"${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  macOS libraries directory not found: $MACOS_BIN_DIR${NC}"
    echo -e "${YELLOW}   This might be a different platform build or the extension needs to be built${NC}"
fi

echo ""
echo -e "${BLUE}📚 For more information about macOS quarantine:${NC}"
echo -e "${BLUE}   https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df${NC}"
