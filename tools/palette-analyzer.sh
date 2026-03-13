#!/usr/bin/env bash
#
# Violet Void Palette Analyzer
# Analyzes colors.json to provide comprehensive statistics
# - Color harmony analysis (complementary, analogous, triadic, etc.)
# - Color temperature (warm/cool balance)
# - Saturation and brightness distribution
# - Palette statistics and comparisons
#

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Check dependencies
if ! command -v pastel &> /dev/null; then
    echo "Error: 'pastel' command not found. Please install pastel (e.g., sudo pacman -S pastel)"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Please install jq."
    exit 1
fi

COLORS_FILE="tokens/colors.json"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Error: $COLORS_FILE not found."
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Helper function to extract HSL values
get_hsl() {
    local hex="$1"
    pastel format hsl "$hex" 2>/dev/null | sed 's/hsl(\(.*\))/\1/' | tr ',' ' '
}

# Helper function to get hue value
get_hue() {
    local hex="$1"
    local hsl=$(get_hsl "$hex")
    echo "$hsl" | awk '{print int($1)}'
}

# Helper function to get saturation value
get_saturation() {
    local hex="$1"
    local hsl=$(get_hsl "$hex")
    echo "$hsl" | awk '{print int($2)}' | tr -d '%'
}

# Helper function to get lightness value
get_lightness() {
    local hex="$1"
    local hsl=$(get_hsl "$hex")
    echo "$hsl" | awk '{print int($3)}' | tr -d '%'
}

# Determine color temperature (warm/cool)
get_temperature() {
    local hue="$1"
    if (( hue >= 0 && hue < 60 )); then
        echo "warm"      # Red to Yellow
    elif (( hue >= 60 && hue < 150 )); then
        echo "cool"      # Yellow-Green to Green-Cyan
    elif (( hue >= 150 && hue < 270 )); then
        echo "cool"      # Cyan to Blue-Magenta
    else
        echo "warm"      # Magenta to Red
    fi
}

# Get color family
get_color_family() {
    local hue="$1"
    if (( hue >= 0 && hue < 15 )); then
        echo "red"
    elif (( hue >= 15 && hue < 45 )); then
        echo "orange"
    elif (( hue >= 45 && hue < 75 )); then
        echo "yellow"
    elif (( hue >= 75 && hue < 150 )); then
        echo "green"
    elif (( hue >= 150 && hue < 195 )); then
        echo "cyan"
    elif (( hue >= 195 && hue < 255 )); then
        echo "blue"
    elif (( hue >= 255 && hue < 285 )); then
        echo "purple"
    elif (( hue >= 285 && hue < 330 )); then
        echo "magenta"
    else
        echo "red"
    fi
}

echo -e "${BOLD}${MAGENTA}🎨 Violet Void Palette Analysis${RESET}"
echo "================================"
echo ""

# Extract all colors
BGS=$(jq -r '.color.background | to_entries[] | "\(.key): \(.value.value)"' "$COLORS_FILE" 2>/dev/null || echo "")
FGS=$(jq -r '.color.foreground | to_entries[] | "\(.key): \(.value.value)"' "$COLORS_FILE" 2>/dev/null || echo "")
ACCENTS=$(jq -r '.color.accent | to_entries[] | .key as $group | .value | to_entries[] | "\($group)-\(.key): \(.value.value)"' "$COLORS_FILE" 2>/dev/null || echo "")

# Combine all colors for analysis
ALL_COLORS=""
[[ -n "$BGS" ]] && ALL_COLORS+="$BGS"$'\n'
[[ -n "$FGS" ]] && ALL_COLORS+="$FGS"$'\n'
[[ -n "$ACCENTS" ]] && ALL_COLORS+="$ACCENTS"

TOTAL_COUNT=$(echo "$ALL_COLORS" | grep -c ':' || echo 0)

# ─────────────────────────────────────────────────────────────────────────────
# Section 1: Basic Statistics
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}📊 Palette Statistics${RESET}"
echo "--------------------"
echo "Total colors: $TOTAL_COUNT"
echo "Backgrounds: $(echo "$BGS" | grep -c ':' || echo 0)"
echo "Foregrounds: $(echo "$FGS" | grep -c ':' || echo 0)"
echo "Accents: $(echo "$ACCENTS" | grep -c ':' || echo 0)"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 2: Color Temperature Analysis
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${YELLOW}🌡️  Color Temperature Analysis${RESET}"
echo "----------------------------"

WARM_COUNT=0
COOL_COUNT=0
NEUTRAL_COUNT=0

while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    hue=$(get_hue "$hex")
    temp=$(get_temperature "$hue")
    if [[ "$temp" == "warm" ]]; then
        ((WARM_COUNT++))
    else
        ((COOL_COUNT++))
    fi
done <<< "$ACCENTS"

TOTAL_ACCENTS=$(echo "$ACCENTS" | grep -c ':' || echo 0)
if (( TOTAL_ACCENTS > 0 )); then
    WARM_PCT=$((WARM_COUNT * 100 / TOTAL_ACCENTS))
    COOL_PCT=$((COOL_COUNT * 100 / TOTAL_ACCENTS))
    echo "Warm colors:  $WARM_COUNT ($WARM_PCT%)"
    echo "Cool colors:  $COOL_COUNT ($COOL_PCT%)"
    
    if (( WARM_PCT > 60 )); then
        echo "Overall: Warm palette (energetic, vibrant)"
    elif (( COOL_PCT > 60 )); then
        echo "Overall: Cool palette (calm, professional)"
    else
        echo "Overall: Balanced palette"
    fi
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 3: Saturation Distribution
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${GREEN}🎨 Saturation Distribution${RESET}"
echo "-------------------------"

LOW_SAT=0
MED_SAT=0
HIGH_SAT=0

while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    sat=$(get_saturation "$hex")
    if (( sat < 30 )); then
        ((LOW_SAT++))
    elif (( sat < 70 )); then
        ((MED_SAT++))
    else
        ((HIGH_SAT++))
    fi
done <<< "$ALL_COLORS"

echo "Low saturation (<30%):  $LOW_SAT colors (muted, subtle)"
echo "Medium saturation:      $MED_SAT colors (balanced)"
echo "High saturation (>70%): $HIGH_SAT colors (vibrant, bold)"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 4: Brightness Distribution
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${BLUE}☀️  Brightness Distribution${RESET}"
echo "--------------------------"

DARK=0
MEDIUM=0
LIGHT=0

while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    light=$(get_lightness "$hex")
    if (( light < 35 )); then
        ((DARK++))
    elif (( light < 65 )); then
        ((MEDIUM++))
    else
        ((LIGHT++))
    fi
done <<< "$ALL_COLORS"

echo "Dark (<35%):    $DARK colors"
echo "Medium:         $MEDIUM colors"
echo "Light (>65%):   $LIGHT colors"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 5: Color Family Distribution
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${MAGENTA}🌈 Color Family Distribution${RESET}"
echo "----------------------------"

declare -A FAMILIES
while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    hue=$(get_hue "$hex")
    family=$(get_color_family "$hue")
    ((FAMILIES[$family]++)) || FAMILIES[$family]=1
done <<< "$ACCENTS"

# Sort by count
for family in "${!FAMILIES[@]}"; do
    echo "$family:${FAMILIES[$family]}"
done | sort -t: -k2 -nr | while IFS=: read -r family count; do
    printf "%-12s %d colors\n" "$family:" "$count"
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 6: Color Harmony Analysis
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}🎼 Color Harmony Analysis${RESET}"
echo "-------------------------"

# Get unique hue values from accents
HUES=""
while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    hue=$(get_hue "$hex")
    HUES+="$hue "
done <<< "$ACCENTS"

# Check for common harmony patterns
HUES_SORTED=($(echo $HUES | tr ' ' '\n' | sort -n | uniq))

check_harmony() {
    local hues=("$@")
    local count=${#hues[@]}
    
    if (( count < 2 )); then
        echo "Insufficient colors for harmony analysis"
        return
    fi
    
    # Complementary check (180° apart)
    for h1 in "${hues[@]}"; do
        for h2 in "${hues[@]}"; do
            diff=$(( (h2 - h1 + 180) % 360 - 180 ))
            diff=${diff#-}
            if (( diff >= 160 && diff <= 200 )); then
                echo "✓ Complementary pair detected: hues ~$h1° and ~$h2°"
                return
            fi
        done
    done
    
    # Analogous check (30° apart)
    local analogous_count=0
    for h1 in "${hues[@]}"; do
        for h2 in "${hues[@]}"; do
            diff=$(( (h2 - h1 + 180) % 360 - 180 ))
            diff=${diff#-}
            if (( diff <= 30 )); then
                ((analogous_count++))
            fi
        done
    done
    if (( analogous_count >= 3 )); then
        echo "✓ Analogous colors detected (nearby hues)"
    fi
    
    # Triadic check (120° apart)
    for h1 in "${hues[@]}"; do
        local found_triadic=false
        for h2 in "${hues[@]}"; do
            diff1=$(( (h2 - h1 + 180) % 360 - 180 ))
            diff1=${diff1#-}
            if (( diff1 >= 100 && diff1 <= 140 )); then
                for h3 in "${hues[@]}"; do
                    diff2=$(( (h3 - h2 + 180) % 360 - 180 ))
                    diff2=${diff2#-}
                    if (( diff2 >= 100 && diff2 <= 140 )); then
                        echo "✓ Triadic harmony detected"
                        return
                    fi
                done
            fi
        done
    done
}

check_harmony "${HUES_SORTED[@]}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 7: Detailed Accent Color Breakdown
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${YELLOW}📝 Detailed Accent Breakdown${RESET}"
echo "----------------------------"

echo "$ACCENTS" | while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    hue=$(get_hue "$hex")
    sat=$(get_saturation "$hex")
    light=$(get_lightness "$hex")
    family=$(get_color_family "$hue")
    temp=$(get_temperature "$hue")
    
    printf "%-20s %s  H:%3d° S:%3d%% L:%3d%%  [%-8s %s]\n" "$name" "$hex" "$hue" "$sat" "$light" "$family" "$temp"
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 8: WCAG Contrast Summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${GREEN}♿ WCAG Contrast Summary${RESET}"
echo "-----------------------"

BG_BASE=$(jq -r '.color.background.base.value' "$COLORS_FILE" 2>/dev/null || echo "")
if [[ -n "$BG_BASE" ]]; then
    PASS_AA=0
    PASS_AAA=0
    FAIL=0
    
    while IFS=": " read -r name hex; do
        [[ -z "$hex" ]] && continue
        ratio=$(pastel contrast "$BG_BASE" "$hex" 2>/dev/null | head -1 | grep -oP '[\d.]+(?=:1)' || echo "0")
        ratio_int=$(echo "$ratio" | awk '{printf "%.0f", $1}')
        
        if (( ratio_int >= 7 )); then
            ((PASS_AAA++))
        elif (( ratio_int >= 45 )); then
            ((PASS_AA++))
        else
            ((FAIL++))
        fi
    done <<< "$FGS"
    
    echo "AAA (7:1+):   $PASS_AAA colors"
    echo "AA (4.5:1+):  $PASS_AA colors"
    echo "Fail:         $FAIL colors"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Section 9: Comparison with Popular Themes
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}${CYAN}🔍 Theme Characteristics${RESET}"
echo "-----------------------"

# Calculate average saturation and lightness
TOTAL_SAT=0
TOTAL_LIGHT=0
COUNT=0

while IFS=": " read -r name hex; do
    [[ -z "$hex" ]] && continue
    sat=$(get_saturation "$hex")
    light=$(get_lightness "$hex")
    TOTAL_SAT=$((TOTAL_SAT + sat))
    TOTAL_LIGHT=$((TOTAL_LIGHT + light))
    ((COUNT++))
done <<< "$ACCENTS"

if (( COUNT > 0 )); then
    AVG_SAT=$((TOTAL_SAT / COUNT))
    AVG_LIGHT=$((TOTAL_LIGHT / COUNT))
    
    echo "Average saturation: $AVG_SAT%"
    echo "Average lightness:  $AVG_LIGHT%"
    echo ""
    
    # Theme comparison
    echo "Compared to popular themes:"
    echo "  Catppuccin: ~60% sat, ~50% light (pastel, soft)"
    echo "  Nord:       ~45% sat, ~55% light (muted, cool)"
    echo "  Dracula:    ~70% sat, ~60% light (vibrant, bold)"
    
    if (( AVG_SAT > 65 )); then
        echo "  Violet Void: High saturation ($AVG_SAT%) - vibrant palette"
    elif (( AVG_SAT < 45 )); then
        echo "  Violet Void: Low saturation ($AVG_SAT%) - muted palette"
    else
        echo "  Violet Void: Medium saturation ($AVG_SAT%) - balanced palette"
    fi
fi
echo ""

echo -e "${BOLD}${GREEN}✅ Analysis complete${RESET}"
