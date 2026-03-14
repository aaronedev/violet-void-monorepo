# Radix Colors Patterns

> Investigation of Radix Colors accessibility-first color system for Violet Void inspiration

## Overview

**Radix Colors** is a carefully designed color system for building accessible, high-contrast UIs. It provides systematic color scales designed specifically for accessible UI development.

- **Link:** https://www.radix-ui.com/colors
- **GitHub:** https://github.com/radix-ui/colors
- **Philosophy:** Accessibility-first, systematic, semantic naming

## Key Patterns

### 1. 12-Step Lightness Scale

Each color has 12 steps (1-12) with consistent meaning:

| Step | Purpose | Usage |
|------|---------|-------|
| 1 | Darkest | Background (app) |
| 2 | Dark | Background (subtle) |
| 3 | Dark-muted | Background (hover) |
| 4 | Muted | Border (subtle) |
| 5 | Muted-bright | Border (hover) |
| 6 | Neutral | Border (default) |
| 7 | Bright | Solid (subtle) |
| 8 | Brighter | Solid (hover) |
| 9 | Primary | Solid (default) |
| 10 | Bright | Text (low-contrast) |
| 11 | Brighter | Text (high-contrast) |
| 12 | Lightest | Text (highest-contrast) |

**Lesson for Violet Void:** Consider a numbered scale system for more granular color variations.

### 2. Semantic Color Roles

Colors are organized by semantic purpose, not just hue:

- **Gray** - Neutral UI elements
- **Red** - Errors, destructive actions
- **Green** - Success, positive states
- **Blue** - Information, primary actions
- **Yellow** - Warnings, attention
- **Orange** - Warnings (alternative)
- **Purple** - Accent, special features
- **Pink** - Accent (alternative)
- **Cyan** - Information (alternative)
- **Teal** - Success (alternative)

**Lesson for Violet Void:** Map accent colors to semantic roles (errors, warnings, success, info).

### 3. Dark Mode Variants

Every color has a dark mode variant with proper contrast:

- Dark mode uses inverted scale (step 1 becomes lightest)
- Automatic contrast adjustment for dark backgrounds
- Same 12-step system, different values

**Lesson for Violet Void:** Create proper dark mode variants with adjusted contrast ratios.

### 4. Alpha Variants

Colors include alpha (transparency) variants:

- `--color-a1` through `--color-a12`
- Useful for overlays, hover states, focus rings
- Consistent opacity across all colors

**Lesson for Violet Void:** Add alpha variants for UI flexibility.

### 5. Automatic WCAG Compliance

Every step is tested against white and black:

- Steps 1-9: Tested against white text
- Steps 10-12: Tested against white background
- Ensures AA compliance automatically

**Lesson for Violet Void:** Validate each palette step against WCAG standards.

### 6. P3 Color Space Support

Includes Display P3 colors for wider gamut:

- `--color-p3-1` through `--color-p3-12`
- More vibrant colors on supported displays
- Graceful fallback to sRGB

**Lesson for Violet Void:** Consider P3 variants for modern displays.

## Violet Void Recommendations

Based on Radix Colors patterns:

### Phase 1: Numbered Scale System
- Create 12-step scales for each accent color
- Document semantic meaning of each step
- Validate contrast at each step

### Phase 2: Semantic Color Mapping
```
violet-void-red → errors, destructive
violet-void-green → success
violet-void-blue → info, primary
violet-void-yellow → warnings
violet-void-purple → accent (existing)
```

### Phase 3: Dark Mode Variants
- Create proper dark mode palette
- Invert scale for dark backgrounds
- Re-validate all contrast ratios

### Phase 4: Alpha Variants
- Add transparency variants for UI states
- Use for overlays, hover, focus
- Maintain consistency across all colors

## Color Scale Example

```css
/* Radix-style 12-step scale for Violet Void purple */
--purple-1: #1a0f2e;  /* Darkest - background */
--purple-2: #251642;  /* Dark - subtle background */
--purple-3: #3a1d66;  /* Dark-muted - hover */
--purple-4: #4f248a;  /* Muted - subtle border */
--purple-5: #642bae;  /* Muted-bright - hover border */
--purple-6: #7c3fd1;  /* Neutral - default border */
--purple-7: #9455e0;  /* Bright - subtle solid */
--purple-8: #ac6bef;  /* Brighter - hover solid */
--purple-9: #7c60d1;  /* Primary - Violet Void base */
--purple-10: #9d8adc; /* Bright - low-contrast text */
--purple-11: #b9a8e8; /* Brighter - high-contrast text */
--purple-12: #e8e0f7; /* Lightest - highest-contrast */
```

## Implementation Notes

1. **Contrast Testing:** Use tools/colorable-test.sh to validate each step
2. **Dark Mode:** Use CSS custom properties with automatic fallback
3. **P3 Support:** Use `@media (color-gamut: p3)` for progressive enhancement
4. **Documentation:** Document semantic meaning of each step

## Related Resources

- [Radix Colors Docs](https://www.radix-ui.com/colors/docs/overview/styling-your-app)
- [Color Scale Generator](https://www.radix-ui.com/colors/custom)
- [Accessibility Guidelines](https://www.radix-ui.com/colors/docs/overview/accessibility)

---

*Investigation date: 2026-03-14*
*Purpose: Learn accessibility-first color system patterns for Violet Void improvements*
