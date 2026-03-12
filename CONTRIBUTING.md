# Contributing to Violet Void

Thank you for your interest in contributing to the Violet Void theme ecosystem!

## Quick Links

- [New Theme Request](../../issues/new?assignees=&labels=enhancement,theme-request&template=new-theme-request.md&title=%5BTheme+Request%5D+)
- [Bug Report](../../issues/new?assignees=&labels=bug&template=bug-report.md&title=%5BBug%5D+)

## Repository Structure

```
violet-void-monorepo/
├── palette/
│   ├── colors.json    # Source of truth for all colors
│   └── colors.css     # CSS custom properties
├── themes/
│   ├── archwiki/      # submodule
│   ├── chatgpt/       # submodule
│   ├── telegram/      # submodule
│   └── ...            # more submodules
├── tools/
│   ├── sync-colors.sh     # Sync colors to all themes
│   ├── update-submodules.sh
│   ├── build-all.sh
│   ├── lint-all.sh
│   └── export-palette.sh  # Export to multiple formats
├── docs/
│   └── CATPPUCCIN_PATTERNS.md  # Porting best practices
└── README.md
```

## Getting Started

### Prerequisites

- Git
- Basic knowledge of the target application's theme format
- Understanding of CSS color formats (hex, RGB, HSL)

### Clone the Repository

```bash
# Clone with all submodules
git clone --recursive https://github.com/aaronedev/violet-void-monorepo.git
cd violet-void-monorepo

# Or if already cloned without --recursive
git submodule update --init --recursive
```

## Adding a New Theme Port

### Step 1: Check Existing Issues

Before starting, check if someone has already requested or is working on this theme.

### Step 2: Create the Theme Repository

1. Create a new repository following the naming convention: `violet-void-theme_<appname>`
2. Use the Violet Void color palette from `palette/colors.json`
3. Follow the application's theme format documentation

### Step 3: Color Mapping

Reference the master palette:

```json
{
  "base": {
    "bg": "#0d0d1a",      // Background
    "bg-alt": "#16162a",  // Alternate background
    "fg": "#e6e6fa",      // Foreground text
    "fg-alt": "#b8b8d0",  // Muted text
    "accent": "#bd93f9",  // Primary accent (violet)
    "accent-alt": "#ff79c6" // Secondary accent (pink)
  },
  "syntax": {
    "keyword": "#bd93f9",
    "string": "#f1fa8c",
    "comment": "#6272a4",
    "function": "#8be9fd",
    "variable": "#ffb86c",
    "number": "#bd93f9",
    "operator": "#ff79c6",
    "type": "#50fa7b"
  }
}
```

### Step 4: Add as Submodule

```bash
# Add as submodule
git submodule add https://github.com/aaronedev/violet-void-theme_newapp.git themes/newapp

# Commit the change
git add .gitmodules themes/newapp
git commit -m "feat: add violet-void-theme_newapp"
```

### Step 5: Update Documentation

1. Add the theme to the main `README.md`
2. Ensure the theme has its own README with:
   - Installation instructions
   - Screenshots
   - License information

### Step 6: Submit a Pull Request

Use the PR template and fill out all relevant sections.

## Color Palette Updates

If you need to update the master color palette:

1. Edit `palette/colors.json`
2. Run `./tools/sync-colors.sh` to propagate changes
3. Update all affected themes
4. Submit a PR with clear rationale for the color changes

## Coding Standards

### General

- Use consistent indentation (2 spaces)
- Include comments for non-obvious color mappings
- Test themes in the target application before submitting

### Theme Files

- Follow the target application's theme format conventions
- Use semantic color names where possible (e.g., `background`, `foreground`)
- Include both light and dark variants if the application supports them

## Testing

Before submitting a PR:

1. Test the theme in the actual application
2. Verify all colors are correctly applied
3. Check for readability and contrast issues
4. Test with common use cases for the application

## Need Help?

- Open a [Discussion](../../discussions) for questions
- Check existing [Issues](../../issues) for similar problems
- Reference `docs/CATPPUCCIN_PATTERNS.md` for porting best practices

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT).
