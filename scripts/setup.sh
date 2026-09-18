#!/bin/bash

# Setup script for Pillar monorepo
# This script sets up the development environment

set -e

echo "🚀 Setting up Pillar monorepo..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed. Please install Dart first."
    exit 1
fi

echo "✅ Flutter and Dart are installed"

PINNED_FLUTTER="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc)"
LOCAL_FLUTTER="$(flutter --version 2>/dev/null | sed -n '1s/^Flutter \([^ ]*\).*/\1/p')"
if [ -n "$PINNED_FLUTTER" ] && [ "$PINNED_FLUTTER" != "$LOCAL_FLUTTER" ]; then
    echo "⚠️  Flutter $LOCAL_FLUTTER is installed, but this repo pins $PINNED_FLUTTER (.fvmrc)."
    echo "    CI builds on $PINNED_FLUTTER — with fvm: fvm use $PINNED_FLUTTER"
fi

# Check Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor

# Install the melos version this repo pins, not whatever is latest. pubspec.lock
# is the same source the CI reads, so local and CI cannot drift apart.
MELOS_VERSION="$(awk '/^  melos:/{f=1} f && /^    version:/{gsub(/"/,"",$2); print $2; exit}' pubspec.lock)"
if [ -z "$MELOS_VERSION" ]; then
    echo "❌ Could not read the melos version from pubspec.lock"
    exit 1
fi

if [ "$(melos --version 2>/dev/null | head -1)" = "$MELOS_VERSION" ]; then
    echo "✅ Melos $MELOS_VERSION is already installed"
else
    echo "📦 Installing Melos $MELOS_VERSION..."
    dart pub global activate melos "$MELOS_VERSION"
fi

# Bootstrap the workspace
echo "🔧 Bootstrapping workspace..."
melos bootstrap

echo "✅ Setup complete!"

# Install Git hooks for Conventional Commits
echo "🔧 Installing Git hooks for Conventional Commits..."
if [ -f "scripts/install_hooks.sh" ]; then
    ./scripts/install_hooks.sh
else
    echo "⚠️  Git hooks installation script not found. You can install them later with: ./scripts/install_hooks.sh"
fi

echo ""
echo "🎉 You can now start developing with Pillar!"
echo ""
echo "Available commands:"
echo "  melos run ci:verify - everything a pull request must pass"
echo "  melos run analyze   - static analysis"
echo "  melos run test      - tests"
echo "  melos run format    - format code"
echo ""
echo "📝 Remember: All commits must follow Conventional Commits format!"
echo "   Example: feat: add user authentication"
echo ""
