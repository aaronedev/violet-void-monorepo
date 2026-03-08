# 🎨 Violet Void Theme

> A dark purple-tinted color system for unified desktop aesthetics

Violet Void is a cohesive color palette designed to bring visual harmony across your entire desktop environment — from terminal emulators to web browsers, from code editors to system UI.

![License](https://img.shields.io/github/license/aaronedev/violet-void-monorepo?color=7c60d1)
![Themes](https://img.shields.io/badge/themes-14+-7c60d1)
![Dark Mode](https://img.shields.io/badge/dark%20mode-yes-0e0e0e?labelColor=0e0e0e&color=7c60d1)

## 🌈 Color Palette

### Backgrounds

| Color | Hex | Preview |
|-------|-----|---------|
| `bg` | `#050505` | ![](https://singlecolorimage.com/get/050505/80x30) |
| `bgDark` | `#0e0e0e` | ![](https://singlecolorimage.com/get/0e0e0e/80x30) |
| `bgHighlight` | `#191919` | ![](https://singlecolorimage.com/get/191919/80x30) |
| `bgSelection` | `#0f0f0f` | ![](https://singlecolorimage.com/get/0f0f0f/80x30) |
| `black` | `#181818` | ![](https://singlecolorimage.com/get/181818/80x30) |

### Foregrounds

| Color | Hex | Preview |
|-------|-----|---------|
| `fg` | `#f0f0f5` | ![](https://singlecolorimage.com/get/f0f0f5/80x30) |
| `fgDark` | `#303030` | ![](https://singlecolorimage.com/get/303030/80x30) |
| `fgMuted` | `#414141` | ![](https://singlecolorimage.com/get/414141/80x30) |
| `fgComment` | `#4c4c4c` | ![](https://singlecolorimage.com/get/4c4c4c/80x30) |
| `white` | `#e7e7e7` | ![](https://singlecolorimage.com/get/e7e7e7/80x30) |

### Accent Colors

| Color | Hex | Preview |
|-------|-----|---------|
| `red` | `#ff1a67` | ![](https://singlecolorimage.com/get/ff1a67/80x30) |
| `redBright` | `#ff004b` | ![](https://singlecolorimage.com/get/ff004b/80x30) |
| `green` | `#42ff97` | ![](https://singlecolorimage.com/get/42ff97/80x30) |
| `greenBright` | `#42ffad` | ![](https://singlecolorimage.com/get/42ffad/80x30) |
| `blue` | `#29adff` | ![](https://singlecolorimage.com/get/29adff/80x30) |
| `blueBright` | `#c7b8ff` | ![](https://singlecolorimage.com/get/c7b8ff/80x30) |
| `cyan` | `#00a8a4` | ![](https://singlecolorimage.com/get/00a8a4/80x30) |
| `cyanBright` | `#00fff9` | ![](https://singlecolorimage.com/get/00fff9/80x30) |
| `magenta` | `#fd007f` | ![](https://singlecolorimage.com/get/fd007f/80x30) |
| `magentaBright` | `#fd0098` | ![](https://singlecolorimage.com/get/fd0098/80x30) |
| `purple` | `#7c60d1` | ![](https://singlecolorimage.com/get/7c60d1/80x30) |
| `purpleBright` | `#fd7cff` | ![](https://singlecolorimage.com/get/fd7cff/80x30) |
| `orange` | `#ff7c7e` | ![](https://singlecolorimage.com/get/ff7c7e/80x30) |
| `yellow` | `#ffd93d` | ![](https://singlecolorimage.com/get/ffd93d/80x30) |

## 📦 Available Themes

| Theme | Type | Install |
|-------|------|---------|
| [ArchWiki](./themes/archwiki) | Stylus | [![Install](https://img.shields.io/badge/install-userstyles-7c60d1)](https://github.com/aaronedev/violet-void-theme_archwiki) |
| [ChatGPT](./themes/chatgpt) | Stylus | [![Install](https://img.shields.io/badge/install-userstyles-7c60d1)](https://github.com/aaronedev/violet-void-theme_chatgpt) |
| [Telegram Web](./themes/telegram) | Stylus | [![Install](https://img.shields.io/badge/install-userstyles-7c60d1)](https://github.com/aaronedev/violet-void-theme_telegram) |
| [Tridactyl](./themes/tridactyl) | CSS | [View](./themes/tridactyl) |
| [Obsidian](./themes/obsidian) | CSS | [View](./themes/obsidian) |
| [Neovim](./themes/nvim) | Lua | [View](./themes/nvim) |
| [Terminal](./themes/terminal) | Shell | [View](./themes/terminal) |
| [FZF](./themes/fzf) | Shell | [View](./themes/fzf) |
| [Glow](./themes/glow) | JSON | [View](./themes/glow) |
| [Geizhals](./themes/geizhals) | Stylus | [View](./themes/geizhals) |
| [Sublime/Bat](./themes/subl) | tmTheme | [View](./themes/subl) |
| [Crackboard](./themes/crackboard) | CSS | [View](./themes/crackboard) |
| [Yazi](./themes/yazi) | TOML | [View](./themes/yazi) |
| [MkDocs](./themes/mkdocs) | CSS | [View](./themes/mkdocs) |

## 🚀 Quick Start

### Clone with Submodules

```bash
# Clone the monorepo with all themes
git clone --recursive https://github.com/aaronedev/violet-void-monorepo.git

# Or clone and init submodules separately
git clone https://github.com/aaronedev/violet-void-monorepo.git
cd violet-void-monorepo
git submodule update --init --recursive
```

### Update All Themes

```bash
./tools/update-submodules.sh
```

### Use the Palette

**CSS Variables:**
```css
@import 'palette/colors.css';

.my-element {
  background: var(--vv-bg);
  color: var(--vv-fg);
  border-color: var(--vv-purple);
}
```

**JSON:**
```js
import colors from './palette/colors.json';

console.log(colors.accents.purple); // #7c60d1
```

## 🛠️ Tools

| Tool | Description |
|------|-------------|
| `tools/sync-colors.sh` | Sync colors from palette to all themes |
| `tools/update-submodules.sh` | Pull latest changes for all submodules |
| `tools/build-all.sh` | Build all themes that require compilation |
| `tools/lint-all.sh` | Lint all themes |

## 🎯 Philosophy

Violet Void is built on these principles:

1. **Cohesion** — Every app on your desktop shares the same color language
2. **Readability** — High contrast text on dark backgrounds for long coding sessions
3. **Purple-tinted** — A unique aesthetic that stands out from generic dark themes
4. **Minimal** — No unnecessary UI chrome, just the content you need

## 📋 Contributing

Want to add a new theme?

1. Create a new repo: `violet-void-theme_<appname>`
2. Add it as a submodule: `git submodule add <url> themes/<appname>`
3. Use colors from `palette/colors.json`
4. Submit a PR!

## 📜 License

MIT — use these colors however you want.

---

<p align="center">
  Made with 💜 by <a href="https://github.com/aaronedev">aaronedev</a>
</p>
