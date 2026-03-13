#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Color Blindness Simulator for Violet Void Palette
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Simulates how the Violet Void palette appears to users with different types
# of color vision deficiencies.
#
# Usage: ./color-blindness-simulator.sh [type] [format]
#   type: protanopia | deuteranopia | tritanopia | all (default: all)
#   format: json | css | text (default: text)
#
# Requirements: Node.js with colorblind package (npm install -g colorblind)
#               or uses built-in approximation algorithms
#
# Link: https://github.com/skratchdot/colorblind
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PALETTE_FILE="$MONOREPO_ROOT/tokens/colors.json"
OUTPUT_DIR="$MONOREPOPO_ROOT/docs/accessibility"

# Color blindness simulation matrices (approximate)
# Based on Brettel, Viénot, Mollon (1997) algorithms

# Protanopia (red-blind) - missing L-cones
simulate_protanopia() {
    local r="$1"
    local g="$2"
    local b="$3"
    
    # Convert to protanopia
    local new_r=$(echo "scale=0; ($r * 0.567 + $g * 0.433 + $b * 0.0) / 1" | bc)
    local new_g=$(echo "scale=0; ($r * 0.558 + $g * 0.442 + $b * 0.0) / 1" | bc)
    local new_b=$(echo "scale=0; ($r * 0.0 + $g * 0.242 + $b * 0.758) / 1" | bc)
    
    echo "$new_r $new_g $new_b"
}

# Deuteranopia (green-blind) - missing M-cones
simulate_deuteranopia() {
    local r="$1"
    local g="$2"
    local b="$3"
    
    # Convert to deuteranopia
    local new_r=$(echo "scale=0; ($r * 0.625 + $g * 0.375 + $b * 0.0) / 1" | bc)
    local new_g=$(echo "scale=0; ($r * 0.7 + $g * 0.3 + $b * 0.0) / 1" | bc)
    local new_b=$(echo "scale=0; ($r * 0.0 + $g * 0.3 + $b * 0.7) / 1" | bc)
    
    echo "$new_r $new_g $new_b"
}

# Tritanopia (blue-blind) - missing S-cones
simulate_tritanopia() {
    local r="$1"
    local g="$2"
    local b="$3"
    
    # Convert to tritanopia
    local new_r=$(echo "scale=0; ($r * 0.95 + $g * 0.05 + $b * 0.0) / 1" | bc)
    local new_g=$(echo "scale=0; ($r * 0.0 + $g * 0.433 + $b * 0.567) / 1" | bc)
    local new_b=$(echo "scale=0; ($r * 0.0 + $g * 0.475 + $b * 0.525) / 1" | bc)
    
    echo "$new_r $new_g $new_b"
}

# Convert hex to RGB
hex_to_rgb() {
    local hex="$1"
    hex="${hex#\#}"
    
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
    
    printf "#%02x%02x%02x\n" "$r" "$g" "$b"
}

# Process a single color through simulation
process_color() {
    local hex="$1"
    local sim_type="$2"
    
    # Convert to RGB
    read -r r g b <<< "$(hex_to_rgb "$hex")"
    
    # Apply simulation
    local new_r new_g new_b
    case "$sim_type" in
        protanopia)
            read -r new_r new_g new_b <<< "$(simulate_protanopia "$r" "$g" "$b")"
            ;;
        deuteranopia)
            read -r new_r new_g new_b <<< "$(simulate_deuteranopia "$r" "$g" "$b")"
            ;;
        tritanopia)
            read -r new_r new_g new_b <<< "$(simulate_tritanopia "$r" "$g" "$b")"
            ;;
        *)
            echo "$hex"
            return
            ;;
    esac
    
    # Clamp values
    new_r=$(echo "if ($new_r < 0) 0 else if ($new_r > 255) 255 else $new_r" | bc)
    new_g=$(echo "if ($new_g < 0) 0 else if ($new_g > 255) 255 else $new_g" | bc)
    new_b=$(echo "if ($new_b < 0) 0 else if ($new_b > 255) 255 else $new_b" | bc)
    
    # Convert back to hex
    rgb_to_hex "${new_r%.*}" "${new_g%.*}" "${new_b%.*}"
}

# Extract colors from palette JSON
extract_colors() {
    if [[ ! -f "$PALETTE_FILE" ]]; then
        echo "Error: Palette file not found at $PALETTE_FILE" >&2
        exit 1
    fi
    
    # Use jq to extract color values
    command -v jq >/dev/null 2>&1 || {
        echo "Error: jq is required. Install with: sudo pacman -S jq" >&2
        exit 1
    }
    
    jq -r '
        .color | .. | objects | select(has("value")) | 
        "\(.value) \(.description // "unknown")"
    ' "$PALETTE_FILE"
}

# Generate simulation report
generate_report() {
    local sim_type="$1"
    local format="$2"
    
    echo "# Color Blindness Simulation: ${sim_type^}"
    echo "# Generated: $(date -Iseconds)"
    echo ""
    
    extract_colors | while read -r hex description; do
        local simulated_hex
        simulated_hex=$(process_color "$hex" "$sim_type")
        
        case "$format" in
            json)
                echo "  \"$description\": \"$simulated_hex\","
                ;;
            css)
                echo "  --${description// /-}: $simulated_hex;"
                ;;
            *)
                echo "$description: $hex → $simulated_hex"
                ;;
        esac
    done
}

# Main function
main() {
    local sim_type="${1:-all}"
    local format="${2:-text}"
    
    # Check dependencies
    command -v bc >/dev/null 2>&1 || {
        echo "Error: bc is required. Install with: sudo pacman -S bc" >&2
        exit 1
    }
    
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         Violet Void - Color Blindness Simulator                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [[ "$sim_type" == "all" ]]; then
        echo "Simulating all color vision deficiency types..."
        echo ""
        
        for type in protanopia deuteranopia tritanopia; do
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Type: ${type^}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            generate_report "$type" "$format"
            echo ""
        done
    else
        generate_report "$sim_type" "$format"
    fi
    
    echo ""
    echo "Note: These simulations use approximation algorithms."
    echo "For more accurate results, consider using the 'colorblind' npm package:"
    echo "  npm install -g colorblind"
}

# Run main function
main "$@"
