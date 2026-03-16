#!/usr/bin/env bash
# svg-palette-visualizer.sh - Generate SVG visualizations of the color palette
# Usage: ./tools/svg-palette-visualizer.sh [swatches|gradients|harmony|all]
#
# Generates SVG visualizations of the Violet Void color palette for documentation
# Output types:
#   - swatches: Individual color swatches in a grid layout
#   - gradients: Gradient strips showing color transitions
#   - harmony: Color harmony diagram (complementary, analogous, triadic)
#   - all: Generate all visualizations (default)
#
# Dependencies:
#   - jq (JSON parsing)
#   - tokens/colors.json in repository root
#
# Output: docs/assets/ directory with SVG files

set -euo pipefail

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BRIGHT_CYAN='\033[1;36m'
RESET='\033[0m'

# Repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PALETTE_FILE="$REPO_ROOT/tokens/colors.json"
OUTPUT_DIR="$REPO_ROOT/docs/assets"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Check dependencies
if ! command -v jq &>/dev/null; then
    echo -e "${RED}Error: jq is required but not installed${RESET}"
    echo "Install with: sudo pacman -S jq"
    exit 1
fi

if [[ ! -f "$PALETTE_FILE" ]]; then
    echo -e "${RED}Error: colors.json not found at $PALETTE_FILE${RESET}"
    exit 1
fi

# Generate color swatches SVG
generate_swatches() {
    echo -e "${CYAN}Generating color swatches SVG...${RESET}"
    
    local svg_file="$OUTPUT_DIR/palette-swatches.svg"
    local swatch_size=120
    local padding=20
    local cols=5
    
    # Count total colors (flatten accent structure for counting)
    local bg_count=$(jq '.color.background | length' "$PALETTE_FILE")
    local fg_count=$(jq '.color.foreground | length' "$PALETTE_FILE")
    # Count accent colors by flattening nested structure
    local accent_count=$(jq '[.color.accent | .[] | length] | add' "$PALETTE_FILE")
    local total=$(( bg_count + fg_count + accent_count ))
    local rows=$(( (total + cols - 1) / cols ))
    local width=$(( cols * (swatch_size + padding) + padding ))
    local height=$(( rows * (swatch_size + padding + 30) + padding + 50 ))
    
    # Start SVG
    cat > "$svg_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" 
     width="$width" 
     height="$height"
     viewBox="0 0 $width $height">
  <style>
    text { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 12px;
      fill: #c8c8c8;
    }
    .title {
      font-size: 16px;
      font-weight: bold;
      fill: #e0d4f0;
    }
  </style>
  
  <rect width="100%" height="100%" fill="#1a1a2e"/>
  
  <text x="$padding" y="30" class="title">Violet Void Color Palette</text>
  
EOF

    local row=0
    local col=0
    local y_offset=50
    
    # Process backgrounds (extract .value.value from nested structure)
    while IFS='|' read -r key hex; do
        local x=$(( padding + col * (swatch_size + padding) ))
        local y=$(( y_offset + row * (swatch_size + padding + 30) ))
        
        cat >> "$svg_file" <<EOF
  <rect x="$x" y="$y" width="$swatch_size" height="$swatch_size"
        fill="$hex" rx="8" ry="8"/>
  <text x="$x" y="$(( y + swatch_size + 20 ))"
        text-anchor="start" font-size="11">bg-$key</text>
  <text x="$x" y="$(( y + swatch_size + 32 ))"
        text-anchor="start" font-size="9" fill="#888">$hex</text>
EOF

        ((col++))
        if [[ $col -ge $cols ]]; then
            col=0
            ((row++))
        fi
    done < <(jq -r '.color.background | to_entries[] | "\(.key)|\(.value.value)"' "$PALETTE_FILE")

    # Process foregrounds (extract .value.value from nested structure)
    while IFS='|' read -r key hex; do
        local x=$(( padding + col * (swatch_size + padding) ))
        local y=$(( y_offset + row * (swatch_size + padding + 30) ))
        
        cat >> "$svg_file" <<EOF
  <rect x="$x" y="$y" width="$swatch_size" height="$swatch_size"
        fill="$hex" rx="8" ry="8"/>
  <text x="$x" y="$(( y + swatch_size + 20 ))"
        text-anchor="start" font-size="11">fg-$key</text>
  <text x="$x" y="$(( y + swatch_size + 32 ))"
        text-anchor="start" font-size="9" fill="#888">$hex</text>
EOF

        ((col++))
        if [[ $col -ge $cols ]]; then
            col=0
            ((row++))
        fi
    done < <(jq -r '.color.foreground | to_entries[] | "\(.key)|\(.value.value)"' "$PALETTE_FILE")

    # Process accents (flatten nested structure: red-base, red-bright, etc.)
    while IFS='|' read -r key hex; do
        local x=$(( padding + col * (swatch_size + padding) ))
        local y=$(( y_offset + row * (swatch_size + padding + 30) ))
        
        cat >> "$svg_file" <<EOF
  <rect x="$x" y="$y" width="$swatch_size" height="$swatch_size"
        fill="$hex" rx="8" ry="8"/>
  <text x="$x" y="$(( y + swatch_size + 20 ))"
        text-anchor="start" font-size="11">$key</text>
  <text x="$x" y="$(( y + swatch_size + 32 ))"
        text-anchor="start" font-size="9" fill="#888">$hex</text>
EOF

        ((col++))
        if [[ $col -ge $cols ]]; then
            col=0
            ((row++))
        fi
    done < <(jq -r '.color.accent | to_entries[] | .key as $color | .value | to_entries[] | "\($color)-\(.key)|\(.value.value)"' "$PALETTE_FILE")

    # Close SVG
    echo "</svg>" >> "$svg_file"
    
    echo -e "${GREEN}✓ Generated: $svg_file${RESET}"
}

# Generate gradient strips SVG
generate_gradients() {
    echo -e "${CYAN}Generating gradient strips SVG...${RESET}"
    
    local svg_file="$OUTPUT_DIR/palette-gradients.svg"
    local width=800
    local height=400
    local strip_height=60
    local padding=40
    
    # Start SVG
    cat > "$svg_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" 
     width="$width" 
     height="$height"
     viewBox="0 0 $width $height">
  <style>
    text { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 14px;
      fill: #c8c8c8;
    }
    .title {
      font-size: 18px;
      font-weight: bold;
      fill: #e0d4f0;
    }
  </style>
  
  <rect width="100%" height="100%" fill="#1a1a2e"/>
  
  <text x="$padding" y="30" class="title">Violet Void Color Gradients</text>
  
  <defs>
EOF

    # Get colors for gradients (extract .value from nested structure)
    local bg_dark=$(jq -r '.color.background.dark.value // "#000000"' "$PALETTE_FILE")
    local bg_base=$(jq -r '.color.background.base.value // "#1a1a2e"' "$PALETTE_FILE")
    local bg_highlight=$(jq -r '.color.background.highlight.value // "#2a2a3e"' "$PALETTE_FILE")
    local fg_base=$(jq -r '.color.foreground.base.value // "#e0d4f0"' "$PALETTE_FILE")
    local fg_muted=$(jq -r '.color.foreground.muted.value // "#c8c8c8"' "$PALETTE_FILE")
    local purple_base=$(jq -r '.color.accent.purple.base.value // "#7c60d1"' "$PALETTE_FILE")
    local cyan_base=$(jq -r '.color.accent.cyan.base.value // "#00a8a4"' "$PALETTE_FILE")
    local magenta_base=$(jq -r '.color.accent.magenta.base.value // "#fd007f"' "$PALETTE_FILE")
    
    # Background gradient
    cat >> "$svg_file" <<EOF
    <linearGradient id="bg-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="$bg_dark"/>
      <stop offset="50%" stop-color="$bg_base"/>
      <stop offset="100%" stop-color="$bg_highlight"/>
    </linearGradient>
EOF

    # Foreground gradient
    cat >> "$svg_file" <<EOF
    <linearGradient id="fg-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="$fg_base"/>
      <stop offset="50%" stop-color="$fg_muted"/>
      <stop offset="100%" stop-color="$fg_base"/>
    </linearGradient>
EOF

    # Accent gradient
    cat >> "$svg_file" <<EOF
    <linearGradient id="accent-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="$purple_base"/>
      <stop offset="50%" stop-color="$cyan_base"/>
      <stop offset="100%" stop-color="$magenta_base"/>
    </linearGradient>
EOF

    # Close defs and add gradient strips
    cat >> "$svg_file" <<EOF
  </defs>
  
  <rect x="$padding" y="70" width="$(( width - padding * 2 ))" height="$strip_height" 
        fill="url(#bg-gradient)" rx="8" ry="8"/>
  <text x="$padding" y="$(( 70 + strip_height + 20 ))">Backgrounds (dark → base → highlight)</text>
  
  <rect x="$padding" y="$(( 70 + strip_height + 40 ))" width="$(( width - padding * 2 ))" height="$strip_height" 
        fill="url(#fg-gradient)" rx="8" ry="8"/>
  <text x="$padding" y="$(( 70 + strip_height * 2 + 60 ))">Foregrounds (base → muted → base)</text>
  
  <rect x="$padding" y="$(( 70 + strip_height * 2 + 80 ))" width="$(( width - padding * 2 ))" height="$strip_height" 
        fill="url(#accent-gradient)" rx="8" ry="8"/>
  <text x="$padding" y="$(( 70 + strip_height * 3 + 100 ))">Accents (purple → cyan → magenta)</text>
EOF

    # Close SVG
    echo "</svg>" >> "$svg_file"
    
    echo -e "${GREEN}✓ Generated: $svg_file${RESET}"
}

# Generate color harmony diagram
generate_harmony() {
    echo -e "${CYAN}Generating color harmony diagram SVG...${RESET}"
    
    local svg_file="$OUTPUT_DIR/palette-harmony.svg"
    local width=600
    local height=400
    local padding=40
    local cx=$(( width / 2 ))
    local cy=$(( height / 2 ))
    local radius=120
    
    # Get primary accent color
    local primary=$(jq -r '.color.accent.purple.base.value // "#7c60d1"' "$PALETTE_FILE")
    
    # Start SVG
    cat > "$svg_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" 
     width="$width" 
     height="$height"
     viewBox="0 0 $width $height">
  <style>
    text { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 12px;
      fill: #c8c8c8;
    }
    .title {
      font-size: 16px;
      font-weight: bold;
      fill: #e0d4f0;
    }
  </style>
  
  <rect width="100%" height="100%" fill="#1a1a2e"/>
  
  <text x="$padding" y="30" class="title">Violet Void Color Harmony</text>
  
  <!-- Color wheel outline -->
  <circle cx="$cx" cy="$cy" r="$radius" fill="none" stroke="#444" stroke-width="2"/>
  
EOF

    # Get all accent base colors and plot them on the wheel
    local angle=0
    local colors=$(jq -r '.color.accent | to_entries[] | "\(.key)|\(.value.base.value // .value.value)"' "$PALETTE_FILE" 2>/dev/null || jq -r '.color.accent | to_entries[] | .key as $k | .value | to_entries[] | select(.key == "base") | "\($k)|\(.value.value)"' "$PALETTE_FILE")
    
    # Add primary color marker at top
    local marker_y=$(( cy - radius ))
    cat >> "$svg_file" <<EOF
  <!-- Primary accent (purple) -->
  <circle cx="$cx" cy="$marker_y" r="15" fill="$primary" stroke="#fff" stroke-width="2"/>
  <text x="$cx" y="$(( marker_y - 20 ))" text-anchor="middle">Purple (Primary)</text>
EOF

    # Add legend
    cat >> "$svg_file" <<EOF
  
  <!-- Legend -->
  <text x="$padding" y="$(( height - 60 ))" font-size="11">Primary: Purple (#7c60d1)</text>
  <text x="$padding" y="$(( height - 45 ))" font-size="11">Analogous: Magenta, Blue</text>
  <text x="$padding" y="$(( height - 30 ))" font-size="11">Complementary: Green, Yellow</text>
  <text x="$padding" y="$(( height - 15 ))" font-size="11">Triadic: Red, Cyan</text>
EOF

    # Close SVG
    echo "</svg>" >> "$svg_file"
    
    echo -e "${GREEN}✓ Generated: $svg_file${RESET}"
}

# Main function
main() {
    local mode="${1:-all}"
    
    echo -e "${BRIGHT_CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     SVG Palette Visualizer for Violet Void Theme         ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    case "$mode" in
        swatches)
            generate_swatches
            ;;
        gradients)
            generate_gradients
            ;;
        harmony)
            generate_harmony
            ;;
        all)
            generate_swatches
            generate_gradients
            generate_harmony
            ;;
        *)
            echo "Usage: $0 [swatches|gradients|harmony|all]"
            echo ""
            echo "Output types:"
            echo "  swatches  - Color swatches in grid layout"
            echo "  gradients - Gradient strips showing color transitions"
            echo "  harmony   - Color harmony diagram"
            echo "  all       - Generate all visualizations (default)"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✓ All visualizations generated in $OUTPUT_DIR/${RESET}"
}

# Run main function
main "$@"
