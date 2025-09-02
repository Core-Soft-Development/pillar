## 1.1.0

 - **FEAT**: first deploy for testing ci ([#4](https://github.com/Core-Soft-Development/pillar/issues/4)). ([66b5dcec](https://github.com/Core-Soft-Development/pillar/commit/66b5dcec9e86019d4e2584e8ff95b1b2bea12a89))

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added
- Initial release of Pillar Core package
- Clean Architecture foundation with base classes for:
  - Domain entities (`BaseEntity`)
  - Use cases (`BaseUseCase`, `NoParamsUseCase`, `SyncUseCase`, `SyncNoParamsUseCase`)
  - Repositories (`BaseRepository`)
  - Services (`BaseService`, `InitializableService`)
  - Providers (`BaseProvider`)
- Comprehensive dependency injection system:
  - `DependencyContainer` interface for dependency management
  - `ProviderDependencyContainer` implementation using Provider
  - Support for factory, singleton, and lazy singleton lifecycles
  - Type-safe dependency resolution with compile-time safety
  - `ServiceLocator` for global access to dependencies
- Flutter integration:
  - `DependencyInjectionProvider` widget for Provider integration
  - `DependencyConsumer` and `DependencySelector` widgets
  - `DependencyInjectionMixin` for easy access in StatefulWidgets
  - Context extensions for dependency access
- Error handling system:
  - Comprehensive failure types (`ServerFailure`, `NetworkFailure`, etc.)
  - Exception types for unexpected errors
  - Structured error handling patterns
- Testing support:
  - Built-in testing utilities
  - Mocking support with mocktail
  - Test coverage for all core functionality
- Complete documentation and examples:
  - Comprehensive README with usage examples
  - Example application demonstrating all features
  - Best practices and architectural guidelines

### Features
- 🏗️ **Clean Architecture Foundation**: Pre-built base classes following clean architecture principles
- 💉 **Dependency Injection**: Powerful DI system with Provider integration
- 🔄 **Lifecycle Management**: Support for factory, singleton, and lazy singleton patterns
- 🎯 **Type Safety**: Fully typed dependency resolution with compile-time safety
- 🧪 **Testing Support**: Built-in testing utilities and mocking support
- 📱 **Flutter Integration**: Seamless integration with Flutter widgets and Provider
- 🚀 **Performance**: Optimized for performance with lazy loading and efficient caching
- 📚 **Documentation**: Comprehensive documentation and examples

### Dependencies
- `flutter`: SDK support for Flutter applications
- `provider`: ^6.1.2 for state management and dependency injection
- `meta`: ^1.12.0 for annotations and metadata

### Development Dependencies
- `flutter_test`: SDK support for testing
- `flutter_lints`: ^4.0.0 for code quality and style enforcement
- `mocktail`: ^1.0.4 for mocking in tests
