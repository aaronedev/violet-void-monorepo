#!/usr/bin/env bash
# Lint all themes
# Usage: ./tools/lint-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Linting all themes..."
echo ""

errors=0

for theme_dir in "$MONOREPO_ROOT/themes"/*/; do
  if [[ -d "$theme_dir" ]]; then
    theme_name=$(basename "$theme_dir")
    echo "Checking $theme_name..."
    
    # Stylelint for CSS/Stylus
    if [[ -f "$theme_dir/.stylelintrc.json" ]] || [[ -f "$theme_dir/package.json" ]]; then
      (cd "$theme_dir" && npx stylelint "**/*.{css,styl}" 2>/dev/null) || {
        echo "  ❌ Lint errors found"
        ((errors++))
      }
    fi
    
    # luacheck for Lua
    if [[ -f "$theme_dir/.luacheckrc" ]] || ls "$theme_dir"/*.lua &>/dev/null; then
      (cd "$theme_dir" && luacheck . 2>/dev/null) || {
        echo "  ❌ Lint errors found"
        ((errors++))
      }
    fi
  fi
done

echo ""
if [[ $errors -eq 0 ]]; then
  echo "✅ All themes passed linting!"
else
  echo "❌ $errors theme(s) have lint errors"
  exit 1
fi
