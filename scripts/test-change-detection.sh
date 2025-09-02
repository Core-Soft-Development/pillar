#!/bin/bash

# Test script for change detection logic
# This script simulates the logic used in CI/CD to detect package changes

echo "🧪 Testing change detection logic..."

# Simulate the CI/CD logic
CHANGED_PACKAGES=0

echo "🔍 Strategy 1: Check against last tag..."
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
  echo "📌 Last tag found: $LAST_TAG"
  CHANGED_PACKAGES=$(melos list --since="$LAST_TAG" --json 2>/dev/null | jq -r '.[].name' | wc -l || echo "0")
  echo "📦 Found $CHANGED_PACKAGES packages with changes since $LAST_TAG"
else
  echo "📌 No tags found"
fi

echo ""
echo "🔍 Strategy 2: Check against develop branch merge base..."
if [ "$CHANGED_PACKAGES" -eq 0 ]; then
  MERGE_BASE=$(git merge-base HEAD origin/develop 2>/dev/null || git merge-base HEAD develop 2>/dev/null || echo "")
  if [ -n "$MERGE_BASE" ] && [ "$MERGE_BASE" != "$(git rev-parse HEAD)" ]; then
    echo "🔗 Merge base with develop: $MERGE_BASE"
    CHANGED_PACKAGES=$(melos list --since="$MERGE_BASE" --json 2>/dev/null | jq -r '.[].name' | wc -l || echo "0")
    echo "📦 Found $CHANGED_PACKAGES packages with changes since merge base"
  else
    echo "🔗 No merge base found or HEAD equals merge base"
  fi
fi

echo ""
echo "🔍 Strategy 3: Check for first release..."
if [ "$CHANGED_PACKAGES" -eq 0 ]; then
  echo "🆕 Checking if this is a first release..."
  ALL_PACKAGES=$(melos list --json 2>/dev/null | jq -r '.[].name' | wc -l || echo "0")

  if [ "$ALL_PACKAGES" -gt 0 ]; then
    echo "📦 Found $ALL_PACKAGES total packages"
    TAG_COUNT=$(git tag -l | wc -l || echo "0")
    echo "🏷️ Found $TAG_COUNT existing tags"

    if [ "$TAG_COUNT" -eq 0 ]; then
      echo "🎉 No previous tags found - treating as first release"
      CHANGED_PACKAGES=$ALL_PACKAGES
    else
      echo "🔍 Tags exist but no changes detected - checking HEAD~1 as fallback"
      CHANGED_PACKAGES=$(melos list --since=HEAD~1 --json 2>/dev/null | jq -r '.[].name' | wc -l || echo "0")
    fi
  fi
fi

echo ""
echo "✅ Final result: $CHANGED_PACKAGES packages with changes"

# Show current git status for debugging
echo ""
echo "📊 Git status for debugging:"
echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "Current HEAD: $(git rev-parse HEAD)"
echo "Total commits: $(git rev-list --count HEAD 2>/dev/null || echo 'unknown')"
echo "Total tags: $(git tag -l | wc -l)"

# List packages if melos is available
echo ""
echo "📦 Available packages:"
if command -v melos >/dev/null 2>&1; then
  melos list --long 2>/dev/null || echo "Unable to list packages (melos not bootstrapped?)"
else
  echo "Melos not available in PATH"
fi

# Exit with appropriate code
if [ "$CHANGED_PACKAGES" -gt 0 ]; then
  echo "🚀 Changes detected - would proceed with versioning and publishing"
  exit 0
else
  echo "⏭️ No changes detected - would skip versioning and publishing"
  exit 1
fi
