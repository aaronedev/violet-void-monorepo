#!/usr/bin/env bash
# WCAG Contrast Matrix Generator for Violet Void Theme
# Generates visual matrix/grid of all contrast ratios between palette colors
# Usage: ./tools/wcag-contrast-matrix.sh [svg|html|md|terminal|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
PALETTE_FILE="$MONOREPO_ROOT/palette/colors.json"
OUTPUT_DIR="$MONOREPO_ROOT/docs/accessibility"
ASSETS_DIR="$MONOREPO_ROOT/assets"

# Default output format
FORMAT="${1:-md}"

# Colors for terminal output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
BOLD='\033[1m'
NC='\033[0m'

# Help message
show_help() {
  echo "WCAG Contrast Matrix Generator for Violet Void Theme"
  echo ""
  echo "Usage: $0 [format]"
  echo ""
  echo "Formats:"
  echo "  svg      Generate SVG grid visualization"
  echo "  html     Generate HTML table with styling"
  echo "  md       Generate Markdown table (default)"
  echo "  terminal Display matrix in terminal"
  echo "  all      Generate all formats"
  echo ""
  echo "Output:"
  echo "  SVG:     $OUTPUT_DIR/contrast-matrix.svg"
  echo "  HTML:    $OUTPUT_DIR/contrast-matrix.html"
  echo "  MD:      $OUTPUT_DIR/contrast-matrix.md"
  echo ""
  echo "WCAG 2.0 Levels:"
  echo "  AAA       Ratio >= 7:1 (green)   - Enhanced contrast"
  echo "  AA        Ratio >= 4.5:1 (blue)  - Minimum contrast"
  echo "  AA-Large  Ratio >= 3:1 (yellow)  - Large text only"
  echo "  FAIL      Ratio < 3:1 (red)      - Insufficient contrast"
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
  exit 0
fi

if [[ ! -f "$PALETTE_FILE" ]]; then
  echo -e "${RED}Error: palette/colors.json not found${NC}" >&2
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
mkdir -p "$ASSETS_DIR"

# Generate contrast data using Node.js
generate_matrix_data() {
  export PALETTE_FILE
  node << 'NODESCRIPT'
const fs = require("fs");

const palette = JSON.parse(fs.readFileSync(process.env.PALETTE_FILE, "utf8"));

// Convert hex to RGB
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

// Convert 8-bit color to sRGB (0-1)
function toSrgb(c) {
  const val = c / 255;
  return val <= 0.03928 ? val / 12.92 : Math.pow((val + 0.055) / 1.055, 2.4);
}

// Calculate relative luminance
function getLuminance(hex) {
  const { r, g, b } = hexToRgb(hex);
  return 0.2126 * toSrgb(r) + 0.7152 * toSrgb(g) + 0.0722 * toSrgb(b);
}

// Calculate contrast ratio
function getContrastRatio(hex1, hex2) {
  let l1 = getLuminance(hex1);
  let l2 = getLuminance(hex2);
  if (l2 > l1) [l1, l2] = [l2, l1];
  return (l1 + 0.05) / (l2 + 0.05);
}

// Get WCAG level
function getWcagLevel(ratio) {
  if (ratio >= 7) return "AAA";
  if (ratio >= 4.5) return "AA";
  if (ratio >= 3) return "AA-Large";
  return "FAIL";
}

// Get level color
function getLevelColor(level) {
  switch (level) {
    case "AAA": return "#4ade80"; // green
    case "AA": return "#60a5fa"; // blue
    case "AA-Large": return "#fbbf24"; // yellow
    default: return "#f87171"; // red
  }
}

// Collect all colors
const backgrounds = Object.entries(palette.backgrounds);
const foregrounds = [...Object.entries(palette.foregrounds), ...Object.entries(palette.accents)];

// Generate matrix data
const matrix = [];
for (const [bgKey, bgHex] of backgrounds) {
  const row = { bgKey, bgHex, cells: [] };
  for (const [fgKey, fgHex] of foregrounds) {
    const ratio = getContrastRatio(bgHex, fgHex);
    const level = getWcagLevel(ratio);
    row.cells.push({ fgKey, fgHex, ratio: Math.round(ratio * 100) / 100, level, color: getLevelColor(level) });
  }
  matrix.push(row);
}

// Summary stats
let passedAAA = 0, passedAA = 0, failed = 0;
for (const row of matrix) {
  for (const cell of row.cells) {
    if (cell.level === "AAA") passedAAA++;
    else if (cell.level === "AA" || cell.level === "AA-Large") passedAA++;
    else failed++;
  }
}

console.log(JSON.stringify({
  backgrounds: backgrounds.map(([k, v]) => ({ key: k, hex: v })),
  foregrounds: foregrounds.map(([k, v]) => ({ key: k, hex: v })),
  matrix,
  summary: { total: matrix.reduce((sum, row) => sum + row.cells.length, 0), passedAAA, passedAA, failed }
}, null, 2));
NODESCRIPT
}

# Generate SVG matrix
generate_svg() {
  echo -e "${CYAN}Generating SVG contrast matrix...${NC}"

  local data
  data=$(generate_matrix_data)

  # Extract dimensions
  local bg_count fg_count
  bg_count=$(echo "$data" | jq '.backgrounds | length')
  fg_count=$(echo "$data" | jq '.foregrounds | length')

  local cell_size=60
  local header_height=120
  local row_label_width=100
  local width=$((row_label_width + fg_count * cell_size + 40))
  local height=$((header_height + bg_count * cell_size + 80))

  local svg_file="$OUTPUT_DIR/contrast-matrix.svg"

  # Start SVG
  cat > "$svg_file" << SVGHEADER
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $width $height" width="$width" height="$height">
  <style>
    .title { font: bold 16px system-ui, sans-serif; fill: #c4b5fd; }
    .bg-label { font: 11px system-ui, sans-serif; fill: #a78bfa; }
    .fg-label { font: 9px system-ui, sans-serif; fill: #a78bfa; writing-mode: vertical-rl; text-orientation: mixed; }
    .ratio { font: 9px system-ui, sans-serif; fill: #1a1a2e; font-weight: 500; }
    .legend-text { font: 10px system-ui, sans-serif; fill: #a78bfa; }
  </style>

  <!-- Background -->
  <rect width="100%" height="100%" fill="#1a1a2e"/>

  <!-- Title -->
  <text x="20" y="25" class="title">Violet Void - WCAG Contrast Matrix</text>

  <!-- Legend -->
  <g transform="translate(20, 45)">
    <rect x="0" y="0" width="12" height="12" fill="#4ade80" rx="2"/>
    <text x="18" y="10" class="legend-text">AAA (7:1+)</text>
    <rect x="90" y="0" width="12" height="12" fill="#60a5fa" rx="2"/>
    <text x="108" y="10" class="legend-text">AA (4.5:1+)</text>
    <rect x="190" y="0" width="12" height="12" fill="#fbbf24" rx="2"/>
    <text x="208" y="10" class="legend-text">AA-Large (3:1+)</text>
    <rect x="310" y="0" width="12" height="12" fill="#f87171" rx="2"/>
    <text x="328" y="10" class="legend-text">Fail (&lt;3:1)</text>
  </g>
SVGHEADER

  # Column headers (foreground colors)
  local x=$row_label_width
  local y=85
  echo "$data" | jq -r '.foregrounds[] | @base64' | while read -r fg; do
    local fg_key fg_hex
    fg_key=$(echo "$fg" | base64 -d | jq -r '.key')
    fg_hex=$(echo "$fg" | base64 -d | jq -r '.hex')
    echo "  <text x=\"$((x + cell_size / 2))\" y=\"$y\" class=\"fg-label\" transform=\"rotate(-45, $((x + cell_size / 2)), $y)\">$fg_key</text>"
    x=$((x + cell_size))
  done >> "$svg_file"

  # Matrix cells
  local row_y=$((header_height))
  echo "$data" | jq -r '.matrix[] | @base64' | while read -r row; do
    local bg_key bg_hex
    bg_key=$(echo "$row" | base64 -d | jq -r '.bgKey')
    bg_hex=$(echo "$row" | base64 -d | jq -r '.bgHex')

    # Row label
    echo "  <text x=\"10\" y=\"$((row_y + cell_size / 2 + 4))\" class=\"bg-label\">$bg_key</text>" >> "$svg_file"

    # Cells
    local cell_x=$row_label_width
    echo "$row" | base64 -d | jq -r '.cells[] | @base64' | while read -r cell; do
      local fg_hex ratio level color
      fg_hex=$(echo "$cell" | base64 -d | jq -r '.fgHex')
      ratio=$(echo "$cell" | base64 -d | jq -r '.ratio')
      level=$(echo "$cell" | base64 -d | jq -r '.level')
      color=$(echo "$cell" | base64 -d | jq -r '.color')

      # Cell background
      echo "  <rect x=\"$cell_x\" y=\"$row_y\" width=\"$((cell_size - 2))\" height=\"$((cell_size - 2))\" fill=\"$color\" rx=\"4\"/>" >> "$svg_file"

      # Ratio text
      echo "  <text x=\"$((cell_x + cell_size / 2 - 1))\" y=\"$((row_y + cell_size / 2 + 3))\" class=\"ratio\" text-anchor=\"middle\">${ratio}</text>" >> "$svg_file"

      cell_x=$((cell_x + cell_size))
    done

    row_y=$((row_y + cell_size))
  done >> "$svg_file"

  # Close SVG
  echo "</svg>" >> "$svg_file"

  echo -e "${GREEN}✓ Generated: $svg_file${NC}"
}

# Generate HTML table
generate_html() {
  echo -e "${CYAN}Generating HTML contrast matrix...${NC}"

  local data
  data=$(generate_matrix_data)

  local html_file="$OUTPUT_DIR/contrast-matrix.html"

  cat > "$html_file" << 'HTMLHEADER'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Violet Void - WCAG Contrast Matrix</title>
  <style>
    :root {
      --bg: #1a1a2e;
      --bg-secondary: #16213e;
      --fg: #e2e2e2;
      --fg-muted: #a78bfa;
      --accent: #7c60d1;
    }
    body {
      font-family: system-ui, -apple-system, sans-serif;
      background: var(--bg);
      color: var(--fg);
      margin: 0;
      padding: 20px;
    }
    h1 {
      color: var(--fg-muted);
      margin-bottom: 10px;
    }
    .legend {
      display: flex;
      gap: 20px;
      margin-bottom: 20px;
      font-size: 14px;
    }
    .legend-item {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .legend-box {
      width: 16px;
      height: 16px;
      border-radius: 3px;
    }
    .aaa { background: #4ade80; }
    .aa { background: #60a5fa; }
    .aa-large { background: #fbbf24; }
    .fail { background: #f87171; }
    table {
      border-collapse: collapse;
      font-size: 12px;
    }
    th, td {
      padding: 8px;
      text-align: center;
      border: 1px solid var(--bg-secondary);
    }
    th {
      background: var(--bg-secondary);
      color: var(--fg-muted);
      font-weight: 500;
    }
    td.bg-label {
      text-align: left;
      color: var(--fg-muted);
      font-weight: 500;
    }
    td.cell {
      font-weight: 600;
      color: #1a1a2e;
      min-width: 50px;
    }
    .summary {
      margin-top: 20px;
      padding: 15px;
      background: var(--bg-secondary);
      border-radius: 8px;
    }
  </style>
</head>
<body>
  <h1>Violet Void - WCAG Contrast Matrix</h1>

  <div class="legend">
    <div class="legend-item"><div class="legend-box aaa"></div> AAA (7:1+)</div>
    <div class="legend-item"><div class="legend-box aa"></div> AA (4.5:1+)</div>
    <div class="legend-item"><div class="legend-box aa-large"></div> AA-Large (3:1+)</div>
    <div class="legend-item"><div class="legend-box fail"></div> Fail (&lt;3:1)</div>
  </div>
HTMLHEADER

  # Table header
  echo '  <table>' >> "$html_file"
  echo '    <thead>' >> "$html_file"
  echo '      <tr><th>Background</th>' >> "$html_file"
  echo "$data" | jq -r '.foregrounds[].key' | while read -r key; do
    echo "        <th>$key</th>" >> "$html_file"
  done
  echo '      </tr>' >> "$html_file"
  echo '    </thead>' >> "$html_file"
  echo '    <tbody>' >> "$html_file"

  # Table rows
  echo "$data" | jq -r '.matrix[] | @base64' | while read -r row; do
    local bg_key
    bg_key=$(echo "$row" | base64 -d | jq -r '.bgKey')
    echo "      <tr>" >> "$html_file"
    echo "        <td class=\"bg-label\">$bg_key</td>" >> "$html_file"

    echo "$row" | base64 -d | jq -r '.cells[] | @base64' | while read -r cell; do
      local ratio level
      ratio=$(echo "$cell" | base64 -d | jq -r '.ratio')
      level=$(echo "$cell" | base64 -d | jq -r '.level')

      local class
      case $level in
        AAA) class="aaa" ;;
        AA) class="aa" ;;
        AA-Large) class="aa-large" ;;
        *) class="fail" ;;
      esac

      echo "        <td class=\"cell $class\">${ratio}</td>" >> "$html_file"
    done

    echo "      </tr>" >> "$html_file"
  done

  echo '    </tbody>' >> "$html_file"
  echo '  </table>' >> "$html_file"

  # Summary
  local total passed_aaa passed_aa failed
  total=$(echo "$data" | jq -r '.summary.total')
  passed_aaa=$(echo "$data" | jq -r '.summary.passedAAA')
  passed_aa=$(echo "$data" | jq -r '.summary.passedAA')
  failed=$(echo "$data" | jq -r '.summary.failed')

  cat >> "$html_file" << HTMLSUMMARY
  <div class="summary">
    <strong>Summary:</strong>
    AAA: $passed_aaa | AA: $passed_aa | Failed: $failed | Total: $total combinations
  </div>
</body>
</html>
HTMLSUMMARY

  echo -e "${GREEN}✓ Generated: $html_file${NC}"
}

# Generate Markdown table
generate_markdown() {
  echo -e "${CYAN}Generating Markdown contrast matrix...${NC}"

  local data
  data=$(generate_matrix_data)

  local md_file="$OUTPUT_DIR/contrast-matrix.md"

  cat > "$md_file" << 'MDHEADER'
# Violet Void - WCAG Contrast Matrix

This matrix shows WCAG 2.0 contrast ratios between all background and foreground color combinations.

## Legend

| Level | Ratio | Icon | Use Case |
|-------|-------|------|----------|
| AAA | ≥ 7:1 | 🟢 | Enhanced contrast, all text sizes |
| AA | ≥ 4.5:1 | 🔵 | Minimum contrast, normal text |
| AA-Large | ≥ 3:1 | 🟡 | Large text only (18px+ or 14px bold) |
| Fail | < 3:1 | 🔴 | Insufficient contrast, non-text only |

## Contrast Matrix

MDHEADER

  # Table header
  local fg_keys
  fg_keys=$(echo "$data" | jq -r '.foregrounds[].key' | tr '\n' '|')
  echo "| Background | $fg_keys" >> "$md_file"
  echo "|------------|$(echo "$data" | jq -r '.foregrounds[] | ":---:"' | tr '\n' '|')" >> "$md_file"

  # Table rows
  echo "$data" | jq -r '.matrix[] | @base64' | while read -r row; do
    local bg_key
    bg_key=$(echo "$row" | base64 -d | jq -r '.bgKey')

    local row_content="$bg_key"
    echo "$row" | base64 -d | jq -r '.cells[] | @base64' | while read -r cell; do
      local ratio level
      ratio=$(echo "$cell" | base64 -d | jq -r '.ratio')
      level=$(echo "$cell" | base64 -d | jq -r '.level')

      local icon
      case $level in
        AAA) icon="🟢" ;;
        AA) icon="🔵" ;;
        AA-Large) icon="🟡" ;;
        *) icon="🔴" ;;
      esac

      row_content="$row_content | $icon ${ratio}"
    done

    echo "| $row_content |" >> "$md_file"
  done

  # Summary
  local total passed_aaa passed_aa failed
  total=$(echo "$data" | jq -r '.summary.total')
  passed_aaa=$(echo "$data" | jq -r '.summary.passedAAA')
  passed_aa=$(echo "$data" | jq -r '.summary.passedAA')
  failed=$(echo "$data" | jq -r '.summary.failed')

  cat >> "$md_file" << MDSUMMARY

## Summary

- **AAA (7:1+):** $passed_aaa combinations
- **AA (4.5:1+):** $passed_aa combinations
- **Failed:** $failed combinations
- **Total:** $total combinations

> **Note:** Failed combinations may still be acceptable for non-text use cases (borders, icons, decorative elements).
MDSUMMARY

  echo -e "${GREEN}✓ Generated: $md_file${NC}"
}

# Display terminal matrix
display_terminal() {
  echo -e "${BOLD}${CYAN}Violet Void - WCAG Contrast Matrix${NC}\n"

  echo -e "${GREEN}🟢 AAA (7:1+)${NC}  ${BLUE}🔵 AA (4.5:1+)${NC}  ${YELLOW}🟡 AA-Large (3:1+)${NC}  ${RED}🔴 Fail${NC}\n"

  local data
  data=$(generate_matrix_data)

  # Header
  printf "${CYAN}%-12s${NC}" ""
  echo "$data" | jq -r '.foregrounds[].key' | while read -r key; do
    printf "${CYAN}%8s${NC}" "${key:0:8}"
  done
  echo

  # Rows
  echo "$data" | jq -r '.matrix[] | @base64' | while read -r row; do
    local bg_key
    bg_key=$(echo "$row" | base64 -d | jq -r '.bgKey')
    printf "${CYAN}%-12s${NC}" "$bg_key"

    echo "$row" | base64 -d | jq -r '.cells[] | @base64' | while read -r cell; do
      local ratio level
      ratio=$(echo "$cell" | base64 -d | jq -r '.ratio')
      level=$(echo "$cell" | base64 -d | jq -r '.level')

      case $level in
        AAA) printf "${GREEN}%8s${NC}" "${ratio}" ;;
        AA) printf "${BLUE}%8s${NC}" "${ratio}" ;;
        AA-Large) printf "${YELLOW}%8s${NC}" "${ratio}" ;;
        *) printf "${RED}%8s${NC}" "${ratio}" ;;
      esac
    done
    echo
  done

  # Summary
  local total passed_aaa passed_aa failed
  total=$(echo "$data" | jq -r '.summary.total')
  passed_aaa=$(echo "$data" | jq -r '.summary.passedAAA')
  passed_aa=$(echo "$data" | jq -r '.summary.passedAA')
  failed=$(echo "$data" | jq -r '.summary.failed')

  echo -e "\n${BOLD}Summary:${NC}"
  echo -e "  ${GREEN}AAA:${NC} $passed_aaa  ${BLUE}AA:${NC} $passed_aa  ${RED}Failed:${NC} $failed  ${CYAN}Total:${NC} $total"
}

# Main execution
case "$FORMAT" in
  svg) generate_svg ;;
  html) generate_html ;;
  md|markdown) generate_markdown ;;
  terminal|term) display_terminal ;;
  all)
    generate_svg
    generate_html
    generate_markdown
    ;;
  *)
    echo -e "${RED}Unknown format: $FORMAT${NC}" >&2
    show_help
    exit 1
    ;;
esac
