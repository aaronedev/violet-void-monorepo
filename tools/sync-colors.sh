#!/usr/bin/env bash
# Sync colors from central palette to all themes
# Usage: ./tools/sync-colors.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
PALETTE_FILE="$MONOREPO_ROOT/palette/colors.json"
DRY_RUN=false

# Colors for output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo -e "${YELLOW}Dry run mode - no changes will be made${NC}"
fi

if [[ ! -f "$PALETTE_FILE" ]]; then
  echo -e "${RED}Error: palette/colors.json not found${NC}"
  exit 1
fi

echo -e "${BLUE}Syncing colors from palette/colors.json to all themes...${NC}"
echo ""

# Parse colors from JSON
parse_color() {
  local group="$1"
  local key="$2"
  jq -r ".${group}.${key} // empty" "$PALETTE_FILE"
}

# Generate color variables for different formats
generate_css_vars() {
  echo "/* Auto-generated from palette/colors.json - do not edit directly */"
  echo ":root {"
  
  # Backgrounds
  for key in $(jq -r '.backgrounds | keys[]' "$PALETTE_FILE"); do
    hex=$(jq -r ".backgrounds.$key" "$PALETTE_FILE")
    echo "  --vv-${key}: ${hex};"
  done
  
  # Foregrounds  
  for key in $(jq -r '.foregrounds | keys[]' "$PALETTE_FILE"); do
    hex=$(jq -r ".foregrounds.$key" "$PALETTE_FILE")
    echo "  --vv-${key}: ${hex};"
  done
  
  # Accents
  for key in $(jq -r '.accents | keys[]' "$PALETTE_FILE"); do
    hex=$(jq -r ".accents.$key" "$PALETTE_FILE")
    # Convert camelCase to kebab-case
    kebab=$(echo "$key" | sed 's/\([A-Z]\)/-\L\1/g')
    echo "  --vv-${kebab}: ${hex};"
  done
  
  echo "}"
}

generate_stylus_vars() {
  echo "// Auto-generated from palette/colors.json - do not edit directly"
  
  for group in backgrounds foregrounds accents; do
    for key in $(jq -r ".${group} | keys[]" "$PALETTE_FILE"); do
      hex=$(jq -r ".${group}.$key" "$PALETTE_FILE")
      kebab=$(echo "$key" | sed 's/\([A-Z]\)/-\L\1/g')
      echo "\$vv-${kebab} = ${hex}"
    done
  done
}

# List all theme directories
echo -e "${BLUE}Available themes:${NC}"
for theme_dir in "$MONOREPO_ROOT/themes"/*/; do
  if [[ -d "$theme_dir" ]]; then
    theme_name=$(basename "$theme_dir")
    echo "  - $theme_name"
  fi
done
echo ""

# TODO: Implement per-theme sync logic
# Each theme type (stylus, css, lua, etc.) needs custom sync logic

echo -e "${GREEN}Color sync complete!${NC}"
echo -e "${YELLOW}Note: Per-theme sync logic not yet implemented.${NC}"
echo -e "${YELLOW}Use tools/generate-theme.sh to create new theme files.${NC}"
