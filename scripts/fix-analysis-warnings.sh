#!/bin/bash

# Fix Analysis Warnings Script
# This script resolves common analysis warnings in the Pillar monorepo

echo "🔧 Fixing analysis warnings in Pillar monorepo..."

# Function to check if a file contains a specific line
contains_line() {
    local file="$1"
    local line="$2"
    grep -q "$line" "$file" 2>/dev/null
}

# Function to add publish_to: none if missing
fix_example_publish_to() {
    local pubspec_file="$1"
    local package_name=$(basename $(dirname "$pubspec_file"))

    if [[ "$package_name" == *"example"* ]] || [[ "$package_name" == "example" ]]; then
        if ! contains_line "$pubspec_file" "publish_to: none"; then
            echo "📝 Adding publish_to: none to $pubspec_file"

            # Insert publish_to: none after version line
            sed -i '' '/^version:/a\
publish_to: none
' "$pubspec_file"
        else
            echo "✅ $pubspec_file already has publish_to: none"
        fi
    fi
}

# Function to convert path dependencies to version dependencies for publishable packages
fix_path_dependencies() {
    local pubspec_file="$1"
    local package_name=$(basename $(dirname "$pubspec_file"))

    # Skip if this is an example package
    if [[ "$package_name" == *"example"* ]] || [[ "$package_name" == "example" ]]; then
        return
    fi

    # Skip if package has publish_to: none
    if contains_line "$pubspec_file" "publish_to: none"; then
        return
    fi

    echo "🔄 Checking path dependencies in $pubspec_file"

    # Check for pillar_core path dependency
    if grep -q "pillar_core:" "$pubspec_file" && grep -A1 "pillar_core:" "$pubspec_file" | grep -q "path:"; then
        echo "📝 Converting pillar_core path dependency to version dependency in $pubspec_file"

        # Replace path dependency with version dependency
        sed -i '' '/pillar_core:/,/path:.*/{
            /pillar_core:/!d
            s/.*/  pillar_core: ^1.0.0/
        }' "$pubspec_file"
    fi
}

# Find all pubspec.yaml files
echo "🔍 Scanning for pubspec.yaml files..."

find packages -name "pubspec.yaml" -type f | while read -r pubspec_file; do
    echo "📄 Processing $pubspec_file"

    # Fix example packages
    fix_example_publish_to "$pubspec_file"

    # Fix path dependencies in publishable packages
    fix_path_dependencies "$pubspec_file"
done

echo ""
echo "🧹 Cleaning analysis cache..."
# Clean analysis cache
find . -name ".dart_tool" -type d -exec rm -rf {} + 2>/dev/null || true

echo ""
echo "📦 Re-bootstrapping packages..."
# This would run melos bootstrap but we'll just echo the command
echo "Run: melos bootstrap"

echo ""
echo "🔍 Testing analysis..."
echo "Run: melos analyze"

echo ""
echo "✅ Analysis warning fixes completed!"
echo ""
echo "📋 Summary of fixes applied:"
echo "  - Added 'publish_to: none' to example packages"
echo "  - Converted path dependencies to version dependencies for publishable packages"
echo "  - Cleaned analysis cache"
echo ""
echo "🚀 Next steps:"
echo "  1. Run 'melos bootstrap' to update dependencies"
echo "  2. Run 'melos analyze' to verify warnings are resolved"
echo "  3. Commit changes if everything looks good"
