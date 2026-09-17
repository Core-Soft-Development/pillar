import 'package:pillar_core/src/core/dependency_injection/dependency_container.dart';
import 'package:pillar_core/src/core/dependency_injection/provider_dependency_container.dart';

/// Global service locator for dependency injection
/// This provides a static API for accessing dependencies when context is not available
class ServiceLocator {
  ServiceLocator._();

  static DependencyContainer? _container;

  /// Initialize the service locator with a dependency container
  static void initialize(DependencyContainer container) {
    _container = container;
  }

  /// Get the current dependency container
  static DependencyContainer get container {
    _container ??= ProviderDependencyContainer.instance;
    return _container!;
  }

  /// Get an instance of [T]
  static T get<T extends Object>() => container.get<T>();

  /// Register a factory that creates instances of [T]
  static void registerFactory<T extends Object>(T Function() factory) {
    container.registerFactory<T>(factory);
  }

  /// Register a singleton instance of [T]
  static void registerSingleton<T extends Object>(T instance) {
    container.registerSingleton<T>(instance);
  }

  /// Register a lazy singleton that creates instance of [T] when first accessed
  static void registerLazySingleton<T extends Object>(T Function() factory) {
    container.registerLazySingleton<T>(factory);
  }

  /// Check if type [T] is registered
  static bool isRegistered<T extends Object>() => container.isRegistered<T>();

  /// Unregister type [T]
  static void unregister<T extends Object>() => container.unregister<T>();

  /// Clear all registrations
  static void clear() => container.clear();

  /// Reset the service locator
  static void reset() {
    container.reset();
    _container = null;
  }
}
