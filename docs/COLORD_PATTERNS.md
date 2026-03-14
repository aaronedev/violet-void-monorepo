# Colord Patterns for Violet Void

> Investigation of colord for high-performance color manipulation in palette tools

## Overview

[Colord](https://github.com/omgovich/colord) is a tiny (1.5KB gzipped) yet powerful color manipulation library. It's significantly faster than chroma-js and culori for common operations, making it ideal for performance-critical palette transformations.

## Installation

```bash
npm install colord
# or
yarn add colord
```

## Key Features for Theme Development

### 1. Color Space Support

```javascript
import { colord, extend } from 'colord';
import a11yPlugin from 'colord/plugins/a11y';
import namesPlugin from 'colord/plugins/names';
import harmoniesPlugin from 'colord/plugins/harmonies';

extend([a11yPlugin, namesPlugin, harmoniesPlugin]);

// Convert between color spaces
const purple = colord('#7c60d1');
purple.toHsl();    // { h: 263, s: 51, l: 60 }
purple.toLab();    // { l: 52, a: 25, b: -40 }
purple.toOklch();  // { l: 0.64, c: 0.14, h: 293 }
```

### 2. High Performance

Colord is optimized for speed:
- **1.5KB gzipped** - much smaller than chroma-js (~30KB)
- **Tree-shakeable** - only import what you need
- **Zero dependencies** - no external dependencies

### 3. Accessibility Plugin

```javascript
import { colord } from 'colord';
import a11yPlugin from 'colord/plugins/a11y';

extend([a11yPlugin]);

// Check contrast ratio
colord('#7c60d1').contrast('#ffffff'); // 7.21 (AAA)

// Find accessible color variant
colord('#7c60d1').a11y('AA'); // Returns variant meeting AA standard

// WCAG compliance checking
colord('#7c60d1').isReadable('#ffffff'); // true
```

### 4. Names Plugin

```javascript
import { colord } from 'colord';
import namesPlugin from 'colord/plugins/names';

extend([namesPlugin]);

// Get closest color name
colord('#7c60d1').toName(); // "mediumpurple"

// Check if color has a name
colord('#ff0000').toName(); // "red"
```

### 5. Harmonies Plugin

```javascript
import { colord } from 'colord';
import harmoniesPlugin from 'colord/plugins/harmonies';

extend([harmoniesPlugin]);

// Generate color harmonies
colord('#7c60d1').harmonies('complementary');
colord('#7c60d1').harmonies('triadic');
colord('#7c60d1').harmonies('analogous');
```

## Use Cases for Violet Void

### 1. Upgrade Tint-Shade Generator

Replace manual HSL calculations with colord for perceptually uniform tints/shades:

```javascript
// Current (HSL-based, perceptually uneven)
const tint = adjustLuminance(hex, 0.1);

// Better (colord, perceptually uniform)
const tint = colord(hex).lighten(0.1).toHex();
```

### 2. Accessibility Validator

Enhance existing WCAG contrast checking:

```javascript
// Quick contrast check
const ratio = colord(bg).contrast(fg);

// Get compliant variant
const accessibleFg = colord(bg).a11y('AA').toHex();
```

### 3. Color Name Resolution

Complement existing color-name-lookup.sh:

```javascript
// Node.js integration
const colorName = colord(hex).toName();
```

## Comparison with Alternatives

| Feature | colord | chroma-js | culori |
|---------|--------|-----------|--------|
| Size | 1.5KB | ~30KB | ~8KB |
| Dependencies | 0 | 0 | 0 |
| OKLCH/OKLab | ✅ | ✅ | ✅ |
| Plugins | ✅ | ❌ | ❌ |
| Tree-shakeable | ✅ | Partial | ✅ |
| Performance | Fastest | Medium | Fast |

## Recommendations

1. **Use colord for new palette tools** - Better performance for CLI tools
2. **Keep chroma-js for complex operations** - More features for advanced color manipulations
3. **Create colord-based contrast validator** - Fast accessibility checks
4. **Add to package.json** for future tool development

## Implementation Priority

- **Low** - Existing tools work fine with chroma-js
- **Nice to have** - For performance-critical operations
- **Consider**: Replace batch operations with colord for speed

## Links

- GitHub: https://github.com/omgovich/colord
- npm: colord
- Documentation: https://colord.omgovich.com/
