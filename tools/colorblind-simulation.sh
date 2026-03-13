#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Color Blindness Simulation Tool for Violet Void Theme
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Simulates how the Violet Void palette appears to users with color vision deficiencies
#
# Usage: ./colorblind-simulation.sh [protanopia|deuteranopia|tritanopia|all]
#
# Requirements:
#   - jq (JSON processor)
#   - bc (calculator)
#   - python3 with colormath or similar (optional, for more accurate simulation)
#
# References:
#   - https://www.color-blindness.com/
#   - https://ixora.io/projects/colorblindness/
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PALETTE_FILE="${SCRIPT_DIR}/../tokens/colors.json"
OUTPUT_DIR="${SCRIPT_DIR}/../docs/accessibility"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Color Blindness Simulation Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Note: These are simplified simulations. For accurate results, use professional tools
# or libraries like colormath (Python) or color-blind (npm).

# Protanopia (red-blind) - Missing L-cones
# Affects ~1% of males
simulate_protanopia() {
    local r="$1"
    local g="$2"
    local b="$3"
    
    # Brettel, Viénot, Mollon simulation matrix
    # Approximate conversion for protanopia
    local new_r=$(echo "scale=0; ($r * 0.567 + $g * 0.433 + $b * 0.0) / 1" | bc)
    local new_g=$(echo "scale=0; ($r * 0.558 + $g * 0.442 + $b * 0.0) / 1" | bc)
    local new_b=$(echo "scale=0; ($r * 0.0 + $g * 0.242 + $b * 0.758) / 1" | bc)
    
    echo "$new_r $new_g $new_b"
}

# Deuteranopia (green-blind) - Missing M-cones
# Affects ~1% of males
simulate_deuteranopia() {
    local r="$1"
    local g="$2"
    local b="$3"
    
    # Approximate conversion for deuteranopia
    local new_r=$(echo "scale=0; ($r * 0.625 + $g * 0.375 + $b * 0.0) / 1" | bc)
    local new_g=$(echo "scale=0; ($r * 0.7 + $g * 0.3 + $b * 0.0) / 1" | bc)
    local new_b=$(echo "scale=0; ($r * 0.0 + $g * 0.3 + $b * 0.7) / 1" | bc)
    
    echo "$new_r $new_g $new_b"
}

# Tritanopia (blue-blind) - Missing S-cones
# Very rare, affects ~0.01% of population
simulate_tritanopia() {
    local r="$1"
    local g="$2"
    local b="$3"
    
    # Approximate conversion for tritanopia
    local new_r=$(echo "scale=0; ($r * 0.95 + $g * 0.05 + $b * 0.0) / 1" | bc)
    local new_g=$(echo "scale=0; ($r * 0.0 + $g * 0.433 + $b * 0.567) / 1" | bc)
    local new_b=$(echo "scale=0; ($r * 0.0 + $g * 0.475 + $b * 0.525) / 1" | bc)
    
    echo "$new_r $new_g $new_b"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Color Conversion Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
    
    # Clamp values to valid range
    new_r=$(echo "if ($new_r < 0) 0 else if ($new_r > 255) 255 else $new_r" | bc)
    new_g=$(echo "if ($new_g < 0) 0 else if ($new_g > 255) 255 else $new_g" | bc)
    new_b=$(echo "if ($new_b < 0) 0 else if ($new_b > 255) 255 else $new_b" | bc)
    
    # Convert back to hex
    rgb_to_hex "${new_r%.*}" "${new_g%.*}" "${new_b%.*}"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Palette Processing
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
    local output_file="$2"
    
    echo "=== $sim_type Simulation ===" > "$output_file"
    echo "" >> "$output_file"
    
    while IFS= read -r line; do
        local hex=$(echo "$line" | awk '{print $1}')
        local desc=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')
        
        local simulated_hex=$(process_color "$hex" "$sim_type")
        
        echo "- **$desc**" >> "$output_file"
        echo "  - Original: \`$hex\`" >> "$output_file"
        echo "  - Simulated: \`$simulated_hex\`" >> "$output_file"
        echo "" >> "$output_file"
    done < <(extract_colors)
}

# Generate JSON output with simulated colors
generate_json() {
    local sim_type="$1"
    local output_file="$2"
    
    # Start JSON object
    echo "{" > "$output_file"
    echo "  \"simulation_type\": \"$sim_type\"," >> "$output_file"
    echo "  \"generated_at\": \"$(date -Iseconds)\"," >> "$output_file"
    echo "  \"colors\": {" >> "$output_file"
    
    local first=true
    while IFS= read -r line; do
        local hex=$(echo "$line" | awk '{print $1}')
        local desc=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')
        
        local simulated_hex=$(process_color "$hex" "$sim_type")
        
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        
        echo -n "    \"$desc\": {\"original\": \"$hex\", \"simulated\": \"$simulated_hex\"}" >> "$output_file"
    done < <(extract_colors)
    
    echo "" >> "$output_file"
    echo "  }" >> "$output_file"
    echo "}" >> "$output_file"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main Execution
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Test simulation with sample colors
test_simulation() {
    echo "=== Color Blindness Simulation Test ==="
    echo ""
    
    local red="#ff1a67"
    local green="#42ff97"
    local blue="#29adff"
    local purple="#7c60d1"
    
    for type in protanopia deuteranopia tritanopia; do
        echo "--- $type ---"
        echo "Red ($red) -> $(process_color "$red" "$type")"
        echo "Green ($green) -> $(process_color "$green" "$type")"
        echo "Blue ($blue) -> $(process_color "$blue" "$type")"
        echo "Purple ($purple) -> $(process_color "$purple" "$type")"
        echo ""
    done
}

# Simulate all colors for a specific type
simulate_all_colors() {
    local sim_type="$1"
    
    echo "=== $sim_type Simulation for Violet Void Palette ==="
    echo ""
    
    while IFS= read -r line; do
        local hex=$(echo "$line" | awk '{print $1}')
        local desc=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')
        
        local simulated_hex=$(process_color "$hex" "$sim_type")
        
        printf "%-30s %s -> %s\n" "$desc" "$hex" "$simulated_hex"
    done < <(extract_colors)
}

# Generate all output files
generate_all_outputs() {
    mkdir -p "$OUTPUT_DIR"
    
    for type in protanopia deuteranopia tritanopia; do
        local md_file="${OUTPUT_DIR}/${type}-simulation.md"
        local json_file="${OUTPUT_DIR}/${type}-simulation.json"
        
        echo "Generating $type simulation..."
        generate_report "$type" "$md_file"
        generate_json "$type" "$json_file"
    done
    
    echo ""
    echo "Output files generated in $OUTPUT_DIR:"
    ls -lh "$OUTPUT_DIR"
}

# Main function
main() {
    local action="${1:-all}"
    
    case "$action" in
        test)
            test_simulation
            ;;
        protanopia|deuteranopia|tritanopia)
            simulate_all_colors "$action"
            ;;
        generate)
            generate_all_outputs
            ;;
        all)
            echo "=== Color Blindness Simulation for Violet Void Theme ==="
            echo ""
            for type in protanopia deuteranopia tritanopia; do
                simulate_all_colors "$type"
                echo ""
            done
            ;;
        *)
            echo "Violet Void Color Blindness Simulation Tool"
            echo ""
            echo "Usage: $0 [test|protanopia|deuteranopia|tritanopia|generate|all]"
            echo ""
            echo "Options:"
            echo "  test         - Run a test simulation with sample colors"
            echo "  protanopia   - Simulate red-blind vision (affects ~1% of males)"
            echo "  deuteranopia - Simulate green-blind vision (affects ~1% of males)"
            echo "  tritanopia   - Simulate blue-blind vision (very rare)"
            echo "  generate     - Generate output files (Markdown and JSON)"
            echo "  all          - Run all simulations (default)"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
