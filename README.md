# Pillar

A Flutter monorepo for building scalable applications with clean architecture and modern development practices.

## Overview

Pillar is a collection of Flutter packages organized as a monorepo, designed to provide reusable components, utilities, and architectural patterns for Flutter applications. This project follows clean architecture principles and modern Flutter development best practices.

## Architecture

This monorepo is built using [Melos](https://melos.invertase.dev/) for workspace management and follows the architectural patterns established by projects like [FlutterFire](https://github.com/firebase/flutterfire).

### Key Technologies

- **Flutter & Dart**: Core framework and language
- **GetIt**: Dependency injection
- **Bloc**: State management
- **Freezed**: Immutable data classes and unions
- **Dio & Retrofit**: HTTP client and API integration
- **AutoRoute**: Navigation and routing
- **Firebase**: Backend services integration

## Getting Started

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.2.0)
- [Melos](https://melos.invertase.dev/) for monorepo management

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/pillar.git
cd pillar
```

2. Install Melos globally:
```bash
dart pub global activate melos
```

3. Bootstrap the workspace:
```bash
melos bootstrap
```

## Development

### Available Scripts

- `melos analyze` - Run static analysis on all packages
- `melos test` - Run tests for all packages
- `melos format` - Format code across all packages
- `melos build_runner` - Generate code using build_runner
- `melos pub:get` - Run pub get on all packages
- `melos pub:upgrade` - Upgrade dependencies for all packages

### Project Structure

```
pillar/
├── packages/           # All Flutter packages
├── docs/              # Documentation
├── scripts/           # Build and utility scripts
├── melos.yaml         # Melos configuration
├── pubspec.yaml       # Root pubspec
└── analysis_options.yaml # Dart analysis configuration
```

## 📦 Packages

This monorepo contains the following packages:

- **[pillar_core](packages/pillar-core)** - Core package with clean architecture foundation and dependency injection
- **[pillar_remote_config](packages/pillar-remote-config)** - Remote configuration management

## 🔄 Versioning & Release Management

This monorepo uses [Melos](https://melos.invertase.dev/) for package management and versioning. See [docs/VERSIONING.md](docs/VERSIONING.md) for detailed instructions.

### Quick Commands

```bash
# Check current versions
melos run version:check

# Local release (development)
melos run release:local

# Production release
melos run release:publish

# Check dependencies
melos run deps:graph

# Handle breaking changes
melos run breaking:check
melos run breaking:update
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

For versioning and release management, see [docs/VERSIONING.md](docs/VERSIONING.md).

## Code Style

This project follows strict coding standards:

- Use English for all code and documentation
- Follow clean architecture principles
- Prefer composition over inheritance
- Use descriptive variable names with auxiliary verbs
- Write concise, technical Dart code
- Follow the linting rules defined in `analysis_options.yaml`

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository or contact the maintainers.
