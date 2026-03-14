# color.io - Browser-Based Palette Visualization

**Investigation Date:** 2026-03-14
**Status:** ✅ Investigated
**Link:** https://color.io/
**Type:** Web-based color tool

## Overview

color.io is a web-based color space visualization and palette analysis tool that provides real-time OKLCH/LCH color picker with gamut mapping and visual color relationship analysis.

## Key Features

### 1. Real-Time Color Space Visualization
- Interactive OKLCH and LCH color pickers
- Real-time gamut mapping and visualization
- Visual representation of color spaces and relationships
- Support for modern color spaces (OKLCH, OKLab, LCH, Lab)

### 2. Palette Analysis
- Visualize color relationships and harmonies interactively
- Gamut mapping for P3 and sRGB displays
- Color contrast and accessibility checking
- Interactive color exploration

### 3. Gamut Mapping
- Visual representation of color gamuts
- P3 and sRGB gamut boundaries
- Out-of-gamut color warnings
- Automatic gamut clipping/mapping

## Use Cases for Violet Void

### 1. Palette Refinement
- **Visual validation:** See palette colors in OKLCH space to ensure perceptual uniformity
- **Color relationship validation:** Verify harmony and balance of accent colors
- **Gamut awareness:** Ensure palette colors are within sRGB/P3 gamuts for consistent display

### 2. Color Education
- **Documentation visuals:** Create screenshots for palette documentation
- **Color theory:** Demonstrate color relationships (complementary, analogous, triadic)
- **Accessibility:** Visualize contrast and color distinguishability

### 3. Variant Generation
- **Inspiration:** Explore similar colors in OKLCH space
- **Harmony discovery:** Find complementary or analogous colors
- **Perceptual uniformity:** Verify tints/shades maintain consistent lightness steps

## How to Use for Violet Void

### 1. Palette Analysis
1. Visit https://color.io/
2. Input Violet Void palette colors (hex or OKLCH)
3. Visualize in OKLCH space
4. Check for perceptual uniformity and harmony

### 2. Gamut Mapping
1. Convert Violet Void colors to OKLCH
2. Check if all colors are within sRGB gamut
3. Identify any out-of-gamut colors
4. Adjust if needed for better display compatibility

### 3. Harmony Exploration
1. Select a base color from Violet Void palette
2. Use color.io's harmony tools
3. Find complementary, analogous, or triadic colors
4. Consider for future palette expansions

## Example: Violet Void Palette in OKLCH

```javascript
// Violet Void primary colors in OKLCH
const violetVoidPalette = {
  purple: { l: 55, c: 80, h: 290 },      // Primary purple
  cyan: { l: 65, c: 70, h: 195 },        // Accent cyan
  magenta: { l: 60, c: 90, h: 330 },     // Accent magenta
  yellow: { l: 80, c: 85, h: 90 },       // Accent yellow
  background: { l: 15, c: 10, h: 270 },  // Dark background
  foreground: { l: 95, c: 5, h: 270 },   // Light foreground
}
```

## Recommendations

### 1. Use for Documentation
- Create visual palette representations for README
- Document color relationships and harmonies
- Show gamut coverage for different displays

### 2. Validate Perceptual Uniformity
- Verify tints/shades have consistent lightness steps
- Ensure accent colors have similar perceived brightness
- Check for color harmony and balance

### 3. Future Palette Development
- Use OKLCH space for new color selection
- Ensure all colors are within sRGB gamut
- Validate accessibility and contrast

### 4. Complement Existing Tools
- Use alongside `pastel` for CLI color manipulation
- Use with `chroma-js` for programmatic color operations
- Use with `palette-analyzer.sh` for automated analysis

## Integration Opportunities

### 1. Palette Validation Script
```bash
#!/bin/bash
# Validate Violet Void palette using color.io concepts
# Check for:
# - Perceptual uniformity (OKLCH lightness consistency)
# - Gamut coverage (sRGB/P3)
# - Color harmony relationships
```

### 2. Documentation Generator
Create visual palette documentation using color.io screenshots:
- Palette in OKLCH space
- Color harmony diagrams
- Gamut coverage visualization
- Contrast checking visualization

### 3. CI/CD Integration
- Validate new palette colors are within gamut
- Check perceptual uniformity of color scales
- Verify accessibility requirements

## Advantages Over Manual Analysis

1. **Visual:** Immediate visual feedback on color relationships
2. **Interactive:** Real-time exploration and adjustment
3. **Modern:** Uses OKLCH/OKLab for perceptual uniformity
4. **Accessible:** Browser-based, no installation required
5. **Educational:** Helps understand color theory concepts

## Limitations

1. **Manual:** Requires manual input and analysis
2. **No automation:** Can't integrate directly into scripts
3. **Browser-only:** Requires web browser access
4. **No export:** Limited export options for palette data

## Conclusion

color.io is an excellent tool for:
- Visual palette validation and refinement
- Color education and documentation
- Inspiration for palette variants
- Understanding color relationships in OKLCH space

For Violet Void, use color.io to:
1. Validate perceptual uniformity of existing palette
2. Create visual documentation assets
3. Explore potential palette variants
4. Educate contributors about color theory

## Next Steps

1. **Document palette in OKLCH:** Convert all Violet Void colors to OKLCH format
2. **Create visual assets:** Generate color.io screenshots for documentation
3. **Validate gamut:** Ensure all colors are within sRGB/P3 gamuts
4. **Explore variants:** Use color.io to find complementary palette options

## Related Tools

- **pastel:** CLI color manipulation (already integrated)
- **chroma-js:** Programmatic color operations (already investigated)
- **culori:** Advanced color space conversions (already investigated)
- **huetiful-js:** Color sorting and harmonies (already integrated)
- **palette-analyzer.sh:** Automated palette analysis (already integrated)

## References

- color.io: https://color.io/
- OKLCH color space: https://oklch.com/
- Color gamut mapping: https://bottosson.github.io/posts/gamutclipping/
