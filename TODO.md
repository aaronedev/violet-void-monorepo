# Violet Void Monorepo TODO

## High Priority

- [ ] Create unified color token system (style-dictionary or similar)
- [x] Add color accessibility checker script (WCAG contrast validation) - a93cbbf
- [ ] Automate theme screenshot generation for README
- [x] Add theme comparison/preview images for README — **DONE 2026-03-12** `63ec827`
  - Created docs/comparisons/README.md with detailed theme comparisons
  - Compares Violet Void with Catppuccin, Nord, and Dracula
  - Includes color mapping tables for migration
  - Added visual characteristics and best use cases
  - Added quick comparison table to main README

## Medium Priority

- [x] Add `tint-shade-generator` for automated palette extensions — **DONE 2026-03-12** `COMMIT_PLACEHOLDER`
  - Generate tints (lighter) and shades (darker) of base palette colors
  - Create extended palette with 10 variations per base color (50, 100, ..., 900)
  - Useful for: UI elements that need subtle variations (hover states, borders, backgrounds)
  - Output formats: JSON, CSS custom properties, Tailwind config
  - Uses pastel CLI for accurate color manipulation (falls back to manual calculation)
  - Usage: ./tools/tint-shade-generator.sh [json|css|tailwind|all]
  - Example: purple-500 (base) → purple-50, -100, -200, ..., -900
- [x] Add color name lookup tool for semantic naming — **DONE 2026-03-12** `0f93b36`
  - Created tools/color-name-lookup.sh for offline color name lookup
  - Maps hex colors to CSS named colors and Violet Void palette names
  - Calculates color distance to find closest match
  - Provides brightness, saturation, and color family analysis
  - Usage: ./tools/color-name-lookup.sh '#7c60d1' or --palette
  - Useful for documentation and semantic naming of colors
- [x] Add `colorable` for batch color contrast testing — **DONE 2026-03-12** `0a0f70c`
  - npm package: `colorable` - Color combination contrast tester
  - Tests all color combinations in palette against WCAG standards
  - Generates accessibility reports with pass/fail for AA/AAA levels
  - Complements existing pastel integration for contrast checking
  - Created tools/colorable-test.sh for automated testing
  - Test sample combinations, text/background combos, or all combinations
  - Usage: ./tools/colorable-test.sh --sample | --text | --all
  - Install helper: ./tools/colorable-test.sh --install
  - Could integrate with CI/CD for automated accessibility validation
  - Link: https://github.com/jxnblk/colorable
  - Useful for: ensuring text/background combinations are accessible
- [ ] Add CI/CD for automated theme validation on PR
- [ ] Create theme preview web page (GitHub Pages)
- [ ] Investigate `themer` for multi-app theme generation — **NEW 2026-03-12**
  - Link: https://github.com/mjswensen/themer
  - Generates themes for 50+ apps from single color scheme
  - Supports: vim, VS Code, Alacritty, Kitty, iTerm2, Slack, Discord, etc.
  - Uses JavaScript/TypeScript for color scheme definitions
  - Could automate violet-void port creation for new applications
  - Alternative to tinted-theming with more active development
  - Consider creating violet-void template for themer ecosystem
- [x] Add color palette export to multiple formats (ASE, CLR, GIMP) — **DONE 2026-03-12** `1a0c5ba`
  - Created tools/export-palette.sh for automated exports
  - Exports to: GIMP palette (.gpl), macOS CLR (.clr.json), CSS custom properties, Tailwind config
  - ASE format via JSON (with conversion instructions)
  - Usage: ./tools/export-palette.sh [ase|gimp|clr|css|tailwind|all]
- [x] Investigate https://github.com/catppuccin/catppuccin for porting patterns — **DONE 2026-03-12**
  - Documented in `docs/CATPPUCCIN_PATTERNS.md`
  - Key learnings: 26 semantic colors, multi-flavor strategy, style guide patterns
  - Recommendations: semantic color mapping, standardized port structure, automation tools
  - Created actionable roadmap for Violet Void improvements
- [x] Investigate https://github.com/nordtheme/nord for theme structure ideas — **DONE
      2026-03-12** `3905b7c`
  - Documented in `docs/NORD_PATTERNS.md`
  - Key learnings: 16-color numbered system (nord0-15), 4-palette organization
    (Polar Night, Snow Storm, Frost, Aurora), dual ambiance design (dark/bright)
  - Recommendations: numbered system for terminal compatibility, dual-mode
    documentation, syntax highlighting guide, port organization standards
  - Created Violet Void ↔ Nord color mapping for cross-theme compatibility
- [ ] Investigate tinted-theming (formerly base16) ecosystem for template-based theme generation
  - Link: https://github.com/tinted-theming/home
  - Template-based approach: define colors once, generate themes for 200+ apps
  - Uses YAML/JSON scheme files with Mustache templates
  - Could automate porting to new applications
  - Base16-builder tool for generating from templates
  - Already has templates for: vim, alacritty, kitty, tmux, fish, zsh, gtk, etc.
  - Would reduce maintenance burden for new app ports
- [ ] Investigate `wallust` for palette generation from images — **NEW 2026-03-12**
  - Link: https://github.com/explosion-spirit/wallust
  - Generates color schemes from images using various algorithms
  - Could provide inspiration for palette refinements or variant creation
  - Supports multiple backends: wal, colorthief, haishoku, colorz
  - Outputs to multiple formats: JSON, TOML, YAML, Xresources, etc.
  - Could be used to create seasonal/variant palettes from wallpapers
  - Alternative to manual palette curation for new color variants

## Low Priority

- [ ] Add theme migration guide for users switching from other themes
- [x] Create contribution templates for new theme ports — **DONE 2026-03-12** `a1ed312`
  - Created issue templates: new-theme-request.md, bug-report.md
  - Created PR template with checklist for theme ports
  - Updated CONTRIBUTING.md with detailed contribution guidelines
  - Includes color mapping reference and testing requirements
- [ ] Add changelog generation automation

## Completed

(none yet)
