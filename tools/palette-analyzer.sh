#!/usr/bin/env bash
#
# Violet Void Palette Analyzer
# Analyzes colors.json to provide comprehensive statistics
#

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

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

echo "🎨 Violet Void Palette Analysis"
echo "==============================="

echo "Extracting colors..."
BGS=$(jq -r '.color.background | to_entries[] | "\(.key): \(.value.value)"' "$COLORS_FILE")
FGS=$(jq -r '.color.foreground | to_entries[] | "\(.key): \(.value.value)"' "$COLORS_FILE")
ACCENTS=$(jq -r '.color.accent | to_entries[] | .key as $group | .value | to_entries[] | "\($group)-\(.key): \(.value.value)"' "$COLORS_FILE")

echo -e "\n📊 Color Formats & Conversions (Accents)"
echo "-------------------------------"
echo "$ACCENTS" | while IFS=": " read -r name hex; do
    echo "Color: $name ($hex)"
    pastel format hsl "$hex" | sed 's/^/  HSL: /'
    pastel format lch "$hex" | sed 's/^/  LCH: /'
done

echo -e "\n🌓 Contrast Check (Base Background vs Foregrounds)"
echo "----------------------------------------------"
BG_BASE=$(jq -r '.color.background.base.value' "$COLORS_FILE")
echo "$FGS" | while IFS=": " read -r name hex; do
    echo -n "Base BG ($BG_BASE) vs $name ($hex): "
    pastel contrast "$BG_BASE" "$hex" | head -n 1 || true
done

echo -e "\nDone."