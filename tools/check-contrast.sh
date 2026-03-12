#!/usr/bin/env bash
# WCAG Color Contrast Checker for Violet Void Theme
# Validates color combinations against WCAG 2.0 accessibility standards
# Usage: ./tools/check-contrast.sh [--json] [--quiet] [--all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
PALETTE_FILE="$MONOREPO_ROOT/palette/colors.json"

# Output options
JSON_OUTPUT=false
QUIET=false
SHOW_ALL=false

# Colors for terminal output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
BOLD='\033[1m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --json) JSON_OUTPUT=true; shift ;;
    --quiet|-q) QUIET=true; shift ;;
    --all|-a) SHOW_ALL=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--json] [--quiet] [--all]"
      echo ""
      echo "Options:"
      echo "  --json     Output results as JSON"
      echo "  --quiet    Only show failures"
      echo "  --all      Show all color combinations"
      echo "  --help     Show this help"
      echo ""
      echo "WCAG 2.0 Levels:"
      echo "  AAA       Ratio >= 7:1 (enhanced contrast)"
      echo "  AA        Ratio >= 4.5:1 (minimum contrast)"
      echo "  AA-Large  Ratio >= 3:1 (large text only)"
      echo "  FAIL      Ratio < 3:1 (insufficient contrast)"
      exit 0
      ;;
    *) shift ;;
  esac
done

if [[ ! -f "$PALETTE_FILE" ]]; then
  echo -e "${RED}Error: palette/colors.json not found${NC}" >&2
  exit 1
fi

# Use Node.js for contrast calculations
# Pass options via environment variables
export JSON_OUTPUT QUIET SHOW_ALL PALETTE_FILE

node << 'NODESCRIPT'
const fs = require("fs");

const jsonOutput = process.env.JSON_OUTPUT === "true";
const quiet = process.env.QUIET === "true";
const showAll = process.env.SHOW_ALL === "true";

// Load colors
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
  
  // Ensure l1 is lighter
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

// Collect all colors
const backgrounds = Object.entries(palette.backgrounds);
const foregrounds = [
  ...Object.entries(palette.foregrounds),
  ...Object.entries(palette.accents)
];

// Test all combinations
const results = [];
let passedAA = 0, passedAAA = 0, failed = 0;

for (const [bgKey, bgHex] of backgrounds) {
  for (const [fgKey, fgHex] of foregrounds) {
    const ratio = getContrastRatio(bgHex, fgHex);
    const level = getWcagLevel(ratio);
    
    if (level === "AAA") passedAAA++;
    else if (level === "AA" || level === "AA-Large") passedAA++;
    else failed++;
    
    results.push({ bgKey, fgKey, bgHex, fgHex, ratio, level });
  }
}

const total = results.length;

// JSON output
if (jsonOutput) {
  console.log(JSON.stringify({
    summary: { total, passedAAA, passedAA, failed },
    results: results.map(r => ({
      background: r.bgKey,
      foreground: r.fgKey,
      bgHex: r.bgHex,
      fgHex: r.fgHex,
      ratio: Math.round(r.ratio * 100) / 100,
      level: r.level
    }))
  }, null, 2));
  process.exit(failed > 0 ? 1 : 0);
}

// Terminal output
const colors = {
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  cyan: "\x1b[36m",
  bold: "\x1b[1m",
  reset: "\x1b[0m"
};

function levelIcon(level) {
  switch (level) {
    case "AAA": return { icon: "✓", color: colors.green };
    case "AA": return { icon: "✓", color: colors.green };
    case "AA-Large": return { icon: "⚠", color: colors.yellow };
    default: return { icon: "✗", color: colors.red };
  }
}

if (!quiet) {
  console.log(`${colors.bold}${colors.cyan}Violet Void WCAG Contrast Report${colors.reset}`);
  console.log(`${colors.cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
}

// Critical combinations (text on backgrounds)
const criticalCombos = [
  ["bg", "fg"], ["bg", "fgMuted"], ["bg", "fgComment"],
  ["bgDark", "fg"], ["bgHighlight", "fg"]
];

if (!quiet) {
  console.log(`${colors.bold}Critical Combinations (Text on Background):${colors.reset}\n`);
  
  for (const [bgKey, fgKey] of criticalCombos) {
    const r = results.find(x => x.bgKey === bgKey && x.fgKey === fgKey);
    if (r) {
      const { icon, color } = levelIcon(r.level);
      console.log(`  ${color}${icon}${colors.reset} ${r.bgKey} + ${r.fgKey}: ${r.ratio.toFixed(2)}:1 (${r.level})`);
    }
  }
  
  console.log(`\n${colors.bold}Accent Colors on Main Background (bg):${colors.reset}\n`);
  
  const accentKeys = Object.keys(palette.accents);
  for (const fgKey of accentKeys) {
    const r = results.find(x => x.bgKey === "bg" && x.fgKey === fgKey);
    if (r) {
      const { icon, color } = levelIcon(r.level);
      const line = `  ${color}${icon}${colors.reset} ${fgKey.padEnd(15)} ${r.ratio.toFixed(2)}:1 (${r.level})`;
      console.log(line);
    }
  }
}

// Show all combinations if requested
if (showAll && !quiet) {
  console.log(`\n${colors.bold}All Combinations:${colors.reset}\n`);
  
  const bgKeys = Object.keys(palette.backgrounds);
  for (const bgKey of bgKeys) {
    console.log(`  ${colors.cyan}${bgKey}:${colors.reset}`);
    for (const r of results.filter(x => x.bgKey === bgKey)) {
      const { icon, color } = levelIcon(r.level);
      console.log(`    ${color}${icon}${colors.reset} ${r.fgKey.padEnd(15)} ${r.ratio.toFixed(2)}:1 (${r.level})`);
    }
    console.log();
  }
}

// Summary
if (!quiet) {
  console.log(`${colors.bold}Summary:${colors.reset}`);
  console.log(`  ${colors.green}AAA (7:1+):${colors.reset}   ${passedAAA} combinations`);
  console.log(`  ${colors.green}AA (4.5:1+):${colors.reset}  ${passedAA} combinations`);
  console.log(`  ${colors.red}Failed:${colors.reset}      ${failed} combinations`);
  console.log(`  ${colors.blue}Total:${colors.reset}       ${total} combinations`);
  
  if (failed > 0) {
    console.log(`\n${colors.yellow}⚠ Some combinations fail WCAG AA. These may be acceptable for non-text use (borders, icons).${colors.reset}`);
  }
}

process.exit(failed > 0 ? 1 : 0);
NODESCRIPT
