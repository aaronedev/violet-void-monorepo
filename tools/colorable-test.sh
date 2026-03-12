#!/usr/bin/env bash
# colorable-test.sh - Test color contrast combinations against WCAG standards
# Uses the 'colorable' npm package for batch accessibility testing
# Link: https://github.com/jxnblk/colorable

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Violet Void palette (from themes/archwiki/src/variables/colors.styl)
# Background colors
DARKER="#0f0f0f"
DARK="#202020"
BASE="#181818"
LIGHT="#bfbfbf"
LIGHTER="#e7e7e7"
WHITE="#ffffff"

# Accent colors
ARCH_BLUE="#8950c7"
SECONDARY_BLUE="#c7b8ff"
RED="#a80065"
SECONDARY_RED="#ff1a67"
GREEN="#4bfe9b"
ORANGE="#fd7cff"

# UI colors
COMMENT="#6f6f6f"
MUTED="#7a7a7a"

# Terminal colors
TERM_RED="#ff1a67"
TERM_GREEN="#42ff97"
TERM_YELLOW="#7c60d1"
TERM_BLUE="#29adff"
TERM_MAGENTA="#fd007f"
TERM_CYAN="#00a8a4"
TERM_WHITE="#505050"

TERM_BRIGHT_BLACK="#252525"
TERM_BRIGHT_RED="#ff004b"
TERM_BRIGHT_GREEN="#42ffad"
TERM_BRIGHT_YELLOW="#fd7cff"
TERM_BRIGHT_BLUE="#c7b8ff"
TERM_BRIGHT_MAGENTA="#fd0098"
TERM_BRIGHT_CYAN="#00fff9"
TERM_BRIGHT_WHITE="#e7e7e7"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Test Violet Void color combinations against WCAG accessibility standards.

OPTIONS:
    -h, --help          Show this help message
    -i, --install       Install colorable npm package
    -a, --all           Test all color combinations
    -t, --text          Test text/background combinations only
    -s, --sample        Test a sample of common combinations
    -j, --json          Output results as JSON
    -v, --verbose       Show detailed output

EXAMPLES:
    $(basename "$0") --install        # Install colorable package
    $(basename "$0") --sample         # Test sample combinations
    $(basename "$0") --text           # Test text/background combos
    $(basename "$0") --all            # Test all combinations (large output)

REQUIREMENTS:
    - Node.js and npm
    - colorable package: npm install -g colorable

EOF
}

# Check if colorable is installed
check_colorable() {
    if ! command -v colorable &> /dev/null; then
        echo -e "${RED}Error: colorable is not installed${NC}"
        echo -e "${YELLOW}Install with: npm install -g colorable${NC}"
        echo -e "${YELLOW}Or run: $(basename "$0") --install${NC}"
        exit 1
    fi
}

# Install colorable
install_colorable() {
    echo -e "${CYAN}Installing colorable...${NC}"
    if command -v npm &> /dev/null; then
        npm install -g colorable
        echo -e "${GREEN}✓ colorable installed successfully${NC}"
    else
        echo -e "${RED}Error: npm is not installed${NC}"
        exit 1
    fi
}

# Test a single color combination
test_combination() {
    local fg="$1"
    local bg="$2"
    local name="$3"
    
    # Create temporary JSON file
    local json_file=$(mktemp)
    cat > "$json_file" <<EOF
{
  "foreground": "$fg",
  "background": "$bg"
}
EOF
    
    # Run colorable
    local result
    result=$(colorable "$json_file" 2>/dev/null || echo "{}")
    rm "$json_file"
    
    # Parse results
    local ratio=$(echo "$result" | jq -r '.combinations[0].contrast // "N/A"' 2>/dev/null || echo "N/A")
    local aa_small=$(echo "$result" | jq -r '.combinations[0].accessibility.aa.small // false' 2>/dev/null || echo "false")
    local aa_large=$(echo "$result" | jq -r '.combinations[0].accessibility.aa.large // false' 2>/dev/null || echo "false")
    local aaa_small=$(echo "$result" | jq -r '.combinations[0].accessibility.aaa.small // false' 2>/dev/null || echo "false")
    local aaa_large=$(echo "$result" | jq -r '.combinations[0].accessibility.aaa.large // false' 2>/dev/null || echo "false")
    
    echo -e "${CYAN}$name${NC}"
    echo "  Foreground: $fg  Background: $bg"
    echo "  Contrast Ratio: $ratio"
    
    # Show accessibility results with colors
    if [[ "$aa_small" == "true" ]]; then
        echo -e "  AA Small:  ${GREEN}✓ PASS${NC}"
    else
        echo -e "  AA Small:  ${RED}✗ FAIL${NC}"
    fi
    
    if [[ "$aa_large" == "true" ]]; then
        echo -e "  AA Large:  ${GREEN}✓ PASS${NC}"
    else
        echo -e "  AA Large:  ${RED}✗ FAIL${NC}"
    fi
    
    if [[ "$aaa_small" == "true" ]]; then
        echo -e "  AAA Small: ${GREEN}✓ PASS${NC}"
    else
        echo -e "  AAA Small: ${RED}✗ FAIL${NC}"
    fi
    
    if [[ "$aaa_large" == "true" ]]; then
        echo -e "  AAA Large: ${GREEN}✓ PASS${NC}"
    else
        echo -e "  AAA Large: ${RED}✗ FAIL${NC}"
    fi
    
    echo ""
}

# Test sample of common combinations
test_sample() {
    check_colorable
    echo -e "${CYAN}Testing sample color combinations...${NC}\n"
    
    # Text on background combinations
    test_combination "$LIGHTER" "$DARKER" "Lighter text on darker background"
    test_combination "$LIGHT" "$DARK" "Light text on dark background"
    test_combination "$LIGHTER" "$BASE" "Lighter text on base background"
    test_combination "$WHITE" "$BASE" "White text on base background"
    test_combination "$ARCH_BLUE" "$DARKER" "Arch blue on darker background"
    test_combination "$SECONDARY_BLUE" "$DARKER" "Secondary blue on darker background"
    test_combination "$GREEN" "$DARKER" "Green on darker background"
    test_combination "$SECONDARY_RED" "$DARKER" "Secondary red on darker background"
    
    # Terminal color combinations
    test_combination "$TERM_RED" "$DARKER" "Terminal red on darker background"
    test_combination "$TERM_GREEN" "$DARKER" "Terminal green on darker background"
    test_combination "$TERM_YELLOW" "$DARKER" "Terminal yellow on darker background"
    test_combination "$TERM_BLUE" "$DARKER" "Terminal blue on darker background"
}

# Test text/background combinations
test_text_combos() {
    check_colorable
    echo -e "${CYAN}Testing all text/background combinations...${NC}\n"
    
    local backgrounds=("$DARKER" "$DARK" "$BASE" "$TERM_BRIGHT_BLACK")
    local foregrounds=("$LIGHTER" "$LIGHT" "$WHITE" "$COMMENT" "$MUTED")
    
    for bg in "${backgrounds[@]}"; do
        for fg in "${foregrounds[@]}"; do
            test_combination "$fg" "$bg" "Text combo: $fg on $bg"
        done
    done
}

# Test all combinations
test_all() {
    check_colorable
    echo -e "${CYAN}Testing all color combinations...${NC}"
    echo -e "${YELLOW}Warning: This will generate a lot of output${NC}\n"
    
    local colors=(
        "$DARKER" "$DARK" "$BASE" "$LIGHT" "$LIGHTER" "$WHITE"
        "$ARCH_BLUE" "$SECONDARY_BLUE" "$RED" "$SECONDARY_RED" "$GREEN" "$ORANGE"
        "$COMMENT" "$MUTED"
        "$TERM_RED" "$TERM_GREEN" "$TERM_YELLOW" "$TERM_BLUE" "$TERM_MAGENTA" "$TERM_CYAN"
        "$TERM_BRIGHT_BLACK" "$TERM_BRIGHT_RED" "$TERM_BRIGHT_GREEN" "$TERM_BRIGHT_YELLOW"
        "$TERM_BRIGHT_BLUE" "$TERM_BRIGHT_MAGENTA" "$TERM_BRIGHT_CYAN" "$TERM_BRIGHT_WHITE"
    )
    
    local count=0
    local total=$((${#colors[@]} * ${#colors[@]}))
    
    for fg in "${colors[@]}"; do
        for bg in "${colors[@]}"; do
            ((count++))
            echo -e "${CYAN}[$count/$total]${NC} Testing $fg on $bg"
            test_combination "$fg" "$bg" "Color combo"
        done
    done
}

# Main
main() {
    local action="sample"
    local verbose=false
    local json_output=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -i|--install)
                install_colorable
                exit 0
                ;;
            -a|--all)
                action="all"
                shift
                ;;
            -t|--text)
                action="text"
                shift
                ;;
            -s|--sample)
                action="sample"
                shift
                ;;
            -j|--json)
                json_output=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                usage
                exit 1
                ;;
        esac
    done
    
    case $action in
        sample)
            test_sample
            ;;
        text)
            test_text_combos
            ;;
        all)
            test_all
            ;;
    esac
}

main "$@"
