# Violet Void Monorepo TODO

## High Priority

- [ ] Create unified color token system (style-dictionary or similar)
- [x] Add color accessibility checker script (WCAG contrast validation) - a93cbbf
- [ ] Automate theme screenshot generation for README
- [ ] Add theme comparison/preview images for README — **NEW 2026-03-12**
  - Create side-by-side comparisons with popular themes (catppuccin, nord, dracula)
  - Automated screenshot generation with different terminal setups
  - Visual diff showing color relationships
  - Helps users make informed decisions about theme adoption
  - Consider using puppeteer/playwright for automated screenshots

## Medium Priority

- [ ] Add CI/CD for automated theme validation on PR
- [ ] Create theme preview web page (GitHub Pages)
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
- [ ] Investigate https://github.com/nordtheme/nord for theme structure ideas
- [ ] Investigate tinted-theming (formerly base16) ecosystem for template-based theme generation
  - Link: https://github.com/tinted-theming/home
  - Template-based approach: define colors once, generate themes for 200+ apps
  - Uses YAML/JSON scheme files with Mustache templates
  - Could automate porting to new applications
  - Base16-builder tool for generating from templates
  - Already has templates for: vim, alacritty, kitty, tmux, fish, zsh, gtk, etc.
  - Would reduce maintenance burden for new app ports

## Low Priority

- [ ] Add theme migration guide for users switching from other themes
- [ ] Create contribution templates for new theme ports
- [ ] Add changelog generation automation

## Completed

(none yet)
