# Packages

This directory contains all the Flutter packages that make up the Pillar monorepo.

## Package Structure

Each package in this directory follows the standard Flutter package structure:

```
package_name/
├── lib/
│   ├── src/           # Private implementation
│   └── package_name.dart  # Public API
├── test/
├── example/           # Example app (if applicable)
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

## Creating a New Package

To create a new package:

1. Create a new directory in this folder
2. Run `flutter create --template=package package_name` inside the directory
3. Update the `pubspec.yaml` with appropriate dependencies
4. Add the package to the root `melos.yaml` (it should be automatically detected)
5. Run `melos bootstrap` from the root directory

## Package Types

### Core Packages
- **pillar_core**: Core utilities and base classes
- **pillar_di**: Dependency injection setup and configuration
- **pillar_network**: HTTP client and API utilities

### UI Packages
- **pillar_ui**: Reusable UI components and widgets
- **pillar_theme**: Theme configuration and styling

### Feature Packages
- **pillar_auth**: Authentication and user management
- **pillar_storage**: Local storage and caching utilities

### Platform Packages
- **pillar_firebase**: Firebase integration utilities
- **pillar_analytics**: Analytics and tracking

## Dependencies

When adding dependencies to packages:

- Use the minimum required version constraints
- Prefer dev_dependencies for build tools
- Keep external dependencies to a minimum
- Use peer dependencies when appropriate

## Testing

Each package should include:

- Unit tests for all public APIs
- Widget tests for UI components
- Integration tests for complex features
- Example apps demonstrating usage

## Documentation

Each package must include:

- Comprehensive README.md
- API documentation using dartdoc comments
- Usage examples
- CHANGELOG.md following semantic versioning
