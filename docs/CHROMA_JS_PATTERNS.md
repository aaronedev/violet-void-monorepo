# Chroma.js Patterns for Violet Void

> Investigation of chroma-js for advanced color manipulation in palette tools

## Overview

[Chroma.js](https://gka.github.io/chroma.js/) is a powerful JavaScript library for color conversions and manipulations. It provides professional-grade color operations that could significantly enhance Violet Void's palette tools.

## Installation

```bash
npm install chroma-js
# or
yarn add chroma-js
```

## Key Features for Theme Development

### 1. Color Space Conversions

```javascript
const chroma = require('chroma-js');

// Convert between color spaces
const purple = chroma('#7c60d1');
purple.hsl();    // [263, 51, 60]
purple.lab();    // [52, 25, -40]
purple.oklch();  // [0.64, 0.14, 293]
```

### 2. Perceptually Uniform Interpolation

Unlike HSL interpolation, chroma-js can interpolate in perceptually uniform spaces:

```javascript
// Create smooth gradients in Lab space
const gradient = chroma.scale(['#7c60d1', '#1a0f2e'])
  .mode('lab')
  .colors(10);

// OKLCH for even better perceptual uniformity
const oklchGradient = chroma.scale(['#7c60d1', '#1a0f2e'])
  .mode('oklch')
  .colors(10);
```

### 3. Color Mixing and Blending

```javascript
// Mix colors
const mixed = chroma.mix('#7c60d1', '#00d9ff', 0.5, 'lab');

// Blend modes
const multiplied = chroma.blend('#7c60d1', '#1a0f2e', 'multiply');
const screened = chroma.blend('#7c60d1', '#00d9ff', 'screen');
```

### 4. Contrast Calculation

```javascript
// WCAG contrast ratio
const contrast = chroma.contrast('#7c60d1', '#1a0f2e');
// Returns contrast ratio (e.g., 8.5)

// Check WCAG compliance
const isAccessible = contrast >= 4.5; // AA large text
const isAAA = contrast >= 7;          // AAA normal text
```

### 5. Tint and Shade Generation

```javascript
// Generate tints (lighter)
function generateTints(baseColor, steps = 10) {
  const base = chroma(baseColor);
  const white = chroma('white');
  return chroma.scale([white, base])
    .mode('lab')
    .colors(steps);
}

// Generate shades (darker)
function generateShades(baseColor, steps = 10) {
  const base = chroma(baseColor);
  const black = chroma('black');
  return chroma.scale([base, black])
    .mode('lab')
    .colors(steps);
}

// Full scale (tints + shades)
function generateScale(baseColor, steps = 11) {
  return chroma.scale(['white', baseColor, 'black'])
    .mode('oklch')
    .colors(steps);
}
```

### 6. Color Harmony Detection

```javascript
// Complementary color
const complement = chroma('#7c60d1').set('hsl.h', '+180');

// Analogous colors
const analogous = [
  chroma('#7c60d1'),
  chroma('#7c60d1').set('hsl.h', '-30'),
  chroma('#7c60d1').set('hsl.h', '+30')
];

// Triadic colors
const triadic = [
  chroma('#7c60d1'),
  chroma('#7c60d1').set('hsl.h', '+120'),
  chroma('#7c60d1').set('hsl.h', '+240')
];
```

### 7. Color Temperature Analysis

```javascript
// Estimate color temperature (warm/cool)
function getTemperature(color) {
  const [h, s, l] = chroma(color).hsl();
  
  // Warm colors: 0-60 (red-yellow) and 300-360 (magenta-red)
  // Cool colors: 60-300 (green-cyan-blue-purple)
  if ((h >= 0 && h < 60) || (h >= 300 && h <= 360)) {
    return 'warm';
  } else {
    return 'cool';
  }
}
```

## Recommendations for Violet Void

### 1. Upgrade tint-shade-generator.sh

Replace manual HSL calculations with chroma-js for perceptually uniform gradients:

```javascript
// tools/tint-shade-chroma.js
const chroma = require('chroma-js');
const palette = require('../tokens/colors.json');

function generatePaletteScale(baseColor, name) {
  return chroma.scale(['#ffffff', baseColor, '#000000'])
    .mode('oklch')
    .colors(11)
    .map((color, i) => ({
      name: `${name}-${i * 100}`,
      hex: color.hex()
    }));
}
```

### 2. Create Harmony Generator Tool

```javascript
// tools/harmony-generator.js
function generateHarmonies(baseColor) {
  const base = chroma(baseColor);
  return {
    complementary: base.set('hsl.h', '+180').hex(),
    analogous: [
      base.set('hsl.h', '-30').hex(),
      base.hex(),
      base.set('hsl.h', '+30').hex()
    ],
    triadic: [
      base.hex(),
      base.set('hsl.h', '+120').hex(),
      base.set('hsl.h', '+240').hex()
    ],
    splitComplementary: [
      base.hex(),
      base.set('hsl.h', '+150').hex(),
      base.set('hsl.h', '+210').hex()
    ]
  };
}
```

### 3. Add Contrast Validation Tool

```javascript
// tools/contrast-validator.js
function validatePaletteContrast(palette) {
  const results = [];
  
  for (const [fgName, fgColor] of Object.entries(palette.foregrounds)) {
    for (const [bgName, bgColor] of Object.entries(palette.backgrounds)) {
      const ratio = chroma.contrast(fgColor, bgColor);
      results.push({
        foreground: fgName,
        background: bgName,
        ratio: ratio.toFixed(2),
        aa: ratio >= 4.5,
        aaa: ratio >= 7
      });
    }
  }
  
  return results;
}
```

## Comparison with Alternatives

| Feature | chroma-js | culori | pastel (CLI) |
|---------|-----------|--------|--------------|
| Size | ~13KB | ~8KB | CLI tool |
| Color spaces | 10+ | 50+ | Limited |
| Interpolation | ✅ | ✅ | ✅ |
| Contrast calc | ✅ | ❌ | ✅ |
| Blending | ✅ | ❌ | ❌ |
| Learning curve | Low | Medium | CLI-based |

## Conclusion

Chroma.js is an excellent choice for Violet Void because:
1. **Simple API** - Easy to integrate into existing tools
2. **Perceptual interpolation** - OKLCH/Lab modes for natural gradients
3. **Built-in contrast** - No need for separate WCAG calculation
4. **Small footprint** - ~13KB minified, suitable for CI/CD

**Recommended Priority**: High
**Use Case**: Upgrade tint-shade-generator and add harmony generation tools

## Next Steps

1. Add chroma-js as a dev dependency
2. Create `tools/tint-shade-chroma.js` for improved palette generation
3. Create `tools/harmony-generator.js` for color harmony analysis
4. Update CI/CD to use chroma-js for contrast validation
5. Document API patterns for future tool development
