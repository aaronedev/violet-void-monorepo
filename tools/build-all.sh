#!/usr/bin/env bash
# Build/compile all themes
# Usage: ./tools/build-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Building all themes..."
echo ""

for theme_dir in "$MONOREPO_ROOT/themes"/*/; do
  if [[ -d "$theme_dir" ]]; then
    theme_name=$(basename "$theme_dir")
    echo "Building $theme_name..."
    
    # Check for build scripts
    if [[ -f "$theme_dir/package.json" ]]; then
      (cd "$theme_dir" && npm run build 2>/dev/null) || echo "  No build script or build failed"
    elif [[ -f "$theme_dir/Makefile" ]]; then
      (cd "$theme_dir" && make 2>/dev/null) || echo "  No build target or build failed"
    else
      echo "  No build step required"
    fi
  fi
done

echo ""
echo "Build complete!"
