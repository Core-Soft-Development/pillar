#!/bin/bash

# Script to install Git hooks for Conventional Commits validation

set -e

echo "🔧 Installing Git hooks for Conventional Commits..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository. Please run this script from the root of your git project."
    exit 1
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy commit-msg hook
if [ -f ".githooks/commit-msg" ]; then
    cp .githooks/commit-msg .git/hooks/commit-msg
    chmod +x .git/hooks/commit-msg
    echo "✅ commit-msg hook installed"
else
    echo "❌ .githooks/commit-msg not found"
    exit 1
fi

# Set git hooks path (optional, for team consistency)
git config core.hooksPath .githooks

echo "✅ Git hooks installed successfully!"
echo ""
echo "📝 All commits will now be validated against Conventional Commits format."
echo ""
echo "Example valid commit messages:"
echo "  feat: add user authentication"
echo "  fix(auth): resolve login validation"
echo "  docs: update README"
echo ""
