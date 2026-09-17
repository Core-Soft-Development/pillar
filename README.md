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

- `melos run ci:verify` - everything a pull request must pass
- `melos run analyze` - static analysis across all packages
- `melos run test` - tests for every package that has them
- `melos run format` - format code (`format:check` to verify without writing)
- `melos run deps:validate` - enforce the package layering rules
- `melos run build_runner` - generate code
- `melos run deps:upgrade` - upgrade dependencies, then re-bootstrap

### Project Structure

```
pillar/
├── packages/           # All Flutter packages, grouped by domain
├── docs/              # Documentation
├── scripts/           # Build and utility scripts
├── melos.yaml         # Melos configuration
├── pubspec.yaml       # Root pubspec
└── analysis_options.yaml # Dart analysis configuration
```

## 📦 Packages

This monorepo contains the following packages:

- **[pillar_core](packages/pillar_core)** - Core package with clean architecture foundation and dependency injection
- **[pillar_remote_config](packages/remote_config/pillar_remote_config)** - Remote configuration management

## 🔄 Versioning & Release Management

This monorepo uses [Melos](https://melos.invertase.dev/) for package management and versioning. See [docs/VERSIONING.md](docs/VERSIONING.md) for detailed instructions.

### Quick Commands

Packages are versioned **independently** — each from its own conventional
commits — and the `pillar` [Bill of Materials](packages/pillar/README.md) pins a
set that was released together. Same model as Firebase.

```bash
# What would the next release version?
melos run version:preview

# Ask pub.dev to validate every package, without publishing
melos run publish:dry-run

# Inspect the dependency graph
melos run deps:graph
```

Releases run in CI on every push to `main`: nothing is written to git until
pub.dev has accepted every package. See [docs/PUBLISHING.md](docs/PUBLISHING.md).

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
