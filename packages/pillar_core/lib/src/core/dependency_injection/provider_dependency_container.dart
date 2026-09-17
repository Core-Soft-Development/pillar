import 'package:flutter/foundation.dart';
import 'package:pillar_core/src/core/dependency_injection/dependency_container.dart';

/// Implementation of [DependencyContainer] using a simple Map-based approach
/// This implementation is framework-agnostic and can be used with Provider
class ProviderDependencyContainer implements DependencyContainer {
  ProviderDependencyContainer._();

  static ProviderDependencyContainer? _instance;

  /// Get the singleton instance of the container
  static ProviderDependencyContainer get instance {
    _instance ??= ProviderDependencyContainer._();
    return _instance!;
  }

  final Map<Type, DependencyRegistration<Object>> _registrations = {};

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    final type = T;
    if (_registrations.containsKey(type)) {
      throw DependencyAlreadyRegisteredException(type);
    }

    _registrations[type] = DependencyRegistration<T>(
      factory: factory,
      lifecycle: DependencyLifecycle.factory,
    );
  }

  @override
  void registerSingleton<T extends Object>(T instance) {
    final type = T;
    if (_registrations.containsKey(type)) {
      throw DependencyAlreadyRegisteredException(type);
    }

    _registrations[type] = DependencyRegistration<T>(
      factory: () => instance,
      lifecycle: DependencyLifecycle.singleton,
      instance: instance,
    );
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    final type = T;
    if (_registrations.containsKey(type)) {
      throw DependencyAlreadyRegisteredException(type);
    }

    _registrations[type] = DependencyRegistration<T>(
      factory: factory,
      lifecycle: DependencyLifecycle.lazySingleton,
    );
  }

  @override
  T get<T extends Object>() {
    final type = T;
    final registration = _registrations[type];

    if (registration == null) {
      throw DependencyNotFoundException(type);
    }

    switch (registration.lifecycle) {
      case DependencyLifecycle.factory:
        return registration.factory() as T;

      case DependencyLifecycle.singleton:
        return registration.instance as T;

      case DependencyLifecycle.lazySingleton:
        if (registration.instance != null) {
          return registration.instance as T;
        }
        final instance = registration.factory() as T;
        _registrations[type] = registration.copyWith(instance: instance);
        return instance;
    }
  }

  @override
  bool isRegistered<T extends Object>() {
    return _registrations.containsKey(T);
  }

  @override
  void unregister<T extends Object>() {
    _registrations.remove(T);
  }

  @override
  void clear() {
    _registrations.clear();
  }

  @override
  void reset() {
    clear();
  }

  /// Get all registered types for debugging purposes
  @visibleForTesting
  List<Type> get registeredTypes => _registrations.keys.toList();

  /// Get registration info for debugging purposes
  @visibleForTesting
  DependencyRegistration<Object>? getRegistration<T extends Object>() {
    return _registrations[T];
  }
}
