# Culori Investigation for Violet Void

> Investigation of [culori](https://culorijs.org/) for advanced color manipulation in Violet Void theme tools.

## Overview

Culori is a comprehensive color library for JavaScript with support for 50+ color spaces. It provides better color interpolation than manual HSL/RGB calculations and could significantly improve Violet Void's palette generation tools.

## Key Features

### Color Spaces Supported

- **RGB variants**: sRGB, Linear RGB, Adobe RGB, ProPhoto RGB, Display P3
- **HSL/HSV**: HSL, HSV, HSI, HWB
- **CIE spaces**: XYZ, Lab (D50/D65), LCH, OKLab, OKLCH
- **Others**: Cubehelix, DIN99, HCG, LRGB, Yiq, and more

### Why OKLCH/OKLab Matters

Traditional HSL interpolation can produce unexpected results:
- Colors may appear to shift in brightness unexpectedly
- Middle colors can look "muddy" or desaturated
- Not perceptually uniform

OKLCH/OKLab solves this by:
- Providing perceptually uniform color interpolation
- Maintaining consistent perceived brightness
- Producing natural-looking gradients

## Potential Violet Void Applications

### 1. Upgrade `tint-shade-generator`

Current approach uses HSL manipulation which can produce uneven tints/shades:

```javascript
// Current (HSL-based) - can produce uneven results
const tint = (color, amount) => {
  const hsl = hexToHSL(color);
  hsl.l = Math.min(100, hsl.l + amount);
  return hslToHex(hsl);
};

// With culori (OKLCH-based) - perceptually uniform
import { formatHex, oklch, parse } from 'culori';

const tint = (color, amount) => {
  const c = oklch(parse(color));
  c.l = Math.min(1, c.l + amount);
  return formatHex(c);
};
```

### 2. Improved Color Harmonies

Generate perceptually accurate complementary, analogous, and triadic colors:

```javascript
import { formatHex, oklch, parse } from 'culori';

const complementary = (hex) => {
  const c = oklch(parse(hex));
  c.h = (c.h + 180) % 360;
  return formatHex(c);
};

const analogous = (hex, steps = 3) => {
  const c = oklch(parse(hex));
  return Array.from({ length: steps }, (_, i) => {
    const clone = { ...c };
    clone.h = (c.h + (i - 1) * 30) % 360;
    return formatHex(clone);
  });
};
```

### 3. Better Gradient Generation

Create smooth, perceptually uniform gradients for theme previews:

```javascript
import { interpolate, oklch, parse, formatHex } from 'culori';

const gradient = (start, end, steps) => {
  const interpolator = interpolate([parse(start), parse(end)])(oklch);
  return Array.from({ length: steps }, (_, i) => 
    formatHex(interpolator(i / (steps - 1)))
  );
};
```

### 4. WCAG Contrast with Perceptual Brightness

More accurate contrast calculations using perceptual lightness:

```javascript
import { oklch, parse } from 'culori';

const perceivedLightness = (hex) => oklch(parse(hex)).l;
const hasGoodContrast = (fg, bg) => 
  Math.abs(perceivedLightness(fg) - perceivedLightness(bg)) > 0.5;
```

## Integration Recommendations

### Short Term

1. **Add culori as optional dependency** to package.json
2. **Create wrapper script** `tools/culori-helpers.js` with common operations
3. **Update tint-shade-generator** to use OKLCH when culori is available

### Medium Term

1. **Add palette harmony generator** using culori's interpolation
2. **Create gradient preview tool** for documentation
3. **Add OKLCH values to palette documentation** for better tooling support

### Long Term

1. **Migrate all color tools** to culori-based implementations
2. **Export OKLCH values** in style-dictionary output formats
3. **Create browser-based palette visualizer** using culori

## Installation

```bash
npm install culori
# or
yarn add culori
```

## Browser Support

Culori works in all modern browsers and Node.js. No dependencies.

## API Highlights

```javascript
import {
  parse,           // Parse any color format
  formatHex,       // Output as #rrggbb
  formatRgb,       // Output as rgb()
  formatHsl,       // Output as hsl()
  oklch,           // Convert to OKLCH
  oklab,           // Convert to OKLab
  interpolate,     // Interpolate between colors
  mixer,           // Create color mixers
  displayable,     // Check if color is displayable
  clampChroma,     // Clamp to displayable gamut
  wcagContrast,    // Calculate WCAG contrast ratio
} from 'culori';
```

## Comparison with Alternatives

| Feature | culori | color.js | d3-color | chroma.js |
|---------|--------|----------|----------|-----------|
| OKLCH support | ✅ | ✅ | ❌ | ❌ |
| OKLab support | ✅ | ✅ | ❌ | ❌ |
| Zero deps | ✅ | ❌ | ✅ | ❌ |
| Tree-shakeable | ✅ | ❌ | ✅ | ❌ |
| Size (min) | ~8KB | ~50KB | ~4KB | ~50KB |

## Conclusion

Culori is an excellent choice for Violet Void's color manipulation needs:
- **Small footprint** (~8KB minified)
- **Modern color spaces** (OKLCH, OKLab)
- **Perceptually uniform** interpolation
- **Well-maintained** and documented
- **Zero dependencies**

Recommended for upgrading the tint-shade-generator and adding harmony generation tools.

## References

- [Culori Documentation](https://culorijs.org/)
- [Culori GitHub](https://github.com/Evercoder/culori)
- [OKLCH Color Space](https://oklch.com/)
- [Perceptual Color Interpolation](https://www.vis4.net/blog/2013/09/mastering-multi-hued-color-scales/)
