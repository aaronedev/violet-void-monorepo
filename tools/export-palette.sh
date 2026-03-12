#!/usr/bin/env bash
#
# export-palette.sh - Export Violet Void palette to multiple formats
# Usage: ./export-palette.sh [format]
# Formats: ase, gimp, clr, css, tailwind, all (default: all)
#
# Outputs to: palette/exports/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PALETTE_FILE="$REPO_ROOT/palette/colors.json"
EXPORT_DIR="$REPO_ROOT/palette/exports"
PALETTE_NAME="Violet Void"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

info() { echo -e "${CYAN}ℹ${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }
error() { echo -e "${RED}✗${RESET} $1" >&2; exit 1; }

# Create export directory
mkdir -p "$EXPORT_DIR"

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
    error "jq is required. Install with: sudo pacman -S jq"
fi

# Parse colors from JSON
parse_colors() {
    local group="$1"
    jq -r ".${group} | to_entries[] | \"\(.key) \(.value)\"" "$PALETTE_FILE"
}

# Convert hex to RGB
hex_to_rgb() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r $g $b"
}

# Export to ASE (Adobe Swatch Exchange) - JSON format for conversion
export_ase() {
    local output_file="$EXPORT_DIR/violet-void-ase-colors.json"
    info "Exporting to ASE-compatible JSON format..."
    
    {
        echo "{"
        echo "  \"version\": \"1.0\","
        echo "  \"name\": \"$PALETTE_NAME\","
        echo "  \"groups\": ["
        
        local first_group=true
        
        for group in backgrounds foregrounds accents; do
            if [ "$first_group" = true ]; then
                first_group=false
            else
                echo ","
            fi
            
            echo "    {"
            echo "      \"name\": \"${group^}\","
            echo "      \"colors\": ["
            
            local first_color=true
            while IFS=' ' read -r name hex; do
                if [ "$first_color" = true ]; then
                    first_color=false
                else
                    echo ","
                fi
                
                local rgb
                rgb=$(hex_to_rgb "$hex")
                local r g b
                read -r r g b <<< "$rgb"
                
                # Convert to float 0-1 range
                local r_float=$(awk "BEGIN {printf \"%.6f\", $r/255}")
                local g_float=$(awk "BEGIN {printf \"%.6f\", $g/255}")
                local b_float=$(awk "BEGIN {printf \"%.6f\", $b/255}")
                
                printf "        {\"name\": \"%s\", \"hex\": \"%s\", \"r\": %s, \"g\": %s, \"b\": %s}" \
                    "$name" "$hex" "$r_float" "$g_float" "$b_float"
            done < <(parse_colors "$group")
            
            echo ""
            echo "      ]"
            printf "    }"
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$output_file"
    
    # Create a README for ASE conversion
    cat > "$EXPORT_DIR/README-ASE.md" << 'EOF'
# ASE Format Conversion

The `violet-void-ase-colors.json` file contains color data that can be converted to ASE format using:

## Option 1: Node.js
```bash
npm install ase-utils
# Then use the library to convert JSON to ASE
```

## Option 2: Python
```bash
pip install ase
# Then use the library to convert JSON to ASE
```

## Option 3: Online Tools
Upload the JSON to online ASE converters.

## Manual Import
For Adobe products, you can also manually add colors from:
- `violet-void.clr.json` (macOS Color Picker)
- `violet-void.gpl` (GIMP palette)
EOF
    
    success "Exported to $output_file"
    echo "  See: $EXPORT_DIR/README-ASE.md for conversion instructions"
}

# Export to GIMP palette
export_gimp() {
    local output_file="$EXPORT_DIR/violet-void.gpl"
    info "Exporting to GIMP palette format..."
    
    {
        echo "GIMP Palette"
        echo "Name: $PALETTE_NAME"
        echo "Description: $(jq -r '.description' "$PALETTE_FILE")"
        echo "Columns: 4"
        echo ""
        echo "# Backgrounds"
        while IFS=' ' read -r name hex; do
            local rgb
            rgb=$(hex_to_rgb "$hex")
            echo "$rgb    $name"
        done < <(parse_colors "backgrounds")
        
        echo ""
        echo "# Foregrounds"
        while IFS=' ' read -r name hex; do
            local rgb
            rgb=$(hex_to_rgb "$hex")
            echo "$rgb    $name"
        done < <(parse_colors "foregrounds")
        
        echo ""
        echo "# Accents"
        while IFS=' ' read -r name hex; do
            local rgb
            rgb=$(hex_to_rgb "$hex")
            echo "$rgb    $name"
        done < <(parse_colors "accents")
    } > "$output_file"
    
    success "Exported to $output_file"
}

# Export to CLR (macOS Color Picker) - uses JSON format that can be imported
export_clr() {
    local output_file="$EXPORT_DIR/violet-void.clr.json"
    info "Exporting to CLR format (macOS Color Picker)..."
    
    {
        echo "{"
        echo "  \"name\": \"$PALETTE_NAME\","
        echo "  \"colors\": ["
        
        local first=true
        
        # Process all color groups
        for group in backgrounds foregrounds accents; do
            while IFS=' ' read -r name hex; do
                local rgb
                rgb=$(hex_to_rgb "$hex")
                local r g b
                read -r r g b <<< "$rgb"
                
                if [ "$first" = true ]; then
                    first=false
                else
                    echo ","
                fi
                
                # Convert to 0-1 range for macOS
                local r_norm=$(awk "BEGIN {printf \"%.6f\", $r/255}")
                local g_norm=$(awk "BEGIN {printf \"%.6f\", $g/255}")
                local b_norm=$(awk "BEGIN {printf \"%.6f\", $b/255}")
                
                printf "    {\"name\": \"%s\", \"red\": %s, \"green\": %s, \"blue\": %s}" \
                    "$name" "$r_norm" "$g_norm" "$b_norm"
            done < <(parse_colors "$group")
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$output_file"
    
    success "Exported to $output_file"
    echo "  Import: Use Color Sync Utility or a CLR import tool"
}

# Export to CSS custom properties
export_css() {
    local output_file="$EXPORT_DIR/violet-void-exports.css"
    info "Exporting to CSS custom properties..."
    
    {
        echo "/* Violet Void Theme - Color Palette Exports */"
        echo "/* Generated: $(date -Iseconds) */"
        echo ""
        echo ":root {"
        
        # Process all color groups
        for group in backgrounds foregrounds accents; do
            echo "  /* ${group^} */"
            while IFS=' ' read -r name hex; do
                # Convert camelCase to kebab-case
                local css_name
                css_name=$(echo "$name" | sed 's/\([A-Z]\)/-\L\1/g')
                echo "  --vv-${group}-${css_name}: ${hex};"
            done < <(parse_colors "$group")
            echo ""
        done
        
        echo "}"
    } > "$output_file"
    
    success "Exported to $output_file"
}

# Export to Tailwind config format
export_tailwind() {
    local output_file="$EXPORT_DIR/violet-void.tailwind.js"
    info "Exporting to Tailwind config format..."
    
    {
        echo "// Violet Void Theme - Tailwind Color Config"
        echo "// Generated: $(date -Iseconds)"
        echo ""
        echo "const violetVoid = {"
        
        # Process all color groups
        for group in backgrounds foregrounds accents; do
            echo "  $group: {"
            while IFS=' ' read -r name hex; do
                # Convert camelCase to kebab-case for consistency
                local css_name
                css_name=$(echo "$name" | sed 's/\([A-Z]\)/-\L\1/g')
                echo "    '${css_name}': '${hex}',"
            done < <(parse_colors "$group")
            echo "  },"
        done
        
        echo "};"
        echo ""
        echo "module.exports = violetVoid;"
    } > "$output_file"
    
    success "Exported to $output_file"
}

# Main export function
main() {
    local format="${1:-all}"
    
    info "Exporting Violet Void palette to: $EXPORT_DIR"
    echo ""
    
    case "$format" in
        ase)
            export_ase
            ;;
        gimp|gpl)
            export_gimp
            ;;
        clr)
            export_clr
            ;;
        css)
            export_css
            ;;
        tailwind)
            export_tailwind
            ;;
        all)
            export_gimp
            export_clr
            export_css
            export_tailwind
            export_ase
            ;;
        *)
            error "Unknown format: $format. Use: ase, gimp, clr, css, tailwind, or all"
            ;;
    esac
    
    echo ""
    success "Palette export complete!"
    echo "  Files exported to: $EXPORT_DIR"
    ls -lh "$EXPORT_DIR"
}

# Run main function
main "$@"
