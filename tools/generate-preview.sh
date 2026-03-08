#!/usr/bin/env bash
# Generate color preview images
# Usage: ./tools/generate-preview.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
PALETTE_FILE="$MONOREPO_ROOT/palette/colors.json"
OUTPUT_DIR="$MONOREPO_ROOT/assets"

mkdir -p "$OUTPUT_DIR"

echo "Generating color preview images..."

# Generate SVG color grid
cat > "$OUTPUT_DIR/color-grid.svg" << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="400" viewBox="0 0 800 400">
  <style>
    .bg { font-family: monospace; font-size: 12px; fill: #f0f0f5; }
    .label { font-family: monospace; font-size: 10px; fill: #414141; }
  </style>
SVGEOF

# Add backgrounds
x=10
y=10
for key in $(jq -r '.backgrounds | keys[]' "$PALETTE_FILE"); do
  hex=$(jq -r ".backgrounds.$key" "$PALETTE_FILE")
  cat >> "$OUTPUT_DIR/color-grid.svg" << SWATCH
  <rect x="$x" y="$y" width="80" height="40" fill="$hex" stroke="#191919"/>
  <text x="$((x+5))" y="$((y+25))" class="bg">$key</text>
SWATCH
  x=$((x+90))
  if [[ $x -gt 700 ]]; then
    x=10
    y=$((y+50))
  fi
done

cat >> "$OUTPUT_DIR/color-grid.svg" << 'SVGEOF'
</svg>
SVGEOF

echo "Generated: $OUTPUT_DIR/color-grid.svg"
echo "Note: For GitHub README, use singlecolorimage.com for color swatches"
