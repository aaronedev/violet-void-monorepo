#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Violet Void - Tint & Shade Generator
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Generates tints (lighter) and shades (darker) of Violet Void palette colors
# Creates extended palette with 9 variations per base color (50, 100, ..., 900)
#
# Usage:
#   ./tools/tint-shade-generator.sh [format] [options]
#
# Formats:
#   json      - JSON format with color metadata
#   css       - CSS custom properties
#   tailwind  - Tailwind CSS config format
#   all       - Generate all formats
#
# Options:
#   --output-dir DIR  - Output directory (default: ./palette-extended)
#   --min-lightness N - Minimum lightness for shades (default: 5)
#   --max-lightness N - Maximum lightness for tints (default: 95)
#
# Examples:
#   ./tools/tint-shade-generator.sh json
#   ./tools/tint-shade-generator.sh css --output-dir ./dist
#   ./tools/tint-shade-generator.sh all
#
# Dependencies:
#   - bash 4.0+
#   - bc (arbitrary precision calculator)
#   - pastel (color manipulation CLI) - optional, falls back to manual calculation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# Color output helpers
BRIGHT_CYAN='\033[96m'
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
RESET='\033[0m'

info() { echo -e "${BRIGHT_CYAN}ℹ${RESET} $*"; }
success() { echo -e "${BRIGHT_GREEN}✓${RESET} $*"; }
warn() { echo -e "${BRIGHT_YELLOW}⚠${RESET} $*"; }

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Violet Void Base Palette
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
declare -A PALETTE=(
  # Backgrounds
  ["bg"]="050505"
  ["bgDark"]="0e0e0e"
  ["bgHighlight"]="191919"
  ["bgSelection"]="0f0f0f"
  ["black"]="181818"
  
  # Foregrounds
  ["fg"]="f0f0f5"
  ["fgDark"]="303030"
  ["fgMuted"]="414141"
  ["fgComment"]="4c4c4c"
  ["white"]="e7e7e7"
  
  # Accent Colors
  ["red"]="ff1a67"
  ["redBright"]="ff004b"
  ["green"]="42ff97"
  ["greenBright"]="42ffad"
  ["blue"]="29adff"
  ["blueBright"]="c7b8ff"
  ["cyan"]="00a8a4"
  ["cyanBright"]="00fff9"
  ["magenta"]="fd007f"
  ["magentaBright"]="fd0098"
  ["purple"]="7c60d1"
  ["purpleBright"]="fd7cff"
  ["orange"]="ff7c7e"
  ["yellow"]="ffd93d"
)

# Tint-shade steps (9 variations: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900)
# 500 = base color, <500 = tints (lighter), >500 = shades (darker)
STEPS=(50 100 200 300 400 500 600 700 800 900)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Color Manipulation Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Check if pastel is available
has_pastel() {
  command -v pastel >/dev/null 2>&1
}

# Check if bc is available
has_bc() {
  command -v bc >/dev/null 2>&1
}

# Convert hex to RGB
hex_to_rgb() {
  local hex="$1"
  hex="${hex#\#}" # Remove # if present
  
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  
  echo "$r $g $b"
}

# Convert RGB to hex
rgb_to_hex() {
  local r="$1"
  local g="$2"
  local b="$3"
  
  printf "%02x%02x%02x\n" "$r" "$g" "$b"
}

# Convert RGB to HSL
rgb_to_hsl() {
  local r="$1"
  local g="$2"
  local b="$3"
  
  # Normalize to 0-1
  local r_norm=$(echo "scale=4; $r / 255" | bc -l 2>/dev/null || echo "0")
  local g_norm=$(echo "scale=4; $g / 255" | bc -l 2>/dev/null || echo "0")
  local b_norm=$(echo "scale=4; $b / 255" | bc -l 2>/dev/null || echo "0")
  
  if has_pastel; then
    # Use pastel for accurate conversion
    pastel color "$r" "$g" "$b" --format hsl 2>/dev/null | awk '{print $1, $2, $3}'
  else
    # Fallback: simplified HSL conversion (less accurate)
    warn "pastel not found, using simplified HSL conversion"
    echo "0 0 50" # Placeholder - manual calculation is complex
  fi
}

# Convert HSL to RGB
hsl_to_rgb() {
  local h="$1"
  local s="$2"
  local l="$3"
  
  if has_pastel; then
    # Use pastel for accurate conversion
    pastel color "hsl($h, $s%, $l%)" --format rgb 2>/dev/null | awk '{print $1, $2, $3}'
  else
    # Fallback: simplified conversion (less accurate)
    warn "pastel not found, using simplified RGB conversion"
    echo "128 128 128" # Placeholder
  fi
}

# Lighten a hex color by percentage
lighten() {
  local hex="$1"
  local percent="$2"
  
  if has_pastel; then
    pastel lighten "$percent%" "$hex" --format hex 2>/dev/null | tr -d '#'
  else
    # Fallback: simple RGB lightening
    local rgb
    rgb=$(hex_to_rgb "$hex")
    read -r r g b <<< "$rgb"
    
    local amount=$((255 * percent / 100))
    r=$((r + (255 - r) * amount / 255))
    g=$((g + (255 - g) * amount / 255))
    b=$((b + (255 - b) * amount / 255))
    
    rgb_to_hex "$r" "$g" "$b"
  fi
}

# Darken a hex color by percentage
darken() {
  local hex="$1"
  local percent="$2"
  
  if has_pastel; then
    pastel darken "$percent%" "$hex" --format hex 2>/dev/null | tr -d '#'
  else
    # Fallback: simple RGB darkening
    local rgb
    rgb=$(hex_to_rgb "$hex")
    read -r r g b <<< "$rgb"
    
    local amount=$((255 * percent / 100))
    r=$((r * (100 - percent) / 100))
    g=$((g * (100 - percent) / 100))
    b=$((b * (100 - percent) / 100))
    
    rgb_to_hex "$r" "$g" "$b"
  fi
}

# Generate tint (lighter version)
generate_tint() {
  local hex="$1"
  local step="$2"  # 50, 100, 200, 300, 400
  
  # Map step to lightness percentage
  # 50 = lightest (80% lighter), 400 = lightest tint (10% lighter)
  local lightness_percent=$((100 - step / 5))
  
  lighten "$hex" "$lightness_percent"
}

# Generate shade (darker version)
generate_shade() {
  local hex="$1"
  local step="$2"  # 600, 700, 800, 900
  
  # Map step to darkness percentage
  # 600 = lightest shade (10% darker), 900 = darkest (40% darker)
  local darkness_percent=$(((step - 500) / 10))
  
  darken "$hex" "$darkness_percent"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Output Generation Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Generate JSON format
generate_json() {
  local output_file="$1"
  
  info "Generating JSON format..."
  
  cat > "$output_file" << 'EOF'
{
  "name": "Violet Void Extended Palette",
  "version": "1.0.0",
  "description": "Extended color palette with tints and shades for Violet Void theme",
  "colors": {
EOF
  
  local first=true
  for color_name in "${!PALETTE[@]}"; do
    local base_hex="${PALETTE[$color_name]}"
    
    if [[ "$first" != "true" ]]; then
      echo "," >> "$output_file"
    fi
    first=false
    
    cat >> "$output_file" << EOF
    "$color_name": {
      "base": "#$base_hex",
      "values": {
EOF
    
    local value_first=true
    for step in "${STEPS[@]}"; do
      local hex
      
      if [[ $step -eq 500 ]]; then
        hex="$base_hex"
      elif [[ $step -lt 500 ]]; then
        hex=$(generate_tint "$base_hex" "$step")
      else
        hex=$(generate_shade "$base_hex" "$step")
      fi
      
      if [[ "$value_first" != "true" ]]; then
        echo "," >> "$output_file"
      fi
      value_first=false
      
      printf '        "%d": "#%s"' "$step" "$hex" >> "$output_file"
    done
    
    cat >> "$output_file" << EOF

      }
    }
EOF
  done
  
  cat >> "$output_file" << 'EOF'
  }
}
EOF
  
  success "Generated: $output_file"
}

# Generate CSS custom properties
generate_css() {
  local output_file="$1"
  
  info "Generating CSS custom properties..."
  
  cat > "$output_file" << 'EOF'
/**
 * Violet Void Extended Palette - CSS Custom Properties
 * Generated automatically by tint-shade-generator.sh
 * 
 * Usage:
 *   color: var(--violet-void-purple-500);
 *   background: var(--violet-void-bg-900);
 */

:root {
EOF
  
  for color_name in "${!PALETTE[@]}"; do
    local base_hex="${PALETTE[$color_name]}"
    
    echo "" >> "$output_file"
    echo "  /* $color_name */" >> "$output_file"
    
    for step in "${STEPS[@]}"; do
      local hex
      
      if [[ $step -eq 500 ]]; then
        hex="$base_hex"
      elif [[ $step -lt 500 ]]; then
        hex=$(generate_tint "$base_hex" "$step")
      else
        hex=$(generate_shade "$base_hex" "$step")
      fi
      
      printf '  --violet-void-%s-%d: #%s;\n' "$color_name" "$step" "$hex" >> "$output_file"
    done
  done
  
  echo "}" >> "$output_file"
  
  success "Generated: $output_file"
}

# Generate Tailwind config format
generate_tailwind() {
  local output_file="$1"
  
  info "Generating Tailwind config format..."
  
  cat > "$output_file" << 'EOF'
// Violet Void Extended Palette - Tailwind CSS Config
// Generated automatically by tint-shade-generator.sh
//
// Usage in tailwind.config.js:
//   const violetVoid = require('./violet-void-tailwind.js');
//   module.exports = {
//     theme: {
//       extend: {
//         colors: violetVoid.colors
//       }
//     }
//   }

module.exports = {
  colors: {
EOF
  
  for color_name in "${!PALETTE[@]}"; do
    local base_hex="${PALETTE[$color_name]}"
    
    echo "    $color_name: {" >> "$output_file"
    
    for step in "${STEPS[@]}"; do
      local hex
      
      if [[ $step -eq 500 ]]; then
        hex="$base_hex"
      elif [[ $step -lt 500 ]]; then
        hex=$(generate_tint "$base_hex" "$step")
      else
        hex=$(generate_shade "$base_hex" "$step")
      fi
      
      printf "      %d: '#%s',\n" "$step" "$hex" >> "$output_file"
    done
    
    echo "    }," >> "$output_file"
  done
  
  cat >> "$output_file" << 'EOF'
  }
};
EOF
  
  success "Generated: $output_file"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

usage() {
  cat << 'EOF'
Violet Void - Tint & Shade Generator

Usage:
  ./tools/tint-shade-generator.sh [format] [options]

Formats:
  json      - JSON format with color metadata
  css       - CSS custom properties
  tailwind  - Tailwind CSS config format
  all       - Generate all formats

Options:
  --output-dir DIR  - Output directory (default: ./palette-extended)
  --help            - Show this help message

Examples:
  ./tools/tint-shade-generator.sh json
  ./tools/tint-shade-generator.sh css --output-dir ./dist
  ./tools/tint-shade-generator.sh all

Dependencies:
  - bash 4.0+
  - pastel (optional, for accurate color manipulation)
  - bc (optional, for fallback calculations)
EOF
}

main() {
  local format="all"
  local output_dir="./palette-extended"
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      json|css|tailwind|all)
        format="$1"
        shift
        ;;
      --output-dir)
        output_dir="$2"
        shift 2
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        warn "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
  
  # Check dependencies
  if ! has_pastel && ! has_bc; then
    warn "Neither 'pastel' nor 'bc' found. Color manipulation may be inaccurate."
    warn "Install pastel: sudo pacman -S pastel"
    warn "Install bc: sudo pacman -S bc"
  fi
  
  # Create output directory
  mkdir -p "$output_dir"
  
  info "Generating extended Violet Void palette..."
  info "Output directory: $output_dir"
  echo ""
  
  # Generate requested formats
  case "$format" in
    json)
      generate_json "$output_dir/violet-void-palette.json"
      ;;
    css)
      generate_css "$output_dir/violet-void-palette.css"
      ;;
    tailwind)
      generate_tailwind "$output_dir/violet-void-tailwind.js"
      ;;
    all)
      generate_json "$output_dir/violet-void-palette.json"
      generate_css "$output_dir/violet-void-palette.css"
      generate_tailwind "$output_dir/violet-void-tailwind.js"
      ;;
  esac
  
  echo ""
  success "Extended palette generation complete!"
  info "Generated files in: $output_dir"
}

main "$@"
