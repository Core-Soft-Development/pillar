#!/bin/bash

# Script to toggle between dry-run (test) and real publish mode

MODE=${1:-"status"}

case $MODE in
  "test")
    echo "🧪 Switching to TEST mode (dry-run)..."

    # CI/CD workflow
    sed -i '' 's/melos publish --no-dry-run/melos publish --dry-run/g' .github/workflows/ci-cd.yml
    sed -i '' 's/📦 Publish to pub.dev/🧪 Test package publication (DRY-RUN MODE)/g' .github/workflows/ci-cd.yml

    # Manual release workflow
    sed -i '' 's/melos publish --no-dry-run/melos publish --dry-run/g' .github/workflows/manual-release.yml

    echo "✅ Switched to TEST mode"
    echo "📝 No packages will be published to pub.dev"
    ;;

  "production")
    echo "🚀 Switching to PRODUCTION mode (real publish)..."

    # CI/CD workflow
    sed -i '' 's/melos publish --dry-run/melos publish --no-dry-run/g' .github/workflows/ci-cd.yml
    sed -i '' 's/🧪 Test package publication (DRY-RUN MODE)/📦 Publish to pub.dev/g' .github/workflows/ci-cd.yml

    # Manual release workflow
    sed -i '' 's/melos publish --dry-run/melos publish --no-dry-run/g' .github/workflows/manual-release.yml

    echo "✅ Switched to PRODUCTION mode"
    echo "⚠️  Packages WILL BE PUBLISHED to pub.dev"
    ;;

  "status")
    echo "📊 Current publish mode status:"
    echo ""

    if grep -q "melos publish --dry-run" .github/workflows/ci-cd.yml; then
      echo "🧪 Currently in TEST mode (dry-run)"
      echo "   - No packages will be published"
      echo "   - Run: ./scripts/toggle-publish-mode.sh production"
    else
      echo "🚀 Currently in PRODUCTION mode"
      echo "   - Packages WILL BE PUBLISHED to pub.dev"
      echo "   - Run: ./scripts/toggle-publish-mode.sh test"
    fi
    ;;

  *)
    echo "Usage: $0 [test|production|status]"
    echo ""
    echo "Commands:"
    echo "  test        - Switch to test mode (dry-run, no publishing)"
    echo "  production  - Switch to production mode (real publishing)"
    echo "  status      - Show current mode"
    echo ""
    echo "Examples:"
    echo "  $0 test        # Switch to test mode"
    echo "  $0 production  # Switch to production mode"
    echo "  $0 status      # Check current mode"
    exit 1
    ;;
esac
