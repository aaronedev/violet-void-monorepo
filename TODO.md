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
- [ ] Investigate https://github.com/nordtheme/nord for theme structure ideas
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
