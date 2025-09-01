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

# Run pub get on all packages
echo "📦 Running pub get on all packages..."
melos pub:get

echo "✅ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  melos analyze    - Run static analysis"
echo "  melos test       - Run tests"
echo "  melos format     - Format code"
echo ""
