#!/usr/bin/env bash
# Generate themed code screenshots using Ray API (ray.tinte.dev)
# Usage: ./tools/generate-screenshots.sh [output-dir]
#
# This tool uses the free Ray API from tinte.dev to generate code screenshots
# with Violet Void-inspired colors. The API supports 500+ syntax themes and
# 16 languages with PNG/SVG export.
#
# Requirements:
# - curl
# - jq
#
# API Docs: https://ray.tinte.dev/docs
# Rate limit: 60 req/min, no auth required

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${1:-$MONOREPO_ROOT/assets/screenshots}"

# Ray API endpoint
RAY_API="https://ray.tinte.dev/api/v1"

# Violet Void-inspired theme (closest match from Ray's 500+ themes)
# Using "one-hunter" as base - a dark purple theme similar to Violet Void
# For custom themes, we'd need to use tinte.dev to create one
DEFAULT_THEME="one-hunter"

# Supported languages
LANGUAGES=(
  "javascript"
  "typescript"
  "python"
  "rust"
  "go"
  "bash"
  "css"
  "html"
  "json"
  "markdown"
)

# Code samples for each language
declare -A CODE_SAMPLES

CODE_SAMPLES[javascript]='// Violet Void Theme Demo
const palette = {
  background: "#1a1625",
  foreground: "#f0f0f5",
  accent: "#7c60d1",
  cyan: "#6bd4d4",
  magenta: "#d16ba5"
};

function applyTheme(colors) {
  return Object.entries(colors)
    .map(([key, value]) => `--${key}: ${value}`)
    .join(";\n");
}

export { palette, applyTheme };'

CODE_SAMPLES[typescript]='// Violet Void - TypeScript Example
interface ColorToken {
  name: string;
  hex: string;
  rgb: [number, number, number];
}

type ThemeVariant = "dark" | "light" | "darker";

const createToken = (
  name: string,
  hex: string
): ColorToken => ({
  name,
  hex,
  rgb: hexToRgb(hex) as [number, number, number]
});

const theme: Record<ThemeVariant, ColorToken[]> = {
  dark: [],
  light: [],
  darker: []
};'

CODE_SAMPLES[python]='# Violet Void Theme - Python Example
from dataclasses import dataclass
from typing import Optional

@dataclass
class Color:
    """Represents a color in multiple formats."""
    name: str
    hex: str
    rgb: tuple[int, int, int]
    
    def to_hsl(self) -> tuple[float, float, float]:
        """Convert RGB to HSL color space."""
        r, g, b = [x / 255 for x in self.rgb]
        # ... conversion logic
        return (0.0, 0.0, 0.0)

class Palette:
    """Violet Void color palette."""
    backgrounds = ["#1a1625", "#12101a", "#0d0b12"]
    accents = ["#7c60d1", "#6bd4d4", "#d16ba5"]'

CODE_SAMPLES[rust]='// Violet Void Theme - Rust Example
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct Color {
    pub name: String,
    pub hex: String,
    pub rgb: (u8, u8, u8),
}

impl Color {
    pub fn new(name: &str, hex: &str) -> Self {
        let rgb = Self::hex_to_rgb(hex);
        Self {
            name: name.to_string(),
            hex: hex.to_string(),
            rgb,
        }
    }
    
    fn hex_to_rgb(hex: &str) -> (u8, u8, u8) {
        // Parse hex color
        (0, 0, 0)
    }
}'

CODE_SAMPLES[go]='// Violet Void Theme - Go Example
package violetvoid

type Color struct {
    Name string
    Hex  string
    RGB  [3]uint8
}

type Palette struct {
    Backgrounds []Color
    Foregrounds []Color
    Accents     []Color
}

func NewPalette() *Palette {
    return &Palette{
        Backgrounds: []Color{
            {Name: "base", Hex: "#1a1625"},
            {Name: "surface", Hex: "#12101a"},
        },
        Accents: []Color{
            {Name: "purple", Hex: "#7c60d1"},
            {Name: "cyan", Hex: "#6bd4d4"},
        },
    }
}'

CODE_SAMPLES[bash]='#!/usr/bin/env bash
# Violet Void Theme - Bash Example

# Palette colors
VIOLET_BASE="#1a1625"
VIOLET_SURFACE="#12101a"
VIOLET_ACCENT="#7c60d1"
VIOLET_CYAN="#6bd4d4"
VIOLET_MAGENTA="#d16ba5"

apply_theme() {
    local mode="${1:-dark}"
    
    case "$mode" in
        dark)
            echo "Setting dark mode..."
            ;;
        light)
            echo "Light mode not available"
            ;;
    esac
}

main() {
    apply_theme "dark"
}

main "$@"'

CODE_SAMPLES[css]='/* Violet Void Theme - CSS Example */
:root {
  /* Backgrounds */
  --violet-base: #1a1625;
  --violet-surface: #12101a;
  --violet-overlay: #0d0b12;
  
  /* Foregrounds */
  --violet-text: #f0f0f5;
  --violet-muted: #8b8b9e;
  --violet-subtle: #414141;
  
  /* Accents */
  --violet-purple: #7c60d1;
  --violet-cyan: #6bd4d4;
  --violet-magenta: #d16ba5;
}

.theme-violet-void {
  background-color: var(--violet-base);
  color: var(--violet-text);
}'

CODE_SAMPLES[html]='<!DOCTYPE html>
<html lang="en" class="theme-violet-void">
<head>
  <meta charset="UTF-8">
  <title>Violet Void Theme</title>
  <link rel="stylesheet" href="theme.css">
</head>
<body>
  <header class="header">
    <h1>Violet Void Theme</h1>
    <nav class="nav">
      <a href="#features">Features</a>
      <a href="#install">Install</a>
    </nav>
  </header>
  <main class="content">
    <p>A dark purple theme for developers.</p>
  </main>
</body>
</html>'

CODE_SAMPLES[json]='{
  "name": "violet-void",
  "version": "1.0.0",
  "description": "Dark purple theme",
  "colors": {
    "background": {
      "base": "#1a1625",
      "surface": "#12101a",
      "overlay": "#0d0b12"
    },
    "foreground": {
      "text": "#f0f0f5",
      "muted": "#8b8b9e",
      "subtle": "#414141"
    },
    "accent": {
      "purple": "#7c60d1",
      "cyan": "#6bd4d4",
      "magenta": "#d16ba5"
    }
  }
}'

CODE_SAMPLES[markdown]='# Violet Void Theme

A dark purple theme for developers who love purple.

## Features

- **Dark backgrounds**: Easy on the eyes
- **Purple accents**: Beautiful violet tones
- **High contrast**: WCAG compliant

## Installation

```bash
# Install via npm
npm install violet-void-theme

# Or clone the repository
git clone https://github.com/user/violet-void
```

## Color Palette

| Name     | Hex       | Usage           |
|----------|-----------|-----------------|
| Base     | `#1a1625` | Background      |
| Surface  | `#12101a` | Cards, panels   |
| Accent   | `#7c60d1` | Links, buttons  |'

# Generate screenshot for a single code sample
generate_screenshot() {
    local language="$1"
    local code="$2"
    local output_file="$3"
    local theme="${4:-$DEFAULT_THEME}"
    
    echo "Generating screenshot for $language..."
    
    # Escape the code for JSON
    local escaped_code
    escaped_code=$(echo "$code" | jq -Rs '.')
    
    # Make API request
    local response
    response=$(curl -s -X POST "$RAY_API/screenshot" \
        -H "Content-Type: application/json" \
        -d "{\"code\": $escaped_code, \"language\": \"$language\", \"theme\": \"$theme\"}" \
        --output "$output_file" \
        -w "%{http_code}")
    
    if [[ "$response" == "200" ]]; then
        echo "✓ Generated: $output_file"
        return 0
    else
        echo "✗ Failed to generate screenshot for $language (HTTP $response)"
        return 1
    fi
}

# Generate all screenshots
generate_all() {
    mkdir -p "$OUTPUT_DIR"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Violet Void Theme Screenshot Generator"
    echo "  Using Ray API (ray.tinte.dev)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    local success=0
    local failed=0
    
    for lang in "${LANGUAGES[@]}"; do
        local output_file="$OUTPUT_DIR/violet-void-${lang}.png"
        
        if generate_screenshot "$lang" "${CODE_SAMPLES[$lang]}" "$output_file" "$DEFAULT_THEME"; then
            ((success++))
        else
            ((failed++))
        fi
        
        # Rate limiting: wait 1 second between requests
        sleep 1
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Summary: $success succeeded, $failed failed"
    echo "  Output: $OUTPUT_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Extract theme from an image
extract_theme() {
    local image_path="$1"
    local output_file="${2:-$OUTPUT_DIR/extracted-theme.json}"
    
    echo "Extracting theme from $image_path..."
    
    # Convert image to base64
    local image_base64
    image_base64=$(base64 -w 0 "$image_path")
    
    # Make API request
    curl -s -X POST "$RAY_API/extract-theme" \
        -H "Content-Type: application/json" \
        -d "{\"image\": \"data:image/png;base64,$image_base64\"}" \
        -o "$output_file"
    
    echo "✓ Theme extracted to: $output_file"
}

# Generate a hero screenshot for README
generate_hero() {
    local output_file="$OUTPUT_DIR/violet-void-hero.png"
    
    # Create a multi-file hero shot
    local hero_code='// Violet Void Theme
// A dark purple theme for developers

const colors = {
  base: "#1a1625",    // Deep purple-black
  surface: "#12101a", // Elevated surfaces
  text: "#f0f0f5",    // Primary text
  purple: "#7c60d1",  // Primary accent
  cyan: "#6bd4d4",    // Secondary accent
  magenta: "#d16ba5"  // Tertiary accent
};

export default colors;'

    generate_screenshot "javascript" "$hero_code" "$output_file" "$DEFAULT_THEME"
    echo "✓ Hero screenshot generated: $output_file"
}

# Main
case "${1:-all}" in
    all)
        generate_all
        ;;
    hero)
        generate_hero
        ;;
    extract)
        shift
        extract_theme "$@"
        ;;
    single)
        shift
        lang="${1:-javascript}"
        output="${2:-$OUTPUT_DIR/violet-void-${lang}.png}"
        generate_screenshot "$lang" "${CODE_SAMPLES[$lang]}" "$output" "$DEFAULT_THEME"
        ;;
    list)
        echo "Available languages:"
        printf '  - %s\n' "${LANGUAGES[@]}"
        ;;
    *)
        echo "Usage: $0 [all|hero|extract <image>|single <lang>|list] [output-dir]"
        echo ""
        echo "Commands:"
        echo "  all           Generate screenshots for all languages"
        echo "  hero          Generate hero screenshot for README"
        echo "  extract       Extract theme colors from an image"
        echo "  single <lang> Generate screenshot for specific language"
        echo "  list          List available languages"
        exit 1
        ;;
esac
