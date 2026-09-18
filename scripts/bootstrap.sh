#!/bin/bash

# Bootstrap script for Pillar monorepo
# This script bootstraps the workspace and installs all dependencies

set -e

echo "🔧 Bootstrapping Pillar monorepo..."

# Check if melos is available
if ! command -v melos &> /dev/null; then
    echo "❌ Melos is not installed. Run ./scripts/setup.sh first."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning workspace..."
melos clean || true

# Bootstrap the workspace
echo "📦 Running melos bootstrap..."
melos bootstrap

echo "✅ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  melos run ci:verify - everything a pull request must pass"
echo "  melos run analyze   - static analysis"
echo "  melos run test      - tests"
echo "  melos run format    - format code"
echo ""
