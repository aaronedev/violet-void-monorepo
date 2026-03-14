# Color.js Patterns for Violet Void

> Investigation of colorjs.io for modern color space support in theme development

## Overview

**Color.js** is a modern color library by Lea Verou and Chris Lilley that provides native support for CSS Color Level 4 features, including OKLCH and OKLAB color spaces.

- **Website**: https://colorjs.io/
- **GitHub**: https://github.com/LeaVerou/color.js
- **npm**: colorjs.io
- **Size**: ~15KB minified + gzipped
- **Dependencies**: Zero

## Key Features

### 1. **Modern Color Spaces**

```javascript
import { Color } from "colorjs.io";

// OKLCH (recommended for perceptually uniform gradients)
const oklch = new Color("oklch", [0.7, 0.15, 150]);
console.log(oklch.toString()); // "oklch(70% 0.15 150)"

// OKLAB (perceptually uniform alternative to Lab)
const oklab = new Color("oklab", [0.7, 0.1, 0.05]);

// Also supports: sRGB, Display P3, Rec2020, Lab, LCH, HSL, HSV, etc.
```

### 2. **Color Interpolation**

```javascript
// Perceptually uniform interpolation in OKLCH
const purple = new Color("oklch", [0.5, 0.2, 300]);
const cyan = new Color("oklch", [0.7, 0.15, 195]);

// Generate 5 steps between colors
const steps = purple.steps(cyan, { space: "oklch", steps: 5 });
steps.forEach(c => console.log(c.toString()));
```

### 3. **Contrast Calculation**

```javascript
// WCAG contrast ratio
const bg = new Color("#121212");
const fg = new Color("#e7e7e7");
const contrast = bg.contrast(fg, "WCAG21");
console.log(contrast); // ~14.5
```

### 4. **Color Manipulation**

```javascript
const color = new Color("#7c60d1");

// Lighten/darken in OKLCH (perceptually uniform)
const lighter = color.lighten(0.1);
const darker = color.darken(0.1);

// Modify specific coordinates
const modified = color.set({
  "l": c => c * 1.2, // 20% lighter
  "c": c => c * 0.8, // 20% less chroma
});
```

### 5. **Gamut Mapping**

```javascript
// Map P3 color to sRGB gamut
const p3Color = new Color("color(display-p3 0 1 0)");
const srgbColor = p3Color.toGamut("srgb");
console.log(srgbColor.toString()); // Closest sRGB equivalent
```

### 6. **CSS Color Level 4 Support**

```javascript
// Parse CSS Color Level 4 syntax
const color = new Color("oklch(70% 0.15 150)");
const hwb = new Color("hwb(270 10% 20%)");

// Convert to any format
console.log(color.to("srgb").toString());
console.log(color.to("lch").toString());
console.log(color.to("hsl").toString());
```

## Use Cases for Violet Void

### 1. **Upgrade Tint-Shade Generator**

Current implementation uses HSL for lighten/darken, which isn't perceptually uniform. Color.js with OKLCH would provide better results:

```javascript
// Before (HSL-based)
const lighter = `hsl(${h}, ${s}%, ${Math.min(l + 10, 100)}%)`;

// After (OKLCH-based with Color.js)
const baseColor = new Color(originalHex);
const lighter = baseColor.lighten(0.1).toString({ format: "hex" });
```

### 2. **Perceptually Uniform Color Scales**

Generate color scales that appear uniform to the human eye:

```javascript
function generateScale(startColor, endColor, steps = 10) {
  const start = new Color(startColor);
  const end = new Color(endColor);
  
  return start.steps(end, {
    space: "oklch",
    steps: steps
  }).map(c => c.toString({ format: "hex" }));
}

// Example: Generate 10-step scale from purple to cyan
const scale = generateScale("#7c60d1", "#00fff9", 10);
```

### 3. **Accessibility-First Color Generation**

Generate accessible text colors for given backgrounds:

```javascript
function findAccessibleColor(bgColor, targetContrast = 4.5) {
  const bg = new Color(bgColor);
  let lightness = bg.oklch.l > 0.5 ? 0.2 : 0.9; // Dark or light text
  let fg = new Color("oklch", [lightness, 0, 0]);
  
  // Adjust lightness until we reach target contrast
  while (bg.contrast(fg, "WCAG21") < targetContrast) {
    lightness += bg.oklch.l > 0.5 ? -0.02 : 0.02;
    fg = new Color("oklch", [lightness, 0, 0]);
  }
  
  return fg.toString({ format: "hex" });
}

// Find accessible text color for Violet Void background
const textColor = findAccessibleColor("#121212"); // Returns high-contrast text
```

### 4. **Color Harmony Generation**

Generate color harmonies using OKLCH hue rotation:

```javascript
function generateComplementary(baseColor) {
  const color = new Color(baseColor);
  const h = color.oklch.h;
  
  return [
    color.toString({ format: "hex" }),
    new Color("oklch", [color.oklch.l, color.oklch.c, (h + 180) % 360])
      .toString({ format: "hex" })
  ];
}

function generateTriadic(baseColor) {
  const color = new Color(baseColor);
  const h = color.oklch.h;
  
  return [
    color.toString({ format: "hex" }),
    new Color("oklch", [color.oklch.l, color.oklch.c, (h + 120) % 360])
      .toString({ format: "hex" }),
    new Color("oklch", [color.oklch.l, color.oklch.c, (h + 240) % 360])
      .toString({ format: "hex" })
  ];
}
```

### 5. **Palette Analysis**

Analyze palette characteristics in perceptual color space:

```javascript
function analyzePalette(colors) {
  return colors.map(hex => {
    const color = new Color(hex);
    return {
      hex: hex,
      oklch: {
        lightness: color.oklch.l.toFixed(3),
        chroma: color.oklch.c.toFixed(3),
        hue: color.oklch.h.toFixed(1)
      },
      perceivedLightness: color.oklch.l > 0.5 ? "Light" : "Dark",
      saturation: color.oklch.c > 0.1 ? "High" : color.oklch.c > 0.05 ? "Medium" : "Low"
    };
  });
}
```

## Comparison with Alternatives

| Feature | Color.js | Chroma.js | Culori | Huetiful |
|---------|----------|-----------|--------|----------|
| OKLCH/OKLAB | ✅ Native | ✅ Via plugin | ✅ Native | ✅ Native |
| Size | 15KB | 13.5KB | 8KB | ~10KB |
| Gamut Mapping | ✅ | ✅ | ✅ | ❌ |
| CSS Color 4 | ✅ Full | Partial | ✅ | Partial |
| Contrast | ✅ WCAG | ✅ WCAG | ❌ | ✅ |
| Interpolation | ✅ OKLCH | ✅ Lab | ✅ OKLCH | ✅ OKLCH |
| Learning Curve | Medium | Easy | Medium | Easy |

## Recommendations

1. **Upgrade Tint-Shade Generator**: Replace HSL-based calculations with OKLCH for perceptually uniform gradients
2. **Create Harmony Generator**: Add tool for generating complementary, triadic, and analogous colors
3. **Add Contrast Validator**: Create automated contrast checking using Color.js WCAG functions
4. **Palette Analysis Enhancement**: Use OKLCH coordinates for better palette analysis and categorization
5. **Consider for Future Tools**: Use Color.js as foundation for new palette manipulation tools

## Integration Example

```javascript
// tools/oklch-gradient-generator.js
import { Color } from "colorjs.io";
import fs from "fs";

function generateGradient(startHex, endHex, steps = 10) {
  const start = new Color(startHex);
  const end = new Color(endHex);
  
  const gradient = start.steps(end, {
    space: "oklch",
    steps: steps
  }).map(c => ({
    hex: c.toString({ format: "hex" }),
    oklch: `oklch(${(c.oklch.l * 100).toFixed(1)}% ${c.oklch.c.toFixed(3)} ${c.oklch.h.toFixed(1)})`
  }));
  
  return gradient;
}

// Generate gradient from Violet Void purple to cyan
const gradient = generateGradient("#7c60d1", "#00fff9", 10);
console.log(JSON.stringify(gradient, null, 2));
```

## Conclusion

Color.js is an excellent choice for Violet Void theme development due to:

- **Native OKLCH/OKLAB support** for perceptually uniform color operations
- **CSS Color Level 4 compliance** for future-proof color handling
- **Zero dependencies** and reasonable size (~15KB)
- **WCAG contrast functions** for accessibility validation
- **Gamut mapping** for cross-device color consistency

While alternatives like chroma.js and culori are also excellent, Color.js stands out for its focus on modern CSS color standards and OKLCH-first approach, making it ideal for creating perceptually uniform theme variants.

**Recommendation**: Use Color.js for new palette manipulation tools and consider upgrading existing tools to use OKLCH-based calculations for better perceptual uniformity.
