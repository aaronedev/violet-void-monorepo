#!/usr/bin/env bash
# Update all submodules to latest
# Usage: ./tools/update-submodules.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$MONOREPO_ROOT"

echo "Updating all submodules to latest..."
git submodule update --remote --merge

echo ""
echo "Submodules updated. Check git status and commit if needed."
