# Huetiful-js Patterns and Integration

> Investigation of huetiful-js for advanced color manipulation in Violet Void theme development.

## Overview

**huetiful-js** is a comprehensive color manipulation library with 50+ functions for advanced color operations. It supports modern color spaces like OKLCH and OKLAB for perceptually uniform color transformations.

- **GitHub**: https://github.com/prjctimg/huetiful
- **npm**: `huetiful-js`
- **Key Feature**: Better perceptual uniformity than HSL-based calculations

## Key Capabilities

### 1. Color Space Support
- OKLCH, OKLAB (perceptually uniform)
- RGB, HSL, HSV
- Lab, LCH
- DIN99 Lab

### 2. Color Sorting and Filtering
```javascript
import { sortByHue, sortByLuminance, filterByContrast } from 'huetiful-js'

// Sort palette by hue
const sorted = sortByHue(palette)

// Sort by luminance (light to dark)
const byLuminance = sortByLuminance(palette)

// Filter by minimum contrast ratio
const accessible = filterByContrast('#000000', palette, 4.5)
```

### 3. Color Interpolation
```javascript
import { interpolate } from 'huetiful-js'

// Perceptually uniform gradient
const gradient = interpolate('#7c60d1', '#00d4aa', { steps: 10, colorspace: 'oklch' })
```

### 4. Color Harmonies
```javascript
import { harmonies } from 'huetiful-js'

// Generate complementary, analogous, triadic schemes
const complement = harmonies('#7c60d1', 'complementary')
const analogous = harmonies('#7c60d1', 'analogous')
const triadic = harmonies('#7c60d1', 'triadic')
```

## Comparison with Alternatives

| Feature | huetiful-js | culori | chroma-js |
|---------|-------------|--------|-----------|
| Color spaces | 10+ | 50+ | 10+ |
| Perceptual uniformity | OKLCH/OKLAB | OKLCH/OKLAB | Lab/LCH |
| Color sorting | ✅ | ❌ | ❌ |
| Color filtering | ✅ | ❌ | ❌ |
| Harmony generation | ✅ | ❌ | ❌ |
| Bundle size | ~15KB | ~8KB | ~50KB |
| Dependencies | 0 | 0 | 0 |

## Recommended Use Cases for Violet Void

### 1. Palette Analysis Tool Upgrade
Replace manual HSL calculations in `tools/palette-analyzer.sh` with huetiful-js for:
- More accurate color temperature detection
- Better harmony detection
- Perceptually uniform sorting

### 2. Harmony Generator Tool
Create `tools/harmony-generator.js`:
```javascript
#!/usr/bin/env node
import { harmonies, nearest } from 'huetiful-js'

const baseColor = process.argv[2]
const harmonyType = process.argv[3] || 'complementary'

const harmony = harmonies(baseColor, harmonyType)
console.log(JSON.stringify(harmony, null, 2))
```

### 3. Contrast Validator Tool
Create `tools/contrast-validator.js`:
```javascript
#!/usr/bin/env node
import { filterByContrast } from 'huetiful-js'

const background = process.argv[2]
const foregrounds = process.argv.slice(3)

const accessible = filterByContrast(background, foregrounds, 4.5)
console.log('Accessible colors:', accessible)
```

## Integration Recommendations

### Phase 1: Tool Enhancement
1. Upgrade `palette-analyzer.sh` to use huetiful-js via Node.js bridge
2. Add harmony generation to `tint-shade-generator.sh`
3. Create standalone harmony generator tool

### Phase 2: CI/CD Integration
1. Add palette harmony validation to GitHub Actions
2. Check for sufficient color variety in generated palettes
3. Validate contrast ratios across all color combinations

### Phase 3: Documentation
1. Add harmony diagrams to palette documentation
2. Include perceptual uniformity notes
3. Document color relationship recommendations

## Installation

```bash
# Install in monorepo
npm install huetiful-js

# Or use globally
npm install -g huetiful-js
```

## Key Takeaways

1. **Better than HSL**: HSL is not perceptually uniform - huetiful-js uses OKLCH for accurate results
2. **Complements culori**: Use huetiful-js for sorting/filtering, culori for conversions
3. **Small footprint**: ~15KB minified, zero dependencies
4. **TypeScript support**: Full type definitions included

## Action Items

- [ ] Add huetiful-js as dev dependency
- [ ] Create `tools/harmony-generator.js` using huetiful-js
- [ ] Upgrade `palette-analyzer.sh` to use huetiful-js for sorting
- [ ] Add harmony validation to CI/CD pipeline
- [ ] Document recommended harmonies for Violet Void palette
