#!/usr/bin/env bash
# color-sorter.sh - Sort palette colors by hue, saturation, or luminosity
#
# Usage:
#   ./tools/color-sorter.sh [hue|sat|lum|chroma] [json|css|md]
#   ./tools/color-sorter.sh hue json     # Sort by hue, output JSON
#   ./tools/color-sorter.sh sat md       # Sort by saturation, output Markdown
#   ./tools/color-sorter.sh lum css      # Sort by luminosity, output CSS
#   ./tools/color-sorter.sh              # Default: sort by hue, output JSON
#
# Description:
#   Sorts Violet Void palette colors for better organization and analysis.
#   Helps identify color gaps and redundancies in the palette.
#
# Dependencies:
#   - jq (for JSON parsing)
#   - pastel (optional, for accurate HSL conversion)
#
# Examples:
#   ./tools/color-sorter.sh hue | jq '.'
#   ./tools/color-sorter.sh sat md > docs/palette-saturation-sorted.md
#   ./tools/color-sorter.sh lum css > assets/css/colors-sorted.css

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PALETTE_FILE="$REPO_ROOT/tokens/colors.json"

# Default options
SORT_BY="${1:-hue}"
OUTPUT_FORMAT="${2:-json}"

# Validate sort option
case "$SORT_BY" in
    hue|sat|lum|chroma|saturation|luminosity)
        ;;
    *)
        echo "Error: Invalid sort option '$SORT_BY'" >&2
        echo "Valid options: hue, sat, lum, chroma, saturation, luminosity" >&2
        exit 1
        ;;
esac

# Validate output format
case "$OUTPUT_FORMAT" in
    json|css|md|markdown)
        ;;
    *)
        echo "Error: Invalid output format '$OUTPUT_FORMAT'" >&2
        echo "Valid options: json, css, md, markdown" >&2
        exit 1
        ;;
esac

# Check for dependencies
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install with: sudo pacman -S jq" >&2
    exit 1
fi

# Function to convert hex to HSL using pastel
# Returns: "hue saturation luminosity"
hex_to_hsl() {
    local hex="$1"
    
    # Use pastel for accurate HSL conversion
    if command -v pastel &>/dev/null; then
        local hsl
        hsl=$(pastel format hsl "$hex" 2>/dev/null)
        # pastel outputs: hsl(0, 100%, 50%)
        # Parse to get: 0 100 50
        hsl=$(echo "$hsl" | sed 's/hsl(//;s/)//;s/%//g' | tr ',' ' ')
        echo "$hsl"
    else
        # Fallback to awk-based conversion
        hex="${hex#\#}"
        
        local r g b
        r=$((16#${hex:0:2}))
        g=$((16#${hex:2:2}))
        b=$((16#${hex:4:2}))
        
        # Use awk for floating point math
        awk -v r="$r" -v g="$g" -v b="$b" 'BEGIN {
            rn = r / 255; gn = g / 255; bn = b / 255
            max = (rn > gn) ? (rn > bn ? rn : bn) : (gn > bn ? gn : bn)
            min = (rn < gn) ? (rn < bn ? rn : bn) : (gn < bn ? gn : bn)
            delta = max - min
            
            lum = (max + min) / 2
            
            if (delta == 0) {
                hue = 0; sat = 0
            } else {
                if (lum < 0.5) sat = delta / (max + min)
                else sat = delta / (2 - max - min)
                
                if (max == rn) hue = 60 * (((gn - bn) / delta) % 6)
                else if (max == gn) hue = 60 * (((bn - rn) / delta) + 2)
                else hue = 60 * (((rn - gn) / delta) + 4)
                
                if (hue < 0) hue += 360
            }
            
            printf "%.2f %.2f %.2f\n", hue, sat * 100, lum * 100
        }'
    fi
}

# Function to get sort key based on mode
get_sort_key() {
    local hue sat lum
    read -r hue sat lum <<< "$1"
    
    case "$SORT_BY" in
        hue)
            echo "$hue"
            ;;
        sat|saturation)
            echo "$sat"
            ;;
        lum|luminosity)
            echo "$lum"
            ;;
        chroma)
            # Chroma = saturation * luminosity (approximation)
            echo "$(echo "scale=2; $sat * $lum / 100" | bc)"
            ;;
    esac
}

# Extract colors from palette
extract_colors() {
    jq -r '
        # Flatten the color structure
        [
            (.color.background | to_entries[] | {name: "bg-\(.key)", value: .value.value, type: "background"}),
            (.color.foreground | to_entries[] | {name: "fg-\(.key)", value: .value.value, type: "foreground"}),
            (.color.accent | to_entries[] | 
                if (.value | has("base")) then
                    if (.value | has("bright")) then
                        {name: "accent-\(.key)-base", value: .value.base.value, type: "accent"},
                        {name: "accent-\(.key)-bright", value: .value.bright.value, type: "accent"}
                    else
                        {name: "accent-\(.key)-base", value: .value.base.value, type: "accent"}
                    end
                else
                    {name: "accent-\(.key)", value: .value.value, type: "accent"}
                end)
        ]
    ' "$PALETTE_FILE"
}

# Main processing
main() {
    # Extract colors
    local colors
    colors=$(extract_colors)
    
    # Build array of colors with HSL values
    declare -a color_data
    while IFS= read -r color; do
        local name value type
        name=$(echo "$color" | jq -r '.name')
        value=$(echo "$color" | jq -r '.value')
        type=$(echo "$color" | jq -r '.type')
        
        local hsl sort_key
        hsl=$(hex_to_hsl "$value")
        sort_key=$(get_sort_key "$hsl")
        
        color_data+=("$sort_key|$name|$value|$type|$hsl")
    done < <(echo "$colors" | jq -c '.[]')
    
    # Sort by sort key
    IFS=$'\n' sorted=($(sort -t'|' -k1 -n <<< "${color_data[*]}"))
    unset IFS
    
    # Output based on format
    case "$OUTPUT_FORMAT" in
        json)
            echo "["
            local first=true
            for entry in "${sorted[@]}"; do
                IFS='|' read -r sort_key name value type hsl <<< "$entry"
                read -r hue sat lum <<< "$hsl"
                
                if [[ "$first" == "true" ]]; then
                    first=false
                else
                    echo ","
                fi
                
                printf '  {"name": "%s", "hex": "%s", "type": "%s", "hue": %s, "saturation": %s, "luminosity": %s}' \
                    "$name" "$value" "$type" "$hue" "$sat" "$lum"
            done
            echo ""
            echo "]"
            ;;
        css)
            echo "/* Violet Void Colors - Sorted by $SORT_BY */"
            echo ":root {"
            for entry in "${sorted[@]}"; do
                IFS='|' read -r sort_key name value type hsl <<< "$entry"
                read -r hue sat lum <<< "$hsl"
                printf '  --%s: %s; /* HSL: %s°, %s%%, %s%% */\n' "$name" "$value" "$hue" "$sat" "$lum"
            done
            echo "}"
            ;;
        md|markdown)
            echo "# Violet Void Palette - Sorted by $SORT_BY"
            echo ""
            echo "| Name | Hex | Type | Hue | Sat | Lum |"
            echo "|------|-----|------|-----|-----|-----|"
            for entry in "${sorted[@]}"; do
                IFS='|' read -r sort_key name value type hsl <<< "$entry"
                read -r hue sat lum <<< "$hsl"
                printf '| %s | `%s` | %s | %s° | %s%% | %s%% |\n' "$name" "$value" "$type" "$hue" "$sat" "$lum"
            done
            ;;
    esac
}

main "$@"
