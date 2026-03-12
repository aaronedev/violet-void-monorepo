# Style Dictionary - Unified Color Tokens

This directory contains the Style Dictionary configuration for Violet Void theme.

## What is Style Dictionary?

Style Dictionary is a tool that allows you to define design tokens (colors, spacing, typography, etc.) once and export them to multiple platforms and formats.

## Structure

```
tokens/
├── colors.json          # Color token definitions
└── README.md           # This file

build/                   # Generated output (after running build)
├── css/
│   └── variables.css    # CSS custom properties
├── scss/
│   └── _variables.scss  # SCSS variables
├── json/
│   └── tokens.json      # Flat JSON tokens
└── js/
    └── tokens.js        # ES6 JavaScript module
```

## Usage

### Build all formats

```bash
npm run build
```

### Build specific format

```bash
npx style-dictionary build --config style-dictionary.config.js
```

## Token Structure

Colors are organized into three categories:

1. **Background colors**: Base, dark, highlight, selection, black
2. **Foreground colors**: Base, dark, muted, comment, white
3. **Accent colors**: Red, green, blue, cyan, magenta, purple, orange, yellow (each with base/bright variants)

## Adding New Tokens

1. Edit `tokens/colors.json` or create new token files
2. Run `npm run build` to generate all format outputs
3. Use the generated files in your theme ports

## Integration with Theme Ports

The generated tokens can be used by:

- **CSS themes**: Import `build/css/variables.css`
- **SCSS themes**: Import `build/scss/_variables.scss`
- **JavaScript themes**: Import `build/js/tokens.js`
- **JSON-based themes**: Use `build/json/tokens.json`

## Future Enhancements

- Add typography tokens (font families, sizes, weights)
- Add spacing tokens (margins, paddings)
- Add border radius tokens
- Add shadow tokens
- Create custom formats for specific theme ports
- Add semantic tokens (primary, secondary, success, warning, error)

## Resources

- [Style Dictionary Documentation](https://styledictionary.com/)
- [Design Tokens Guide](https://designtokens.org/)
