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

# Check Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor

# Install Melos globally if not already installed
if ! command -v melos &> /dev/null; then
    echo "📦 Installing Melos..."
    dart pub global activate melos
else
    echo "✅ Melos is already installed"
fi

# Bootstrap the workspace
echo "🔧 Bootstrapping workspace..."
melos bootstrap

# Run pub get on root
echo "📦 Running pub get on root..."
flutter pub get

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
echo "  melos analyze    - Run static analysis"
echo "  melos test       - Run tests"
echo "  melos format     - Format code"
echo "  melos clean      - Clean workspace"
echo ""
echo "📝 Remember: All commits must follow Conventional Commits format!"
echo "   Example: feat: add user authentication"
echo ""
