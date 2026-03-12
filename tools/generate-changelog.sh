#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━   Violet Void Changelog Generator   ━━━━━━━━━━━━━━━━━━━━━
# Generates CHANGELOG.md from git commit history using conventional commits
# Usage: ./tools/generate-changelog.sh [options]
#
# Options:
#   --from <tag>     Start from specific tag (default: last tag)
#   --to <tag>       End at specific tag (default: HEAD)
#   --output <file>  Output file (default: CHANGELOG.md)
#   --dry-run        Print to stdout instead of file
#   --help           Show this help

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
FROM_TAG=""
TO_TAG="HEAD"
OUTPUT_FILE="CHANGELOG.md"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --from)
            FROM_TAG="$2"
            shift 2
            ;;
        --to)
            TO_TAG="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            sed -n '2,12p' "$0" | sed 's/# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get the repository root
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Get last tag if not specified
if [[ -z "$FROM_TAG" ]]; then
    FROM_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "")"
fi

# Get current version from latest tag or use "Unreleased"
CURRENT_VERSION="$(git describe --tags --abbrev=0 2>/dev/null || echo "Unreleased")"
if [[ "$TO_TAG" != "HEAD" ]]; then
    CURRENT_VERSION="$TO_TAG"
fi

# Get date for the version
VERSION_DATE="$(date +%Y-%m-%d)"

# Function to categorize commits
categorize_commit() {
    local message="$1"
    
    # Extract type from conventional commit
    local type="$(echo "$message" | sed -E 's/^([a-z]+)(\(.+\))?!?: .*/\1/' | head -1)"
    
    case "$type" in
        feat|feature)
            echo "features"
            ;;
        fix|bugfix)
            echo "bug-fixes"
            ;;
        docs|documentation)
            echo "documentation"
            ;;
        style|refactor|perf|performance)
            echo "improvements"
            ;;
        test|tests)
            echo "testing"
            ;;
        build|ci|chore|revert)
            echo "maintenance"
            ;;
        *)
            echo "other"
            ;;
    esac
}

# Function to format commit message
format_commit() {
    local message="$1"
    local hash="$2"
    
    # Remove type prefix and format
    local formatted="$(echo "$message" | sed -E 's/^[a-z]+(\(.+\))?!?: //')"
    
    # Capitalize first letter
    formatted="$(echo "$formatted" | sed 's/./\U&/')"
    
    echo "- $formatted ([${hash:0:7}](https://github.com/aaronedev/violet-void-monorepo/commit/$hash))"
}

# Generate changelog content
generate_changelog() {
    local range=""
    if [[ -n "$FROM_TAG" ]]; then
        range="$FROM_TAG..$TO_TAG"
    else
        range="$TO_TAG"
    fi
    
    # Initialize categories
    declare -A categories
    categories[features]=""
    categories[bug-fixes]=""
    categories[documentation]=""
    categories[improvements]=""
    categories[testing]=""
    categories[maintenance]=""
    categories[other]=""
    
    # Process commits
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi
        
        local hash="$(echo "$line" | cut -d'|' -f1)"
        local message="$(echo "$line" | cut -d'|' -f2)"
        
        # Skip merge commits
        if [[ "$message" =~ ^Merge ]]; then
            continue
        fi
        
        # Categorize and format
        local category="$(categorize_commit "$message")"
        local formatted="$(format_commit "$message" "$hash")"
        
        categories[$category]+="$formatted"$'\n'
    done < <(git log --pretty=format:"%h|%s" $range 2>/dev/null || echo "")
    
    # Generate output
    echo "# Changelog"
    echo ""
    echo "All notable changes to Violet Void Theme will be documented in this file."
    echo ""
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),"
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
    echo ""
    
    # Version header
    if [[ "$CURRENT_VERSION" != "Unreleased" ]]; then
        echo "## [$CURRENT_VERSION] - $VERSION_DATE"
    else
        echo "## [Unreleased]"
    fi
    echo ""
    
    # Output categories with commits
    local has_changes=false
    
    if [[ -n "${categories[features]}" ]]; then
        echo "### ✨ Features"
        echo ""
        echo -n "${categories[features]}"
        has_changes=true
    fi
    
    if [[ -n "${categories[bug-fixes]}" ]]; then
        echo "### 🐛 Bug Fixes"
        echo ""
        echo -n "${categories[bug-fixes]}"
        has_changes=true
    fi
    
    if [[ -n "${categories[improvements]}" ]]; then
        echo "### 💫 Improvements"
        echo ""
        echo -n "${categories[improvements]}"
        has_changes=true
    fi
    
    if [[ -n "${categories[documentation]}" ]]; then
        echo "### 📚 Documentation"
        echo ""
        echo -n "${categories[documentation]}"
        has_changes=true
    fi
    
    if [[ -n "${categories[testing]}" ]]; then
        echo "### 🧪 Testing"
        echo ""
        echo -n "${categories[testing]}"
        has_changes=true
    fi
    
    if [[ -n "${categories[maintenance]}" ]]; then
        echo "### 🔧 Maintenance"
        echo ""
        echo -n "${categories[maintenance]}"
        has_changes=true
    fi
    
    if [[ "$has_changes" == false ]]; then
        echo "No changes in this release."
    fi
    
    echo ""
}

# Main execution
if [[ "$DRY_RUN" == true ]]; then
    generate_changelog
else
    generate_changelog > "$OUTPUT_FILE"
    echo -e "${GREEN}✓ Changelog generated: $OUTPUT_FILE${NC}"
fi
