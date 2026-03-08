# Violet Void Theme Monorepo

This repository aggregates all Violet Void theme projects as Git submodules, providing:

- 🎨 **Central color palette** (`palette/`)
- 🛠️ **Shared tooling** (`tools/`)
- 📦 **All themes** (`themes/`)

## Structure

```
violet-void-monorepo/
├── palette/
│   ├── colors.json    # Source of truth for colors
│   └── colors.css     # CSS custom properties
├── themes/
│   ├── archwiki/      # submodule
│   ├── chatgpt/       # submodule
│   ├── telegram/      # submodule
│   └── ...            # more submodules
├── tools/
│   ├── sync-colors.sh
│   ├── update-submodules.sh
│   ├── build-all.sh
│   └── lint-all.sh
└── README.md
```

## Getting Started

```bash
# Clone with all submodules
git clone --recursive https://github.com/aaronedev/violet-void-monorepo.git

# Update all themes to latest
./tools/update-submodules.sh
```

## Adding a New Theme

```bash
# Add as submodule
git submodule add https://github.com/aaronedev/violet-void-theme_newapp.git themes/newapp

# Commit the change
git add .gitmodules themes/newapp
git commit -m "Add violet-void-theme_newapp"
```

## Syncing Colors

Edit `palette/colors.json` to update the master palette, then run:

```bash
./tools/sync-colors.sh
```

Note: Per-theme sync logic needs to be implemented based on each theme's format.
